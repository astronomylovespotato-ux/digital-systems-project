`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = 1'b0,
    output logic counter_enable = 1'b0,
    output logic lap_hold = 1'b0
);

  logic valid_start_stop;
  logic valid_lap;

  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  assign valid_start_stop = rise_start_stop && !rise_lap;
  assign valid_lap = rise_lap && !rise_start_stop;

  assign next_counter_enable = valid_start_stop ? !counter_enable : counter_enable;

  assign next_counter_rst = valid_lap && !counter_enable && !lap_hold;

  always_comb begin
    next_lap_hold = lap_hold;

    if (counter_rst) begin
      next_lap_hold = 1'b0;
    end else if (valid_lap) begin
      if (counter_enable) begin
        next_lap_hold = !lap_hold;
      end else begin
        next_lap_hold = 1'b0;
      end
    end
  end

  always_ff @(posedge clk) begin
    counter_rst <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold <= next_lap_hold;
  end

endmodule
