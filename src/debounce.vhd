library ieee;
use ieee.std_logic_1164.all;
entity debounce is
generic ( STABLE_CYCLES : positive := 20 ); 
port (
    clk, rst : in std_logic;
    d : in std_logic; -- already synchronized
    clean : out std_logic;
    press : out std_logic
);
end entity debounce;
architecture rtl of debounce is
    signal clean_i: std_logic :='0';
    signal cnt: natural range 0 to STABLE_CYCLES -1 :=0;
    signal clean_d :std_logic :='0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst ='1' then
                clean_i <='0';
                clean_d <='0';
                cnt <=0;
            else 
                clean_d <=clean_i;
                if d = clean_i then
                    cnt <=0;
                elsif cnt = STABLE_CYCLES-1 then
                    clean_i <=d;
                    cnt <=0;
                else 
                    cnt <=cnt +1;
                end if;
            end if;
        end if;
    end process;
press <= clean_i and not clean_d;
clean <=clean_i;
end architecture rtl;