; runs during boot in real mode and prints a message to the screen

org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, msg

.print:
    lodsb                 
    test al, al
    jz .wait_key
    mov ah, 0x0E          
    int 0x10               ; BIOS video service
    jmp .print

.wait_key:
    mov ah, 0x00           
    int 0x16               
.halt:
    cli
    hlt
    jmp .halt

msg db "Hello from BIOS in real mode!",0

times 510-($-$$) db 0
dw 0xAA55                  ; boot signature
