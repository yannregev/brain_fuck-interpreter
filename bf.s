.data
	.equ SIZE, 50000
	buffer: .skip SIZE

.text
	.equ EOF, 0
	.equ PRINT, 1
	.equ PLUS, 2
	.equ MINUS, 3
	.equ BIGGER, 4
	.equ SMALLER, 5
	.equ LOOP_START, 6
	.equ LOOP_END, 7
	.equ INPUT, 8

	jumptable:
		.quad end
		.quad case_print
		.quad case_plus
		.quad case_minus
		.quad case_bigger
		.quad case_smaller
		.quad case_loop
		.quad case_end_loop
		.quad case_input
		
	text: .asciz "%d\n"
.global _bf

_bf:
	
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp


	movq %rdi, -8(%rbp)
	call _strlen
	movq %rax, -32(%rbp)
	
	movq -8(%rbp), %rdi
	movq %rax, %rsi
	call _fill_jumptable
	testq %rax, %rax
	jz end


	leaq buffer(%rip), %r9
	movq -8(%rbp), %r10
	movq %rax, %r13
	movq $-1, %r14
	leaq jumptable(%rip), %r12

loop:
	incq %r14
	xorq %rax, %rax
	movb (%r10, %r14), %al
	movq (%r12, %rax, 8), %rax
	jmp *%rax
	
end:
	addq $16, %rsp
	movq %r13, %rdi
	call _free
	movq %rbp, %rsp
	popq %rbp
	retq

case_print:


	leaq (%r9), %rsi
	movq $0x2000004, %rax
	movq $1, %rdi
	movq $1, %rdx
	syscall
	jmp loop

case_bigger:
	incq %r14
	xorq %rax, %rax
	movb (%r10, %r14), %al
	addq %rax, %r9
	jmp loop

case_smaller:
	incq %r14
	xorq %rax, %rax
	movb (%r10, %r14), %al
	subq %rax, %r9
	jmp loop

case_plus:
	incq %r14
	movb (%r9), %al
	movb (%r10, %r14), %bl
	addb %bl, %al
	movb %al, (%r9)
	jmp loop

case_minus:
	incq %r14
	movb (%r9), %al
	movb (%r10, %r14), %bl
	subb %bl, %al
	movb %al, (%r9)
	jmp loop

case_loop:
	cmpb $0, (%r9)
	jne loop
skip_loop:
	movq (%r13, %r14, 8), %rbx
	movq %rbx, %r14
dont_skip_loop:
	jmp loop

case_end_loop:
	cmpb $0, (%r9)
	je loop
jump_back:
	movq (%r13, %r14, 8), %rbx
	movq %rbx, %r14
dont_jump_back:
	jmp loop

case_input:
	jmp loop



_fill_jumptable:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp

	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)

	movq %rsi, %rdi
	shlq $3, %rdi
	call _malloc
	testq %rax, %rax
	jz failed
	movq %rax, -24(%rbp)
		
	movq -8(%rbp), %rdi
	movq $-1, %rbx
	jmp jumptable_loop
skip:
	incq %rbx
jumptable_loop:
	incq %rbx
	movb (%rdi, %rbx), %r10b
	cmpb $0x00, %r10b
	je jumptable_end

	cmpb $PLUS, %r10b
	je skip

	cmpb $MINUS, %r10b
	je skip

	cmpb $BIGGER, %r10b
	je skip

	cmpb $SMALLER, %r10b
	je skip

	cmpb $LOOP_START, %r10b
	je start_loop
	cmpb $LOOP_END,	%r10b
	je end_loop
	jmp jumptable_loop
start_loop:
	pushq %rbx	
	jmp jumptable_loop
end_loop:
	popq %r9
	movq %r9, (%rax, %rbx, 8)
	movq (%rax, %rbx, 8), %r10
	movq %rbx, (%rax, %r10, 8)
	jmp jumptable_loop
failed:
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	retq
jumptable_end:
	movq -24(%rbp), %rax
	addq $32, %rsp
	movq %rbp, %rsp
	popq %rbp
	retq

