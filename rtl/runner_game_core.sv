`timescale 1ns / 1ps

module runner_game_core #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic move_left,
    input logic move_right,
    output logic [1:0] player_lane,
    output logic [2:0] obstacle_5,
    output logic [2:0] obstacle_4,
    output logic [2:0] obstacle_3,
    output logic [2:0] obstacle_2,
    output logic [2:0] obstacle_1,
    output logic [2:0] obstacle_0,
    output logic game_over
);

  // Obstacles advance every 0.5 seconds.
  // With a 50 MHz board clock, this is 25,000,000 cycles.
  localparam int TickCycles = CYCLES_PER_SECOND / 2;
  localparam int TickWidth = $clog2(TickCycles + 1);

  logic [TickWidth-1:0] tick_count = '0;
  logic game_tick;

  assign game_tick = tick_count == TickWidth'(TickCycles - 1);

  always_ff @(posedge clk) begin
    if (rst || game_tick) begin
      tick_count <= '0;
    end else begin
      tick_count <= tick_count + TickWidth'(1);
    end
  end

  logic [2:0] random_bits;

  runner_game_lfsr u_lfsr (
      .clk(clk),
      .rst(rst),
      .enable(game_tick && !game_over),
      .random_bits(random_bits)
  );

  logic [2:0] random_spawn_select;
  logic [2:0] new_obstacle;

  assign random_spawn_select = random_bits[2:0];

  // Easier spawn rate:
  // 3/8 chance of an obstacle, 5/8 chance of a gap.
  always_comb begin
    case (random_spawn_select)
      3'd0: new_obstacle = 3'b001;  // left lane
      3'd1: new_obstacle = 3'b010;  // middle lane
      3'd2: new_obstacle = 3'b100;  // right lane
      default: new_obstacle = 3'b000;  // no obstacle
    endcase
  end

  logic [1:0] next_player_lane;

  always_comb begin
    next_player_lane = player_lane;

    if (move_left && player_lane != 2'd0) begin
      next_player_lane = player_lane - 2'd1;
    end else if (move_right && player_lane != 2'd2) begin
      next_player_lane = player_lane + 2'd1;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      player_lane <= 2'd1;

      obstacle_5  <= 3'b000;
      obstacle_4  <= 3'b000;
      obstacle_3  <= 3'b000;
      obstacle_2  <= 3'b000;
      obstacle_1  <= 3'b000;
      obstacle_0  <= 3'b000;

      game_over   <= 1'b0;
    end else if (!game_over) begin
      if (move_left || move_right) begin
        player_lane <= next_player_lane;
      end

      if (game_tick) begin
        obstacle_0 <= obstacle_1;
        obstacle_1 <= obstacle_2;
        obstacle_2 <= obstacle_3;
        obstacle_3 <= obstacle_4;
        obstacle_4 <= obstacle_5;
        obstacle_5 <= new_obstacle;

        if (obstacle_1[next_player_lane]) begin
          game_over <= 1'b1;
        end
      end
    end
  end

endmodule
