`timescale 1ns / 1ps

module button_debouncer (
  input logic clk,
  input logic rst,
  input logic bt_in,
  output logic bt
);
  // declaration
  localparam DVSR = 5 * 10 ** 6; // 50 ms

  typedef enum logic [1:0] {
    zero, one, one_wait, one_wait_2
  } state_type;
  state_type state_reg, state_next;

  logic [22:0] bt_reg;
  logic [22:0] bt_next;
  logic tick;

  // button state reg
  always_ff @(posedge clk, posedge rst) begin
    if (rst) bt_reg <= 23'b0;
    else bt_reg <= bt_next;
  end
  
  // button next state logic
  assign bt_next = (bt_reg == DVSR) ? 23'b0 : bt_reg + 1;
  assign tick = (bt_reg == DVSR - 1) ? 1 : 0;

  // FSM state reg
  always_ff @(posedge clk, posedge rst) begin
    if (rst) state_reg <= zero;
    else state_reg <= state_next;
  end

  // FSM
  always_comb begin
    case (state_reg)
      zero : begin
        bt = 0;
        state_next = bt_in ? one : zero;
      end
      one : begin
        bt = 1;
        state_next = one_wait;
      end
      one_wait : begin
        bt = 1;
        state_next = tick ? one_wait_2 : one_wait;
      end
      one_wait_2 : begin
        bt = 1;
        state_next = bt_in ? one : zero;
      end
      default : begin
        bt = 0;
        state_next = bt_in ? one : zero;
      end
    endcase
  end
endmodule
