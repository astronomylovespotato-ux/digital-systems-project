`timescale 1ns / 1ps
module hms_counter #(  // maximum values
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // minutes
    parameter int N_SECONDS = 60,  // numiber of N_SECONDS

    //output widths
    parameter int W_HOURS   = 24,
    parameter int W_MINUTES = 60,
    parameter int W_SECONDS = 60
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  // turns constants to correct bit width
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  //signals that detect when the counters wrap
  logic second_rollover;
  logic minute_rollover;


  // rollover logic
  assign second_rollover = enable && (seconds == MaxSeconds);
  // enable is high, seconds have reached their ax value


  assign minute_rollover = second_rollover && (minutes == MaxMinutes);
  // seconds roll over, and minutes are at max value

  //second counter, counts every clock when enable is high
  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),  // global tick
      .up(1'b1),  // always counting up
      .count(seconds)
  );

  //minute counter, increments when seconds wrap
  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up(1'b1),
      .count(minutes)
  );

  //Hour counter
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),  // triggered by min rollover
      .up(1'b1),
      .count(hours)

  );

endmodule
