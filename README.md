# Pong FPGA
## 'clk_en' design decisions
* 'en' is registered inside the synchronous 'rising_edge(clk)' process rather than outside of the process.
* **Wrap edge ('count = DIVIDE - 1') 'count' wraps back to '0' and 'en' goes to '1' for 1 clock cycle.
** 0,0,0,1,0,0,0,1,...

# Pong on the Basys 3 - Part 1: Digital design foundations

## Overview
This project implements the foundational clock-enable, button-conditioning, and register-control infrastructure for a hardware Pong game on the Digilent Basys 3 FPGA in VHDL-2008. Part 1 delivers a verified, synthesizable top-level design (`top_part1`) that divides the 100 MHz board clock into a 2 Hz enable strobe to blink `led(1)` at 1 Hz while synchronizing, debouncing, and edge-detecting `btnC` to toggle `led(0)` once per physical press. 

## Simulate
# 1. Analyze all RTL source files in dependency order
ghdl -a --std=08 src/clk_en.vhd src/sync2.vhd src/debounce.vhd src/btn_input.vhd src/top_part1.vhd

# 2. Analyze testbenches
ghdl -a --std=08 tb/tb_clk_en.vhd tb/tb_debounce.vhd tb/tb_btn_input.vhd tb/tb_top_part1.vhd

# 3. Elaborate and run each self-checking testbench (exporting waveforms to .ghw)
ghdl -e --std=08 tb_clk_en && ghdl -r --std=08 tb_clk_en --wave=tb_clk_en.ghw
ghdl -e --std=08 tb_debounce && ghdl -r --std=08 tb_debounce --wave=tb_debounce.ghw
ghdl -e --std=08 tb_btn_input && ghdl -r --std=08 tb_btn_input --wave=tb_btn_input.ghw
ghdl -e --std=08 tb_top_part1 && ghdl -r --std=08 tb_top_part1 --wave=tb_top_part1.ghw

## Modules
# 1.clk_en 
DIVIDE - Generic - Positive - Number of clk cycles between single cycle en pulses (50_000_000 for 500 ms)
clk -in - std_logic : 100 MHZ system clock
rst -in - std_logic : active high reset ( tied to '0' in top_part1)
en - out- std_logic : single clock cycle enable pulse asserted when the internal counter reaches DIVIDE-1

# 2. sync2
clk -in - std_logic : 100 MHZ system clock
d -in -std_logic : asynchronous external pushbutton signal ('btnC')
q -out -std_logic: two stage synchronized output for synchronous logic

# 3. debounce
STABLE_CYCLES -Generic -positive -Consecutive clk cycles d must remain opposite to clean_i before updating (entity default 20; overridden to 1_000_000 in top_part1)
clk -in- std_logic -100 MHz system clock. 
rst -in- std_logic- Synchronous active-high reset.
d -in - std_logic - Synchronized button level from sync2
clean- out - std_logic - Debounced steady button level (clean_i). |
press - out - std_logic - Single-cycle rising-edge pulse (clean_i and not clean_d). 

# 4. btn_input
STABLE_CYCLES - Generic - positive -Consecutive clk cycles passed to debounce (entity default 20; overridden to 1_000_000 in top_part1). |
clk - in - std_logic -  100 MHz system clock. 
rst - in- std_logic - Synchronous active-high reset passed to debounce. 
btn_raw - in - std_logic - Raw asynchronous button pin (btnC). 
clean- out - std_logicd- Debounced button level. 
press - out - std_logic - Single-cycle rising-edge press pulse. 

# 5. `top_part1` (`src/top_part1.vhd`)
DIVIDE - Generic - Positive - Number of clk cycles between single cycle en pulses (50_000_000 for 500 ms)
STABLE_CYCLES -Generic -positive -Consecutive clk cycles d must remain opposite to clean_i before updating ( 1_000_000 in top_part1)
clk -in - std_logic : 100 MHZ system clock
btnC - in - std_logic  Center pushbutton . 
led - out - std_logic_vector(1 downto 0) Board LEDs: led(0) toggles on btnC; led(1)  blinks at 1 Hz. 