`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync
);

  /* verilator lint_off UNUSEDSIGNAL */
  logic [3:0] key_pressed = 4'b0000;
  /* verilator lint_on UNUSEDSIGNAL */

  logic [3:0] key_stage_1 = 4'b0000;

  always_ff @(posedge clk) begin
    key_stage_1 <= ~key_n;
    key_sync <= key_stage_1;
  end
endmodule


