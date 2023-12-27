`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_alu
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

module rv32i_alu(
    output logic [31:0] alu_result,
    input  logic [31:0] rs1_value,
    input  logic [31:0] rs2_value,
    input  logic [31:0] imm_value,
    input  logic [31:0] pc,
    input  alu_op_a_t   alu_op_a,
    input  alu_op_b_t   alu_op_b,
    input  alu_op_t     alu_op,
    input  logic        alu_stall,
    input  logic        clk,
    input  logic        reset
    );
    
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_value;
    logic [4:0]  shift_amount;
    
    // shifts use the lower 5 bits of the intermediate or rs2 value
    assign shift_amount = alu_operand_b[4:0];
    
    // ALU Operand A select
    always_comb begin
        unique case (alu_op_a)
            SRC_0   : alu_operand_a = 'd0;
            SRC_PC  : alu_operand_a = pc;
            default : alu_operand_a = rs1_value;
        endcase
    end
    
    // ALU Operand B select
    always_comb begin
        unique case (alu_op_b)
            SRC_4   : alu_operand_b = 'd4;
            SRC_IMM : alu_operand_b = imm_value;
            default : alu_operand_b = rs2_value;
        endcase
    end
    
    // ALU Operation
    always_comb begin
        unique case (alu_op)
            ADD     : alu_value = alu_operand_a + alu_operand_b;
            SUB     : alu_value = alu_operand_a - alu_operand_b;
            SLT     : alu_value = (32)'($signed(alu_operand_a) < $signed(alu_operand_b));
            SLTU    : alu_value = (32)'(alu_operand_a < alu_operand_b);
            XOR     : alu_value = alu_operand_a ^ alu_operand_b;
            OR      : alu_value = alu_operand_a | alu_operand_b;
            AND     : alu_value = alu_operand_a & alu_operand_b;
            SL      : alu_value = alu_operand_a << shift_amount;
            SRL     : alu_value = alu_operand_a >> shift_amount;
            SRA     : alu_value = $signed(alu_operand_a) >>> shift_amount;
            default : alu_value = alu_operand_a + alu_operand_b;
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (!alu_stall) begin
            alu_result <= alu_value;
        end
    end
    
endmodule
