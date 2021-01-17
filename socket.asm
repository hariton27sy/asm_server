.include "helpers.asm"

.data

AF_INET = 2
SOCK_STREAM = 1

error_create: .ascii "Can not create socket\n"
error_create_len = . - error_create

error_connect: .ascii "Can not connect to the server\n"
error_connect_len = . - error_connect

error_bind: .ascii "Cannot bind socket to the address\n"
error_bind_len = . - error_bind

error_listen: .ascii "Cannot not enable socket to listen mode\n"
error_listen_len = . - error_listen

error_accept: .ascii "Cannot accept connection\n"
error_accept_len = . - error_accept

addr: .short 2 # тип адреса
      .byte 0x1f, 0x90 # порт в big-endian
      .byte 127, 0, 0, 1 # сам адрес
      .space 16 - (. - addr) # выравнивание до 16 байт
addr_len = . - addr

test:
    .short 2
    .byte 0x1f, 0x90
    .byte 0, 0, 0, 0
    .space 16 - (. - test)
.text

# Создание сокета
# Возвращаемое значение:
#   %rax - дескриптор сокета
# В случае ошибки, завершает работу приложения
socket:
    mov $41, %rax # номер системного вызова - socket()
    mov $AF_INET, %rdi # arg0 - domain
    mov $SOCK_STREAM, %rsi # arg1 - type
    xor %rdx, %rdx # arg2 - protocol
    syscall

    cmp $-1, %rax
    je 1f # В случае ошибки функция возвращает значение -1
    ret
1:
    mov $1, %rax
    mov %rax, %rdi
    mov $error_create, %rsi
    mov $error_create_len, %rdx
    syscall
    exit $1

# Подключиться к серверу. Берет адрес из переменной addr (временно)
# Входные параметры:
#   %rdi - дескриптор сокета
#   %rsi - указатель на адрес
#   %rdx - длина адреса
# В случае ошибки завершает работу приложения
connect:
    mov %eax, %edi # arg0 - дескриптор сокета
    mov $42, %rax # системный вызов connect()
    mov $addr, %rsi # arg1 - аддрес подключения
    mov $addr_len, %rdx # arg2 - размер адреса
    syscall

    test %rax, %rax
    jne 1f
    ret
1:
    mov $1, %rax
    mov %rax, %rdi
    mov $error_connect, %rsi
    mov $error_connect_len, %rdx
    syscall
    exit $1

# Привязывает сокет к определенному порту на адрес 0.0.0.0
# Входные параметры:
#   %rdi - дескриптор сокета
#   %rax - порт
# В случае ошибки завершение работы приложения
bind:
    # Кладем всю структуру на стэк. Так как структура состоит из 16 байт а используем только 8,
    # то сначала кладем 8 нулевых байт (это всего одна операция push со значением)
    # Будем слушать с любого адреса, поэтому адрес это 4 байта нулей
    # Имеем порт в регистре, просто сме
    shl $16, %rax
    add $0x2, %rax
    push $0
    push %rax
    
    mov $49, %rax
    mov %rsp, %rsi
    mov $16, %rdx
    syscall

    test %rax, %rax
    jne 1f

    pop %rax
    pop %rax

    ret
1:
    print error_bind error_bind_len
    exit $1

# Включаем на сокете режим прослушивания с максимальным
# числом подключений 1
# Входные параметры:
#   %rdi - дескриптор сокета
# В случае ошибки завершение работы приложения
listen:
    mov $50, %rax
    mov $1, %rsi
    syscall

    test %rax, %rax
    jne 1f
    ret
1:
    print error_listen error_listen_len
    exit $1

# https://man7.org/linux/man-pages/man2/accept.2.html
# %rdi - дескриктор сокета.
# %rsi - указатель на то чтобы записать туда адрес.
# %rdx - указатель на длину адреса.
# Выходные параметры:
#   %rax - дескриптор сокета, с подключением
# В случае ошибки завершается работа приложения
accept:
    mov $43, %rax
    xor %rdx, %rdx
    syscall

    cmp $-1, %rax
    je 1f
    ret
1:
    print error_accept error_accept_len
    exit $1
