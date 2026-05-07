[BITS 32]
[GLOBAL start]

[SECTION .multiboot]
align 4
    dd 0x1BADB002
    dd 0x00
    dd -(0x1BADB002 + 0x00)

[SECTION .text]
start:
    mov edi, 0xB8000
    mov ecx, 80 * 25
    mov ax, 0x0720
    rep stosw
    
    mov ebx, 0xB8000
    mov byte [ebx], 'H'
    mov byte [ebx+1], 0x07
    mov byte [ebx+2], 'e'
    mov byte [ebx+3], 0x07
    mov byte [ebx+4], 'l'
    mov byte [ebx+5], 0x07
    mov byte [ebx+6], 'l'
    mov byte [ebx+7], 0x07
    mov byte [ebx+8], 'o'
    mov byte [ebx+9], 0x07
    mov byte [ebx+10], ' '
    mov byte [ebx+11], 0x07
    mov byte [ebx+12], 'G'
    mov byte [ebx+13], 0x07
    mov byte [ebx+14], 'R'
    mov byte [ebx+15], 0x07
    mov byte [ebx+16], 'U'
    mov byte [ebx+17], 0x07
    mov byte [ebx+18], 'B'
    mov byte [ebx+19], 0x07
    mov byte [ebx+20], '!'
    mov byte [ebx+21], 0x07
    
    jmp $
