# Compiler and linker settings
CC = riscv64-unknown-elf-gcc
LD = riscv64-unknown-elf-gcc
CFLAGS = -march=rv32i -mabi=ilp32 -nostartfiles
LDFLAGS = -T linker.ld

# Source file and output file
SRC = example.c
OBJ = $(SRC:.c=.o)
OUT = example.elf

all: $(OUT)

$(OUT): $(OBJ)
    $(LD) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $(OUT)

%.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@

clean:
    rm -f $(OBJ) $(OUT)

.PHONY: all clean

