# Pong FPGA
## 'clk_en' design decisions
* 'en' is registered inside the synchronous 'rising_edge(clk)' process rather than outside of the process.
* **Wrap edge ('count = DIVIDE - 1') 'count' wraps back to '0' and 'en' goes to '1' for 1 clock cycle.
** 0,0,0,1,0,0,0,1,...