`timescale 1ns / 1ps

module stopwatch
(
  input  logic       clk,
  input  logic       rst,
  input  logic       en,
  output logic [3:0] d7, d6, d5, d4, d3, d2, d1, d0
);

  // declaration
  localparam  DVSR = 10 ** 6; // can change to 10 ** 2 to speed up sim
  logic [19:0] cs_reg, cs_next; 
  logic [3:0] d7_reg, d6_reg, d5_reg, d4_reg, d3_reg, d2_reg, d1_reg, d0_reg;
  logic [3:0] d7_next, d6_next, d5_next, d4_next, d3_next, d2_next, d1_next, d0_next;
  logic cs_tick; // centisecond tick

  // register
  always_ff @(posedge clk)
  begin
    cs_reg <= cs_next;
    d7_reg <= d7_next;
    d6_reg <= d6_next;
    d5_reg <= d5_next;
    d4_reg <= d4_next;
    d3_reg <= d3_next;
    d2_reg <= d2_next;
    d1_reg <= d1_next;
    d0_reg <= d0_next;
  end

  // next-state logic
  // 0.01 sec tick generator: mod-1M
  assign cs_next = (rst || (cs_reg == DVSR && en)) ? 20'b0 :
                    (en) ? cs_reg + 1 :
                    cs_reg;

  assign cs_tick = (cs_reg == DVSR) ? 1'b1 : 1'b0;

  // 8-digit BCD counter
  always_comb begin
    d7_next = d7_reg;
    d6_next = d6_reg;
    d5_next = d5_reg;
    d4_next = d4_reg;
    d3_next = d3_reg;
    d2_next = d2_reg;
    d1_next = d1_reg;
    d0_next = d0_reg;

    // reset
    if (rst) begin
      d7_next = 4'd0;
      d6_next = 4'd0;
      d5_next = 4'd0;
      d4_next = 4'd0;
      d3_next = 4'd0;
      d2_next = 4'd0;
      d1_next = 4'd0;
      d0_next = 4'd0;
    end

    // counting digits
    else if (cs_tick) begin
      if (d0_reg != 4'd9) d0_next = d0_reg + 1;
      else begin // reach XXXXX9 (0.09s)
        d0_next = 4'd0;
        if (d1_reg != 4'd9) d1_next = d1_reg + 1;
        else begin // reach XXXX99 (0.9s)
          d1_next = 4'd0;
          if (d2_reg != 4'd9) d2_next = d2_reg + 1;
          else begin // reach XXX999 (9s)
            d2_next = 4'd0;
            if (d3_reg != 4'd5) d3_next = d3_reg + 1;
            else begin // reach XX5999 (59.9s)
              d3_next = 4'd0;
              if (d4_reg != 4'd9) d4_next = d4_reg + 1;
              else begin // reach X95999 (9:59.99)
                d4_next = 4'd0;
                if (d5_reg != 4'd5) d5_next = d5_reg + 1;
                else begin // reach 595999 (59:59.99)
                  d5_next = 4'd0;
                  if (d6_reg != 4'd9) d6_next = d6_reg + 1;
                  else begin // reach 9595999 (9:59:99.99)
                    d6_next = 4'd0;
                    if (d7_reg != 4'd9) d7_next = d7_reg + 1;
                    else d7_next = 4'd0; // reach 99595999 (99:59:99.99)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  // output logic
  assign d0 = d0_reg;
  assign d1 = d1_reg;
  assign d2 = d2_reg;
  assign d3 = d3_reg;
  assign d4 = d4_reg;
  assign d5 = d5_reg;
  assign d6 = d6_reg;
  assign d7 = d7_reg;

endmodule