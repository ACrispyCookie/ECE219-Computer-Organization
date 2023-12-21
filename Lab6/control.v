`include "constants.h"
`timescale 1ns/1ps

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,  
                output reg [1:0] ALUcntrl,  
                input [5:0] opcode);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
      /* TO FILL IN: The control signal values in each and every case */
          begin   
            RegDst = 1'b1;
            MemRead = 1'b0;
            ALUSrc = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            Branch = 1'b0;    
            ALUcntrl = 2'b10;   
          end
       `LW :   
           begin
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            MemToReg = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl = 2'b00;
           end
        `SW :   
           begin 
            RegDst = 1'b0;
            ALUSrc = 1'b1;
            MemToReg = 1'b0;
            RegWrite = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl = 2'b00;
           end
       `BEQ:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01;
           end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
// TO FILL IN: Module details
module EX_bypass_detector(output reg [1:0] ForwardA, output reg [1:0] ForwardB, 
                          input [4:0] IDEX_RegisterRs, input [4:0] IDEX_RegisterRt, 
                          input [4:0] EXMEM_RegisterRd, input [4:0] MEMWB_RegisterRd,
                          input EXMEM_RegWrite, input MEMWB_RegWrite);
          
  always @(*) begin
    if (EXMEM_RegWrite && EXMEM_RegisterRd != 0 && EXMEM_RegisterRd == IDEX_RegisterRs)
      ForwardA <= 2'b10;
    else if (MEMWB_RegWrite && MEMWB_RegisterRd != 0 && MEMWB_RegisterRd == IDEX_RegisterRs && (EXMEM_RegisterRd != IDEX_RegisterRs || EXMEM_RegWrite == 0))
      ForwardA <= 2'b01;
    else
      ForwardA <= 2'b00;
    
    if (EXMEM_RegWrite && EXMEM_RegisterRd != 0 && EXMEM_RegisterRd == IDEX_RegisterRt)
      ForwardB <= 2'b01;
    else if (MEMWB_RegWrite && MEMWB_RegisterRd != 0 && MEMWB_RegisterRd == IDEX_RegisterRt && (EXMEM_RegisterRd != IDEX_RegisterRt || EXMEM_RegWrite == 0))
      ForwardB <= 2'b10;
    else
      ForwardB <= 2'b00;
  end
endmodule          
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
// TO FILL IN: Module details 

											// auto einai to HAZARD UNIT (logika ne) ??????????????????????????????????????????????????????????????????????????

module ID_stall_detector(input [4:0] IFID_RegRs, input [4:0] IFID_RegRt, input IDEX_MemRead, input [4:0] IDEX_RegRt, output reg IFID_Write, output reg PC_Write, output reg MUX_nop /*MUX signal for IDEX*/);
  
  always @(*) begin
    if (IDEX_MemRead == 1 && (IDEX_RegRt == IFID_RegRs || IDEX_RegRt == IFID_RegRt)) begin
      // stall
      PC_Write = 1'b0;
      IFID_Write = 1'b0;
      MUX_nop = 1'b1;
    end else begin
      // do not stall
      PC_Write = 1'b1;
      IFID_Write = 1'b1;
      MUX_nop = 1'b0;
    end
  end
endmodule
                       
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp  = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
