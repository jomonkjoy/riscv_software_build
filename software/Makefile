# Compiler and linker settings
RISCV_PREFIX = riscv64-unknown-elf-
CC = $(RISCV_PREFIX)gcc
LD = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
CFLAGS = -march=rv32i -mabi=ilp32 -nostartfiles
LDFLAGS = -T linker.ld

# Source file and output file
SRC = example.c
OBJ = $(SRC:.c=.o)
ELF_OUT = example.elf
DUMP = example.txt

# Memory files
HEX_FILE = program.hex
IMEM_FILE = instr_mem.mem
DMEM_FILE = data_mem.mem

all: $(HEX_FILE) $(IMEM_FILE) $(DMEM_FILE) $(DUMP)

$(HEX_FILE): $(ELF_OUT)
	$(OBJCOPY) -O ihex $< $@

# Xilinx FPGA memory initialization files in HEX format
$(IMEM_FILE): $(ELF_OUT)
	$(OBJCOPY) -O verilog $< $(IMEM_FILE) --only-section=.text --verilog-data-width 4

# Xilinx FPGA memory initialization files in HEX format
$(DMEM_FILE): $(ELF_OUT)
	$(OBJCOPY) -O verilog $< $(DMEM_FILE) --only-section=.data --verilog-data-width 4

# If you want to view the disassembled code, you can use a RISC-V disassembler like riscv32-unknown-elf-objdump:
$(DUMP): $(ELF_OUT)
	$(OBJDUMP) -D $< > $@

# Assemble and link the code using the RISC-V GCC toolchain:
$(ELF_OUT): $(OBJ)
	$(LD) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $(ELF_OUT)

# Compile the C code to assembly using the RISC-V GCC toolchain (assuming you have it installed):
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(ELF_OUT) $(HEX_FILE) $(IMEM_FILE) $(DMEM_FILE) $(DUMP)

.PHONY: all clean

