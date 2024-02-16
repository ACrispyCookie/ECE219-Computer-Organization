	.file	"lab9_program.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"Seconds = %f\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB3:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	call	clock@PLT
	movq	%rax, %rbx
	call	clock@PLT
	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	leaq	.LC1(%rip), %rdi
	cvtsi2sdq	%rbx, %xmm1
	cvtsi2sdq	%rax, %xmm0
	movl	$1, %eax
	subsd	%xmm1, %xmm0
	divsd	.LC0(%rip), %xmm0
	call	printf@PLT
	movl	$536870912, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE3:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC0:
	.long	0
	.long	1093567616
	.ident	"GCC: (GNU) 13.2.1 20230801"
	.section	.note.GNU-stack,"",@progbits
