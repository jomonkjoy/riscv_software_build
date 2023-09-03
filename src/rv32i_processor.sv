module rv32i_processor #(
    parameter C_S_AXIL_IO_ADDR_WIDTH = 32,
    parameter C_S_AXIL_IO_DATA_WIDTH = 32
)   (
    // AXI-Lite master interface for IO
    output logic [C_S_AXIL_IO_ADDR_WIDTH-1 : 0]     s_axil_io_awaddr,
    output logic [2 : 0]                            s_axil_io_awprot,
    output logic                                    s_axil_io_awvalid,
    input  logic                                    s_axil_io_awready,
    output logic [C_S_AXIL_IO_DATA_WIDTH-1 : 0]     s_axil_io_wdata,
    output logic [(C_S_AXIL_IO_DATA_WIDTH/8)-1 : 0] s_axil_io_wstrb,
    output logic                                    s_axil_io_wvalid,
    input  logic                                    s_axil_io_wready,
    input  logic [1 : 0]                            s_axil_io_bresp,
    input  logic                                    s_axil_io_bvalid,
    output logic                                    s_axil_io_bready,
    output logic [C_S_AXIL_IO_ADDR_WIDTH-1 : 0]     s_axil_io_araddr,
    output logic [2 : 0]                            s_axil_io_arprot,
    output logic                                    s_axil_io_arvalid,
    input  logic                                    s_axil_io_arready,
    input  logic [C_S_AXIL_IO_DATA_WIDTH-1 : 0]     s_axil_io_rdata,
    input  logic [1 : 0]                            s_axil_io_rresp,
    input  logic                                    s_axil_io_rvalid,
    output logic                                    s_axil_io_rready,

    // Clock & reset
    input  logic                                    aclk,
    input  logic                                    areset_n
);

    wire [31:0] if_id_instruction;
    wire [31:0] id_ex_instruction;
    wire [31:0] ex_mem_instruction;
    wire [31:0] mem_wb_instruction;

    wire [31:0] if_id_pc;
    wire [31:0] id_ex_pc;
    wire [31:0] ex_mem_pc;
    wire [31:0] mem_wb_pc;

    wire [31:0] if_id_next_pc;
    wire [31:0] id_ex_next_pc;
    wire [31:0] ex_mem_next_pc;
    wire [31:0] mem_wb_next_pc;

    wire stall;
    wire if_id_stall;
    wire id_ex_stall;
    wire ex_mem_stall;
    wire mem_wb_stall;

    wire flush;
    wire if_id_flush;
    wire id_ex_flush;
    wire ex_mem_flush;
    wire mem_wb_flush;

    // Instantiate the IF (Instruction Fetch) stage
    IF_Stage if_stage(
        .clk(clk),
        .rst(rst),
        .pc_if(if_id_next_pc),
        .instruction_memory(instruction_memory),
        .instruction(if_id_instruction),
        .pc_id(if_id_pc),
        .stall_id(if_id_stall),
        .flush_id(if_id_flush)
    );

    // Instantiate the ID (Instruction Decode) stage
    ID_Stage id_stage(
        .clk(clk),
        .rst(rst),
        .instruction_if(if_id_instruction),
        .pc_if(if_id_pc),
        .instruction_id(id_ex_instruction),
        .pc_id(id_ex_pc),
        .next_pc_id(id_ex_next_pc),
        .stall_if(if_id_stall),
        .stall_id(id_ex_stall),
        .flush_if(if_id_flush),
        .flush_id(id_ex_flush)
    );

    // Instantiate the EX (Execution) stage
    EX_Stage ex_stage(
        .clk(clk),
        .rst(rst),
        .instruction_id(id_ex_instruction),
        .pc_id(id_ex_pc),
        .next_pc_id(id_ex_next_pc),
        .instruction_ex(ex_mem_instruction),
        .pc_ex(ex_mem_pc),
        .next_pc_ex(ex_mem_next_pc),
        .stall_id(id_ex_stall),
        .stall_ex(ex_mem_stall),
        .flush_id(id_ex_flush),
        .flush_ex(ex_mem_flush),
        .data_memory(data_memory),
        .data_memory_read(data_memory_read),
        .write_data_memory(write_data_memory)
    );

    // Instantiate the MEM (Memory Access) stage
    MEM_Stage mem_stage(
        .clk(clk),
        .rst(rst),
        .instruction_ex(ex_mem_instruction),
        .pc_ex(ex_mem_pc),
        .next_pc_ex(ex_mem_next_pc),
        .instruction_mem(mem_wb_instruction),
        .pc_mem(mem_wb_pc),
        .next_pc_mem(mem_wb_next_pc),
        .stall_ex(ex_mem_stall),
        .stall_mem(mem_wb_stall),
        .flush_ex(ex_mem_flush),
        .flush_mem(mem_wb_flush),
        .data_memory(data_memory),
        .data_memory_read(data_memory_read),
        .write_data_memory(write_data_memory)
    );

    // Instantiate the WB (Write Back) stage
    WB_Stage wb_stage(
        .clk(clk),
        .rst(rst),
        .instruction_mem(mem_wb_instruction),
        .pc_mem(mem_wb_pc),
        .next_pc_mem(mem_wb_next_pc),
        .reg_file(reg_file)
    );

    // Connect stall and flush signals
    assign stall = if_id_stall | id_ex_stall | ex_mem_stall | mem_wb_stall;
    assign flush = if_id_flush | id_ex_flush | ex_mem_flush | mem_wb_flush;

endmodule

