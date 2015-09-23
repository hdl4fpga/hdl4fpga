convolution:
	movslq	%edx, %rax
	addq	%rax, %rax
	leaq	(%rdi,%rax), %rdx
	leaq	-168(%rdi,%rax), %rdi
	xorl	%eax, %eax
.L3:
	movzwl	(%rdx), %ecx
	subq	$2, %rdx
	addq	$2, %rsi
	imulw	-2(%rsi), %cx
	addl	%ecx, %eax
	cmpq	%rdi, %rdx
	jne	.L3
	rep ret
