`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_regfile
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


module rv32i_regfile(
    output logic [31:0] read_data_1,
    input  logic [4:0]  read_register_1,
    input  logic        read_enable_1,
    input  logic        read_clear_1,
    output logic [31:0] read_data_2,
    input  logic [4:0]  read_register_2,
    input  logic        read_enable_2,
    input  logic        read_clear_2,

    input  logic [31:0] write_data,
    input  logic [4:0]  write_register,
    input  logic        write_enable,
    
    input  logic        clk,
    input  logic        reset
    );
    
    logic [31:0] read_data_1_reg;
    logic [31:0] read_data_2_reg;
    logic [31:0] read_data_1_forward;
    logic [31:0] read_data_2_forward;
    logic        read_register_1_eq_zero;
    logic        read_register_2_eq_zero;
    logic        read_register_1_eq_write;
    logic        read_register_2_eq_write;
    logic        read_register_1_forward;
    logic        read_register_2_forward;
    
    // Forward '0 for read from zero address
    assign read_register_1_eq_zero  = (read_register_1 == '0);
    assign read_register_2_eq_zero  = (read_register_2 == '0);
    // Forward Write-data for read during write from same address
    assign read_register_1_eq_write = (read_register_1 == write_register) & write_enable;
    assign read_register_2_eq_write = (read_register_2 == write_register) & write_enable;
    // Forwarding lgic for the read-port
    assign read_data_1 = read_register_1_forward ? read_data_1_forward : read_data_1_reg;
    assign read_data_2 = read_register_2_forward ? read_data_2_forward : read_data_2_reg;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            read_data_1_forward <= '0;
            read_register_1_forward <= 1'b1;
        end else if (read_clear_1) begin
            read_data_1_forward <= '0;
            read_register_1_forward <= 1'b1;
        end else if (read_enable_1) begin
            read_data_1_forward <= read_register_1_eq_zero ? '0 : write_data;
            read_register_1_forward <= read_register_1_eq_zero | read_register_1_eq_write;
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            read_data_2_forward <= '0;
            read_register_2_forward <= 1'b1;
        end else if (read_clear_2) begin
            read_data_2_forward <= '0;
            read_register_2_forward <= 1'b1;
        end else if (read_enable_2) begin
            read_data_2_forward <= read_register_2_eq_zero ? '0 : write_data;
            read_register_2_forward <= read_register_2_eq_zero | read_register_2_eq_write;
        end
    end
    
    rv32i_gpr rs1_rf (
        .clock(clk),
        .data(write_data),
        .rdaddress({4'd0,read_register_1}), // 9-bit address
        .wraddress({4'd0,write_register}), // 9-bit address
        .rden(read_enable_1),
        .wren(write_enable),
        .q(read_data_1_reg)
    );
    
    rv32i_gpr rs2_rf (
        .clock(clk),
        .data(write_data),
        .rdaddress({4'd0,read_register_2}), // 9-bit address
        .wraddress({4'd0,write_register}), // 9-bit address
        .rden(read_enable_2),
        .wren(write_enable),
        .q(read_data_2_reg)
    );
    
endmodule
