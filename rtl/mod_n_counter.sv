`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,  // n states
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,  //synchronous
    input logic enable,
    output logic [WIDTH-1:0] count = '0  // initialise count to 0
);
  // managing the widths
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  logic [WIDTH-1:0] next_count;

  //next state logic

  always_comb begin
    if (count == Max) begin
      next_count = '0;
    end else begin
      next_count = count + One;

    end
  end

  // state update
  always_ff @(posedge clk) begin
    if (rst) begin  // reset has priority over everything else
      count <= '0;  // non-blocking as ff
    end else if (enable) begin
      count <= next_count;
    end
    // this makes it so that rst = 0 and enable = 0 no assignment happens

  end

endmodule
