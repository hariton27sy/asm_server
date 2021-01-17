.text
.globl _start

_start:
    mov $-10, %rax
    xor %rbx, %rbx
    cmp %rbx, %rax
    jb 2f
1:
    xor %rcx, %rcx
    jmp 3f
2:
    mov $1, %rcx
3:
    mov $60, %rax
    syscall
