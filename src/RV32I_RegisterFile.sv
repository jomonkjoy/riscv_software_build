module RV32I_RegisterFile (
  input logic clk,
  input logic rst,
  input logic [4:0] read_reg1, read_reg2, write_reg,
  input logic [31:0] write_data,
  input logic reg_write_enable,
  output logic [31:0] read_data1, read_data2
);
  // Define the number of registers
  localparam REG_COUNT = 32;

  // Define the register file
  logic [31:0] registers [REG_COUNT - 1:0];

  // Read logic
  always_comb begin
    read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];
  end

  // Write logic
  always_ff @(posedge clk or posedge rst)
    if (rst)
      registers <= '0;
    else if (reg_write_enable)
      registers[write_reg] <= write_data;

endmodule
