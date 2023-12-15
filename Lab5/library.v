// This file contains library modules to be used in your design.
`include "constants.h"
`timescale 1ns/1ps

// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
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

    zero = (out == 0) ? 1 : 0;
  end
endmodule

// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, wen, addr, din, dout);
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;

  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;  
  
  always @(din or wen or ren or addr)
   begin
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] = din;
   end
endmodule

/*module InstructionMemory (addr, data);
  input [31:0] addr;
  output wire [31:0] data;
  reg [31:0] mem[1023:0];

  assign data = mem[addr[9:0]];
endmodule*/

// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock, reset, wen;
  input [4:0] raA, raB, wa;
  input [31:0] wd;
  output wire [31:0] rdA, rdB;
  output reg [31:0] data[31:0];
  integer i;

  always @(negedge clock, negedge reset) begin
    if (reset) begin
      if (wen && wa != 0) data[wa] <= wd;
    end
    else begin
      for (i = 0; i < 32; i = i + 1)
        data[i] <= 0;
    end
  end

  assign rdA = data[raA];
  assign rdB = data[raB];
endmodule

// Module to control the data path. 
//                          Input: opcode of the instruction
//                          Output: all the control signals needed 
module ControlUnit(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Bne, ALUOp, Jump, opcode);
  input [5:0] opcode;
  output reg RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Bne, Jump;
  output reg [1:0] ALUOp;
  
  always @* begin
    case (opcode)
      6'h00: begin // R-type
        RegDst = 1'b1;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b1;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Bne = 1'b0;
        ALUOp = 2'b10;
        Jump = 1'b0;
      end
      6'h23: begin // lw
        RegDst = 1'b0;
        ALUSrc = 1'b1;
        MemtoReg = 1'b1;
        RegWrite = 1'b1;
        MemRead = 1'b1;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Bne = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b0;
      end
      6'h2b: begin // sw
        RegDst = 1'b0;
        ALUSrc = 1'b1;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b1;
        Branch = 1'b0;
        Bne = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b0;
      end
      6'h8: begin // addi
        RegDst = 1'b0;
        ALUSrc = 1'b1;
        MemtoReg = 1'b0;
        RegWrite = 1'b1;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Bne = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b0;
      end
      6'h4: begin // beq
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b1;
        Bne = 1'b0;
        ALUOp = 2'b01;
        Jump = 1'b0;
      end
      6'h5: begin // bne
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b1;
        Bne = 1'b1;
        ALUOp = 2'b01;
        Jump = 1'b0;
      end
      6'h2: begin // jump
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Bne = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b1;
      end
    endcase
  end
endmodule

// Module to control the ALU. 
//                          Input: ALUop, func
//                          Output: ALUControl signal 
module ALUControl(ALUControl, ALUOp, func);
  input [1:0] ALUOp;
  input [5:0] func;
  output reg [3:0] ALUControl;

  always @* begin
    case (ALUOp)
      2'h0: ALUControl = 4'h2;
      2'h1: ALUControl = 4'h6;
      2'h2: begin
        case (func)
          6'h20: ALUControl = 4'h2;
          6'h22: ALUControl = 4'h6;
          6'h24: ALUControl = 4'h0;
          6'h25: ALUControl = 4'h1;
          6'h2a: ALUControl = 4'h7;
          default: ALUControl = 4'h0;
        endcase
      end
      default: ALUControl = 4'h0;
    endcase
  end
endmodule