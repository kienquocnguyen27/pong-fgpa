library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_en is
    generic (DIVIDE : positive := 4);
    port(   clk: in std_logic;
            rst: in std_logic;
            en: out std_logic := '0'

    );
end entity;

architecture Behavioral of clk_en is
    signal count : integer range 0 to DIVIDE - 1;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count <= DIVIDE -1;
                en <= '0';
            elsif count = DIVIDE -1 then
                count <= 0;
                en <= '1';
            else 
            count <= count +1;
            en <= '0';
            end if;
        end if;
    end process;
end architecture;
