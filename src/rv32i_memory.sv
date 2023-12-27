`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_memory
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

module rv32i_memory(
    output decode_t     memory_inst,
    // Data Memory - 1 clk read latency
    output logic        memory_write,
    output logic        memory_read,
    output logic [31:0] memory_address,
    output logic [3:0]  memory_byteenable,
    output logic [31:0] memory_write_data,
    input  logic [31:0] memory_read_data,
    
    // Register file Write-Back
    output logic [31:0] memory_alu_result,
    output logic [31:0] memory_load_data,
    output register_t   memory_wb_register,
    output logic        memory_wb_enable,
    output logic        memory_to_reg,
    
    // Execute results output
    input  decode_t     execute_inst,
    input  logic [31:0] execute_alu_result,
    input  logic [31:0] execute_rs2_data,
    
    input  logic        memory_stall,
    input  logic        memory_flush,
    
    input  logic        clk,
    input  logic        reset
    );
    
    logic [31:0] load_data_b;
    logic [31:0] load_data_h;
    logic [31:0] load_data_w;
    logic [1:0]  mem_word_offset;
    
    // - funct3[1:0]:  00->byte 01->halfword 10->word
    // - funct3[2]: 0->do sign expansion   1->no sign expansion
    // - mem_addr[1:0]: indicates which byte/halfword is accessed
    assign mem_word_offset      = memory_address[1:0];
    
    // Stores copy the value in register rs2 to memory.
    assign memory_write         = execute_inst.store;
    assign memory_read          = execute_inst.load;
    assign memory_address       = execute_alu_result;
    assign memory_write_data    = execute_rs2_data << (mem_word_offset[1:0]*8);
    
    always_comb begin
        unique case(execute_inst.funct3[1:0])
            2'b00   : memory_byteenable = 4'b0001 << mem_word_offset; // byte access
            2'b01   : memory_byteenable = 4'b0011 << mem_word_offset; // halfword access
            2'b10   : memory_byteenable = 4'b1111 << mem_word_offset; // word access
            default : memory_byteenable = 4'b1111;
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (!memory_stall) begin
            memory_alu_result <= execute_alu_result;
        end
    end
    
    // Loads copy a value from memory to register rd.
    assign load_data_b = memory_read_data >> (mem_word_offset[1:0]*8) & 32'h_00_00_00_ff;
    assign load_data_h = memory_read_data >> (mem_word_offset[1:0]*8) & 32'h_00_00_ff_ff;
    assign load_data_w = memory_read_data;
    
    always_comb begin
        unique case(execute_inst.funct3[2:0])
            3'b000  : memory_load_data = {{24{load_data_b[07]}}, load_data_b[07:0]}; // sign extended byte access
            3'b001  : memory_load_data = {{16{load_data_h[15]}}, load_data_h[15:0]}; // sign extended halfword access
            3'b010  : memory_load_data = load_data_w; // word access
            3'b100  : memory_load_data = {24'b0, load_data_b[07:0]}; // unsigned bytes access
            3'b101  : memory_load_data = {16'b0, load_data_h[15:0]}; // unsigned halfword access
            default : memory_load_data = load_data_w; // word access
        endcase
    end
    
    // Loads copy a value from memory to register rd.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            memory_wb_register <= zero;
            memory_wb_enable <= '0;
            memory_to_reg <= '0;
            memory_inst <= '0;
        end else if (memory_flush) begin
            memory_wb_register <= zero;
            memory_wb_enable <= '0;
            memory_to_reg <= '0;
            memory_inst <= '0;
        end else if (!memory_stall) begin
            memory_wb_register <= execute_inst.rd;
            memory_wb_enable <= execute_inst.rd_write;
            memory_to_reg <= execute_inst.load;
            memory_inst <= execute_inst;
        end
    end
    
endmodule
