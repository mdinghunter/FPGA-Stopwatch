`timescale 1ns / 1ps

module stopwatch_tb ();

  // declaration
  logic       clk; 
  logic       clr; 
  logic       go;
  logic [3:0] d5, d4, d3, d2, d1, d0;

  // instatiation
  stopwatch dut (
    .clk,
    .clr,
    .go,
    .d5, .d4, .d3, .d2, .d1, .d0
  );

  // generate clk
  always #5 clk = ~clk;

  // test
  initial begin
  
    // normal operation
    clk = 0;
    clr = 0;
    go = 1;
    #10;

    clr = 1;
    #10;

    clr = 0;
    #(10 ** 9);

    // stop
    go = 0;
    #(10 ** 6);

    // resume
    go = 1;
    #(10 ** 6);
    
    // clear
    clr = 1;
    #10;
    clr = 0;
    #(10 ** 6);

    $finish;
  end
endmodule
