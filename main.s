.text

	ErrorMsg:	.asciz	"Usage: ./bf <bffile>\n"
	FileError:	.asciz	"Could not open file\n"
	format:		.asciz	"r"
	print:		.asciz  "%d, "

.global _main
_main:

	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	cmpq $2, %rdi
	jne error
	
	movq 8(%rsi), %rdi
	leaq -8(%rbp), %rsi
	xorq %rax, %rax
	call _read_file
	
	testq %rax, %rax
	jz fileerror
	
	movq %rax, %rdi
	call _byte_code

	movq %rax, %rdi
	call _bf
	
	jmp end

fileerror:
	leaq FileError(%rip), %rdi
	xorq %rax, %rax
	call _printf
	jmp end
error:
	leaq ErrorMsg(%rip), %rdi
	xorq %rax, %rax
	call _printf
end:
	movq %rbp, %rsp
	popq %rbp
	retq
	
	
	
	
