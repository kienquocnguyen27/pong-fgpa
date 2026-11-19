library ieee;
use ieee.std_logic_1164.all;

entity tb_sync2 is
end entity tb_sync2;

architecture sim of tb_sync2 is
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

    signal clk : std_logic := '0';
    signal d   : std_logic := '0';
    signal q   : std_logic;
begin
    -- Instantiate Unit Under Test (UUT)
    uut : entity work.sync2
        port map (
            clk => clk,
            d   => d,
            q   => q
        );

    -- 100 MHz Clock Generator
    clk_proc : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_proc;

    -- Asynchronous Stimulus
    stim_proc : process
    begin
        -- 1. Start at 0 for a few cycles
        d <= '0';
        wait for 23 ns; -- arbitrary non-edge time (between edge at 20 ns and 30 ns)

        -- 2. d goes 0 -> 1 at an arbitrary time
        d <= '1';
        wait for 44 ns; -- holds high until 67 ns (arbitrary time)

        -- 3. d goes 1 -> 0 -> 1 -> 0 later (simulating async transitions/glitches)
        d <= '0';
        wait for 36 ns; -- until 103 ns
        d <= '1';
        wait for 25 ns; -- until 128 ns
        d <= '0';
        wait for 40 ns;

        -- Stop simulation cleanly
        std.env.finish;
    end process stim_proc;

end architecture sim;