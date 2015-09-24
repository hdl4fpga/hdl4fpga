;  GCC 4.8.4 -O2 -S -std=gnu99 -mtune=corei7-avx
;
; ++ Aportan al cálculo en el lazo
; -- NO aportan al cálculo en el lazo
;

convolution:
	movslq	%edx, %rax
	salq	$2, %rax
	leaq	(%rdi,%rax), %rdx
	leaq	-336(%rdi,%rax), %rdi
	xorl	%eax, %eax
.L3:
	movl	(%rsi), %ecx  ; --  <---+ 84 veces
	subq	$4, %rdx	  ; --      | 7 instr.
	addq	$4, %rsi	  ; --      |
	imull	4(%rdx), %ecx ; ++      |
	addl	%ecx, %eax	  ; ++      |
	cmpq	%rdi, %rdx	  ; --      |
	jne	.L3				  ; --  >>--+
	rep ret
