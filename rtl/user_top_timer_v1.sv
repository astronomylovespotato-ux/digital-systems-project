`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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

  localparam int HoldCycles = CYCLES_PER_SECOND;
  localparam int RepeatCycles = CYCLES_PER_SECOND / 10;
  localparam int FlashPeriodCycles = CYCLES_PER_SECOND / 2;
  localparam int FlashDutyCycles = (FlashPeriodCycles * 4) / 5;
  localparam int HoldWidth = $clog2(HoldCycles);

  logic rise_start_stop;
  logic rise_edit;
  logic inc_pulse;
  logic dec_pulse;

  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_edit_edge (
      .clk(clk),
      .sig_in(button[3]),
      .rise(rise_edit)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(RepeatCycles)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(RepeatCycles)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  logic [2:0] selector_mode_enable;

  edit_mode_selector #(
      .HOLD_CYCLES(HoldCycles)
  ) u_edit_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(selector_mode_enable)
  );

  logic [2:0] mode_enable = 3'b000;

  logic [$clog2(HoldCycles + 1)-1:0] edit_hold_count = '0;
  logic edit_hold_done = 1'b0;
  logic enter_edit;

  always_ff @(posedge clk) begin
    if (!button[3]) begin
      edit_hold_count <= '0;
      edit_hold_done  <= 1'b0;
    end else if (!edit_hold_done) begin
      if (edit_hold_count == HoldWidth'(HoldCycles - 1)) begin
        edit_hold_done <= 1'b1;
      end else begin
        edit_hold_count <= edit_hold_count + 1'b1;
      end
    end
  end

  assign enter_edit = button[3] && !edit_hold_done && (edit_hold_count == HoldWidth'(HoldCycles - 1));

  logic running = 1'b0;
  logic is_zero;

  always_ff @(posedge clk) begin
    if ((mode_enable != 3'b000) &&
        (mode_enable != 3'b001) &&
        (mode_enable != 3'b010) &&
        (mode_enable != 3'b100)) begin
      mode_enable <= 3'b000;
    end else if (running) begin
      mode_enable <= 3'b000;
    end else if (mode_enable == 3'b000) begin
      if (enter_edit) begin
        mode_enable <= 3'b001;
      end
    end else if (rise_edit) begin
      case (mode_enable)
        3'b001:  mode_enable <= 3'b010;
        3'b010:  mode_enable <= 3'b100;
        3'b100:  mode_enable <= 3'b000;
        default: mode_enable <= 3'b000;
      endcase
    end
  end

  logic edit_seconds;
  logic edit_minutes;
  logic edit_hours;
  logic edit_mode;

  assign edit_seconds = (mode_enable == 3'b001);
  assign edit_minutes = (mode_enable == 3'b010);
  assign edit_hours = (mode_enable == 3'b100);
  assign edit_mode = edit_seconds || edit_minutes || edit_hours;

  always_ff @(posedge clk) begin
    if (edit_mode || enter_edit) begin
      running <= 1'b0;
    end else if (is_zero) begin
      running <= 1'b0;
    end else if (rise_start_stop) begin
      running <= !running;
    end
  end

  logic one_second_tick;
  logic timer_tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_one_second_tick (
      .clk (clk),
      .run (running && !edit_mode && !is_zero),
      .tick(one_second_tick)
  );

  assign timer_tick = running && !edit_mode && !is_zero && one_second_tick;

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic seconds_borrow;
  logic minutes_borrow;
  logic hours_borrow;

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(timer_tick),
      .edit_mode(edit_seconds),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(seconds_borrow),
      .edit_mode(edit_minutes),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(minutes_borrow),
      .edit_mode(edit_hours),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(hours),
      .borrow_out(hours_borrow)
  );

  assign is_zero = (hours == 5'd0) && (minutes == 6'd0) && (seconds == 6'd0);

  logic flash_on;

  pwm_generator #(
      .PERIOD_CYCLES(FlashPeriodCycles),
      .DUTY_CYCLES  (FlashDutyCycles)
  ) u_flash (
      .clk(clk),
      .rst(!edit_mode),
      .pwm_out(flash_on)
  );

  assign blank_seconds = edit_seconds && flash_on;
  assign blank_minutes = edit_minutes && flash_on;
  assign blank_hours = edit_hours && flash_on;

  assign hours_disp = {2'b00, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign led = sw;

  /* verilator lint_off UNUSED */
  logic unused_button_2;
  logic unused_hours_borrow;
  logic [2:0] unused_selector_mode_enable;

  assign unused_button_2 = button[2];
  assign unused_hours_borrow = hours_borrow;
  assign unused_selector_mode_enable = selector_mode_enable;
  /* verilator lint_on UNUSED */

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
