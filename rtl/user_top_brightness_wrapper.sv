`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
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

  localparam int PwmCycles = CYCLES_PER_SECOND / 1000;
  localparam int PwmWidth = $clog2(PwmCycles);

  logic [PwmWidth-1:0] pwm_count;

  mod_n_counter #(
      .N(PwmCycles),
      .WIDTH(PwmWidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  logic [1:0] brightness_select;
  logic [PwmWidth-1:0] duty_cycles;
  logic full_brightness;
  logic pwm_blank;

  assign brightness_select = sw[9:8];
  assign full_brightness   = brightness_select == 2'b10;

  always_comb begin
    case (brightness_select)
      2'b00:   duty_cycles = PwmWidth'(PwmCycles / 8);  // 12.5%
      2'b01:   duty_cycles = PwmWidth'(PwmCycles / 4);  // 25%
      2'b11:   duty_cycles = PwmWidth'(PwmCycles / 2);  // 50%
      default: duty_cycles = '0;  // full handled separately
    endcase
  end

  assign pwm_blank = full_brightness ? 1'b0 : !(pwm_count < duty_cycles);

  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_app (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  assign blank_hours   = app_blank_hours || pwm_blank;
  assign blank_minutes = app_blank_minutes || pwm_blank;
  assign blank_seconds = app_blank_seconds || pwm_blank;

endmodule
