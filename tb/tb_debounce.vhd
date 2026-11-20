library ieee;
use ieee.std_logic_1164.all;

entity tb_debounce is
end entity tb_debounce;

architecture sim of tb_debounce is
    constant CLK_PERIOD: time :=10 ns;
    constant STABLE_CYCLES: positive:=20;

    signal clk: std_logic:='0';
    signal rst: std_logic:='1';
    signal d: std_logic:='0';
    signal clean: std_logic;
    signal press: std_logic;
    signal n_press:natural :=0;
    signal done: boolean :=false;

procedure drive (signal s: out std_logic; v: std_logic; t:time) is
    begin
        s <=v;
        wait for t;
end procedure drive;
begin
    dut: entity work.debounce
        generic map (
            STABLE_CYCLES =>STABLE_CYCLES
        )
        port map (
            clk   => clk,
            rst   => rst,
            d     => d,
            clean => clean,
            press => press
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
    count_press : process(clk)
    begin
        if rising_edge(clk) then
        if rst='1' then 
            n_press <=0;
        elsif press ='1' then
            n_press <= n_press+1;
        end if;
        end if;
    end process count_press;

    stim: process
    begin
        rst<='1';
        d <='0';
        wait for 3* CLK_PERIOD;
        wait until rising_edge(clk);
        rst <='0';
        wait for 2* CLK_PERIOD;
        --Press >= 5 glitches, hold solidly for >= 2x STABLE_CYCLES
        drive(d,'1', 20 ns);
        drive(d,'0', 10 ns);
        drive(d,'1', 30 ns);
        drive(d,'0', 20 ns);
        drive(d,'1', 10 ns);
        drive(d,'0', 10 ns);
        drive(d,'1', 40 ns);
        drive(d,'0', 20 ns);
        drive(d,'1', 20 ns);
        drive(d,'0', 10 ns);

        -- hold for 2.5 STABLE_CYCLES
        drive(d,'1', 500 ns);
        assert clean = '1'
            report "FAIL Scenario (a): clean did not go high after stable press"severity error;
        assert n_press = 1
            report "FAIL Scenario (a): expected n_press = 1 "  severity error;
        
        --Single glitch shorter than STABLE_CYCLES
        drive(d,'1', 120 ns);
        drive(d,'0', 300 ns);
        assert clean = '0'
            report "FAIL Scenario (b): short glitch falsely triggered clean"severity error;
        assert n_press = 1
            report "FAIL Scenario (b): short glitch incremented n_press"severity error;
        
        --release with glitches
        drive(d, '0', 20 ns);  -- release glitch 1
        drive(d, '1', 10 ns);
        drive(d, '0', 30 ns);  -- release glitch 2
        drive(d, '1', 20 ns);
        drive(d, '0', 10 ns);  -- release glitch 3
        drive(d, '1', 10 ns);

        -- Hold released steadily for 2.5x STABLE_CYCLES (500 ns)
        drive(d, '0', 500 ns);

        assert clean = '0'
            report "FAIL Scenario (c): clean did not fall to 0 after release"severity error;
        assert n_press = 1
            report "FAIL Scenario (c): release should not trigger press; expected n_press = 1 " severity error;


        --Press, release, press again after a stable period
        drive(d, '1', 350 ns);
        drive(d, '0', 350 ns);
        assert n_press = 2
            report "FAIL Scenario (d-1): expected n_press = 2 " severity error;

        -- Second clean press (makes 3 total)
        drive(d, '1', 350 ns);
        assert n_press = 3
            report "FAIL Scenario (d-2): expected n_press = 3 " severity error;

        -- Reset while button is held
        rst <= '1';
        wait for 3 * CLK_PERIOD;
        assert clean = '0' and press = '0'
            report "FAIL Scenario (f): outputs did not go to 0 on reset"
            severity error;

        -- Release reset while d is STILL held '1':
        rst <= '0';
        wait for 350 ns;
        assert clean = '1' and n_press = 1
        report "FAIL Scenario (f-after): expected fresh press after reset release while held" severity error;

        report "ALL DEBOUNCE TESTS PASSED!" severity note;
        done <= true;
        wait;
    end process stim;

end architecture sim;
        