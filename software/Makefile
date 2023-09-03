# Compiler and linker settings
RISCV_PREFIX = riscv64-unknown-elf-
CC = $(RISCV_PREFIX)gcc
LD = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
CFLAGS = -march=rv32i -mabi=ilp32 -nostartfiles
LDFLAGS = -T linker.ld

# Source file and output file
SRC = example.c
OBJ = $(SRC:.c=.o)
OUT = example.elf
DUMP = example.txt

all: $(DUMP)

# If you want to view the disassembled code, you can use a RISC-V disassembler like riscv32-unknown-elf-objdump:
$(DUMP): $(OUT)
	$(OBJDUMP) -D $< > $@

# Assemble and link the code using the RISC-V GCC toolchain:
$(OUT): $(OBJ)
	$(LD) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $(OUT)

# Compile the C code to assembly using the RISC-V GCC toolchain (assuming you have it installed):
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(OUT) $(DUMP)

.PHONY: all clean

