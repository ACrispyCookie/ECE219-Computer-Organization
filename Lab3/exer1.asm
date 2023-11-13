.data
	string: 
		.space 1000
.globl main
.text

.macro print_string(%s)
.data
	string: .asciiz %s
.text
	li $v0, 4
	la $a0, string
	syscall
.end_macro

.macro print_string_reg(%s)
.text
	li $v0, 4
	la $a0, (%s)
	syscall
.end_macro
		
.macro read_string(%str, %maxlen)
	li $v0, 8
	la $a0, %str
	li $a1, %maxlen
	syscall
	
	# Set NULL terminator
	la $a0, %str
	jal strlen
	
	add $t0, $a0, $v0
	sb $zero, ($t0)
.end_macro
	
					
main:
	
	#call print string (Please...)
	print_string("Please, give a string of characters: ")
	read_string(string, 255)
	
	bnez $v0, not_empty_string 
	empty_string:
		print_string("String is empty!")
		j exit
	not_empty_string:

	la $a0, string
	move $a1, $v0
	jal is_symmetric_str

	beq $v0, 0, is_not_symmetric
	is_symmetric:
		print_string("String \"")
		la $s0, string
		print_string_reg($s0)  
		print_string("\" is symmetric.\n")
		j exit
	is_not_symmetric:
		print_string("String \"")
		la $s0, string
		print_string_reg($s0)
		print_string("\" is not symmetric.\n")
	
	exit:
		li $v0, 17
		li $a0, 0
		syscall

# parameters: (char *s, int length)
is_symmetric_str:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	bgtz $a1, length_not_zero
	# return symmetrical
	addi $sp, $sp, 4
	li $v0, 1
	jr $ra
	
	length_not_zero:
	# get first char
	la $t0, ($a0)
	lb $t0, ($t0)

	# get last char
	la $t1, ($a0)
	add $t1, $t1, $a1
	addi $t1, $t1, -1
	lb $t1, ($t1)
	
	bne $t0, $t1, chars_not_equal
	chars_equal:
		addi $t2, $a0, 1
		addi $t3, $a1, -2

		move $a0, $t2
		move $a1, $t3

		jal is_symmetric_str

		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
	chars_not_equal:
		addi $sp, $sp, 4
		li $v0, 0
		jr $ra

# finds the length of a given string
# Uses $t0
strlen:
	# Load string address
	la $t0, ($a0)

	strl_loop:
		lb $t1, ($t0)
		
        	#if is NULL
		beqz $t1, strl_loop_end
		#if char is space
		#beq $t1, 0x20, strl_loop_end
		beq $t1, 0xa, strl_loop_end
		
		addi $t0, $t0, 1 #move pointer
		j strl_loop
	strl_loop_end:

    	sub $v0, $t0, $a0 # Counter is 
    	jr $ra
strlen_end: