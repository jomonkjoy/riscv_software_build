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
    output logic [31:0] decode_imm,
    output logic [4:0]  decode_rs1_address,
    output logic [4:0]  decode_rs2_address,
    output logic [4:0]  decode_rd_address,
    output logic [11:0] decode_funct12,
    output logic [6:0]  decode_funct7,
    output logic [2:0]  decode_funct3,
    output logic [4:0]  decode_opcode,
    // Input from Instruction Fetch
    input  logic [31:0] fetch_instruction,
    input  logic [31:0] fetch_pc
    );
    
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [11:0] funct12;
    logic [31:0] imm;
    
    // 32-bit Instruction Formats
    always_comb begin
        opcode = fetch_instruction[6:0];
        
        case (opcode[6:0])
            7'b0110011: begin // R-type ALU instructions
                // funct7 determines the exact instruction
                $display("R-type ALU Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = fetch_instruction[31:25];
                rs2 = fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
                case (funct7)
                    7'b0000000: ;// add
                    // Additional decoding if needed
                    7'b0000001: ;// mul
                    // Additional decoding if needed
                    // Add more cases for other R-type instructions
                endcase
            end
            7'b0010011: begin // I-type ALU instructions
                // funct3 determines the exact instruction
                $display("I-type ALU Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = '0;
                imm[11:0] = fetch_instruction[31:20];
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
                case (funct3)
                    3'b000: ;// addi
                    // Additional decoding if needed
                    3'b001: ;// slli
                    // Additional decoding if needed
                    // Add more cases for other I-type instructions
                endcase
            end
            7'b0000011: begin // I-type Load instructions
                // funct3 determines the exact instruction
                $display("I-type Load Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = '0;
                imm[11:0] = fetch_instruction[31:20];
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
                case (funct3)
                    3'b000: ;// addi
                    // Additional decoding if needed
                    3'b001: ;// slli
                    // Additional decoding if needed
                    // Add more cases for other I-type instructions
                endcase
            end
            7'b1100111: begin // I-type JALR instructions
                // funct3 determines the exact instruction
                $display("I-type JALR Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = '0;
                imm[11:0] = fetch_instruction[31:20];
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = '0; // fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
            end
            7'b0100011: begin // S-type Store instructions
                $display("S-type Store Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = '0;
                imm[11:5] = fetch_instruction[31:25];
                imm[4:0] = fetch_instruction[11:7];
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = fetch_instruction[14:12];
                rd = '0; // fetch_instruction[11:7];
            end
            7'b1100011: begin // B-type Branch instructions
                $display("B-type Branch Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:13] = '0;
                imm[12] = fetch_instruction[31];
                imm[10:5] = fetch_instruction[30:25];
                imm[4:1] = fetch_instruction[11:8];
                imm[11] = fetch_instruction[7];
                imm[0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = fetch_instruction[24:20];
                rs1 = fetch_instruction[19:15];
                funct3 = fetch_instruction[14:12];
                rd = '0; // fetch_instruction[11:7];
            end
            7'b0110111: begin // U-type LUI instructions
                $display("U-type LUI Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = fetch_instruction[31:12];
                imm[11:0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = '0; // fetch_instruction[19:15];
                funct3 = '0; // fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
            end
            7'b0010111: begin // U-type AUIPC instructions
                $display("U-type AUIPC Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:12] = fetch_instruction[31:12];
                imm[11:0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = '0; // fetch_instruction[19:15];
                funct3 = '0; // fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
            end
            7'b0010011: begin // J-type JAL instructions
                $display("J-type JAL Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:21] = '0;
                imm[20] = fetch_instruction[31];
                imm[10:1] = fetch_instruction[30:21];
                imm[11] = fetch_instruction[20];
                imm[19:12] = fetch_instruction[19:12];
                imm[0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = '0; // fetch_instruction[19:15];
                funct3 = '0; // fetch_instruction[14:12];
                rd = fetch_instruction[11:7];
            end
            default : begin // Handle unknown opcode
                $display("Unsuported Instruction on PC:%8h", fetch_pc[31:0]);
                imm[31:0] = '0;
                funct12 = '0; // fetch_instruction[31:20];
                funct7 = '0; // fetch_instruction[31:25];
                rs2 = '0; // fetch_instruction[24:20];
                rs1 = '0; // fetch_instruction[19:15];
                funct3 = '0; // fetch_instruction[14:12];
                rd = '0; // fetch_instruction[11:7];
            end
        endcase
    end

    // Instruction decode output
    assign decode_imm = imm;
    assign decode_rs1_address = rs1;
    assign decode_rs2_address = rs2;
    assign decode_rd_address = rd;
    assign decode_funct12 = funct12;
    assign decode_funct7 = funct7;
    assign decode_funct3 = funct3;
    assign decode_opcode = opcode;
    
endmodule
