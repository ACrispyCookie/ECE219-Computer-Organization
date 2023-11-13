.globl main
.data
.align 2
in_1_length: .word 4
in_1:
	.word -5, 0, 2, 11
in_2_length: .word 5
in_2:
	.word -2, 0, 1, 13, 15
out_length: .word 9
out:
	.space 72

.macro print_string(%s)
.data
	string: .asciiz %s
.text
	li $v0, 4
	la $a0, string
	syscall
.end_macro

.macro print_int(%s)
.text
	li $v0, 1
	move $a0, %s
	syscall
.end_macro

.text
main:
	#int *out arg
	addi $sp, $sp, -4
	la $t0, out
	sw $t0, ($sp)
	
	#other args
	la $a0, in_1
	lw $a1, in_1_length
	la $a2, in_2
	lw $a3, in_2_length
	
	jal merge
	
	print_string("Out: [")
	move $t0, $0
	lw $t1, out_length
	for:
		bge $t0, $t1, end_for
		
		#get correct offset
		move $t2, $t0
		sll $t2, $t2, 2

		#print int
		lw $t3, out($t2)
		print_int($t3)
		print_string(" ")
		
		addi $t0, $t0, 1
		j for
	end_for:
	print_string("]")
	
	#exit
	li $v0, 17
	li $a0, 0
	syscall

merge:
	add $t0, $0, $0
	add $t1, $0, $0
	add $t2, $0, $0

    	while_both:
        	bge $t0, $a1, end_while_both
        	bge $t1, $a3, end_while_both
        	
        	#get correct element from in1
        	move $t3, $t0
        	sll $t3, $t3, 2
        	la $t4, ($a0)
        	add $t3, $t3, $t4
        	lw $t3, ($t3)
        	
        	#get correct element from in2
        	move $t4, $t1
        	sll $t4, $t4, 2
        	la $t5, ($a2)
        	add $t4, $t4, $t5
        	lw $t4, ($t4)
        	
        	bgt $t4, $t3, move_in1
        	j move_in2
        	move_in1:
        		move $t5, $t2
        		sll $t5, $t5, 2
        		lw $t6, ($sp)
        		add $t5, $t5, $t6
        		sw $t3, ($t5)
        		
        		addi $t0, $t0, 1
        		j end_move
        	move_in2:
        		move $t5, $t2
        		sll $t5, $t5, 2
        		lw $t6, ($sp)
        		add $t5, $t5, $t6
        		sw $t4, ($t5)
        	
        		addi $t1, $t1, 1
        	end_move:
        	
        	addi $t2, $t2, 1
        	j while_both
    	end_while_both:
    	
    	while_i:
        	bge $t0, $a1, end_while_i
        	
    		#get correct element from in1
        	move $t3, $t0
        	sll $t3, $t3, 2
        	la $t4, ($a0)
        	add $t3, $t3, $t4
        	lw $t3, ($t3)
        	
        	move $t5, $t2
        	sll $t5, $t5, 2
        	lw $t6, ($sp)
        	add $t5, $t5, $t6
        	sw $t3, ($t5)
        		
        	addi $t0, $t0, 1
        	addi $t2, $t2, 1
        	j while_i
    	end_while_i:
    	
    	while_j:
        	bge $t1, $a3, end_while_j
        	
    		#get correct element from in2
		move $t3, $t1
        	sll $t3, $t3, 2
        	la $t4, ($a2)
        	add $t3, $t3, $t4
        	lw $t3, ($t3)

        	move $t5, $t2
        	sll $t5, $t5, 2
        	lw $t6, ($sp)
        	add $t5, $t5, $t6
        	sw $t3, ($t5)
        		
        	addi $t1, $t1, 1
        	addi $t2, $t2, 1
        	j while_j
    	end_while_j:
    	
	addi $sp, $sp 4
	jr $ra