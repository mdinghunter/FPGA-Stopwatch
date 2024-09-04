`timescale 1ns / 1ps

module button_debouncer_tb ();

  logic clk;
  logic rst;
  logic bt_in;
  logic bt;

  button_debouncer dut (
    .clk,
    .rst,
    .bt_in,
    .bt
  );

  always #5 clk = ~clk;

  initial begin
    
    clk = 0;
    bt_in = 1;
    rst = 1;
    #10;
    rst = 0;
    #(3 * 10 ** 8); bt_in = 0;
    #(3 * 10 ** 8); bt_in = 1;
    
    // simulated bouncing
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(3 * 10 ** 8); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(10 ** 6); bt_in = 0;
    #(10 ** 6); bt_in = 1;
    #(3 * 10 ** 8);

    $finish;
  end

endmodule


