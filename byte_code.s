.data
	.equ PRINT, 1
	.equ PLUS, 2
	.equ MINUS, 3
	.equ BIGGER, 4
	.equ SMALLER, 5
	.equ LOOP_START, 6
	.equ LOOP_END, 7
	.equ INPUT, 8
.text
	
.global _byte_code
_byte_code:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp

	movq %rdi, -8(%rbp)

	call _strlen
	movq %rax, %rdi

	shl $2, %rdi
	call _malloc
	testq %rax, %rax	
	jz malloc_error
	

	movq -8(%rbp), %rdi
	movq %rax, %rsi

	movq $-1, %rcx
	movq $-1, %rdx
loop:
	incq %rdx
nop:
	incq %rcx
	movb (%rdi, %rcx), %al

	cmpb $'\n', %al
	je nop
	cmpb $' ', %al
	je nop
	cmpb $0x00, %al
	je end
	cmpb $'.', %al
	je case_print
	cmpb $',', %al
	je case_input
	cmpb $'[', %al
	je case_loop
	cmpb $']', %al
	je case_end_loop

	
	decq %rcx
	movq $0, %rbx
same_instruction:
	incq %rbx
	incq %rcx
	movb (%rdi, %rcx), %al
	cmpb 1(%rdi, %rcx), %al
	je same_instruction
	
	cmpb $'+', %al
	je case_plus

	cmpb $'-', %al
	je case_minus

	cmpb $'<', %al
	je case_smaller

	cmpb $'>', %al
	je case_bigger
	jmp loop
end:

	addq $48, %rsp
	movq %rsi, %rax
	movq %rbp, %rsp
	popq %rbp
	retq

malloc_error:
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	retq

case_print:
	movb $PRINT, (%rsi,%rdx)
	jmp loop
case_bigger:
	movb $BIGGER, (%rsi,%rdx)
	incq %rdx
	movb %bl, (%rsi,%rdx)
	jmp loop

case_smaller:
	movb $SMALLER, (%rsi,%rdx)
	incq %rdx
	movb %bl, (%rsi,%rdx)
	jmp loop

case_plus:
	movb $PLUS, (%rsi,%rdx)
	incq %rdx
	movb %bl, (%rsi,%rdx)
	jmp loop

case_minus:
	movb $MINUS, (%rsi,%rdx)
	incq %rdx
	movb %bl, (%rsi,%rdx)
	jmp loop

case_loop:
	movb $LOOP_START, (%rsi,%rdx)
	jmp loop

case_end_loop:
	movb $LOOP_END, (%rsi,%rdx)
	jmp loop

case_input:
	jmp loop









