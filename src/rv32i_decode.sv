`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 14:22:04
// Design Name: 
// Module Name: rv32i_decode
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

module rv32i_decode(
    // Instruction decode output
    output decode_t     decode_inst,
    output logic [31:0] decode_rs1_data,
    output logic [31:0] decode_rs2_data,
    output logic [31:0] decode_imm_data,
    output logic [31:0] decode_pc,
    output alu_op_a_t   decode_alu_op_a,
    output alu_op_b_t   decode_alu_op_b,
    output alu_op_t     decode_alu_op,
    // register address for Forwarding logic
    output register_t   fetch_rs1_register,
    output register_t   fetch_rs2_register,
    // Register file Write-Back
    input  logic [31:0] write_data,
    input  register_t   write_register,
    input  logic        write_enable,
    
    // Input from Instruction Fetch
    input  logic [31:0] fetch_instruction,
    input  logic [31:0] fetch_pc,
    
    input  logic        decode_stall,
    input  logic        decode_flush,
    
    input  logic        clk,
    input  logic        reset
    );
    
    logic [4:0]  rs1_address;
    logic [4:0]  rs2_address;
    logic [4:0]  rd_address;
    logic        rs1_read;
    logic        rs2_read;
    logic        rd_write;
    logic        illegal;
    logic [4:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [11:0] funct12;
    logic [31:0] imm_utype,imm_jtype,imm_itype,imm_btype,imm_stype;
    alu_op_t     alu_reg_op;
    alu_op_t     alu_imm_op;
    alu_op_t     alu_add_sub_op;
    alu_op_t     alu_srl_sra_op;
    
    assign funct12      = fetch_instruction[31:20];
    assign funct7       = fetch_instruction[31:25];
    assign rs2_address  = fetch_instruction[24:20];
    assign rs1_address  = fetch_instruction[19:15];
    assign funct3       = fetch_instruction[14:12];
    assign rd_address   = fetch_instruction[11:7];
    assign opcode       = fetch_instruction[6:2];
    
    assign fetch_rs1_register = register_t'(rs1_address);
    assign fetch_rs2_register = register_t'(rs2_address);
    
    // Register File instance
    rv32i_regfile regfile (
        .read_data_1(decode_rs1_data),
        .read_register_1(rs1_address),
        .read_enable_1(!decode_stall),
        .read_clear_1(decode_flush),
        .read_data_2(decode_rs2_data),
        .read_register_2(rs2_address),
        .read_enable_2(!decode_stall),
        .read_clear_2(decode_flush),
        
        .write_data(write_data),
        .write_register(5'(write_register)),
        .write_enable(write_enable),
        
        .clk(clk),
        .reset(reset)
    );
    
    rv32i_decode_fmt decode_fmt (
        // Instruction decode output
        .decode_imm(),
        .decode_rs1_address(),
        .decode_rs2_address(),
        .decode_rd_address(),
        .decode_funct12(),
        .decode_funct7(),
        .decode_funct3(),
        .decode_opcode(),
        // Input from Instruction Fetch
        .fetch_instruction(fetch_instruction),
        .fetch_pc(fetch_pc)
    );
    
    // decode immediates
    assign imm_utype  = {    fetch_instruction[31],   fetch_instruction[30:12], {12{1'b0}}};
    assign imm_jtype  = {{12{fetch_instruction[31]}}, fetch_instruction[19:12],fetch_instruction[20],fetch_instruction[30:21],1'b0};
    assign imm_itype  = {{21{fetch_instruction[31]}}, fetch_instruction[30:20]};
    assign imm_btype  = {{20{fetch_instruction[31]}}, fetch_instruction[7],fetch_instruction[30:25],fetch_instruction[11:8],1'b0};
    assign imm_stype  = {{21{fetch_instruction[31]}}, fetch_instruction[30:25],fetch_instruction[11:7]};
    
    // Immediate data decode
    always_ff @(posedge clk) begin
        if (!decode_stall) begin
            case(opcode)
                5'b00000    : decode_imm_data <= imm_itype; // rd <- mem[rs1+Iimm]
                5'b00100    : decode_imm_data <= imm_itype; // rd <- rs1 OP Iimm
                5'b00101    : decode_imm_data <= imm_utype; // rd <- PC + Uimm
                5'b01000    : decode_imm_data <= imm_stype; // mem[rs1+Simm] <- rs2
                5'b01100    : decode_imm_data <= '0; // rd <- rs1 OP rs2
                5'b01101    : decode_imm_data <= imm_utype; // rd <- Uimm
                5'b11000    : decode_imm_data <= imm_btype; // if(rs1 OP rs2) PC<-PC+Bimm
                5'b11001    : decode_imm_data <= imm_itype; // rd <- PC+4; PC<-rs1+Iimm
                5'b11011    : decode_imm_data <= imm_jtype; // rd <- PC+4; PC<-PC+Jimm
                5'b11100    : decode_imm_data <= '0; // rd <- CSR <- rs1/uimm5
                default     : decode_imm_data <= '0;
            endcase
        end
    end
    
    // ALU operand A decode
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_alu_op_a <= SRC_RS1;
        end else if (decode_flush) begin
            decode_alu_op_a <= SRC_RS1;
        end else if (!decode_stall) begin
            case(opcode)
                5'b00000    : decode_alu_op_a <= SRC_RS1; // rd <- mem[rs1+Iimm]
                5'b00100    : decode_alu_op_a <= SRC_RS1; // rd <- rs1 OP Iimm
                5'b00101    : decode_alu_op_a <= SRC_PC; // rd <- PC + Uimm
                5'b01000    : decode_alu_op_a <= SRC_RS1; // mem[rs1+Simm] <- rs2
                5'b01100    : decode_alu_op_a <= SRC_RS1; // rd <- rs1 OP rs2
                5'b01101    : decode_alu_op_a <= SRC_0; // rd <- Uimm
                5'b11000    : decode_alu_op_a <= SRC_RS1; // if(rs1 OP rs2) PC<-PC+Bimm
                5'b11001    : decode_alu_op_a <= SRC_PC; // rd <- PC+4; PC<-rs1+Iimm
                5'b11011    : decode_alu_op_a <= SRC_PC; // rd <- PC+4; PC<-PC+Jimm
                5'b11100    : decode_alu_op_a <= SRC_RS1; // rd <- CSR <- rs1/uimm5
                default     : decode_alu_op_a <= SRC_RS1;
            endcase
        end
    end
    
    // ALU operand b decode
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_alu_op_b <= SRC_RS2;
        end else if (decode_flush) begin
            decode_alu_op_b <= SRC_RS2;
        end else if (!decode_stall) begin
            case(opcode)
                5'b00000    : decode_alu_op_b <= SRC_IMM; // rd <- mem[rs1+Iimm]
                5'b00100    : decode_alu_op_b <= SRC_IMM; // rd <- rs1 OP Iimm
                5'b00101    : decode_alu_op_b <= SRC_IMM; // rd <- PC + Uimm
                5'b01000    : decode_alu_op_b <= SRC_IMM; // mem[rs1+Simm] <- rs2
                5'b01100    : decode_alu_op_b <= SRC_RS2; // rd <- rs1 OP rs2
                5'b01101    : decode_alu_op_b <= SRC_IMM; // rd <- Uimm
                5'b11000    : decode_alu_op_b <= SRC_RS2; // if(rs1 OP rs2) PC<-PC+Bimm
                5'b11001    : decode_alu_op_b <= SRC_4; // rd <- PC+4; PC<-rs1+Iimm
                5'b11011    : decode_alu_op_b <= SRC_4; // rd <- PC+4; PC<-PC+Jimm
                5'b11100    : decode_alu_op_b <= SRC_RS2; // rd <- CSR <- rs1/uimm5
                default     : decode_alu_op_b <= SRC_RS2;
            endcase
        end
    end
    
    assign alu_add_sub_op = fetch_instruction[30] ? SUB : ADD;
    assign alu_srl_sra_op = fetch_instruction[30] ? SRA : SRL;
    
    // ALU-Immediate operation decode
    always_comb begin
        case(funct3)
            3'b000  : alu_imm_op = ADD;
            3'b001  : alu_imm_op = SL;
            3'b010  : alu_imm_op = SLT;
            3'b011  : alu_imm_op = SLTU;
            3'b100  : alu_imm_op = XOR;
            3'b101  : alu_imm_op = alu_srl_sra_op;
            3'b110  : alu_imm_op = OR;
            3'b111  : alu_imm_op = AND;
            default : alu_imm_op = ADD;
        endcase
    end
    
    // ALU-Register operation decode
    always_comb begin
        case(funct3)
            3'b000  : alu_reg_op = alu_add_sub_op;
            3'b001  : alu_reg_op = SL;
            3'b010  : alu_reg_op = SLT;
            3'b011  : alu_reg_op = SLTU;
            3'b100  : alu_reg_op = XOR;
            3'b101  : alu_reg_op = alu_srl_sra_op;
            3'b110  : alu_reg_op = OR;
            3'b111  : alu_reg_op = AND;
            default : alu_reg_op = ADD;
        endcase
    end
    
    // ALU operation decode
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_alu_op <= ADD;
        end else if (decode_flush) begin
            decode_alu_op <= ADD;
        end else if (!decode_stall) begin
            case(opcode)
                5'b00000    : decode_alu_op <= ADD; // rd <- mem[rs1+Iimm]
                5'b00100    : decode_alu_op <= alu_imm_op; // rd <- rs1 OP Iimm
                5'b00101    : decode_alu_op <= ADD; // rd <- PC + Uimm
                5'b01000    : decode_alu_op <= ADD; // mem[rs1+Simm] <- rs2
                5'b01100    : decode_alu_op <= alu_reg_op; // rd <- rs1 OP rs2
                5'b01101    : decode_alu_op <= ADD; // rd <- Uimm
                5'b11000    : decode_alu_op <= SUB; // if(rs1 OP rs2) PC<-PC+Bimm
                5'b11001    : decode_alu_op <= ADD; // rd <- PC+4; PC<-rs1+Iimm
                5'b11011    : decode_alu_op <= ADD; // rd <- PC+4; PC<-PC+Jimm
                5'b11100    : decode_alu_op <= ADD; // rd <- CSR <- rs1/uimm5
                default     : decode_alu_op <= ADD;
            endcase
        end
    end
    
    // PC register
    always_ff @(posedge clk) begin
        if (!decode_stall) begin
            decode_pc <= fetch_pc;
        end
    end
    
    // RS1-read
    always_comb begin
        case(opcode)
            5'b00000    : rs1_read = 1'b1; // rd <- mem[rs1+Iimm]
            5'b00100    : rs1_read = 1'b1; // rd <- rs1 OP Iimm
            5'b00101    : rs1_read = 1'b0; // rd <- PC + Uimm
            5'b01000    : rs1_read = 1'b1; // mem[rs1+Simm] <- rs2
            5'b01100    : rs1_read = 1'b1; // rd <- rs1 OP rs2
            5'b01101    : rs1_read = 1'b0; // rd <- Uimm
            5'b11000    : rs1_read = 1'b1; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : rs1_read = 1'b1; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : rs1_read = 1'b0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : rs1_read = 1'b1; // rd <- CSR <- rs1/uimm5
            default     : rs1_read = 1'b0;
        endcase
    end
    
    // RS2-read
    always_comb begin
        case(opcode)
            5'b00000    : rs2_read = 1'b0; // rd <- mem[rs1+Iimm]
            5'b00100    : rs2_read = 1'b0; // rd <- rs1 OP Iimm
            5'b00101    : rs2_read = 1'b0; // rd <- PC + Uimm
            5'b01000    : rs2_read = 1'b1; // mem[rs1+Simm] <- rs2
            5'b01100    : rs2_read = 1'b1; // rd <- rs1 OP rs2
            5'b01101    : rs2_read = 1'b0; // rd <- Uimm
            5'b11000    : rs2_read = 1'b1; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : rs2_read = 1'b0; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : rs2_read = 1'b0; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : rs2_read = 1'b0; // rd <- CSR <- rs1/uimm5
            default     : rs2_read = 1'b0;
        endcase
    end
    
    // RD-write
    always_comb begin
        case(opcode)
            5'b00000    : rd_write = 1'b1; // rd <- mem[rs1+Iimm]
            5'b00100    : rd_write = 1'b1; // rd <- rs1 OP Iimm
            5'b00101    : rd_write = 1'b1; // rd <- PC + Uimm
            5'b01000    : rd_write = 1'b0; // mem[rs1+Simm] <- rs2
            5'b01100    : rd_write = 1'b1; // rd <- rs1 OP rs2
            5'b01101    : rd_write = 1'b1; // rd <- Uimm
            5'b11000    : rd_write = 1'b0; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : rd_write = 1'b1; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : rd_write = 1'b1; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : rd_write = 1'b1; // rd <- CSR <- rs1/uimm5
            default     : rd_write = 1'b0;
        endcase
    end
    
    // Illegal Instruction opcode
    always_comb begin
        case(opcode)
            5'b00000    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- mem[rs1+Iimm]
            5'b00100    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- rs1 OP Iimm
            5'b00101    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- PC + Uimm
            5'b01000    : illegal = fetch_instruction[1:0] != 2'b11; // mem[rs1+Simm] <- rs2
            5'b01100    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- rs1 OP rs2
            5'b01101    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- Uimm
            5'b11000    : illegal = fetch_instruction[1:0] != 2'b11; // if(rs1 OP rs2) PC<-PC+Bimm
            5'b11001    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- PC+4; PC<-rs1+Iimm
            5'b11011    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- PC+4; PC<-PC+Jimm
            5'b11100    : illegal = fetch_instruction[1:0] != 2'b11; // rd <- CSR <- rs1/uimm5
            default     : illegal = 1'b1;
        endcase
    end
    
    // RV32I instruction decode
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_inst           <= '0;
            decode_inst.rs1       <= zero;
            decode_inst.rs2       <= zero;
            decode_inst.rd        <= zero;
        end else if (decode_flush) begin
            decode_inst           <= '0;
            decode_inst.rs1       <= zero;
            decode_inst.rs2       <= zero;
            decode_inst.rd        <= zero;
        end else if (!decode_stall) begin
            decode_inst.funct12   <= funct12;
            decode_inst.rs1       <= register_t'(rs1_address);
            decode_inst.rs2       <= register_t'(rs2_address);
            decode_inst.rd        <= register_t'(rd_address);
            decode_inst.rs1_zero  <= (rs1_address == '0);
            decode_inst.rs2_zero  <= (rs2_address == '0);
            decode_inst.rd_zero   <= (rd_address == '0);
            decode_inst.rs1_read  <= rs1_read & (rs1_address != '0);
            decode_inst.rs2_read  <= rs2_read & (rs2_address != '0);
            decode_inst.rd_write  <= rd_write & (rd_address != '0);
            decode_inst.illegal   <= illegal;
            decode_inst.funct7    <= funct7;
            decode_inst.funct3    <= funct3;
            decode_inst.load      <= (opcode == 5'b00000); // rd <- mem[rs1+Iimm]
            decode_inst.alu_imm   <= (opcode == 5'b00100); // rd <- rs1 OP Iimm
            decode_inst.aui_pc    <= (opcode == 5'b00101); // rd <- PC + Uimm
            decode_inst.store     <= (opcode == 5'b01000); // mem[rs1+Simm] <- rs2
            decode_inst.alu_reg   <= (opcode == 5'b01100); // rd <- rs1 OP rs2
            decode_inst.lui       <= (opcode == 5'b01101); // rd <- Uimm
            decode_inst.branch    <= (opcode == 5'b11000); // if(rs1 OP rs2) PC<-PC+Bimm
            decode_inst.jalr      <= (opcode == 5'b11001); // rd <- PC+4; PC<-rs1+Iimm
            decode_inst.jal       <= (opcode == 5'b11011); // rd <- PC+4; PC<-PC+Jimm
            decode_inst.system    <= (opcode == 5'b11100); // rd <- CSR <- rs1/uimm5
        end
    end
    
endmodule
