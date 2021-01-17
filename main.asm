.include "socket.asm"
.globl _start

.text

_start:
    call socket
    # после этого вызова дескриптор сокета лежит в %rax
    # а _connect принимает дескриптор в параметре %rdi
    # поэтому скопируем значение
    mov %rax, %rdi
    mov $0x901f, %rax
    call bind

    call listen

    exit
