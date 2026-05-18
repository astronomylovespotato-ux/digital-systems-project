`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic enable;
  logic up;

  wire  inc_event = edit_mode && inc && !dec;
  wire  dec_event = edit_mode && dec && !inc;
  wire  tick_event = !edit_mode && tick;

  assign enable = inc_event || dec_event || tick_event;
  assign up = inc_event;

  assign borrow_out = !clr && !edit_mode && tick && (count == '0);

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

endmodule
