`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  // final counter value before held turns high
  localparam int CountMax = HOLD_CYCLES;

  // number of bits to store countwidth
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic Count_enable;

  logic [CountWidth-1:0] count;

  // counter stores how long button is held for
  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(Count_enable),
      .count(count)
  );

  //reset counter when button is released
  assign count_rst = !button;

  assign Count_enable = button && !held;

  assign held = button && (count == CountWidth'(CountMax));
endmodule
