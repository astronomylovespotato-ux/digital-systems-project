`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 7,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);
  logic [WIDTH-1:0] next_count;
  // next state logic
  always_comb begin
    if (up) begin  //Increment
      if (count == Max) next_count = '0;
      else next_count = count + One;
    end else begin  // decrement
      if (count == '0) next_count = Max;
      else next_count = count - One;
    end
  end

  always_ff @(posedge clk) begin  // this is the state update
    if (enable) count <= next_count;
  end
endmodule



