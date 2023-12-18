`timescale 1ns/1ps

// ALU Module. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
  parameter N = 32;
  output reg [N-1:0] out;
  output reg zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;

  always @* begin
    case (op)
      4'h0: out = inA & inB;
      4'h1: out = inA | inB;
      4'h2: out = inA + inB;
      4'h6: out = inA - inB;
      4'h7: out = (inA < inB) ? 1 : 0;
      4'hc: out = ~(inA | inB);
    endcase

    if (out == 0) zero = 1;
    else zero = 0;
  end
endmodule

// Register File Module. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock, reset, wen;
  input [4:0] raA, raB, wa;
  input [31:0] wd;
  output reg [31:0] rdA, rdB;
  output reg [31:0] data[31:0];

  always @(negedge clock, reset) begin
    if (reset) begin
      if (wen) data[wa] = wd;
    end
    else begin
      for (i = 0; i < 32; i = i + 1)
        data[i] = i;
  end

  always @(data[raA], data[raB], raA, raB) begin
    rdA = data[raA];
    rdB = data[raB];
  end
endmodule