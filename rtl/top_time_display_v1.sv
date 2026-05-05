`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       CLOCK_50,
    input  logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // hours range 0-23, min and sec, 0-59

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;


  logic tick;

  // seperating slower rates of signals
  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;


  // rate generators which create one-cycle enable pulses at differing speeds
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_rate_1hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_rate_25hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_rate_1khz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1khz)

  );

  // select clock speed using switches.
  // SW = 00: 1 Hz
  // SW = 01: 25 Hz
  // SW = 10: 1 kHz
  // SW = 11: 50 MHz, meaning tick every clock cycle

  always_comb begin
    unique case (SW)
      2'b00: tick = tick_1hz;
      2'b01: tick = tick_25hz;
      2'b10: tick = tick_1khz;
      2'b11: tick = 1'b1;
    endcase
  end

  //main time counter
  // increments seconds when tick is high,
  //and minutes and hours are handled
  //by the hms_counter internally
  hms_counter u_hms (
      .clk(CLOCK_50),
      .enable(tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // BCD DIGIT

  logic [3:0] hours_tens;
  logic [3:0] hours_ones;
  logic [3:0] minutes_tens;
  logic [3:0] minutes_ones;
  logic [3:0] seconds_tens;
  logic [3:0] seconds_ones;

  // binary_to_bcd expects a 7-bits
  // hours is only 5 bits
  // extend with 2 leading zeros using concatenation
  binary_to_bcd u_bcd_hours (
      .bin ({2'b00, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );
  // same with minutes, but it is 6 bits
  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );
  // seconds are the same as minutes
  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  // hex 5 and 4 are hrs, 3 and 2 are min and 1 and 0 are seconds
  // de1-soc sseg are active low
  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex5 (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex4 (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex3 (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex2 (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex1 (
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) u_hex0 (
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );
  // blank is set to 0 so that the values are shown, instead of making teh display blank
endmodule

