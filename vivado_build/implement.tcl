
# Get the project name and top module from command line arguments
set project_name [lindex $argv 0]
set top_module [lindex $argv 1]

# Open the project
open_project ./$project_name/$project_name.xpr

# Run implementation
launch_runs impl_1 -to_step write_bitstream -jobs 4

# Wait for implementation to complete
wait_on_run impl_1

# Generate the bitstream
write_bitstream -force ./output/$project_name.bit

# Save the project
save_project

# Exit Vivado
exit
