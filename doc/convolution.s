;  "GCC  4.8.4" -O2 -S -std=gnu99 -mtune=corei7-avx
;
; ++ Aportan al cálculo en el lazo
; -- NO aportan al cálcu en el lazo
;

convolution:
.LFB0:
	movslq	%edx, %rax
	salq	$2, %rax
	leaq	(%rdi,%rax), %rdx
	leaq	-336(%rdi,%rax), %rdi
	xorl	%eax, %eax
.L3:
	movl	(%rsi), %ecx	; --	<----+
	subq	$4, %rdx		; --	     |
	addq	$4, %rsi		; --	     |
	imull	4(%rdx), %ecx	; ++	     | Lazo de 7 instrucciones
	addl	%ecx, %eax		; ++	     |
	cmpq	%rdi, %rdx		; --	     |
	jne	.L3					; --	>>---+
	rep ret

