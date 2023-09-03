# Load design
open_project your_project.xpr

# Set simulation library and design
set_property simulator_language "Mixed" [current_project]
set_property top your_top_module [get_filesets sim_1]

# Add source files (change these paths accordingly)
add_files -file {/path/to/your_top_module.sv}
add_files -file {/path/to/other_module1.sv}
add_files -file {/path/to/other_module2.sv}

# Compile the design
analyze -all
elaborate your_top_module

# Set simulation time resolution and add a simulation run
set_property CONFIG.CLOCK_PULSE_PERIOD {10 ns} [get_filesets sim_1]
create_sim -name sim_1 -testbench -module {your_testbench} -simset {Simulator} -view {Waveform} -view {State} -view {Log} -view {Logfile} -view {Trace} -view {Snapshot}
add_wave -simset {Simulator} -radix Bin -signal your_top_module/*
run_sim

# Save simulation results
write_hwdef your_top_module.hwdef
write_bitstream your_top_module.bit

# Exit XSIM
exit

