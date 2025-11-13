

[org 0x7C00]

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax, 0x0013
    int 0x10


main:
    mov al, [color]       
    call fill_screen       
    call delay            
    inc byte [color]       
    jmp main

fill_screen:
    push ax
    push es
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 320*200        
    rep stosb
    pop es
    pop ax
    ret


delay:
    mov cx, 0xFFFF
.d1: loop .d1
    ret

color db 0

times 510-($-$$) db 0
dw 0xAA55
