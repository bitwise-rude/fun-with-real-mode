;  Cool BIOS Bootloader Demo
;  Assemble with: nasm -f bin boot.asm -o boot.bin
;  Run in QEMU:   qemu-system-x86_64 -fda boot.bin


BITS 16               
ORG 0x7C00               ; IMPORTANT:every BIOS loads boot sector at 0x7C00

start:
    cli                 
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00     
    sti


    mov ax, 0x0600      
    mov bh, 0x07        
    mov cx, 0x0000      
    mov dx, 0x184F      
    int 0x10


    mov ah, 0x0E        
    mov si, msg_title
print_title:
    lodsb              
    or  al, al
    jz  wait_key
    int 0x10
    jmp print_title

wait_key:

    mov ah, 0x00
    int 0x16           
    mov bl, al        


    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10


    mov si, msg_key
print_msg:
    lodsb
    or  al, al
    jz  print_key
    mov ah, 0x0E
    int 0x10
    jmp print_msg

print_key:
    mov ah, 0x0E
    mov al, bl         
    int 0x10


hang:
    jmp hang


msg_title db "=== MEYAN BOOTLOADER ===", 0
msg_key   db "You pressed: ", 0


times 510-($-$$) db 0
dw 0xAA55
