`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  logic unused_buttons;
  assign unused_buttons = |button[3:2];

  logic rise_start_stop;
  logic rise_lap;

  logic counter_rst;
  logic counter_enable;
  logic lap_hold;

  logic [6:0] raw_minutes;
  logic [5:0] raw_seconds;
  logic [6:0] raw_centiseconds;

  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_lap_edge (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(raw_minutes),
      .seconds(raw_seconds),
      .centiseconds(raw_centiseconds)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_minutes_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(raw_minutes),
      .q(hours_disp)
  );

  snapshot_mux #(
      .WIDTH(6)
  ) u_seconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(raw_seconds),
      .q(minutes_disp[5:0])
  );

  assign minutes_disp[6] = 1'b0;

  snapshot_mux #(
      .WIDTH(7)
  ) u_centiseconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(raw_centiseconds),
      .q(seconds_disp)
  );

  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

  assign led = 10'b0;

  /* verilator lint_off UNUSED */
  logic [9:0] unused_sw;
  assign unused_sw = sw;
  /* verilator lint_on UNUSED */

endmodule
