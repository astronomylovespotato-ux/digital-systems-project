`timescale 1ns / 1ps

module runner_game_lfsr (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [2:0] random_bits
);

  logic [7:0] lfsr = 8'hA5;

  always_ff @(posedge clk) begin
    if (rst) begin
      lfsr <= 8'hA5;
    end else if (enable) begin
      lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
    end
  end

  assign random_bits = lfsr[2:0];

endmodule
