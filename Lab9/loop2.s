	.file	"lab9_program.c"
	.text
	.section	.rodata
.LC1:
	.string	"Seconds = %f\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	$268435456, -20(%rbp)
	movl	$0, -28(%rbp)
	movl	-28(%rbp), %eax
	movl	%eax, -32(%rbp)
	call	clock@PLT
	movq	%rax, -16(%rbp)
	movl	$0, -24(%rbp)
	jmp	.L2
.L3:
	addl	$1, -32(%rbp)
	addl	$1, -28(%rbp)
	addl	$1, -24(%rbp)
.L2:
	movl	-24(%rbp), %eax
	cmpl	-20(%rbp), %eax
	jl	.L3
	call	clock@PLT
	movq	%rax, -8(%rbp)
	pxor	%xmm0, %xmm0
	cvtsi2sdq	-8(%rbp), %xmm0
	pxor	%xmm1, %xmm1
	cvtsi2sdq	-16(%rbp), %xmm1
	subsd	%xmm1, %xmm0
	movsd	.LC0(%rip), %xmm1
	divsd	%xmm1, %xmm0
	movq	%xmm0, %rax
	movq	%rax, %xmm0
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$1, %eax
	call	printf@PLT
	movl	-32(%rbp), %edx
	movl	-28(%rbp), %eax
	addl	%edx, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.section	.rodata
	.align 8
.LC0:
	.long	0
	.long	1093567616
	.ident	"GCC: (GNU) 13.2.1 20230801"
	.section	.note.GNU-stack,"",@progbits
