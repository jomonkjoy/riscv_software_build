`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_decode_fmt
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

import rv32i_package::*;

module rv32i_decode_fmt(
    // Instruction decode output
    output logic [4:0]  decode_rs1_address,
    output logic [4:0]  decode_rs2_address,
    output logic [4:0]  decode_rd_address,
    output logic [11:0] decode_funct12,
    output logic [6:0]  decode_funct7,
    output logic [2:0]  decode_funct3,
    output logic [4:0]  decode_opcode,
    // Input from Instruction Fetch
    input  logic [31:0] fetch_instruction
    );
    
    logic [4:0]  rs1_address;
    logic [4:0]  rs2_address;
    logic [4:0]  rd_address;
    logic [4:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [11:0] funct12;
    
    assign funct12      = fetch_instruction[31:20];
    assign funct7       = fetch_instruction[31:25];
    assign rs2_address  = fetch_instruction[24:20];
    assign rs1_address  = fetch_instruction[19:15];
    assign funct3       = fetch_instruction[14:12];
    assign rd_address   = fetch_instruction[11:7];
    assign opcode       = fetch_instruction[6:2];
    
    // RV32I instruction opcode
    assign decode_opcode = opcode;
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_rs1_address = rs1_address; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_rs1_address = rs1_address; // rd <- rs1 OP Iimm
            5'b00101    : decode_rs1_address = '0; // rd <- PC + Uimm
            5'b01000    : decode_rs1_address = rs1_address; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_rs1_address = rs1_address; // rd <- rs1 OP rs2
            5'b01101    : decode_rs1_address = '0; // rd <- Uimm
            5'b11000    : decode_rs1_address = rs1_address; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_rs1_address = rs1_address; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_rs1_address = '0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_rs1_address = rs1_address; // rd <- CSR <- rs1/uimm5
            default     : decode_rs1_address = '0;
        endcase
    end
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_rs2_address = '0; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_rs2_address = '0; // rd <- rs1 OP Iimm
            5'b00101    : decode_rs2_address = '0; // rd <- PC + Uimm
            5'b01000    : decode_rs2_address = rs2_address; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_rs2_address = rs2_address; // rd <- rs1 OP rs2
            5'b01101    : decode_rs2_address = '0; // rd <- Uimm
            5'b11000    : decode_rs2_address = rs2_address; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_rs2_address = '0; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_rs2_address = '0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_rs2_address = '0; // rd <- CSR <- rs1/uimm5
            default     : decode_rs2_address = '0;
        endcase
    end
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_rd_address = rd_address; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_rd_address = rd_address; // rd <- rs1 OP Iimm
            5'b00101    : decode_rd_address = rd_address; // rd <- PC + Uimm
            5'b01000    : decode_rd_address = '0; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_rd_address = rd_address; // rd <- rs1 OP rs2
            5'b01101    : decode_rd_address = rd_address; // rd <- Uimm
            5'b11000    : decode_rd_address = '0; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_rd_address = rd_address; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_rd_address = rd_address; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_rd_address = rd_address; // rd <- CSR <- rs1/uimm5
            default     : decode_rd_address = '0;
        endcase
    end
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_funct12 = '0; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_funct12 = '0; // rd <- rs1 OP Iimm
            5'b00101    : decode_funct12 = '0; // rd <- PC + Uimm
            5'b01000    : decode_funct12 = '0; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_funct12 = '0; // rd <- rs1 OP rs2
            5'b01101    : decode_funct12 = '0; // rd <- Uimm
            5'b11000    : decode_funct12 = '0; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_funct12 = '0; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_funct12 = '0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_funct12 = funct12; // rd <- CSR <- rs1/uimm5
            default     : decode_funct12 = '0;
        endcase
    end
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_funct7 = '0; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_funct7 = '0; // rd <- rs1 OP Iimm
            5'b00101    : decode_funct7 = '0; // rd <- PC + Uimm
            5'b01000    : decode_funct7 = '0; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_funct7 = funct7; // rd <- rs1 OP rs2
            5'b01101    : decode_funct7 = '0; // rd <- Uimm
            5'b11000    : decode_funct7 = '0; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_funct7 = '0; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_funct7 = '0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_funct7 = '0; // rd <- CSR <- rs1/uimm5
            default     : decode_funct7 = '0;
        endcase
    end
    
    // RV32I instruction decode
    always_comb begin
        case(opcode)
            5'b00000    : decode_funct3 = funct3; // rd <- mem[rs1+Iimm]
            5'b00100    : decode_funct3 = funct3; // rd <- rs1 OP Iimm
            5'b00101    : decode_funct3 = '0; // rd <- PC + Uimm
            5'b01000    : decode_funct3 = funct3; // mem[rs1+Simm] <- rs2
            5'b01100    : decode_funct3 = funct3; // rd <- rs1 OP rs2
            5'b01101    : decode_funct3 = '0; // rd <- Uimm
            5'b11000    : decode_funct3 = funct3; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : decode_funct3 = '0; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : decode_funct3 = '0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : decode_funct3 = funct3; // rd <- CSR <- rs1/uimm5
            default     : decode_funct3 = '0;
        endcase
    end
    
endmodule
