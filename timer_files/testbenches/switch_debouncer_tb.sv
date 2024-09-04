`timescale 1ns / 1ps

module switch_debouncer_tb ();

  logic clk;
  logic rst;
  logic sw_in;
  logic sw_out;

  switch_debouncer dut (
    .clk,
    .rst,
    .sw_in,
    .sw_out
  );

  always #5 clk = ~clk;

  initial begin
    
    clk = 0;
    sw_in = 1;
    rst = 1;
    #10;
    rst = 0;
    #(5 * 10 ** 7); sw_in = 0;
    
    // simulated switch bouncing
    #(5 * 10 ** 7); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(5 * 10 ** 7); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(10 ** 6); sw_in = 0;
    #(10 ** 6); sw_in = 1;
    #(5 * 10 ** 7);

    $finish;
  end

endmodule
