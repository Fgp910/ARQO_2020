--------------------------------------------------------------------------------
-- Unidad de adelantamiento de datos a la alu del micro. Arq0 2020-2021
--
-- Grupo 1301_08: Leandro Garcia y Fabian Gutierrez.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity forwarding_unit is
    port (
        --Entradas
        EX_MEM_RegWr: in std_logic; --Señal de escritura en fase MEM
        MEM_WB_RegWr: in std_logic; --Señal de escritura en fase WB
        EX_MEM_rd: in std_logic_vector(4 downto 0); --Registro destino en la fase MEM
        MEM_WB_rd: in std_logic_vector(4 downto 0); --Registro destino en la fase WB
        Reg_rs: in std_logic_vector(4 downto 0); --Registro rs
        Reg_rt: in std_logic_vector(4 downto 0); --Registro rt
        --Salidas
        AdelantarA: out std_logic_vector(1 downto 0); --Control de adelantamiento de rs
        AdelantarB: out std_logic_vector(1 downto 0)  --Control de adelantamiento de rt
    );
end forwarding_unit;


architecture rtl of forwarding_unit is
begin
    AdelantarA <= '10' when EX_MEM_RegWr = '1' and EX_MEM_rd /= '000000' and EX_MEM_rd = Reg_rs else
                  '01' when MEM_WB_RegWr = '1' and MEM_WB_rd /= '000000' and MEM_WB_rd = Reg_rs else
                  '00';

    AdelantarB <= '10' when EX_MEM_RegWr = '1' and EX_MEM_rd /= '000000' and EX_MEM_rd = Reg_rt else
                  '01' when MEM_WB_RegWr = '1' and MEM_WB_rd /= '000000' and MEM_WB_rd = Reg_rt else
                  '00';
end architecture;