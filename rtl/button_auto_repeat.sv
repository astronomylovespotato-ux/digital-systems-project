`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // repeat cycles must be smaller than hold cycles
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  // creates one pulse when button first goes from low to high
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  //held becomes high after button is held for HOLD_CYCLES
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );


  // once held is high, reepated pulses are generated

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate (
      .clk (clk),
      .run (button),
      .tick(pulse_train)
  );


  assign pulse = rise | (held & pulse_train);

endmodule
