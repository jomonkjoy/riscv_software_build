# Makefile for XSIM simulation

# Define the name of your XSIM executable (e.g., xsim or xsimk)
XSIM_EXECUTABLE = xsim

# Define your top-level module name
TOP_MODULE = your_top_module

# Define the testbench file for your simulation
TESTBENCH = testbench.sv

# Define the simulation time in ns
SIM_TIME = 100ns

# Define the XSIM script file that specifies the simulation commands
XSIM_SCRIPT = xsim_script.tcl

# Simulation target
simulate: compile
	$(XSIM_EXECUTABLE) -tclbatch $(XSIM_SCRIPT) -svlog $(TOP_MODULE)

# Compile target
compile:
	xelab -debug typical $(TOP_MODULE) -s $(TOP_MODULE).sim

# Clean target to remove generated files
clean:
	rm -rf work .Xil xsim.dir webtalk* *.wdb *.log

.PHONY: simulate compile clean

