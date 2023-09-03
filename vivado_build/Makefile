# Vivado Project Settings
PROJECT_NAME = my_project
TOP_MODULE = my_top_module
VIVADO_VERSION = 2021.1
VIVADO_PATH = /path/to/vivado/$(VIVADO_VERSION)/bin/vivado

# Source and Output Directories
SRC_DIR = src
CONSTRAINTS_DIR = constraints
OUTPUT_DIR = output

# Vivado Commands
BUILD_CMD = $(VIVADO_PATH) -mode batch -source build.tcl -notrace

.PHONY: all clean

all: build

build: create_project synthesize implement

create_project:
	$(BUILD_CMD) -source create_project.tcl -tclargs $(PROJECT_NAME) $(TOP_MODULE)

synthesize:
	$(BUILD_CMD) -source synthesize.tcl -tclargs $(PROJECT_NAME) $(TOP_MODULE)

implement:
	$(BUILD_CMD) -source implement.tcl -tclargs $(PROJECT_NAME) $(TOP_MODULE)

clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf .Xil

