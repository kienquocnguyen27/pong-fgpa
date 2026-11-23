library ieee;
use ieee.std_logic_1164.all;
entity top_part1 is
generic (
    DIVIDE : positive := 50_000_000; 
    STABLE_CYCLES : positive := 1_000_000 
);
port (
    clk : in std_logic;
    btnC : in std_logic;
    led : out std_logic_vector(1 downto 0)
);
end entity top_part1;
architecture rtl of top_part1 is
    signal en: std_logic;
    signal press: std_logic;
    signal led0_reg: std_logic :='0';
    signal led1_reg: std_logic :='0';
begin
    u_clk_en: entity work.clk_en 
        generic map(
            DIVIDE => DIVIDE
        )
        port map (
            clk => clk,
            en => en,
            rst => '0'
        );
    u_btn: entity work.btn_input
        generic map(
            STABLE_CYCLES => STABLE_CYCLES
        )
        port map (
            clk => clk,
            rst => '0',
            btn_raw => btnC,
            clean => open,
            press => press
        );
    process (clk)
        begin
            if rising_edge(clk) then
                if press ='1' then
                    led0_reg <= not led0_reg;
                end if;
                if en ='1' then
                    led1_reg <= not led1_reg;
                end if;
            end if;
    end process;
    led(0) <= led0_reg;
    led(1) <= led1_reg;
    
end architecture rtl;