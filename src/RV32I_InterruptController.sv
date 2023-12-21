module RV32I_InterruptController (
  input logic clk,
  input logic rst,
  input logic [31:0] interrupt_signals,
  input logic [31:0] interrupt_enable,
  output logic interrupt_req,
  output logic [31:0] interrupt_vector
);

  // Define your interrupt controller logic here
  logic [31:0] pending_interrupts;

  always_ff @(posedge clk or posedge rst)
    if (rst)
      pending_interrupts <= 32'b0;
    else
      pending_interrupts <= interrupt_signals & interrupt_enable;

  assign interrupt_req = (pending_interrupts != 32'b0);
  assign interrupt_vector = priority_encoder(pending_interrupts);

  // Implement priority encoder logic
  function logic [4:0] priority_encoder;
    input logic [31:0] inputs;
    output logic [4:0] encoded;
    reg [4:0] temp;

    always_comb begin
      for (int i = 0; i < 32; i = i + 1)
        if (inputs[i]) begin
          temp = i;
          break;
        end
    end

    assign encoded = temp;
  endfunction

endmodule
