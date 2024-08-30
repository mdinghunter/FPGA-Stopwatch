`timescale 1ns / 1ps

module PWM_dimmer (
  input clk,
  input logic [3:0] w,
  input logic [7:0] seg,
  output logic [7:0] seg_out
);
  
  // instantiation
  logic [17:0] pulse_counter = 0;

  // register
  always_ff @(posedge clk) begin
    if (pulse_counter < w * 10 ** 3) begin
      pulse_counter <= pulse_counter + 1;
      seg_out <= seg;
    end else if (pulse_counter < 15 * 10 ** 3) begin
      pulse_counter <= pulse_counter + 1;
      seg_out <= 8'b11111111;
    end else begin
      pulse_counter <= 0;
      seg_out <= 8'b11111111;
    end
  end
endmodule
