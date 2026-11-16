library ieee;
use ieee.std_logic_1164.all;

entity tb_counter8 is
end entity;

architecture sim of tb_counter8 is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal count: std_logic_vector (7 downto 0);
begin 
    uut: entity work.counter8
    port map (
        clk => clk,
        rst => rst,
        count => count
    );
    clk_gen: process
    begin
        -- Toggle the clock every 5 ns
        clk <= not clk;
        wait for 5 ns;
    end process;

    stimulus: process
    begin
        -- Reset = 1 for at least 2 rising edges then Reset = 0
        rst <= '1';
        wait for 15 ns;
        wait until rising_edge(clk);
        rst <= '0';   
    
        -- Count 600 cycles
        wait for 6000 ns;

        -- Reset = 1 for 3 cycles then release it and let it count more
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait for 500 ns;
        std.env.finish;
    end process;
end architecture;
