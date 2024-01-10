/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/
`timescale 1ns/1ps

module cpu(input clock, input reset);
  reg [31:0] PC;
  reg [31:0] IFID_PCplus4;
  reg [31:0] IFID_instr;
  reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_PCplus4;
  reg [4:0] IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd, IDEX_instr_shamt;
  reg IDEX_RegDst, IDEX_ALUSrc;
  reg [1:0] IDEX_ALUcntrl;
  reg IDEX_Branch, IDEX_MemRead, IDEX_MemWrite, IDEX_Bne;
  reg IDEX_MemToReg, IDEX_RegWrite;
  reg [4:0] EXMEM_RegWriteAddr, EXMEM_instr_rd;
  reg [31:0] EXMEM_ALUOut;
  reg EXMEM_Zero;
  reg [31:0] EXMEM_MemWriteData, EXMEM_BranchAddr;
  reg EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg, EXMEM_Bne;
  reg [31:0] MEMWB_DMemOut;
  reg [4:0] MEMWB_RegWriteAddr, MEMWB_instr_rd;
  reg [31:0] MEMWB_ALUOut;
  reg MEMWB_MemToReg, MEMWB_RegWrite;
  wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData, PCIncr, ALUSrcIn, BranchAddr;
  wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch, Bne, Jump, PCSrc;
  wire [5:0] opcode, func;
  wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr, instr_shamt;
  wire [3:0] ALUOp;
  wire [1:0] ALUcntrl;
  wire [15:0] imm;
  wire [1:0] ForwardA, ForwardB;
  wire bubble_idex, bubble_ifid, bubble_exmem, IDEX_ALUshamt;
  wire IFID_write;
  wire IFID_PCwrite;

  /***************** Instruction Fetch Unit (IF)  ****************/
  always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)
      PC <= -1;
    else if (PC == -1)
      PC <= 0;
    else if (IFID_PCwrite)
      if (PCSrc == 1'b1)
        PC <= EXMEM_BranchAddr;
      else if (Jump == 1'b1)
        PC <= {IFID_PCplus4[31:28], IFID_instr[25:0], 2'b00};
      else
        PC <= PC + 4;
  end

  // IFID pipeline register
  always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 || bubble_ifid)
    begin
      IFID_PCplus4 <= 32'b0;
      IFID_instr <= 32'b0;
    end
    else
    begin
      if (IFID_write)
      begin
        IFID_PCplus4 <= PC + 32'd4;
        IFID_instr <= instr;
      end
    end
  end

  // TO FILL IN: Instantiate the Instruction Memory here
  Memory cpu_IMem(clock, reset, 1'b1, 1'b0, {2'b00, PC[31:2]}, 0, instr);

  /***************** Instruction Decode Unit (ID)  ****************/
  assign opcode = IFID_instr[31:26];
  assign func = IFID_instr[5:0];
  assign instr_rs = IFID_instr[25:21];
  assign instr_rt = IFID_instr[20:16];
  assign instr_rd = IFID_instr[15:11];
  assign instr_shamt = IFID_instr[10:6];
  assign imm = IFID_instr[15:0];
  assign signExtend = {{16{imm[15]}}, imm};

  // Register file
  RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
  always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 || bubble_idex)
    begin
      IDEX_instr_shamt <= 5'b0;
      IDEX_rdA <= 32'b0;
      IDEX_rdB <= 32'b0;
      IDEX_signExtend <= 32'b0;
      IDEX_instr_rd <= 5'b0;
      IDEX_instr_rs <= 5'b0;
      IDEX_instr_rt <= 5'b0;
      IDEX_RegDst <= 1'b0;
      IDEX_ALUcntrl <= 2'b0;
      IDEX_ALUSrc <= 1'b0;
      IDEX_Branch <= 1'b0;
      IDEX_Bne <= 1'b0;
      IDEX_MemRead <= 1'b0;
      IDEX_MemWrite <= 1'b0;
      IDEX_MemToReg <= 1'b0;
      IDEX_RegWrite <= 1'b0;
      IDEX_PCplus4 <= 1'b0;
    end
    else
    begin
      IDEX_instr_shamt <= instr_shamt;
      IDEX_rdA <= rdA;
      IDEX_rdB <= rdB;
      IDEX_signExtend <= signExtend;
      IDEX_instr_rd <= instr_rd;
      IDEX_instr_rs <= instr_rs;
      IDEX_instr_rt <= instr_rt;
      IDEX_RegDst <= RegDst;
      IDEX_ALUcntrl <= ALUcntrl;
      IDEX_ALUSrc <= ALUSrc;
      IDEX_Branch <= Branch;
      IDEX_Bne <= Bne;
      IDEX_MemRead <= MemRead;
      IDEX_MemWrite <= MemWrite;
      IDEX_MemToReg <= MemToReg;
      IDEX_RegWrite <= RegWrite;
      IDEX_PCplus4 <= IFID_PCplus4;
    end
  end

  // Main Control Unit
  control_main control_main (RegDst, Branch, Bne, Jump, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, ALUcntrl, opcode);

  // TO FILL IN: Instantiation of Control Unit that generates stalls
  HazardUnit HazardUnit (instr_rs, instr_rt, IDEX_MemRead, IDEX_Branch, Jump, PCSrc, IDEX_instr_rt, IFID_write, IFID_PCwrite, bubble_ifid, bubble_idex, bubble_exmem);

  /***************** Execution Unit (EX)  ****************/
  assign ALUInA = (IDEX_ALUshamt == 1) ? IDEX_instr_shamt :
                  (ForwardA == 2'b00) ? IDEX_rdA :
                  (ForwardA == 2'b01) ? wRegData :
                  (ForwardA == 2'b10) ? EXMEM_ALUOut :
                  IDEX_rdA;

  assign ALUSrcIn = (ForwardB == 2'b01) ? EXMEM_ALUOut :
                    (ForwardB == 2'b10) ? wRegData :
                    IDEX_rdB;

  assign ALUInB = (IDEX_ALUSrc == 1'b0) ? ALUSrcIn : IDEX_signExtend;

  assign BranchAddr = IDEX_PCplus4 + (IDEX_signExtend << 2);

  // ALU
  ALU #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

  assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

  // EXMEM pipeline register
  always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 || bubble_exmem)
    begin
      EXMEM_ALUOut <= 32'b0;
      EXMEM_RegWriteAddr <= 5'b0;
      EXMEM_MemWriteData <= 32'b0;
      EXMEM_Zero <= 1'b0;
      EXMEM_Branch <= 1'b0;
      EXMEM_MemRead <= 1'b0;
      EXMEM_MemWrite <= 1'b0;
      EXMEM_MemToReg <= 1'b0;
      EXMEM_RegWrite <= 1'b0;
      EXMEM_BranchAddr <= 32'b0;
    end
    else
    begin
      EXMEM_ALUOut <= ALUOut;
      EXMEM_RegWriteAddr <= RegWriteAddr;
      EXMEM_MemWriteData <= ALUSrcIn;
      EXMEM_Zero <= Zero;
      EXMEM_Branch <= IDEX_Branch;
      EXMEM_Bne <= IDEX_Bne;
      EXMEM_MemRead <= IDEX_MemRead;
      EXMEM_MemWrite <= IDEX_MemWrite;
      EXMEM_MemToReg <= IDEX_MemToReg;
      EXMEM_RegWrite <= IDEX_RegWrite;
      EXMEM_BranchAddr <= BranchAddr;
    end
  end

  // ALU control
  control_alu control_alu(ALUOp, IDEX_ALUshamt, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
  ForwardingUnit forward_unit(ForwardA, ForwardB, IDEX_instr_rs, IDEX_instr_rt,
                                  EXMEM_RegWriteAddr, MEMWB_RegWriteAddr, EXMEM_RegWrite, MEMWB_RegWrite);

  /***************** Memory Unit (MEM)  ****************/

  assign PCSrc = EXMEM_Branch == 1'b1 && (EXMEM_Bne == 1'b1 && EXMEM_Zero == 1'b0 || EXMEM_Bne == 1'b0 && EXMEM_Zero == 1'b1);

  // Data memory 1KB
  // Instantiate the Data Memory here
  Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);

  // MEMWB pipeline register
  always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)
    begin
      MEMWB_DMemOut <= 32'b0;
      MEMWB_ALUOut <= 32'b0;
      MEMWB_RegWriteAddr <= 5'b0;
      MEMWB_MemToReg <= 1'b0;
      MEMWB_RegWrite <= 1'b0;
    end
    else
    begin
      MEMWB_DMemOut <= DMemOut;
      MEMWB_ALUOut <= EXMEM_ALUOut;
      MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
      MEMWB_MemToReg <= EXMEM_MemToReg;
      MEMWB_RegWrite <= EXMEM_RegWrite;
    end
  end

  /***************** WriteBack Unit (WB)  ****************/
  // TO FILL IN: Write Back logic
  assign wRegData =
                (reset == 1'b0) ? 0 :
                (MEMWB_MemToReg == 1) ? MEMWB_DMemOut :
                MEMWB_ALUOut;

endmodule
