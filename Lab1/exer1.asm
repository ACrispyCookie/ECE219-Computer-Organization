.globl main

.macro print_int(%x)
addi $v0, $0, 1
move $a0, %x
syscall
.end_macro

.macro print_string(%x)
.data
string: .asciiz %x
.text
addi $v0, $0, 4
la $a0, string
syscall
.end_macro

.macro read_int(%x)
li $v0, 5
syscall
move %x, $v0
.end_macro

.text
main:
	#print read prompt
	print_string("Give integer: ")
	
	#read integer
	read_int($s0)
	
	#initialize counter
	add $t0, $0, $0
	li $t1, 32
	move $t2, $s0

for:
	bge $t0, $t1, end_for
	
	andi $t3, $t2, 0x80000000
	srl $t3, $t3, 31
	beq $t3, 1, end_for
	sll $t2, $t2, 1
	
	addi, $t0, $t0, 1
	j for
	
end_for:
	print_string("Number ")
	print_int($s0)
	print_string(" has ")
	print_int($t0)
	print_string(" leading zeros")
	
	#exit program
	li $v0,  17
	li $a0, 0
	syscall


	
	
