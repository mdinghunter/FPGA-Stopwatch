`timescale 1ns / 1ps

module timer (
  input logic        clk,
  input logic        rst,
  input logic        en, // enable ticking/starts counting
  input logic        digit_inc, // increment selected digit when setting time
  input logic        digit_toggle, // change selected digit
  output logic       times_up, // led output to show timer reached 0
  output logic [3:0] d7, d6, d5, d4, d3, d2, d1, d0 // current 7-seg pattern for each digit on display
);

  // declaration
  typedef enum logic {
    zero, one
  } state_type;
  state_type toggle_state_reg, toggle_state_next, inc_state_reg, inc_state_next;

  typedef enum logic [1:0] {
    set, run, finish
  } timer_state_type;
  timer_state_type timer_state_reg, timer_state_next;

  localparam DVSR = 10 ** 8; // 1s
  logic [26:0] second_reg, second_next;
  logic [3:0] d7_reg, d6_reg, d5_reg, d4_reg, d3_reg, d2_reg;
  logic [3:0] d7_next, d6_next, d5_next, d4_next, d3_next, d2_next;
  logic [2:0] digit_reg, digit_next;
  logic toggle_plus_one, inc_plus_one;
  logic tick;

    // register
  always_ff @(posedge clk) begin
    second_reg <= second_next;
    d2_reg <= d2_next;
    d3_reg <= d3_next;
    d4_reg <= d4_next;
    d5_reg <= d5_next;
    d6_reg <= d6_next;
    d7_reg <= d7_next;
    digit_reg <= digit_next;
  end

  // next-state logic
  // 1 sec tick generator: mod-100M
  assign second_next = (rst || (second_reg == DVSR && en)) ? 27'b0 :
                   (en) ? second_reg + 1 :
                   second_reg;
  assign tick = (second_reg == DVSR) ? 1'b1 : 1'b0;

  // FSM state reg
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      toggle_state_reg <= zero;
      inc_state_reg <= zero;
      timer_state_reg <= set;
    end
    else begin
      toggle_state_reg <= toggle_state_next;
      inc_state_reg <= inc_state_next;
      timer_state_reg <= timer_state_next;
    end
  end

  // posedge detection FSM for digit_toggle and digit_inc
  always_comb begin
    // defaults
    toggle_state_next = toggle_state_reg;
    toggle_plus_one = 1'b0;
    inc_plus_one = 1'b0;
    inc_state_next = inc_state_reg;
    
    case (toggle_state_reg)
      zero : begin
        if (digit_toggle) begin
          toggle_plus_one = 1'b1;
          toggle_state_next = one;
        end
      end
      one : begin
        if (~digit_toggle) toggle_state_next = zero;
      end
    endcase
    case (inc_state_reg)
      zero : begin
        if (digit_inc) begin
          inc_plus_one = 1'b1;
          inc_state_next = one;
        end
      end
      one : begin
        if (~digit_inc) inc_state_next = zero;
      end
    endcase
  end

  always_comb begin
    // defaults
    timer_state_next = timer_state_reg;
    digit_next = digit_reg;
    d2_next = d2_reg;
    d3_next = d3_reg;
    d4_next = d4_reg;
    d5_next = d5_reg;
    d6_next = d6_reg;
    d7_next = d7_reg;
    times_up = 1'b0;

    // toggle digit selected
    if (toggle_plus_one) begin
      if (digit_reg == 7) digit_next = 3'd2;
      else digit_next = digit_reg + 1;
    end

    // reset
    if (rst) begin
      timer_state_next = set;
      digit_next = 3'd2;
      d2_next = 4'd0;
      d3_next = 4'd0;
      d4_next = 4'd0;
      d5_next = 4'd0;
      d6_next = 4'd0;
      d7_next = 4'd0;
      times_up = 1'b0;
    end

    case (timer_state_reg)
      set : begin
        // digit select and increment
        case (digit_reg)
          4'd2 : begin
            if (inc_plus_one) begin
              if (d2_reg == 4'd9) d2_next = 0;
              else d2_next = d2_reg + 1;
            end
          end
          4'd3 : begin
            if (inc_plus_one) begin
              if (d3_reg == 4'd5) d3_next = 0;
              else d3_next = d3_reg + 1;
            end
          end
          4'd4 : begin
            if (inc_plus_one) begin
              if (d4_reg == 4'd9) d4_next = 0;
              else d4_next = d4_reg + 1;
            end
          end
          4'd5 : begin
            if (inc_plus_one) begin
              if (d5_reg == 4'd5) d5_next = 0;
              else d5_next = d5_reg + 1;
            end
          end
          4'd6 : begin
            if (inc_plus_one) begin
              if (d6_reg == 4'd9) d6_next = 0;
              else d6_next = d6_reg + 1;
            end
          end
          4'd7 : begin
            if (inc_plus_one) begin
              if (d7_reg == 4'd9) d7_next = 0;
              else d7_next = d7_reg + 1;
            end
          end
          default : begin
            if (inc_plus_one) begin
              if (d2_reg == 4'd9) d2_next = 0;
              else d2_next = d2_reg + 1;
            end
          end
        endcase
        if (en) timer_state_next = run;
      end
      // timer ticking down
      run : begin
        if (tick) begin
          if (d2_reg != 4'd0) d2_next = d2_reg - 1;
          else begin
            d2_next = 4'd9;
            if (d3_reg != 4'd0) d3_next = d3_reg - 1;
            else begin
              d3_next = 4'd5;
              if (d4_reg != 4'd0) d4_next = d4_reg - 1;
              else begin
                d4_next = 4'd9;
                if (d5_reg != 4'd0) d5_next = d5_reg - 1;
                else begin
                  d5_next = 4'd5;
                  if (d6_reg != 4'd0) d6_next = d6_reg - 1;
                  else begin
                    d6_next = 4'd9;
                    if (d7_reg != 4'd0) d7_next = d7_reg - 1;
                  end
                end
              end
            end
          end
        end
        if (d2_reg == 0 && d3_reg == 0 && d4_reg == 0 && 
            d5_reg == 0 && d6_reg == 0 && d7_reg == 0)
          timer_state_next = finish;
        else timer_state_next = run;
      end
      // timer hitting 0
      finish : begin
        times_up = 1'b1;
      end
    endcase
  end

  // output logic
  assign d0 = 4'd10; // invalid value to trigger default case of BCD decoder
  assign d1 = 4'd10; // invalid value to trigger default case of BCD decoder
  assign d2 = d2_reg;
  assign d3 = d3_reg;
  assign d4 = d4_reg;
  assign d5 = d5_reg;
  assign d6 = d6_reg;
  assign d7 = d7_reg;

endmodule

