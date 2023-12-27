# This is a comment

# Clock constraint: Set the clock frequency to 100 MHz
create_clock -add -name cpu_clk -period 10.00 -waveform {0 5} [get_ports { clk }]

# The delay value is the delay external to the FPGA
# UCF Example: OFFSET = IN 6ns BEFORE clock; assume period is 10ns
# The XDC delay is 10 - 6 = 4ns

set_input_delay 4 -clock cpu_clk [all_inputs]

# The delay value is the delay external to the FPGA
# UCF Example: OFFSET = OUT 6ns AFTER clock; assume period is 10ns
# The XDC delay is 10 - 6 = 4ns

set_output_delay 4 -clock cpu_clk [all_outputs]

