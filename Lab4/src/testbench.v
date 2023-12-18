// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`timescale 1ns/1ps
`define clock_period 10

module cpu_tb;
reg       clock, reset;    // Clock and reset signals
reg   [4:0] raA, raB, wa;
reg         wen;
reg   [3:0] ALUop;
wire   [31:0] wd;
wire  [31:0] rdA, rdB; 
wire         ALUZero; 
integer i;

// Instantiate regfile module
RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
ALU alu(wd, ALUZero, rdA, rdB, ALUop);

initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka
      
  // Initialize the module 
   $dumpfile("dumpfile.vcd");
   $dumpvars(0, cpu_tb);
   for (i = 0; i < 32; i = i + 1)
      $monitor("Reg[%d]=%d", i, regs.data[i]);

   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;

   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
      regs.data[i] = i;   // Note that always R0 = 0 in MIPS 
      
   // Now apply some inputs. 
   // You SHOULD EXTEND this part of the code with extra inputs 
   #(`clock_period)
   ALUop = 4'h0; raA = 5'h1; raB = 5'h3; wa = 5'h3; wen = 1'b1; 
   #(`clock_period)
   ALUop = 4'h2; wa = 5'h4;
   #(`clock_period)
   ALUop = 4'h6; raA=5'h5; raB=5'h1; wa=5'h3;
   #(`clock_period)
   ALUop = 4'h7; raA=5'h3; raB=5'h2; wa=5'h1;
   #(`clock_period)
   ALUop = 4'hc; raA=5'h2; raB=5'h3; wa=5'h4;
   #(`clock_period)
   wen = 1'b0;

   $finish;
end 

// Generate clock by inverting the signal every half of clock period
always begin
   #(`clock_period/2) clock = ~clock;  
end
   
endmodule
