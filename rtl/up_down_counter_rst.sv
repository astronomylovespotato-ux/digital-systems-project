`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);

  localparam logic [WIDTH-1:0] MaxValue = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  initial count = '0;

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      if (up) begin
        count <= (count == MaxValue) ? '0 : count + One;
      end else begin
        count <= (count == '0) ? MaxValue : count - One;
      end
    end
  end

endmodule
