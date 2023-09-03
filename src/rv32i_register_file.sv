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

    // Synthesis attributes to map to Block RAM
    (* ram_style = "block" *)
    (* use_bram = "yes" *)
    (* use_bram_for_single_port = "yes" *)
    logic [31:0]    RV32I_RF_A [31:0];
    // Synthesis attributes to map to Block RAM
    (* ram_style = "block" *)
    (* use_bram = "yes" *)
    (* use_bram_for_single_port = "yes" *)
    logic [31:0]    RV32I_RF_B [31:0];

    logic [31:0]    read_data1_reg;
    logic           read_reg1_zero;
    logic [31:0]    read_data2_reg;
    logic           read_reg2_zero;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_reg1_zero <= 1'b1;
            read_reg2_zero <= 1'b1;
        end else begin
            read_reg1_zero <= (read_reg1 == 0);
            read_reg2_zero <= (read_reg2 == 0);
        end
    end

    // Register file A definition
    always @(posedge clk) begin
        read_data1_reg <= RV32I_RF_A[read_reg1];
        if (write_enable) begin
            // Write to the register file
            if (write_reg != 0) begin
                RV32I_RF_A[write_reg] <= write_data;
            end
        end
    end

    // Register file B definition
    always @(posedge clk) begin
        read_data2_reg <= RV32I_RF_B[read_reg2];
        if (write_enable) begin
            // Write to the register file
            if (write_reg != 0) begin
                RV32I_RF_B[write_reg] <= write_data;
            end
        end
    end

    assign read_data1 = read_reg1_zero ? 32'h00000000 : read_data1_reg;
    assign read_data2 = read_reg2_zero ? 32'h00000000 : read_data2_reg;

endmodule

