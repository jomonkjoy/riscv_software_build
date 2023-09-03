# Get the project name and top module from command line arguments
set project_name [lindex $argv 0]
set top_module [lindex $argv 1]

# Create a new Vivado project
create_project -force $project_name ./$project_name

# Set the top module
set_property top $top_module [current_fileset]

# Add source files to the project
add_files -norecurse [glob ./src/*.v]

# Add constraint files to the project
add_files -norecurse [glob ./constraints/*.xdc]

# Save the project
save_project

# Exit Vivado
exit

