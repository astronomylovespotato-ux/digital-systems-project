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

  function automatic logic [3:0] obstacle_digit(input logic [2:0] obstacle);
    begin
      case (obstacle)
        3'b001:  obstacle_digit = 4'd1;  // left
        3'b010:  obstacle_digit = 4'd2;  // middle
        3'b100:  obstacle_digit = 4'd3;  // right
        default: obstacle_digit = 4'd0;  // no obstacle
      endcase
    end
  endfunction

  function automatic logic [3:0] player_digit(input logic [1:0] lane);
    begin
      case (lane)
        2'd0: player_digit = 4'd1;  // left
        2'd1: player_digit = 4'd2;  // middle
        2'd2: player_digit = 4'd3;  // right
        default: player_digit = 4'd0;
      endcase
    end
  endfunction

  always_comb begin
    if (game_over) begin
      hours_disp   = 7'd99;
      minutes_disp = 7'd99;
      seconds_disp = 7'd99;
    end else begin
      hours_disp   = 7'(obstacle_digit(obstacle_5) * 10 + obstacle_digit(obstacle_4));
      minutes_disp = 7'(obstacle_digit(obstacle_3) * 10 + obstacle_digit(obstacle_2));

      // Bottom display:
      // tens digit = closest obstacle row
      // ones digit = player lane
      seconds_disp = 7'(obstacle_digit(obstacle_1) * 10 + player_digit(player_lane));
    end
  end

  /* verilator lint_off UNUSED */
  logic [3:0] unused_obstacle_0;
  assign unused_obstacle_0 = obstacle_0;
  /* verilator lint_on UNUSED */

endmodule
