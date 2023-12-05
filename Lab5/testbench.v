// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "constants.h"
`timescale 1ns/1ps

module cpu_tb;
integer   i;
reg       clock, reset;    // Clock and reset signals

// Instantiate CPU here with name cpu0
CPU cpu0(clock, reset);

// Initialization and signal generation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Generate clock and reset signal here

// Initialize Register File with initial values. 
// cpu0 is the name of the cpu instance
// cpu_regs is the name of the register file instance in the CPU verilog file 
// data[] is the register file array 
initial begin
  $dumpvars(0, cpu0);
  $dumpfile("cpu_tb.vcd");
  $display("Starting simulation");
  $monitor("Time %0d: PC = %0h, Instr = %0h, RegDst = %0b, ALUSrc = %0b, MemtoReg = %0b, RegWrite = %0b, MemRead = %0b, MemWrite = %0b, Branch = %0b, ALUOp = %0b, Jump = %0b, ALUControl = %0h, ALUOut = %0h, Zero = %0b, ALUInB = %0h, signExtendedInstr = %0h, wa = %0h, rdA = %0h, rdB = %0h, wd = %0h, memOut = %0h", $time, cpu0.PC, cpu0.instr, cpu0.RegDst, cpu0.ALUSrc, cpu0.MemtoReg, cpu0.RegWrite, cpu0.MemRead, cpu0.MemWrite, cpu0.Branch, cpu0.ALUOp, cpu0.Jump, cpu0.ALUControl, cpu0.ALUOut, cpu0.Zero, cpu0.ALUInB, cpu0.signExtendedInstr, cpu0.wa, cpu0.rdA, cpu0.rdB, cpu0.wd, cpu0.memOut);
  $readmemh("program.hex", cpu0.IMem.data);
  
  clock = 0;
  reset = 0;
  #(4 * `clock_period) reset = 1;

  for (i = 0; i < 32; i = i+1)
    cpu0.cpu_regs.data[i] = i;   // Note that R0 = 0 in MIPS 

  // Initialize Instruction Memory. You have to develop "program.hex" as a text file 
  // which containsthe instruction opcodes as 32-bit hexadecimal values.

  #(100*`clock_period) $finish;
end 

// Clock signals
always begin
  #(`clock_period/2) clock = ~clock;
end

endmodule
