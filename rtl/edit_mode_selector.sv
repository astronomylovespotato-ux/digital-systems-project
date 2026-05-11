`timescale 1ns / 1ps
module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);

  //long press detector

  logic long_press;

  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  // short press detector
  logic press;

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  // armed arming_latch
  logic armed;
  logic disarm;

  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  //mode counter
  logic reset_counter;
  logic enable_counter;

  logic [1:0] count;

  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // counter control logic
  // counter only runs in edit mode
  assign enable_counter = armed && press;

  // reset counter when it is not armed
  assign reset_counter = !armed;


  // exit edit mode when currently at hours and another press occurs
  assign disarm = armed && press && (count == 2'd2);

  //output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
