`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  // Ccounts from 0 to period_cycles -1
  localparam int CountWidth = $clog2(PERIOD_CYCLES);

  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  // if there is a 0 duty cycle, always low,
  // if 100% duty, always high
  // if high for the first duty cycle counts,
  // then then low for the rest of the period
  assign pwm_out = (DUTY_CYCLES == 0) ? 1'b0 :
  (DUTY_CYCLES >= PERIOD_CYCLES) ? 1'b1 :
  (count < CountWidth'(DUTY_CYCLES));

endmodule
