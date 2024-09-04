`timescale 1ns / 1ps

module disp (
  input logic        clk, // 100 MHz clock
  input logic        rst, // reset
  input logic        en_in, // enable ticking/starts counting
  input logic        digit_inc_in, // increment selected digit when setting time
  input logic        digit_toggle_in, // change selected digit
  input logic [3:0]  w, // PWM brightness setting, integer values 0-15
  output logic [7:0] seg_out, // 7-seg pattern to illuminate
  output logic [7:0] an, // which 7-seg to illuminate
  output logic       times_up // led output to show timer reached 0
);

  // declaration
  logic [3:0] d7, d6, d5, d4, d3, d2, d1, d0; // current 7-seg pattern for each digit on display
  logic [19:0] counter_reg, counter_next; // 20-bit reg for time MUX display counting
  logic [3:0] dec_in; // current input into time MUX
  logic [7:0] seg; // pre-PWM 7-seg output

  // instantiation
  switch_debouncer sw_db (
    .clk,
    .rst,
    .sw_in (en_in),
    .sw_out (en)
  );

  button_debouncer bt_db0 (
    .clk,
    .rst,
    .bt_in (digit_toggle_in),
    .bt (digit_toggle)
  );

  button_debouncer bt_db1 (
    .clk,
    .rst,
    .bt_in (digit_inc_in),
    .bt (digit_inc)
  );

  timer timer_module (
    .clk,
    .rst,
    .en,
    .digit_toggle,
    .digit_inc,
    .times_up,
    .d7, .d6, .d5, .d4, .d3, .d2, .d1, .d0
  );

  PWM_dimmer dimmer (
    .clk,
    .w,
    .seg,
    .seg_out
  );

  // register
  always_ff @(posedge clk, posedge rst) begin
    if (rst) counter_reg <= 0;
    else if (counter_reg < 8 * 10 ** 5) counter_reg <= counter_next;
    else counter_reg <= 0;
  end
  
  // next state logic
  assign counter_next = counter_reg + 1;

  // display logic
  always_comb begin
    
    // time MUX
    if (counter_reg < 10 ** 5) begin
        an = 8'b11111110;
        dec_in = d0;
    end else if (counter_reg < 2 * 10 ** 5) begin
        an = 8'b11111101;
        dec_in = d1;
    end else if (counter_reg < 3 * 10 ** 5) begin
        an = 8'b11111011;
        dec_in = d2;
    end else if (counter_reg < 4 * 10 ** 5) begin
        an = 8'b11110111;
        dec_in = d3;
    end else if (counter_reg < 5 * 10 ** 5) begin
        an = 8'b11101111;
        dec_in = d4;
    end else if (counter_reg < 6 * 10 ** 5) begin
        an = 8'b11011111;
        dec_in = d5;
    end else if (counter_reg < 7 * 10 ** 5) begin
        an = 8'b10111111;
        dec_in = d6;        
    end else begin
        an = 8'b01111111;
        dec_in = d7;
    end
    
    // BCD decoder
    case (dec_in)
      4'h0: seg[6:0] = 7'b1000000;
      4'h1: seg[6:0] = 7'b1111001;
      4'h2: seg[6:0] = 7'b0100100;
      4'h3: seg[6:0] = 7'b0110000;
      4'h4: seg[6:0] = 7'b0011001;
      4'h5: seg[6:0] = 7'b0010010;
      4'h6: seg[6:0] = 7'b0000010;
      4'h7: seg[6:0] = 7'b1111000;
      4'h8: seg[6:0] = 7'b0000000;
      4'h9: seg[6:0] = 7'b0010000;
      default: seg[6:0] = 7'b1111111;
    endcase

    // decimal points
    case (an)
      8'b10111111 : seg[7] = 0;
      8'b11101111 : seg[7] = 0;
      default : seg[7] = 1;
    endcase
  end
endmodule