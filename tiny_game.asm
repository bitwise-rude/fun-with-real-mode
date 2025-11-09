; Tiny bootable move-game (real mode)
; Avengers assemble: nasm -f bin game.asm -o game.bin
; Run:     qemu-system-x86_64 -fda game.bin

; must have qemu and nasm installed
BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax, 0xB800
    mov es, ax

    mov di, 0
    mov cx, 2000        
.clear_loop:
    mov byte [es:di], ' '   
    mov byte [es:di+1], 0x07 
    add di, 2
    loop .clear_loop

    mov byte [player_row], 12
    mov byte [player_col], 40

    call draw_player

main_loop:
  
    xor ah, ah
    int 0x16            
    mov al, ah           
    cmp al, 0x48         
    je .move_up
    cmp al, 0x50         
    je .move_down
    cmp al, 0x4B        
    je .move_left
    cmp al, 0x4D         
    je .move_right
    cmp al, 0x1B        
    je .exit
    jmp main_loop

.move_up:
    mov al, [player_row]
    cmp al, 0
    je .skip_redraw
    call erase_player
    dec byte [player_row]
    call draw_player
    jmp main_loop

.move_down:
    mov al, [player_row]
    cmp al, 24
    je .skip_redraw
    call erase_player
    inc byte [player_row]
    call draw_player
    jmp main_loop

.move_left:
    mov al, [player_col]
    cmp al, 0
    je .skip_redraw
    call erase_player
    dec byte [player_col]
    call draw_player
    jmp main_loop

.move_right:
    mov al, [player_col]
    cmp al, 79
    je .skip_redraw
    call erase_player
    inc byte [player_col]
    call draw_player
    jmp main_loop

.skip_redraw:
    jmp main_loop

draw_player:
    push ax
    push bx
    push cx
    push dx
    movzx ax, byte [player_row]  ; ax = row
    mov bx, ax
    shl ax, 6          
    mov cx, bx
    shl cx, 4           
    add ax, cx           
    add ax, word [player_col] 
    shl ax, 1            
    mov di, ax
    mov byte [es:di], '@'
    mov byte [es:di+1], 0x0E
    pop dx
    pop cx
    pop bx
    pop ax
    ret

erase_player:
    push ax
    push bx
    push cx
    push dx
    movzx ax, byte [player_row]
    mov bx, ax
    shl ax, 6
    mov cx, bx
    shl cx, 4
    add ax, cx
    add ax, word [player_col]
    shl ax, 1
    mov di, ax
    mov byte [es:di], ' '
    mov byte [es:di+1], 0x07
    pop dx
    pop cx
    pop bx
    pop ax
    ret

.exit:
    mov si, exit_msg
.print_exit:
    lodsb
    or al, al
    jz .halt
    mov ah, 0x0E
    int 0x10
    jmp .print_exit

.halt:
    cli
    hlt
    jmp .halt


player_row  db 0
player_col  db 0

exit_msg db 13,10, "Goodbye! (press nothing)", 0

; padding + sigature
times 510-($-$$) db 0
dw 0xAA55
