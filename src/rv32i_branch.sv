`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_branch
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

module rv32i_branch(
    output logic [31:0] branch_target,
    output logic        branch_taken,
    input  logic [31:0] rs1_value,
    input  logic [31:0] rs2_value,
    input  logic [31:0] imm_value,
    input  logic [31:0] pc,
    input  logic [2:0]  funct3,
    input  logic        jalr_op,
    input  logic        jal_op,
    input  logic        branch_op,
    input  logic        branch_stall,
    input  logic        branch_flush,
    input  logic        clk,
    input  logic        reset
    );
    
    // Branch   : if(rs1 OP rs2) PC<-PC+Bimm
    // JalR     : rd <- PC+4; PC<-rs1+Iimm
    // Jal      : rd <- PC+4; PC<-PC+Jimm
    
    logic [31:0] target_base;
    logic        branch_compare;

    always_comb begin
        unique case (funct3)
            3'b000  : branch_compare = rs1_value == rs2_value;  // BEQ
            3'b001  : branch_compare = rs1_value != rs2_value;  // BNE
            3'b100  : branch_compare = $signed(rs1_value) <  $signed(rs2_value);    // BLT
            3'b101  : branch_compare = $signed(rs1_value) >= $signed(rs2_value);    // BGE
            3'b110  : branch_compare = rs1_value <  rs2_value;  // BLTU
            3'b111  : branch_compare = rs1_value >= rs2_value;  // BGEU
            default : branch_compare = '0;
        endcase
    end
    
    // Base address for JalR OR Branch operation
    assign target_base = (jalr_op) ? rs1_value : pc;
    // Target address adder = (Base address) + (offset; Immediate value)
    always_ff @(posedge clk) begin
        if (!branch_stall) begin
            branch_target <= target_base + imm_value;
        end
    end
    
    // branch taken, Register comparator
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            branch_taken <= 1'b0;
        end else if (branch_flush) begin
            branch_taken <= 1'b0;
        end else if (!branch_stall) begin
            branch_taken <= (jalr_op | jal_op) ? 1'b1 : (branch_op & branch_compare);
        end
    end
    
endmodule
