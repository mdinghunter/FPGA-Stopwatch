`timescale 1ns / 1ps

module switch_debouncer (
  input logic  clk,
  input logic  rst,
  input logic  sw_in,
  output logic sw_out
);
  // declaration
  localparam DVSR = 10 ** 6; // 10 ms

  typedef enum logic [1:0] {
    zero, one, one_wait, one_wait_2
  } state_type;
  state_type state_reg, state_next;
  
  logic [19:0] sw_reg;
  logic [19:0] sw_next;
  logic tick;

  // switch state reg
  always_ff @(posedge clk, posedge rst) begin
    if (rst) sw_reg <= 20'b0;
    else sw_reg <= sw_next;
  end
  
  // switch next state logic
  assign sw_next = (sw_reg == DVSR) ? 20'b0 : sw_reg + 1;
  assign tick = (sw_reg == DVSR - 1) ? 1'b1 : 1'b0;

  // FSM state reg
  always_ff @(posedge clk, posedge rst) begin
    if (rst) state_reg <= zero;
    else state_reg <= state_next;
  end

  // FSM logic
  always_comb begin
    case (state_reg)
      zero : begin
        sw_out = 1'b0;
        state_next = sw_in ? one : zero;
      end
      one : begin
        sw_out = 1'b1;
        state_next = tick ? one_wait : one;
      end
      one_wait : begin
        sw_out = 1'b1;
        state_next = tick ? one_wait_2 : one_wait;
      end
      one_wait_2 : begin
        sw_out = 1'b1;
        state_next = sw_in ? one : zero;
      end
    endcase
  end
endmodule


