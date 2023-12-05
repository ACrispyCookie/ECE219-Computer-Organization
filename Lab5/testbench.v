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
