.macro exit code=$0
    mov $60, %rax
    mov \code, %rdi
    syscall
.endm


.macro print addr len
    mov $1, %rax
    mov $1, %rdi
    mov $\addr, %rsi
    mov $\len, %rdx
    syscall
.endm
