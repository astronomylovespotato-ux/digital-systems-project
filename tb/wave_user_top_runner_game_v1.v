`timescale 1ns / 1ps

module wave_user_top_runner_game_v1;

  reg clk = 1'b0;
  reg [3:0] button = 4'b0000;
  reg [9:0] sw = 10'b0000000000;

  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire blank_hours;
  wire blank_minutes;
  wire blank_seconds;

  always #5 clk = ~clk;

  user_top_runner_game_v1 #(
      .CYCLES_PER_SECOND(20)
  ) dut (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  initial begin
    $dumpfile("wave_user_top_runner_game_v1.vcd");
    $dumpvars(0, wave_user_top_runner_game_v1);

    // Initial reset
    button[2] = 1'b1;
    #30;
    button[2] = 1'b0;

    // Let the first game run for a while
    #100;

    // Move left: lane 1 -> lane 0
    button[0] = 1'b1;
    #20;
    button[0] = 1'b0;

    #180;

    // Move right: lane 0 -> lane 1
    button[1] = 1'b1;
    #20;
    button[1] = 1'b0;

    #180;

    // Move right again: lane 1 -> lane 2
    button[1] = 1'b1;
    #20;
    button[1] = 1'b0;

    // Keep running long enough to see collision/game_over
    #2000;

    // Reset after game_over to show restart behaviour
    button[2] = 1'b1;
    #40;
    button[2] = 1'b0;

    #200;

    // Move left again after restart
    button[0] = 1'b1;
    #20;
    button[0] = 1'b0;

    #300;

    // Move right after restart
    button[1] = 1'b1;
    #20;
    button[1] = 1'b0;

    // Let second run continue
    #3000;

    $finish;
  end

endmodule
