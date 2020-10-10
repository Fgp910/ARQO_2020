--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2020-2021
--
-- Grupo 1301_08: Leandro Garcia y Fabian Gutierrez.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk        : in  std_logic; -- Reloj activo en flanco subida
      Reset      : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
      IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is

  component alu
    port(
      OpA     : in std_logic_vector (31 downto 0);
      OpB     : in std_logic_vector (31 downto 0);
      Control : in std_logic_vector (3 downto 0);
      Result  : out std_logic_vector (31 downto 0);
      Zflag   : out std_logic
    );
  end component;

  component reg_bank
     port (
        Clk   : in std_logic; -- Reloj activo en flanco de subida
        Reset : in std_logic; -- Reset as�ncrono a nivel alto
        A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
        Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
        A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
        Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
        A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
        Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
        We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
     );
  end component reg_bank;

  component control_unit
     port (
        -- Entrada = codigo de operacion en la instruccion:
        OpCode   : in  std_logic_vector (5 downto 0);
        -- Seniales para el PC
        Branch   : out  std_logic; -- 1 = Ejecutandose instruccion branch
        Jump     : out  std_logic; -- 1 = Ejecutandose salto incondicional
        -- Seniales relativas a la memoria
        MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
        MemWrite : out  std_logic; -- Escribir la memoria
        MemRead  : out  std_logic; -- Leer la memoria
        -- Seniales para la ALU
        ALUSrc   : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
        ALUOp    : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
        -- Seniales para el GPR
        RegWrite : out  std_logic; -- 1=Escribir registro
        RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
     );
  end component;

  component alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
 end component alu_control;

  signal Alu_Op2      : std_logic_vector(31 downto 0);
  signal ALU_Igual_EX, ALU_Igual_MEM    : std_logic;
  signal AluControl   : std_logic_vector(3 downto 0);
  signal reg_RD_data  : std_logic_vector(31 downto 0);
  signal reg_RD_EX, reg_RD_MEM , reg_RD_WB      : std_logic_vector(4 downto 0);

  signal Regs_eq_branch : std_logic;
  signal PC_next        : std_logic_vector(31 downto 0);
  signal PC_reg         : std_logic_vector(31 downto 0);
  signal PC_plus4_IF    : std_logic_vector(31 downto 0);
  signal PC_plus4_ID    : std_logic_vector(31 downto 0);
  signal PC_plus4_EX    : std_logic_vector(31 downto 0);

  signal Instruction_IF : std_logic_vector(31 downto 0); -- La instrucción desde lamem de instr
  signal Instruction_ID : std_logic_vector(31 downto 0);
  signal Inm_ext_ID, Inm_ext_EX     : std_logic_vector(31 downto 0); -- La parte baja de la instrucción extendida de signo
  signal Dir_reg_RT_ID, Dir_reg_RD_ID : std_logic_vector(4 downto 0);
  signal Dir_reg_RT_EX, Dir_reg_RD_EX : std_logic_vector(4 downto 0);
  signal reg_RS_ID, reg_RT_ID         : std_logic_vector(31 downto 0);
  signal reg_RS_EX, reg_RT_EX, reg_RT_MEM         : std_logic_vector(31 downto 0);

  signal dataIn_MEM, dataIn_WB     : std_logic_vector(31 downto 0); --From Data Memory
  signal Addr_Branch_EX, Addr_Branch_MEM    : std_logic_vector(31 downto 0);

  signal Ctrl_Jump, Ctrl_Branch_ID, Ctrl_MemWrite_ID, Ctrl_MemRead_ID,
  Ctrl_ALUSrc_ID, Ctrl_RegDest_ID, Ctrl_MemToReg_ID, Ctrl_RegWrite_ID : std_logic;
  signal Ctrl_ALUOP_ID  : std_logic_vector(2 downto 0);

  signal Ctrl_Branch_EX, Ctrl_MemWrite_EX, Ctrl_MemRead_EX,
  Ctrl_ALUSrc_EX, Ctrl_RegDest_EX, Ctrl_MemToReg_EX, Ctrl_RegWrite_EX : std_logic;
  signal Ctrl_ALUOP_EX  : std_logic_vector(2 downto 0);

  signal Ctrl_Branch_MEM, Ctrl_MemWrite_MEM, Ctrl_MemRead_MEM, Ctrl_MemToReg_MEM, Ctrl_RegWrite_MEM: std_logic;

  signal Ctrl_MemToReg_WB, Ctrl_RegWrite_WB: std_logic;

  signal Addr_Jump      : std_logic_vector(31 downto 0);
  signal Addr_Jump_dest : std_logic_vector(31 downto 0);
  signal desition_Jump  : std_logic;
  signal Alu_Res_EX, ALU_Res_MEM, Alu_Res_WB : std_logic_vector(31 downto 0);

  signal enable_IF_ID   : std_logic;
  signal enable_ID_EX   : std_logic;
  signal enable_EX_MEM  : std_logic;
  signal enable_MEM_WB  : std_logic;

begin

  PC_next <= Addr_Jump_dest when desition_Jump = '1' else PC_plus4_IF;

  PC_reg_proc: process(Clk, Reset)
  begin
    if Reset = '1' then
      PC_reg <= (others => '0');
    elsif rising_edge(Clk) then
      PC_reg <= PC_next;
    end if;
  end process;

  PC_plus4_IF    <= PC_reg + 4;
  IAddr          <= PC_reg;
  Instruction_IF <= IDataIn;

  IF_ID_reg: process(Clk, Reset)
  begin
    if Reset = '1' then
      PC_plus4_ID    <= (others => '0');
      Instruction_ID <= (others => '0');
    elsif rising_edge(Clk) and enable_IF_ID = '1' then
      PC_plus4_ID    <= PC_plus4_IF;
      Instruction_ID <= Instruction_IF;
    end if;
  end process;

  RegsMIPS : reg_bank
  port map (
    Clk   => Clk,
    Reset => Reset,
    A1    => Instruction_ID(25 downto 21),
    Rd1   => reg_RS_ID,
    A2    => Instruction_ID(20 downto 16),
    Rd2   => reg_RT_ID,
    A3    => reg_RD_WB,
    Wd3   => reg_RD_data,
    We3   => Ctrl_RegWrite_WB
  );

  UnidadControl : control_unit
  port map(
    OpCode   => Instruction_ID(31 downto 26),
    -- Señales para el PC
    Jump     => Ctrl_Jump,
    Branch   => Ctrl_Branch_ID,
    -- Señales para la memoria
    MemToReg => Ctrl_MemToReg_ID,
    MemWrite => Ctrl_MemWrite_ID,
    MemRead  => Ctrl_MemRead_ID,
    -- Señales para la ALU
    ALUSrc   => Ctrl_ALUSrc_ID,
    ALUOP    => Ctrl_ALUOP_ID,
    -- Señales para el GPR
    RegWrite => Ctrl_RegWrite_ID,
    RegDst   => Ctrl_RegDest_ID
  );

  Inm_ext_ID <= x"FFFF" & Instruction_ID(15 downto 0) when Instruction_ID(15)='1' else
                x"0000" & Instruction_ID(15 downto 0);
  Dir_reg_RT_ID <= Instruction_ID(20 downto 16);
  Dir_reg_RD_ID <= Instruction_ID(15 downto 11);
  Addr_Jump     <= PC_plus4(31 downto 28) & Instruction(25 downto 0) & "00";

  ID_EX_reg: process(Clk, Reset)
  begin
    if Reset = '1' then
      Ctrl_RegWrite_EX <= '0';
      Ctrl_MemToReg_EX <= '0';
      Ctrl_Branch_EX   <= '0';
      Ctrl_MemRead_EX  <= '0';
      Ctrl_MemWrite_EX <= '0';
      Ctrl_RegDest_EX  <= '0';
      Ctrl_ALUOP_EX    <= (others => '0');
      Ctrl_ALUSrc_EX   <= '0';
      PC_plus4_EX      <= (others => '0');
      reg_RS_EX        <= (others => '0');
      reg_RT_EX        <= (others => '0');
      Inm_ext_EX       <= (others => '0');
      Dir_reg_RT_EX    <= (others => '0');
      Dir_reg_RD_EX    <= (others => '0');
    elsif rising_edge(Clk) and enable_ID_EX = '1' then
      Ctrl_RegWrite_EX <= Ctrl_RegWrite_ID;
      Ctrl_MemToReg_EX <= Ctrl_MemToReg_ID;
      Ctrl_Branch_EX   <= Ctrl_Branch_ID;
      Ctrl_MemRead_EX  <= Ctrl_MemRead_ID;
      Ctrl_MemWrite_EX <= Ctrl_MemWrite_ID;
      Ctrl_RegDest_EX  <= Ctrl_RegDest_ID;
      Ctrl_ALUOP_EX    <= Ctrl_ALUOP_ID;
      Ctrl_ALUSrc_EX   <= Ctrl_ALUSrc_ID;
      PC_plus4_EX      <= PC_plus4_ID;
      reg_RS_EX        <= reg_RS_ID;
      reg_RT_EX        <= reg_RT_ID;
      Inm_ext_EX       <= Inm_ext_ID;
      Dir_reg_RT_EX    <= Dir_reg_RT_ID;
      Dir_reg_RD_EX    <= Dir_reg_RD_ID;
    end if;
  end process;

  Addr_Branch_EX <= PC_plus4_EX + (Inm_ext_EX(29 downto 0) & "00");

  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp      => Ctrl_ALUOP_EX, -- Codigo de control desde la unidad de control
    Funct      => Inm_ext_EX (5 downto 0), -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );

  Alu_MIPS : alu
  port map (
    OpA     => reg_RS_EX,
    OpB     => Alu_Op2,
    Control => AluControl,
    Result  => Alu_Res_EX,
    Zflag   => ALU_Igual_EX
  );

  Alu_Op2   <= reg_RT_EX when Ctrl_ALUSrc_EX = '0' else Inm_ext_EX;
  reg_RD_EX <= Dir_reg_RT_EX when Ctrl_RegDest_EX = '0' else Dir_reg_RD_EX;

  EX_MEM_reg: process(Clk, Reset)
  begin
    if Reset = '1' then
      Ctrl_RegWrite_MEM <= '0';
      Ctrl_MemToReg_MEM <= '0';
      Ctrl_Branch_MEM   <= '0';
      Ctrl_MemRead_MEM  <= '0';
      Ctrl_MemWrite_MEM <= '0';
      Addr_Branch_MEM   <= (others => '0');
      ALU_Igual_MEM     <= '0';
      Alu_Res_MEM       <= (others => '0');
      reg_RT_MEM        <= (others => '0');
      reg_RD_MEM        <= (others => '0');
    elsif rising_edge(Clk) and enable_EX_MEM = '1' then
      Ctrl_RegWrite_MEM <= Ctrl_RegWrite_EX;
      Ctrl_MemToReg_MEM <= Ctrl_MemToReg_EX;
      Ctrl_Branch_MEM   <= Ctrl_Branch_EX;
      Ctrl_MemRead_MEM  <= Ctrl_MemRead_EX;
      Ctrl_MemWrite_MEM <= Ctrl_MemWrite_EX;
      Addr_Branch_MEM   <= Addr_Branch_EX;
      ALU_Igual_MEM     <= ALU_Igual_EX;
      Alu_Res_MEM       <= Alu_Res_EX;
      reg_RT_MEM        <= reg_RT_EX;
      reg_RD_MEM        <= reg_RD_EX;
    end if;
  end process;

  desition_Jump  <= Ctrl_Jump or (Ctrl_Branch_MEM and ALU_Igual_MEM);
  Addr_Jump_dest <= Addr_Jump   when Ctrl_Jump='1'       else
                    Addr_Branch when Ctrl_Branch_MEM='1' else
                    (others =>'0');

  DAddr      <= Alu_Res_MEM;
  DDataOut   <= reg_RT_MEM;
  DWrEn      <= Ctrl_MemWrite_MEM;
  DRdEn      <= Ctrl_MemRead_MEM;
  dataIn_MEM <= DDataIn;

  MEM_WB_reg: process(Clk, Reset)
  begin
    if Reset = '1' then
      Ctrl_RegWrite_WB <= '0';
      Ctrl_MemToReg_WB <= '0';
      dataIn_WB        <= (others => '0');
      Alu_Res_WB       <= (others => '0');
      reg_RD_WB        <= (others => '0');
    elsif rising_edge(Clk) and enable_MEM_WB = '1' then
      Ctrl_RegWrite_WB <= Ctrl_RegWrite_MEM;
      Ctrl_MemToReg_WB <= Ctrl_MemToReg_MEM;
      dataIn_WB        <= dataIn_MEM;
      Alu_Res_WB       <= Alu_Res_MEM;
      reg_RD_WB        <= reg_RD_MEM;
    end if;
  end process;

  reg_RD_data <= dataIn_WB when Ctrl_MemToReg_WB = '1' else Alu_Res_WB;

end architecture;
