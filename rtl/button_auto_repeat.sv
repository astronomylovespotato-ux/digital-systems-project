`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic pulse_train;
  logic held;

  // Fires a combinational single-cycle pulse the moment button goes high
  // (rise = button & ~sig_prev, which is 0 by the next clock edge)
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  // held asserts after (HOLD_CYCLES - REPEAT_CYCLES + 1) consecutive held cycles.
  // This is QUAL_CYCLES: chosen so that the rate generator's first tick
  // (which fires REPEAT_CYCLES-1 cycles after held, plus 1 cycle for its
  // internal `running` register) lands exactly on cycle HOLD_CYCLES.
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Generates periodic ticks every REPEAT_CYCLES clocks while held is high.
  // run=held (not button) so counting only begins after the hold threshold.
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  assign pulse = rise | (button & pulse_train);

endmodule
