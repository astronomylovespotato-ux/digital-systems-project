`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  // tick_qualifier becomes high at the end of each count cycle.
  logic tick_qualifier;

  //makes it run depending on the stored state of run compared to it direct state
  logic running = 1'b0;

  always_ff @(posedge clk) begin
    running <= run;
  end

  //moore style
  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general

      //number of bits needed
      localparam int CountWidth = $clog2(CYCLE_COUNT);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      // Resets when run is low
      assign rst_count = !run;

      // count when run is high
      assign enable_count = run;

      // tick qualifier is high when counter is at its final value
      assign tick_qualifier = count == CountWidth'(CYCLE_COUNT - 1);

    end else begin : g_special

      assign tick_qualifier = 1'b1;

    end
  endgenerate

endmodule
