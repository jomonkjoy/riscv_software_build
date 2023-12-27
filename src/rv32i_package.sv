`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 15:17:27
// Design Name: 
// Module Name: rv32i_package
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package rv32i_package;

    localparam RESET_VECTOR = 32'h0001008C;
    localparam RV32I_NOP    = 32'h00000013;
    
    // registers
    typedef enum logic [4:0] {
        zero, // Hard-Wired Zero
        ra, // Return Address
        sp, // Stack Pointer
        gp, // Global Pointer
        tp, // Thread Pointer
        t0, t1, t2, // Temporary/Alternate Link Register
        fp, s1, // Saved Register (Frame Pointer)
        a0, a1, a2, a3, a4, a5, a6, a7, // Function Argument/Return Value Registers
        s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, // Saved Registers
        t3, t4, t5, t6 // Temporary Registers
    } register_t;

    // Instruction Decode control
    typedef struct packed {
        logic [11:0] funct12;
        register_t rs1;
        register_t rs2;
        register_t rd;
        logic [6:0] funct7;
        logic [2:0] funct3;
        logic rs1_zero;
        logic rs2_zero;
        logic rd_zero;
        logic rs1_read;
        logic rs2_read;
        logic rd_write;
        logic illegal;
        logic load;
        logic alu_imm;
        logic aui_pc;
        logic store;
        logic alu_reg;
        logic lui;
        logic branch;
        logic jalr;
        logic jal;
        logic system;
    } decode_t;
    
    // internal, decoded opcodes
    typedef enum logic [1:0] {
        SRC_0,
        SRC_PC,
        SRC_RS1
    } alu_op_a_t;

    // internal, decoded opcodes
    typedef enum logic [1:0] {
        SRC_4,
        SRC_IMM,
        SRC_RS2
    } alu_op_b_t;
  
    // internal, decoded opcodes
    typedef enum logic [3:0] {
        ADD,
        SUB,
        SLT,
        SLTU,
        XOR,
        OR,
        AND,
        SL,
        SRL,
        SRA
    } alu_op_t;
  
    // CPU request (CPU -> cache controller)
    typedef struct packed {
        logic [31:0] addr;
        logic [31:0] data;
        logic rw;   // 0 = read, 1 = write
        logic valid; // request valid
    } cpu_req_type;

    // Cache response (cache controller -> CPU)
    typedef struct packed {
        logic [31:0] data;
        logic ready; // result is ready
    } cpu_res_type;
    
endpackage
