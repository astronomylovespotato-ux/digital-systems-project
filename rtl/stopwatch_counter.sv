`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);


  logic centisecond_tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_rate (
      .clk (clk),
      .run (enable && !rst),
      .tick(centisecond_tick)
  );

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable && centisecond_tick),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
