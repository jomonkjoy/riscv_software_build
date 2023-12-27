`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_execute
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

module rv32i_execute(
    // Execute results output
    output decode_t     execute_inst,
    output logic [31:0] execute_alu_result,
    output logic [31:0] execute_rs2_data,
    output logic [31:0] execute_branch_target,
    output logic        execute_branch_taken,
    
    // Instruction decode output
    input  decode_t     decode_inst,
    input  logic [31:0] decode_rs1_data,
    input  logic [31:0] decode_rs2_data,
    input  logic [31:0] decode_imm_data,
    input  logic [31:0] decode_pc,
    input  alu_op_a_t   decode_alu_op_a,
    input  alu_op_b_t   decode_alu_op_b,
    input  alu_op_t     decode_alu_op,
    
    input  logic        execute_stall,
    input  logic        execute_flush,
    
    input  logic        clk,
    input  logic        reset
    );
    
    rv32i_alu alu (
        .alu_result(execute_alu_result),
        .rs1_value(decode_rs1_data),
        .rs2_value(decode_rs2_data),
        .imm_value(decode_imm_data),
        .pc(decode_pc),
        .alu_op_a(decode_alu_op_a),
        .alu_op_b(decode_alu_op_b),
        .alu_op(decode_alu_op),
        .alu_stall(execute_stall),
        .clk(clk),
        .reset(reset)
    );
    
    rv32i_branch branch (
        .branch_target(execute_branch_target),
        .branch_taken(execute_branch_taken),
        .rs1_value(decode_rs1_data),
        .rs2_value(decode_rs2_data),
        .imm_value(decode_imm_data),
        .pc(decode_pc),
        .funct3(decode_inst.funct3),
        .jalr_op(decode_inst.jalr),
        .jal_op(decode_inst.jal),
        .branch_op(decode_inst.branch),
        .branch_stall(execute_stall),
        .branch_flush(execute_flush),
        .clk(clk),
        .reset(reset)
    );
    
    // RS2 value is the Memory Write Data
    always_ff @(posedge clk) begin
        if (!execute_stall) begin
            execute_rs2_data <= decode_rs2_data;
        end
    end
    
    // RV32I instruction decode
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            execute_inst <= '0;
        end else if (execute_flush) begin
            execute_inst <= '0;
        end else if (!execute_stall) begin
            execute_inst <= decode_inst;
        end
    end
    
endmodule
