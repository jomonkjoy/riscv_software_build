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
    
    // Instantiate the memory module
    my_memory #(.INIT_FILE("instr_mem.mem")) instruction_memory (
        .clk(clk),
        .address(instruction_address[11:2]),
        .write_data('0),
        .write_byteenable('0),
        .write_enable('0),
        .read_data(instruction_data[31:0])
    );
        
    // Instantiate the memory module
    my_memory #(.INIT_FILE("data_mem.mem")) data_memory (
        .clk(clk),
        .address(memory_address[11:2]),
        .write_data(memory_write_data[31:0]),
        .write_byteenable(memory_byteenable[3:0]),
        .write_enable(memory_write),
        .read_data(memory_read_data[31:0])
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

module my_memory #(
  parameter INIT_FILE = ""
 ) (
  input logic [9:0] address,
  input logic [31:0] write_data,
  input logic [3:0] write_byteenable,
  input logic write_enable,
  output logic [31:0] read_data,
  input logic clk
);
  // Memory definition
  logic [31:0] mem [0:1023];

  // Initial block to initialize memory
  initial begin
    $readmemh(INIT_FILE, mem);
    // Additional simulation setup code goes here
  end
  
  // Memory read and write logic
  always_ff @(posedge clk) begin
    if (write_enable) begin
      // Write operation
      for (int i=0; i<4; i++) begin
        if (write_byteenable[i]) begin
          mem[address][i*8 -: 8] <= write_data[i*8 -: 8];
        end
      end
    end else begin
      // Read operation
      read_data <= mem[address];
    end
  end
endmodule