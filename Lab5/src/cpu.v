// This file contains library modules to be used in your design. 

`include "constants.h"
`timescale 1ns/1ps

module CPU (clk, reset);
    input clk, reset;

    output reg [31:0] PC;
    wire [31:0] instr;

    //Control signals
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Bne, Jump;
    
    //ALU wires
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    wire [31:0] ALUOut;
    wire Zero;
    wire [31:0] ALUInB;
    wire [31:0] signExtendedInstr;

    //Register file wires
    wire [4:0] wa;
    wire [31:0] rdA, rdB;
    wire [31:0] wd;

    //Memory wires
    wire [31:0] memOut;

    Memory IMem (1'b1, 1'b0, {2'b00, PC[31:2]}, 0, instr);
    ControlUnit CUnit(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Bne, ALUOp, Jump, instr[31:26]);
    ALUControl AControl(ALUControl, ALUOp, instr[5:0]);
    RegFile cpu_regs(clk, reset, instr[25:21], instr[20:16], wa, RegWrite, wd, rdA, rdB);
    ALU alu(ALUOut, Zero, rdA, ALUInB, ALUControl);
    Memory DMem(MemRead, MemWrite, ALUOut, rdB, memOut);

    always @(posedge clk, negedge reset) begin
        if(!reset)
            PC = 0;
        else if (Branch == 1'b1 && (Bne == 1'b1 && Zero == 1'b0 || Bne == 1'b0 && Zero == 1'b1))
            PC = PC + (signExtendedInstr << 2);
        else if (Jump == 1'b1)
            PC = {PC[31:28], instr[25:0], 2'b00};
        else
            PC = PC + 4;
		
    end

    assign wd = (MemtoReg == 1'b1) ? memOut : ALUOut;
    assign signExtendedInstr = { {16{instr[15]}}, instr[15:0] };
    assign ALUInB = (ALUSrc == 1'b1) ? signExtendedInstr : rdB;
    assign wa = (RegDst == 1'b1) ? instr[15:11] : instr[20:16];
endmodule