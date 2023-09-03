module rv32i_register_file (

    // RD interface
    input  logic [4:0]      write_reg,
    input  logic [31:0]     write_data,
    input  logic            write_enable,
    // RS1 interface
    input  logic [4:0]      read_reg1,
    output logic [31:0]     read_data1,
    // RS2 interface
    input  logic [4:0]      read_reg2,
    output logic [31:0]     read_data2,

    input  logic            clk,
    input  logic            rst_n
);

    reg [31:0] RF_REGISTERS [31:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize RF_REGISTERS to zero on reset
            for (int i = 0; i < 32; i = i + 1) begin
                RF_REGISTERS[i] <= 32'h00000000;
            end
        end else if (write_enable) begin
            // Write to the register file
            if (write_reg != 0) begin
                RF_REGISTERS[write_reg] <= write_data;
            end
        end
    end

    assign read_data1 = (read_reg1 == 0) ? 32'h00000000 : RF_REGISTERS[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'h00000000 : RF_REGISTERS[read_reg2];

endmodule

