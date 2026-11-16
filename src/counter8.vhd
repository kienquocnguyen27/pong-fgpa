library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter8 is
    port(
        clk: in std_logic;
        rst: in std_logic;
        count: out std_logic_vector (7 downto 0)
    );
end entity;

architecture Behavioral of counter8 is
    signal d_u : unsigned (7 downto 0);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                d_u <= (others =>'0');
            elsif d_u = 255 then
                d_u <= (others =>'0');
            else 
                d_u <= d_u + 1;
            end if;
        end if;
    end process;
    count <= std_logic_vector (d_u);
end architecture;
