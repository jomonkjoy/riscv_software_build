module rv32i_instruction_decode (

    input  logic [4:0]      write_reg,
    input  logic [31:0]     write_data,
    input  logic            write_enable,
    input  logic [31:0]     instruction,
    output logic [4:0]      rs1,
    output logic [4:0]      rs2,
    output logic [4:0]      rd,
    output logic [6:0]      opcode,
    output logic [2:0]      funct3,
    output logic [6:0]      funct7,
    output logic            reg_write_enable,
    output logic            mem_read_enable,
    output logic            mem_write_enable,
    output logic [2:0]      alu_op,
    output logic [31:0]     rs1_data,
    output logic [31:0]     rs1_data,
    output logic [31:0]     imm_data,
    input  logic            clk,
    input  logic            rst_n
);

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Register file instance
    rv32i_register_file (
      .write_reg(write_reg),
      .write_data(write_data),
      .write_enable(write_enable),
      .read_reg1(instruction[19:15]),
      .read_data1(rs1_data),
      .read_reg2(instruction[24:20]),
      .read_data2(rs2_data),
      .clk(clk),
      .rst_n(rst_n)
    );

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        rs1 <= 0;
        rs2 <= 0;
        rd <= 0;
        alu_op <= 0;
        reg_write_enable <= 0;
        mem_read_enable <= 0;
        mem_write_enable <= 0;
      end else begin
        case(opcode)
          // R-type instructions
          7'b0110011: begin
            rs1 <= instruction[19:15];
            rs2 <= instruction[24:20];
            rd <= instruction[11:7];
            alu_op <= funct3;
            reg_write_enable <= 1;
            mem_read_enable <= 0;
            mem_write_enable <= 0;
          end

          // I-type instructions
          7'b0010011: begin
            rs1 <= instruction[19:15];
            rd <= instruction[11:7];
            alu_op <= funct3;
            reg_write_enable <= 1;
            mem_read_enable <= 0;
            mem_write_enable <= 0;
          end

          // Load instructions
          7'b0000011: begin
            rs1 <= instruction[19:15];
            rd <= instruction[11:7];
            alu_op <= funct3;
            reg_write_enable <= 1;
            mem_read_enable <= 1;
            mem_write_enable <= 0;
          end

          // Store instructions
          7'b0100011: begin
            rs1 <= instruction[19:15];
            rs2 <= instruction[24:20];
            alu_op <= funct3;
            reg_write_enable <= 0;
            mem_read_enable <= 0;
            mem_write_enable <= 1;
          end

          // Branch instructions
          7'b1100011: begin
            rs1 <= instruction[19:15];
            rs2 <= instruction[24:20];
            alu_op <= funct3;
            reg_write_enable <= 0;
            mem_read_enable <= 0;
            mem_write_enable <= 0;
          end

          // Other instructions
          default: begin
            rs1 <= 0;
            rs2 <= 0;
            rd <= 0;
            alu_op <= 0;
            reg_write_enable <= 0;
            mem_read_enable <= 0;
            mem_write_enable <= 0;
          end
        endcase
      end
    end

endmodule

