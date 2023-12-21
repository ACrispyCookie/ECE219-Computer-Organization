v 1.0
Changes: 
	- Allaja sto control.v to HazardUnit an den kanw la8os (NOT TESTED)
	- Added ReadMe
	- fixed syntax errors classic :)

Note: An grafw burdes apla kades mou delete kai graftes sry eimai ligo egkefalika nekros me ton pireto *insert thumbs up emoji here*

TODO:
	se periptwsh pou den prolabw prin to deis esu.
		- Add Enable signal to PC, IFEX, kai opou xriazete gia to HazardUnit
		- Add wires sto cpu tis ejodous tou HazardUnit
		- Add Forwarding unit (should be ez)
		- Boss: 
			- Make registed MEM, opoion allon 8elei


v 1.2

Changes: 
	- Finished Forwarding Unit (NOT TESTED)
		Note: Needs wiring to cpu circuitry i think 
	- Finished HazardUnit (NOT TESTED)

TODO:
	- Do the the "TO FILL"s
	- WB logic (NO IDEA)
	- Boss: 
		- Make registed MEM, opoion allon 8elei


add $t0, $t0, $s0  : PASS   	// @0 01104020			
sw $ra, 4($t2)     : PASS		// @1 ad5f0004		
lw $t5, 4($t2)     : PASS		// @2 8d4d0004
sub $t1, $t1, $a0  : PASS		// @3 01244822	
or $t6, $t7, $t5   : PASS		// @4 01ed7025	
and $s3, $s0, $s2  : PASS		// @5 02129824		
lw $t6, 4($t2)     : @AA@		// @6 8d4e0004		
STALL @AND						
sw $gp, 8($t2)     : PASS		// @7 ad5c0008		
lw $v0, 8($t2)     : PASS		// @8 8d420008		
and $a0, $v0, $t5  : PASS		// @9 004d2024		
or $a0, $a0, $t0   : PASS		// @A 00882025		
add $t1, $a0, $v0  : PASS		// @B 00824820		
STALL @SLL						
slt $sp, $a0, $t1  : PASS		// @C 0089e82a	
lw $v0, 8($t2)     : PASS		// @D 8d420008		
sll $s4, $v0, 12   : FAIL		// @E 0002a300	
sllv $s6, $s4, $sp : FAIL		// @F 03b4b004		
addi $s6, $s6, -100: FAIL		// @10 22d6ff9c		



 assign out = 
			(op == 4'b0000) ? inA & inB :
			(op == 4'b0001) ? inA | inB :
			(op == 4'b0010) ? inA + inB : 
			(op == 4'b0110) ? inA - inB : 
			(op == 4'b0111) ? ((inA < inB)?1:0) : 
			(op == 4'b1100) ? ~(inA | inB) :
			'bx;

                 
assign ALUInA = (ForwardA == 2'b00) ? IDEX_rdA :
                (ForwardA == 2'b01) ? wRegData :
                (ForwardA == 2'b10) ? EXMEM_ALUOut :
                IDEX_rdA;
                 
assign ALUInB = (ForwardB == 2'b00) ? (IDEX_ALUSrc == 1'b0) ? IDEX_rdB : IDEX_signExtend : 
                (ForwardB == 2'b01) ? EXMEM_ALUOut : 
                (ForwardB == 2'b10) ? wRegData : 
                (IDEX_ALUSrc == 1'b0) ? IDEX_rdB : IDEX_signExtend;

