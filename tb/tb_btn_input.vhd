library ieee;
use ieee.std_logic_1164.all;

entity tb_btn_input is
end entity tb_btn_input;

architecture sim of tb_btn_input is
    constant CLK_PERIOD    : time     := 10 ns;
    constant STABLE_CYCLES : positive := 20;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal btn_raw : std_logic := '0';
    signal clean   : std_logic;
    signal press   : std_logic;
    signal n_press : natural   := 0;
    signal done    : boolean   := false;

    procedure drive (signal s : out std_logic; v : std_logic; t : time) is
    begin
        s <= v;
        wait for t;
    end procedure drive;

begin
    dut : entity work.btn_input
        generic map (
            STABLE_CYCLES => STABLE_CYCLES
        )
        port map (
            clk     => clk,
            rst     => rst,
            btn_raw => btn_raw,
            clean   => clean,
            press   => press
        );

    clk_gen : process
    begin
        while not done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_gen;

    count_presses : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                n_press <= 0;
            elsif press = '1' then
                n_press <= n_press + 1;
            end if;
        end if;
    end process count_presses;

    stim : process
    begin
        -- Initial Reset
        rst     <= '1';
        btn_raw <= '0';
        wait for 3 * CLK_PERIOD;
        wait until rising_edge(clk);
        rst <= '0';
        wait for 2 * CLK_PERIOD;

         --Asynchronous edges NOT aligned to the 10 ns clock
        -- Bouncy press with off-clock durations (3.7 ns, 14.3 ns, etc.)
        drive(btn_raw, '1', 13.7 ns);
        drive(btn_raw, '0', 11.3 ns);
        drive(btn_raw, '1', 24.7 ns);
        drive(btn_raw, '0', 17.9 ns);
        drive(btn_raw, '1', 12.1 ns);
        drive(btn_raw, '0', 16.3 ns);

        -- Hold steady for > 2x STABLE_CYCLES + sync2 latency
        drive(btn_raw, '1', 503.7 ns);

        assert clean = '1'
            report "FAIL Scenario (e-press): clean did not go high with off-clock edges"
            severity error;
        assert n_press = 1
            report "FAIL Scenario (e-press): expected n_press = 1 " severity error;
        -- Short asynchronous glitch (< STABLE_CYCLES) while released
        drive(btn_raw, '0', 353.7 ns);
        assert clean = '0' and n_press = 1
            report "FAIL Scenario (e-release): clean did not fall cleanly"
            severity error;

        drive(btn_raw, '1', 113.7 ns); -- ~11.4 cycles (too short)
        drive(btn_raw, '0', 303.7 ns);
        assert clean = '0' and n_press = 1
            report "FAIL Scenario (e-glitch): short off-clock glitch falsely triggered"
            severity error;

        --  Reset while the button is held down
        -- Press and stabilize the button first (brings n_press to 2)
        drive(btn_raw, '1', 350 ns);
        assert clean = '1' and n_press = 2
            report "FAIL Scenario (f-setup): expected clean = 1 and n_press = 2 before reset"
            severity error;

        -- Assert reset while btn_raw is still '1'
        rst <= '1';
        wait for 3 * CLK_PERIOD;
        assert clean = '0' and press = '0'
            report "FAIL Scenario (f-reset): outputs did not drop to 0 during reset"
            severity error;

        -- Release reset while btn_raw remains held at '1':
        -- After sync2 (2 cycles) + STABLE_CYCLES (20 cycles), clean rises and generates 1 fresh press
        rst <= '0';
        wait for 350 ns;
        assert clean = '1' and n_press = 1
            report "FAIL Scenario (f-after): expected fresh press (n_press = 1) after reset release while held" severity error;

        report "ALL BTN_INPUT TESTS PASSED!" severity note;
        done <= true;
        wait;
    end process stim;

end architecture sim;