library ieee;
use ieee.std_logic_1164.all;
entity sync2 is
port (
    clk : in std_logic;
    d : in std_logic; -- asynchronous: not related to clk
    q : out std_logic
);
end entity sync2;
architecture rtl of sync2 is
    signal stage1: std_logic :='0';
    signal stage2: std_logic :='0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            stage1 <=d;
            stage2 <=stage1;
        end if;
    end process;
    q <= stage2;
end architecture rtl;