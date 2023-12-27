`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_fetch
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

module rv32i_fetch(
    // Instruction Memory - 1 clk read latency
    output logic        instruction_read,
    output logic [31:0] instruction_address,
    input  logic [31:0] instruction_data,
    
    output logic [31:0] fetch_instruction,
    output logic [31:0] fetch_pc,
    
    input  logic [31:0] execute_branch_target,
    input  logic        execute_branch_taken,
    
    input  logic        fetch_stall,
    input  logic        fetch_flush,
    
    input  logic        clk,
    input  logic        reset
    );
    
    // PC register
    logic [31:0]    pc;
    logic [31:0]    pc_reg;
    logic           pc_valid;
    logic [31:0]    insn_saved;
    logic [31:0]    addr_saved;
    logic           saved;
    
    assign instruction_read     = pc_valid;
    assign instruction_address  = {pc[31:2],2'b00};
    
    // Stall Intruction fetch, when Load-use hazard detected.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_valid <= 1'b0;
        end else begin
            pc_valid <= !fetch_stall;
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= RESET_VECTOR;
            pc_reg <= RESET_VECTOR;
        end else if (pc_valid & !fetch_stall) begin
            if (execute_branch_taken) begin
                pc <= {execute_branch_target[31:2],2'b00};
            end else begin
                pc <= pc + 32'd4;
            end
            pc_reg <= pc;
        end
    end
    
    // Flag for saved insn/address
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            saved <= 1'b1; // Insert NOP at Power-On-Reset
        end else if (fetch_flush) begin
            saved <= 1'b1; // Insert NOP on pipeline flush
        end else if (fetch_stall & !saved) begin
            saved <= 1'b1;
        end else if (pc_valid & !fetch_stall) begin
            saved <= 1'b0;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            insn_saved <= RV32I_NOP;
        end else if (fetch_flush) begin
            insn_saved <= RV32I_NOP;
        end else if (fetch_stall & !saved) begin
            insn_saved <= instruction_data;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_saved <= RESET_VECTOR;
        end else if (fetch_flush) begin
            addr_saved <= RESET_VECTOR;
        end else if (fetch_stall & !saved) begin
            addr_saved <= {pc_reg[31:2],2'b00};
        end
    end
    
    // Driving output to Instruction Decode unit
    assign fetch_instruction   = saved ? insn_saved : instruction_data;
    assign fetch_pc            = saved ? addr_saved : pc_reg;
    
endmodule
