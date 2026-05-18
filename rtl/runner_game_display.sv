`timescale 1ns / 1ps

module runner_game_display (
    input logic [1:0] player_lane,
    input logic [2:0] obstacle_5,
    input logic [2:0] obstacle_4,
    input logic [2:0] obstacle_3,
    input logic [2:0] obstacle_2,
    input logic [2:0] obstacle_1,
    input logic [2:0] obstacle_0,
    input logic game_over,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp
);

  logic [6:0] hours_segments;
  logic [6:0] minutes_segments;
  logic [6:0] seconds_obstacle_segments;
  logic [6:0] player_segments;

  // Segment order: [6:0] = g, f, e, d, c, b, a.
  //
  // Each display represents two game sections:
  // upper section uses f/a/b
  // lower section uses e/d/c
  //
  // Lanes:
  // lane 0 = left
  // lane 1 = middle
  // lane 2 = right

  assign hours_segments = {
    1'b0, obstacle_5[0], obstacle_4[0], obstacle_4[1], obstacle_4[2], obstacle_5[2], obstacle_5[1]
  };

  assign minutes_segments = {
    1'b0, obstacle_3[0], obstacle_2[0], obstacle_2[1], obstacle_2[2], obstacle_3[2], obstacle_3[1]
  };

  assign seconds_obstacle_segments = {
    1'b0, obstacle_1[0], obstacle_0[0], obstacle_0[1], obstacle_0[2], obstacle_1[2], obstacle_1[1]
  };

  always_comb begin
    case (player_lane)
      2'd0: player_segments = 7'b1010000;  // left: f + e
      2'd1: player_segments = 7'b1001001;  // middle: g + d + a
      default: player_segments = 7'b0100100;  // right: b + c
    endcase
  end

  always_comb begin
    if (game_over) begin
      hours_disp   = 7'b1111111;
      minutes_disp = 7'b1111111;
      seconds_disp = 7'b1111111;
    end else begin
      hours_disp   = hours_segments;
      minutes_disp = minutes_segments;
      seconds_disp = seconds_obstacle_segments | player_segments;
    end
  end

endmodule
