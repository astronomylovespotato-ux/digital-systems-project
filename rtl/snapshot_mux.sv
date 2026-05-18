`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] snapshot = '0;

  // Only capture d while not holding.
  // Once hold is high, snapshot stays frozen.
  always_ff @(posedge clk) begin
    if (!hold) begin
      snapshot <= d;
    end
  end

  // If hold is low, q follows d immediately.
  // If hold is high, q shows the frozen snapshot.
  assign q = hold ? snapshot : d;

endmodule
