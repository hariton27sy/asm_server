.include "helpers.asm"

.data

client_connected: .ascii "Connected client with address "
client_connected_len = . - client_connected
dot: .ascii "."
colon: .ascii "."
newline: .byte 10

.text

# Конвертирует число в строку 
# Входные параметры:
#   %rdi - неотрицательное число
#   %rsi - адрес куда писать число
#   %rdx - максимальная длина памяти для числа
# Выходные параметры:
#   %rax - длина числа
# Ошибки:
#   Если все число не помещается в доступную память, то оно обрежется
number_to_string:
    xor %rax, %rax
    push %rbp
    push %rsi
    test %rdx, %rdx
    jz 1f

    mov %rdx, %rbp

    mov %rdi, %rax
    mov $10, %rcx
    xor %rbx, %rbx
2:
    xor %rdx, %rdx
    inc %rbx
    div %rcx
    push %rdx
    
    test %rax, %rax
    jnz 2b
3:
    cmp %rbp, %rbx
    jle 4f
    pop %rax
    dec %rbx
    jmp 3b
4:
    mov %rbx, %rax
5:
    test %rbx, %rbx
    jz 1f
    pop %rcx
    add $0x30, %cl
    movb %cl, (%rsi)
    inc %rsi
    dec %rbx
    jmp 5b
1:
    pop %rsi
    pop %rbp
    ret

# Печатает информацию о подключенном клиенте
# Вход:
#   %rdi - указатель на структуру адреса
print_message:
    push %rdi
    mov %rdi, %rax
    print client_connected client_connected_len
    push $0 # Будем складывать сюда число
    xor %rcx
1:
    xor %rdi, %rdi
    movb 4(%rcx, %rax), %dil

    

    pop %rdi
    ret

    