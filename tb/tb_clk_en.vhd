library ieee;
use ieee.std_logic_1164.all;

entity tb_clk_en is
    generic ( DIVIDE : positive := 4 );
end entity tb_clk_en;

architecture sim of tb_clk_en is
    constant CLK_PERIOD : time := 10 ns;
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal en        : std_logic;
    signal stim_done : boolean := false;
begin
    dut : entity work.clk_en
        generic map (
            DIVIDE => DIVIDE
        )
        port map (
            clk => clk,
            rst => rst,
            en  => en
        );

    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;

    stim : process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';
        wait for (10 * DIVIDE + 5) * CLK_PERIOD;
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD * 100;
        stim_done <= true;
        wait;
    end process stim;

    monitor : process (clk)
        variable errors             : natural := 0;
        variable cycles_since_pulse : natural := 0;
        variable prev_had_pulse     : boolean := false;
        variable pulse_count        : natural := 0;
        variable cycles_after_rst   : natural := 0;
        variable rst_cycles         : natural := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rst_cycles := rst_cycles + 1;
                -- C3: en stays low during reset (starting on 2nd edge for synchronous reset)
                if (rst_cycles >= 2) and (en /= '0') then
                    report "ERROR: en is not low during reset" severity error;
                    errors := errors + 1;
                end if;
                cycles_since_pulse := 0;
                prev_had_pulse     := false;
                cycles_after_rst   := 0;
                pulse_count        := 0;
            else
                rst_cycles       := 0;
                cycles_after_rst := cycles_after_rst + 1;

                -- C5: First pulse after reset happens on tick 2 (registered output latency)
                if (cycles_after_rst = 2) and (en /= '1') then
                    report "ERROR: First pulse after reset did not happen as expected" severity error;
                    errors := errors + 1;
                end if;

                if en = '1' then
                    pulse_count := pulse_count + 1;

                    -- C1: Gap between every pair of pulses equals DIVIDE periods
                    if cycles_since_pulse > 0 then
                        if cycles_since_pulse /= DIVIDE then
                            report "ERROR: Gap between every pair of pulses is not equal to DIVIDE periods" severity error;
                            errors := errors + 1;
                        end if;
                    end if;
                    cycles_since_pulse := 1;

                    -- C2: Pulse is never wider than one clock period when DIVIDE > 1
                    if prev_had_pulse and (DIVIDE > 1) then
                        report "ERROR: Pulse is wider than one clock period" severity error;
                        errors := errors + 1;
                    end if;
                    prev_had_pulse := true;
                else
                    if cycles_since_pulse > 0 then
                        cycles_since_pulse := cycles_since_pulse + 1;
                    end if;
                    prev_had_pulse := false;
                end if;

                -- C4: In N * DIVIDE cycles, exact N pulses
                if cycles_after_rst>1 and ((cycles_after_rst-1) mod DIVIDE) = 0 then
                    if pulse_count /= ((cycles_after_rst-1) / DIVIDE) then
                        report "ERROR: Wrong pulse count in N*DIVIDE cycles" severity error;
                        errors := errors + 1;
                    end if;
                end if;
            end if;

            if stim_done then
                if errors = 0 then
                    report "PASS";
                else
                    report "FAIL" severity error;
                end if;
                std.env.finish;
            end if;
        end if;
    end process monitor;
end architecture sim;