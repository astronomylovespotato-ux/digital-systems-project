`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);


  //stores previous value of sig_in
  logic sig_prev = 1'b0;

  //rising edge occurs when input is high but previously was low
  assign rise = sig_in && !sig_prev;

  //update previous input on each clock edge
  always_ff @(posedge clk) begin
    sig_prev <= sig_in;
  end
endmodule
