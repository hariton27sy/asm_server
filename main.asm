.include "socket.asm"
.globl _start

.data
format: .ascii

test_msg: .ascii "Hello, there!"
test_msg_len = . - test_msg

.bss
_sock_fd: .space 4
_addr_len: .space 8
.align 16
_addr: .space 16

.text

_start:
    call socket # Создаем TCP-сокет
    mov %eax, _sock_fd # ЗАпишем дескриптор сокета в память

    # Забиндим сокет на 0.0.0.0:8080
    mov %rax, %rdi
    mov $0x901f, %rax
    call bind

    # Включим режим прослушивания
    mov $1, %rsi
    call listen
inf_loop:
    # Ждем новые подключения
    mov _sock_fd, %edi
    mov $_addr, %rsi
    mov $_addr_len, %rdx
    call accept

    # Отправляем сообщение
    mov %rax, %rdi
    mov $test_msg, %rsi
    mov $test_msg_len, %rdx
    call send

    # Закрываем соединение
    call close

    jmp inf_loop
