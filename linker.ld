/* Linker script for separating Program (text) and Data memory */

/* Memory regions */
MEMORY
{
    /* Program memory (flash) */
    flash (rx) : ORIGIN = 0x00000000, LENGTH = 0x10000

    /* Data memory (RAM) */
    ram (rw) : ORIGIN = 0x20000000, LENGTH = 0x8000
}

/* Entry point */
ENTRY(_start)

/* Sections */
SECTIONS
{
    /* Text section (program memory) */
    .text : ALIGN(4)
    {
        *(.text)
    } > flash

    /* Data section (data memory) */
    .data : ALIGN(4)
    {
        *(.data)
        *(.bss)
    } > ram
}
