# riscv_software_build
Compiling C code for the RISC-V RV32I architecture using a linker script 

## RISCV GNU tool chain
https://github.com/riscv-collab/riscv-gnu-toolchain

## Below are the steps to do this using the GCC compiler.

1. Write your C code (let's call it example.c):
2. Compile the C code to assembly using the RISC-V GCC toolchain (assuming you have it installed): riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -S example.c -o example.s
       In the above command:
           -march=rv32i specifies the RV32I ISA (base integer instructions).
           -mabi=ilp32 specifies the ILP32 ABI (32-bit integer, long, and pointer).
            This will generate example.s, which is the assembly code.

3. Create a linker script (let's call it linker.ld) for your RV32I target.
       This linker script specifies the memory layout of your program, including the entry point (main in this case), the .text (code) section, and the .data (initialized data) section.

4. Assemble and link the code using the RISC-V GCC toolchain: riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostartfiles -T linker.ld example.s -o example.elf
       In this command:
             -nostartfiles is used to exclude standard startup files, as we're providing our own entry point in the linker.ld script.
             -T linker.ld specifies the linker script to use.
      example.s is the assembly code generated in step 2.
      This will produce an ELF executable file named example.elf.

5. If you want to view the disassembled code, you can use a RISC-V disassembler like riscv32-unknown-elf-objdump: riscv32-unknown-elf-objdump -d example.elf
6. To compile and link the code: make
7. To clean the generated files: make clean

## Creating a linker script that separates program memory (code) and data memory is a common requirement, especially in embedded systems where program code and data are stored in different memory regions. 

Below is an example linker script for a RISC-V RV32I architecture that separates program memory (flash) and data memory (RAM):
In this linker script:
1. We define two memory regions using the MEMORY block: flash for program memory (flash) and ram for data memory (RAM). You should adjust the ORIGIN and LENGTH values according to your hardware configuration.
2. The ENTRY(_start) directive specifies the entry point of your program. _start is a common symbol for the program's entry point, but you can replace it with the actual name of your program's entry point.
3. In the SECTIONS block:
       - The .text section is defined to contain code and is located in the flash memory region.
       - The .data section is defined to contain initialized data (.data) and uninitialized data (.bss) and is located in the ram memory region.
   
You can adjust the memory region sizes and addresses to match your specific hardware. After creating this linker script, you can use it with the RISC-V GCC toolchain, as shown in the previous response, to compile and link your code.
