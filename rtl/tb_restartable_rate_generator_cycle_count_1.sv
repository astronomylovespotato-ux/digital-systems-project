`timescale 1ns / 1ps

module tb_restartable_rate_generator_cycle_count_1;

  logic clk;
  logic run;
  logic tick;

  // CYCLE_COUNT = 1 means tick should occur every clock cycle while run = 1.
  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  // 10 ns clock period
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    // Start disabled
    run = 1'b0;

    // Let a few clock cycles pass
    repeat (3) @(posedge clk);

    // While run = 0, tick should be low
    if (tick !== 1'b0) begin
      $display("FAIL: tick should be 0 when run is 0");
      $finish;
    end

    // Enable the rate generator
    run = 1'b1;

    // With CYCLE_COUNT = 1, tick should be high every cycle
    repeat (10) begin
      @(posedge clk);

      if (tick !== 1'b1) begin
        $display("FAIL: tick should be 1 every cycle when CYCLE_COUNT = 1 and run = 1");
        $finish;
      end
    end

    // Disable again
    run = 1'b0;
    @(posedge clk);

    if (tick !== 1'b0) begin
      $display("FAIL: tick should return to 0 when run is 0");
      $finish;
    end

    $display("PASS: restartable_rate_generator works correctly when CYCLE_COUNT = 1");
    $finish;
  end

endmodule
