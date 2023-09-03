# Get the project name and top module from command line arguments
set project_name [lindex $argv 0]
set top_module [lindex $argv 1]

# Open the project
open_project ./$project_name/$project_name.xpr

# Set the target language and simulator
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# Run synthesis
launch_runs synth_1 -jobs 4

# Wait for synthesis to complete
wait_on_run synth_1

# Save the project
save_project

# Exit Vivado
exit

