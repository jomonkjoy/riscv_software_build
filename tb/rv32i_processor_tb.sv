`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2021 08:12:01
// Design Name: 
// Module Name: rv32i_processor_tb
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


module rv32i_processor_tb(

    );
    
    parameter PERIOD = 10;

    // Declare some signals so we can see how I/O works
    reg clk    = 0;
    reg reset  = 1;

    // Instruction Memory - 1 clk read latency
    logic        instruction_read;
    logic [31:0] instruction_address;
    logic [31:0] instruction_data;
    // Data Memory - 1 clk read latency
    logic        memory_write;
    logic        memory_read;
    logic [31:0] memory_address;
    logic [3:0]  memory_byteenable;
    logic [31:0] memory_write_data;
    logic [31:0] memory_read_data;
    
    rv32i_processor processor (
        .instruction_read(instruction_read),
        .instruction_address(instruction_address),
        .instruction_data(instruction_data),
        .memory_write(memory_write),
        .memory_read(memory_read),
        .memory_address(memory_address),
        .memory_byteenable(memory_byteenable),
        .memory_write_data(memory_write_data),
        .memory_read_data(memory_read_data),
        .clk(clk),
        .reset(reset)
    );
    
    // Print some stuff as an example
    initial begin
        $display("[%0t] Model running...\n", $time);
    end
    
    always begin
        clk = 1'b0;
        #(PERIOD/2) clk = 1'b1;
        #(PERIOD/2);
    end
    
    initial begin
        // Initialize Inputs
        reset = 1;
        
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        
        // Add stimulus here
    end

endmodule
