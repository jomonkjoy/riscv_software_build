`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_processor
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

module rv32i_processor(
    // Instruction Memory - 1 clk read latency
    output logic        instruction_read,
    output logic [31:0] instruction_address,
    input  logic [31:0] instruction_data,
    // Data Memory - 1 clk read latency
    output logic        memory_write,
    output logic        memory_read,
    output logic [31:0] memory_address,
    output logic [3:0]  memory_byteenable,
    output logic [31:0] memory_write_data,
    input  logic [31:0] memory_read_data,
    
    input  logic clk,
    input  logic reset
    );
    
    // Instruction Fetch stage
    logic [31:0] fetch_instruction;
    logic [31:0] fetch_pc;
    logic        fetch_stall;
    logic        fetch_flush;
    
    // Instruction Decode stage
    // Instruction decode output
    decode_t     decode_inst;
    logic [31:0] decode_rs1_data;
    logic [31:0] decode_rs2_data;
    logic [31:0] decode_imm_data;
    logic [31:0] decode_pc;
    alu_op_a_t   decode_alu_op_a;
    alu_op_b_t   decode_alu_op_b;
    alu_op_t     decode_alu_op;
    // Register file Write-Back
    logic [31:0] write_data;
    register_t   write_register;
    logic        write_enable;
    logic        decode_stall = 0;
    logic        decode_flush;
    
    // Execute stage
    decode_t     execute_inst;
    logic [31:0] execute_alu_result;
    logic [31:0] execute_rs2_data;
    logic [31:0] execute_branch_target;
    logic        execute_branch_taken;
    logic        execute_branch_taken_d1;
    logic        execute_branch_taken_d2;
    logic        execute_stall = 0;
    logic        execute_flush;
    
    // Memory Access stage
    decode_t     memory_inst;
    logic [31:0] memory_alu_result;
    logic [31:0] memory_load_data;
    register_t   memory_wb_register;
    logic        memory_wb_enable;
    logic        memory_to_reg;
    logic        memory_stall = 0;
    logic        memory_flush = 0;
    
    // Load-Use Hazard Detection
    register_t   fetch_rs1_register;
    register_t   fetch_rs2_register;
    logic        load_rs1_hazard;
    logic        load_rs2_hazard;
    logic        load_use_hazard;
    
    // Forwarding logic for Data Hazards
    logic [31:0] forward_rs1_data;
    logic [31:0] forward_rs2_data;
    logic        execute_data_rs1_hazard;
    logic        execute_data_rs2_hazard;
    logic        memory_data_rs1_hazard;
    logic        memory_data_rs2_hazard;
    
    // Hazard detection unit --------------------------------------------------
    
    // Load-use hazard If detected, stall and insert bubble
    assign load_rs1_hazard = (decode_inst.rd == fetch_rs1_register) & decode_inst.rd_write;
    assign load_rs2_hazard = (decode_inst.rd == fetch_rs2_register) & decode_inst.rd_write;
    // Datapath with Load-use Hazard Detection
    always_comb begin
        if (decode_inst.load && (load_rs1_hazard || load_rs2_hazard)) begin
            load_use_hazard = 1'b1;
        end else begin
            load_use_hazard = 1'b0;
        end
    end
    
    // Force control values in ID/EX register to 0, will insert bubble in pipeline
    assign decode_flush = load_use_hazard | execute_branch_taken | execute_branch_taken_d1;
    // Prevent update of PC and IF/ID register, will stall fetch stage
    assign fetch_stall  = load_use_hazard;
    // Hazard detection unit --------------------------------------------------
    
    // Forwarding unit --------------------------------------------------------
    // Data hazards are detected when the source register (rs1 or rs2) of the current instruction is the same as 
    // the destination register (rd) of the previous instruction.
    // Another hazard could happen at the Write Back Stage when writing and reading at the same address.
    
    // Datapath with Forwarding ALU Operand A
    assign execute_data_rs1_hazard = (decode_inst.rs1 == execute_inst.rd) & execute_inst.rd_write;
    assign memory_data_rs1_hazard  = (decode_inst.rs1 == memory_inst.rd) & memory_inst.rd_write;
    
    always_comb begin
        if (execute_data_rs1_hazard) begin
            forward_rs1_data = execute_alu_result;
        end else if (memory_data_rs1_hazard) begin
            forward_rs1_data = write_data;
        end else begin
            forward_rs1_data = decode_rs1_data;
        end
    end
    
    // Datapath with Forwarding ALU Operand B
    assign execute_data_rs2_hazard = (decode_inst.rs2 == execute_inst.rd) & execute_inst.rd_write;
    assign memory_data_rs2_hazard  = (decode_inst.rs2 == memory_inst.rd) & memory_inst.rd_write;
    
    always_comb begin
        if (execute_data_rs2_hazard) begin
            forward_rs2_data = execute_alu_result;
        end else if (memory_data_rs2_hazard) begin
            forward_rs2_data = write_data;
        end else begin
            forward_rs2_data = decode_rs2_data;
        end
    end
    // Forwarding unit --------------------------------------------------------
    
    // Branch Hazards, if Branch Taken. flush IF/ID, ID/EX & EX/MEM
    assign fetch_flush      = execute_branch_taken;
    assign execute_flush    = execute_branch_taken | execute_branch_taken_d1 | execute_branch_taken_d2;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            execute_branch_taken_d1 <= 1'b0;
            execute_branch_taken_d2 <= 1'b0;
        end else begin
            execute_branch_taken_d1 <= execute_branch_taken;
            execute_branch_taken_d2 <= execute_branch_taken_d1;
        end
    end
    
    // Instruction fetch from memory
    rv32i_fetch fetch (
        .instruction_read(instruction_read),
        .instruction_address(instruction_address),
        .instruction_data(instruction_data),
        .fetch_instruction(fetch_instruction),
        .fetch_pc(fetch_pc),
        .execute_branch_target(execute_branch_target),
        .execute_branch_taken(execute_branch_taken),
        .fetch_stall(fetch_stall),
        .fetch_flush(fetch_flush),
        .clk(clk),
        .reset(reset)
    );
    
    // Instruction decode & register read
    rv32i_decode decode (
        .decode_inst(decode_inst),
        .decode_rs1_data(decode_rs1_data),
        .decode_rs2_data(decode_rs2_data),
        .decode_imm_data(decode_imm_data),
        .decode_pc(decode_pc),
        .decode_alu_op_a(decode_alu_op_a),
        .decode_alu_op_b(decode_alu_op_b),
        .decode_alu_op(decode_alu_op),
        .fetch_rs1_register(fetch_rs1_register),
        .fetch_rs2_register(fetch_rs2_register),
        .write_data(write_data),
        .write_register(write_register),
        .write_enable(write_enable),
        .fetch_instruction(fetch_instruction),
        .fetch_pc(fetch_pc),
        .decode_stall(decode_stall),
        .decode_flush(decode_flush),
        .clk(clk),
        .reset(reset)
    );
    
    // Execute operation or calculate address
    rv32i_execute execute (
        .execute_inst(execute_inst),
        .execute_alu_result(execute_alu_result),
        .execute_rs2_data(execute_rs2_data),
        .execute_branch_target(execute_branch_target),
        .execute_branch_taken(execute_branch_taken),
        .decode_inst(decode_inst),
        .decode_rs1_data(forward_rs1_data),//(decode_rs1_data),
        .decode_rs2_data(forward_rs2_data),//(decode_rs2_data),
        .decode_imm_data(decode_imm_data),
        .decode_pc(decode_pc),
        .decode_alu_op_a(decode_alu_op_a),
        .decode_alu_op_b(decode_alu_op_b),
        .decode_alu_op(decode_alu_op),
        .execute_stall(execute_stall),
        .execute_flush(execute_flush),
        .clk(clk),
        .reset(reset)
    );
    
    // Access memory operand
    rv32i_memory memory (
        .memory_inst(memory_inst),
        .memory_write(memory_write),
        .memory_read(memory_read),
        .memory_address(memory_address),
        .memory_byteenable(memory_byteenable),
        .memory_write_data(memory_write_data),
        .memory_read_data(memory_read_data),
        .memory_alu_result(memory_alu_result),
        .memory_load_data(memory_load_data),
        .memory_wb_register(memory_wb_register),
        .memory_wb_enable(memory_wb_enable),
        .memory_to_reg(memory_to_reg),
        .execute_inst(execute_inst),
        .execute_alu_result(execute_alu_result),
        .execute_rs2_data(execute_rs2_data),
        .memory_stall(memory_stall),
        .memory_flush(memory_flush),
        .clk(clk),
        .reset(reset)
    );
    
    // Write result back to register
    assign write_data       = memory_to_reg ? memory_load_data : memory_alu_result;
    assign write_register   = memory_wb_register;
    assign write_enable     = memory_wb_enable;

endmodule
