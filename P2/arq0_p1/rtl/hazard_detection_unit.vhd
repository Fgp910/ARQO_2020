--------------------------------------------------------------------------------
-- Unidad de deteccion de riesgos del micro. Arq0 2020-2021
--
-- Grupo 1301_08: Leandro Garcia y Fabian Gutierrez.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity hazard_detection_unit is
    port (
        reg_RS_IF_ID   : in std_logic_vector(4 downto 0);
        reg_RT_IF_ID   : in std_logic_vector(4 downto 0);
        reg_RT_ID_EX   : in std_logic_vector(4 downto 0);
        mem_read_ID_EX : in std_logic;
        insert_bubble  : out std_logic;
    );
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is
    insert_bubble <= '1' when mem_read_ID_EX = '1' and (reg_RT_ID_EX =
                     reg_RS_IF_ID or reg_RT_ID_EX = reg_RT_IF_ID) else '0';
end architecture;
