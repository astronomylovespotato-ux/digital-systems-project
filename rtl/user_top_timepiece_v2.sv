`timescale 1ns / 1ps

module user_top_timepiece_v2 #(
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

  typedef struct packed {
    logic [3:0] button;
    logic [9:0] sw;
  } ui_in_t;

  typedef struct packed {
    logic [9:0] led;
    logic [6:0] hours_disp;
    logic [6:0] minutes_disp;
    logic [6:0] seconds_disp;
    logic blank_hours;
    logic blank_minutes;
    logic blank_seconds;
  } ui_out_t;

  ui_in_t watch_in, timer_in, stopwatch_in, game_in;
  ui_out_t watch_out, timer_out, stopwatch_out, game_out;


  /* verilator lint_off WIDTHEXPAND */
  /* verilator lint_off UNUSEDSIGNAL */
  /* verilator lint_off UNUSEDPARAM */

  user_top_watch_v4 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_watch (
      .clk(clk),
      .button(watch_in.button),
      .sw(watch_in.sw),
      .led(watch_out.led),
      .hours_disp(watch_out.hours_disp),
      .minutes_disp(watch_out.minutes_disp),
      .seconds_disp(watch_out.seconds_disp),
      .blank_hours(watch_out.blank_hours),
      .blank_minutes(watch_out.blank_minutes),
      .blank_seconds(watch_out.blank_seconds)
  );

  user_top_timer_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_timer (
      .clk(clk),
      .button(timer_in.button),
      .sw(timer_in.sw),
      .led(timer_out.led),
      .hours_disp(timer_out.hours_disp),
      .minutes_disp(timer_out.minutes_disp),
      .seconds_disp(timer_out.seconds_disp),
      .blank_hours(timer_out.blank_hours),
      .blank_minutes(timer_out.blank_minutes),
      .blank_seconds(timer_out.blank_seconds)
  );

  user_top_stopwatch_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch (
      .clk(clk),
      .button(stopwatch_in.button),
      .sw(stopwatch_in.sw),
      .led(stopwatch_out.led),
      .hours_disp(stopwatch_out.hours_disp),
      .minutes_disp(stopwatch_out.minutes_disp),
      .seconds_disp(stopwatch_out.seconds_disp),
      .blank_hours(stopwatch_out.blank_hours),
      .blank_minutes(stopwatch_out.blank_minutes),
      .blank_seconds(stopwatch_out.blank_seconds)
  );

  user_top_runner_game_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_game (
      .clk(clk),
      .button(game_in.button),
      .sw(game_in.sw),
      .led(game_out.led),
      .hours_disp(game_out.hours_disp),
      .minutes_disp(game_out.minutes_disp),
      .seconds_disp(game_out.seconds_disp),
      .blank_hours(game_out.blank_hours),
      .blank_minutes(game_out.blank_minutes),
      .blank_seconds(game_out.blank_seconds)
  );

  /* verilator lint_on WIDTHEXPAND */
  /* verilator lint_on UNUSEDSIGNAL */
  /* verilator lint_on UNUSEDPARAM */

  // Multiplexers


  ui_in_t ui_top_in;
  assign ui_top_in.sw = sw;
  assign ui_top_in.button = button;

  ui_in_t ui_top_in_no_buttons;
  assign ui_top_in_no_buttons.sw = sw;
  assign ui_top_in_no_buttons.button = '0;

  ui_out_t ui_top_out;

  assign led = ui_top_out.led;
  assign hours_disp = ui_top_out.hours_disp;
  assign minutes_disp = ui_top_out.minutes_disp;
  assign seconds_disp = ui_top_out.seconds_disp;
  assign blank_hours = ui_top_out.blank_hours;
  assign blank_minutes = ui_top_out.blank_minutes;
  assign blank_seconds = ui_top_out.blank_seconds;

  logic [1:0] mode_sel;
  assign mode_sel = sw[1:0];

  always_comb begin
    watch_in = ui_top_in_no_buttons;
    timer_in = ui_top_in_no_buttons;
    stopwatch_in = ui_top_in_no_buttons;
    game_in = ui_top_in_no_buttons;

    case (mode_sel)
      2'b00: begin
        watch_in   = ui_top_in;
        ui_top_out = watch_out;
      end

      2'b01: begin
        stopwatch_in = ui_top_in;
        ui_top_out   = stopwatch_out;
      end

      2'b10: begin
        game_in = ui_top_in;
        ui_top_out = game_out;
      end

      2'b11: begin
        timer_in   = ui_top_in;
        ui_top_out = timer_out;
      end

      default: begin
        watch_in   = ui_top_in;
        ui_top_out = watch_out;
      end
    endcase
  end

endmodule
