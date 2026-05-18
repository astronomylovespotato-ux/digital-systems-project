`timescale 1ns / 1ps

module user_top_runner_game_v1 #(
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

  logic move_left;
  logic move_right;
  logic rst_game;

  // Controls:
  // button[0] = move left
  // button[1] = move right
  // button[2] = reset game
  assign rst_game = button[2];

  rising_edge_detector u_left_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(move_left)
  );

  rising_edge_detector u_right_edge (
      .clk(clk),
      .sig_in(button[1]),
      .rise(move_right)
  );

  logic [1:0] player_lane;

  logic [2:0] obstacle_5;
  logic [2:0] obstacle_4;
  logic [2:0] obstacle_3;
  logic [2:0] obstacle_2;
  logic [2:0] obstacle_1;
  logic [2:0] obstacle_0;

  logic game_over;

  runner_game_core #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_core (
      .clk(clk),
      .rst(rst_game),
      .move_left(move_left),
      .move_right(move_right),
      .player_lane(player_lane),
      .obstacle_5(obstacle_5),
      .obstacle_4(obstacle_4),
      .obstacle_3(obstacle_3),
      .obstacle_2(obstacle_2),
      .obstacle_1(obstacle_1),
      .obstacle_0(obstacle_0),
      .game_over(game_over)
  );

  logic [6:0] game_hours_disp;
  logic [6:0] game_minutes_disp;
  logic [6:0] game_seconds_disp;

  runner_game_display u_display (
      .player_lane(player_lane),
      .obstacle_5(obstacle_5),
      .obstacle_4(obstacle_4),
      .obstacle_3(obstacle_3),
      .obstacle_2(obstacle_2),
      .obstacle_1(obstacle_1),
      .obstacle_0(obstacle_0),
      .game_over(1'b0),
      .hours_disp(game_hours_disp),
      .minutes_disp(game_minutes_disp),
      .seconds_disp(game_seconds_disp)
  );

  // Flash all LEDs and seven-segment outputs after collision.
  localparam int FlashCycles = CYCLES_PER_SECOND / 2;
  localparam int FlashWidth = $clog2(FlashCycles + 1);

  logic [FlashWidth-1:0] flash_count = '0;
  logic flash_on = 1'b0;

  always_ff @(posedge clk) begin
    if (!game_over || rst_game) begin
      flash_count <= '0;
      flash_on <= 1'b0;
    end else if (flash_count == FlashWidth'(FlashCycles - 1)) begin
      flash_count <= '0;
      flash_on <= ~flash_on;
    end else begin
      flash_count <= flash_count + FlashWidth'(1);
    end
  end

  assign hours_disp = game_over ? {7{flash_on}} : game_hours_disp;
  assign minutes_disp = game_over ? {7{flash_on}} : game_minutes_disp;
  assign seconds_disp = game_over ? {7{flash_on}} : game_seconds_disp;

  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

  assign led = game_over ? {10{flash_on}} : {8'b0, player_lane};

  logic unused_button;
  assign unused_button = button[3];

  logic unused_switches;
  assign unused_switches = |sw;

endmodule
