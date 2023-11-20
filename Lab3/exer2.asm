.globl main
.text

.macro print_int(%x)
addi $v0, $0, 1
move $a0, %x
syscall
.end_macro

.macro exit()
li $v0,  17
li $a0, 0
syscall
.end_macro

main:
li $a0, 3
li $a1, 5

jal f

print_int($v0)
exit()

f: #$a0 = n, $a1 = m

bnez $a0, n_not_zero
move $v0, $a1
jr $ra

n_not_zero:
bnez $a1, m_not_zero
move $v0, $a0
jr $ra

m_not_zero:
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $a1, 8($sp)

addi $a0, $a0, -1
jal f
move $t0, $v0

lw $a0, 8($sp)
lw $a1, 4($sp)
addi $a1, $a1, -1
jal f

add $v0, $0, $t0
lw $ra, 0($sp)
addi $sp, $sp, 12
jr $ra
