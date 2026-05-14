
`timescale 1ns / 1ps

module user_top_watch_v2 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,

    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,

    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds


);
  //
  // core Functionality
  //

  // seconds
  logic [5:0] seconds;
  logic [5:0] minutes;
  logic [4:0] hours;

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  //minutes

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );


  //hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;

  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // 1hz tick from clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  //minutes increment when seconds rollover from 59 to 0
  assign minutes_tick = seconds_tick && (seconds == 6'd59);

  //hours increment when minutes rollover from 59 to 0
  assign hours_tick = minutes_tick && (minutes == 6'd59);




  // zero extended outputs
  assign hours_disp = {2'b00, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // unused outputs
  assign led = 10'b0;
  assign seconds_edit = 1'b0;
  assign minutes_edit = 1'b0;
  assign hours_edit = 1'b0;

  assign seconds_inc = 1'b0;
  assign minutes_inc = 1'b0;
  assign hours_inc = 1'b0;

  assign seconds_dec = 1'b0;
  assign minutes_dec = 1'b0;
  assign hours_dec = 1'b0;


  // mode selection
  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND - 1)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  //had problems with the pwm not reseting so it is starting at an unknown state
  logic pwm_rst;
  logic pwm_out;
  // this reset occurs during the first cycle in order to initialise the PWM counter
  initial pwm_rst = 1'b1;
  always_ff @(posedge clk) pwm_rst <= 1'b0;

  localparam int FlashPeriod = CYCLES_PER_SECOND / 2;
  localparam int FlashDuty = CYCLES_PER_SECOND / 2 - CYCLES_PER_SECOND / 10;


  pwm_generator #(
      .PERIOD_CYCLES(FlashPeriod),
      .DUTY_CYCLES  (FlashDuty)
  ) u_flash_pwm (
      .clk    (clk),
      .rst    (pwm_rst),
      .pwm_out(pwm_out)
  );
  assign blank_seconds = mode_enable[0] && !pwm_out;
  assign blank_minutes = mode_enable[1] && !pwm_out;
  assign blank_hours   = mode_enable[2] && !pwm_out;


endmodule
