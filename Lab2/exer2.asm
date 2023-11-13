
.data
array: .byte 0x70, 0x8C, 0xF3, 0x82, 0x1B, 0x9D, 0x52, 0x3C, 0x46

.text

# Macro that prints a given string
.macro print_string(%x)
	.data
	string: .asciiz %x
	.text
	
	# store %x 
	addi $sp, $sp, -4
	sw $a0, ($sp)
	
	addi $v0, $0, 4
	la $a0, string
	syscall
	
	# restore %x
	lw $a0, ($sp)
	addi $sp, $sp, 4
.end_macro

# Macro that print an integer
.macro print_int(%x)
	# store %x 
	addi $sp, $sp, -4
	sw $a0, ($sp)
	
	# print
	addi $v0, $0, 1
	addi $a0, $zero, %x
	syscall
	
	# restore %x
	lw $a0, ($sp)
	addi $sp, $sp, 4
.end_macro

# Macro that prints an integer in binary form
.macro itob_print(%integer)
	li $t0, 1         # Load the value 1 into $t0
	sll $t0, $t0, 31  # Shift left by 31 bits to create the mask

loop_itob:
	# and mask/int left
	beqz $t0, end_loop_itob
	and $t1, %integer, $t0
	bnez $t1, print_1
print_0:
	print_int(0)
	srl $t0, $t0, 1 # Move mask right 1
	j loop_itob
print_1:
	print_int(1)
	srl $t0, $t0, 1 # Move mask right 1
	j loop_itob
end_loop_itob:
.end_macro

# Byte changes value when bits < Nbits_in_row it is 
# shifted to the right bits_in_row - Nbits amount
.macro bits_in_row(%row, %offset, %bits, %byte)
	add $t6, $zero, %bits
	move $t8, %row
	# temp: t7 is bits of first row
	addi $t7, $zero, 8
	sub $t7, $t7, %offset

	beq %row, 0, first_row
other_row:
	sub $t6, $t6, $t7
	
	# t7 is 8*row
	sll $t7, $t8, 3
	sub $t6, $t6, $t7
	
	bltz $t6, last_row
	addi $v0, $zero, 8
	j bits_in_row_end

last_row:
	addi $t6, $t6, 8
	move $v0, $t6
	j bits_in_row_end

first_row:
	move $v0, $t7
	
	# Bits_in_row > Nbits Shift also to the right
	bge %bits, $t7, bits_in_row_end
	sub $t7, $t7, %bits
	srlv %byte, %byte, $t7
	sub $v0, $v0, $t7
	
bits_in_row_end:
.end_macro

# Reads an integer from the terminal
.macro read_int(%x)
	li $v0, 5
	syscall
	move %x, $v0
.end_macro

.globl main

main:
	# set programme parameters
	print_string("Give pointer to array:\n")
	read_int($t0)
	la $a0, array($t0)

offset_loop:
	print_string("Give offset from pointer (Value 0 to 7):\n")
	read_int($t0)
	bgt $t0, 7, offset_loop
	bltz $t0, offset_loop
end_offset_loop:
	
	add $a1, $zero, $t0

Nbit_loop:
	print_string("Give number of bits to read (Value 0 to 32):\n")
	read_int($t0)
	bgt $t0, 32, Nbit_loop
	bltz $t0, Nbit_loop
end_Nbit_loop:
	
	add $a2, $zero, $t0
	
	# Only call funct if Nbits != 0
	beqz $a2, ZeroBits

nonZeroBits:
	jal bits_read
	move $a0, $v0
	print_string("Result:\n")
	itob_print($a0)
	
	jal _exit

ZeroBits:
	print_string("No bits read!\n")
	
	jal _exit


bits_read:
	# $t1 is ptr
	move $t1, $a0
	move $t2, $zero
	move $t3, $zero
	move $t4, $zero
	move $t5, $zero
	
	lbu $t0, ($t1)
	
	# $t2 = 32 - offset
	bits_in_row($t3, $a1, $a2, $t0)
	addi $t2, $zero, 32
	sub $t2, $t2, $v0
	
	# keep only $t2 LSBs
	sllv $t0, $t0, $t2 
	srlv $t0, $t0, $t2 

	
loop_br:
	addi $t3, $t3, 1
	
	bits_in_row($t3, $a1, $a2, $t4)
	move $t2, $v0
	
	blez $t2, end_loop_br
	
	# Get next byte to insert
	addi $t1, $t1, 1
	lbu $t4, ($t1)

	# keep only $t2 MSBs
	addi $t5, $zero, 8
	sub $t5, $t5, $t2
	srlv $t4, $t4, $t5
	
	# shift left destination to or
	sllv $t0, $t0, $t2
	
	or $t0, $t0, $t4
	j loop_br
	
end_loop_br:
	move $v0, $t0
	jr $ra
	
bits_read_end:

_exit:
	# exit program
	li $v0,17
	la $a0,0
   	syscall
