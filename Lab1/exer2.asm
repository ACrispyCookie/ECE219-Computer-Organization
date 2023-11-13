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
	print_string("Please give N1: ")
	read_int($s2)
	bltz $s2,end

	print_string("Please give N2: ")
	read_int($s3)
	bltz $s3,end
	
	move $s0,$s2
	move $s1,$s3

read_loop:
	print_string("Please give N1: ")
	read_int($s2)
	bltz $s2,end

	print_string("Please give N2: ")
	read_int($s3)
	bltz $s3,end

case_union:
	bgt $s0, $s3, case_no_union # if (n1 > n2')
	blt $s1, $s2, case_no_union # if (n2 < n1')

check_n1:
	blt $s0, $s2, check_n2 # if (n1 < n1')
	move $s0, $s2
	
check_n2:
	bgt $s1, $s3 read_loop # if (n2 > n2')
	move $s1, $s3
	
	j read_loop
	
case_no_union:
	sub $t0, $s1, $s0 # n2 - n1
	sub $t1, $s3, $s2 # n2' - n1'
	
	ble $t1, $t0, read_loop # if (n2' - n1') < (n2 - n1)
	
update_all:
	move $s0, $s2
	move $s1, $s3
	
	j read_loop

end:
	print_string("The max final union of ranges is [")
	print_int($s0)
	print_string(", ")
	print_int($s1)
	print_string("].")
	
	# exit program
	li $v0,17
	la $a0,0
	syscall