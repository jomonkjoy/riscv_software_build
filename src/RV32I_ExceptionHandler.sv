module RV32I_ExceptionHandler (
  input logic clk,
  input logic rst,
  input logic mei_exception,
  input logic [31:0] mei_cause,
  output logic [31:0] mepc, // Machine Exception Program Counter
  output logic [2:0] mcause // Machine Cause
);

  // Define your exception handler logic here
  logic [31:0] exception_pc;

  always_ff @(posedge clk or posedge rst)
    if (rst)
      exception_pc <= 32'b0;
    else if (mei_exception)
      exception_pc <= mei_cause;
    else
      exception_pc <= 32'b0;

  // Map the MEI exception to a specific cause for simplicity
  always_comb
    case (mei_exception)
      1'b1: mcause = 3'b001; // Example: External interrupt
      default: mcause = 3'b000; // No exception
    endcase

  assign mepc = exception_pc;

endmodule
