library ieee;
use ieee.std_logic_1164.all;

entity btn_input is
    generic (
        STABLE_CYCLES : positive := 20
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        btn_raw : in  std_logic;
        clean   : out std_logic;
        press   : out std_logic
    );
end entity btn_input;

architecture rtl of btn_input is
    -- Internal wire connecting sync2 output to debounce input
    signal btn_sync : std_logic;
begin
    u_sync : entity work.sync2
        port map (
            clk => clk,
            d   => btn_raw,
            q   => btn_sync
        );

    u_deb : entity work.debounce
        generic map (
            STABLE_CYCLES => STABLE_CYCLES
        )
        port map (
            clk   => clk,
            rst   => rst,
            d     => btn_sync,
            clean => clean,
            press => press
        );
end architecture rtl;