    ; Runs on VGA MODE
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

    mov ax, 0x0013
    int 0x10

    mov word [x], 160
    mov word [y], 100
    mov byte [dir], 1
    mov word [score], 0
    mov word [food_x], 80
    mov word [food_y], 50

main:
    call read_key
    call clear_old
    call move_snake
    call check_food
    call draw_pixel
    call draw_food
    call draw_score
    call delay
    jmp main

read_key:
    mov ah, 0x01
    int 0x16
    jz .done
    xor ah, ah
    int 0x16
    cmp ah, 0x48
    jne .c1
      mov byte [dir], 0
      jmp .done
.c1:
    cmp ah, 0x4D
    jne .c2
      mov byte [dir], 1
      jmp .done
.c2:
    cmp ah, 0x50
    jne .c3
      mov byte [dir], 2
      jmp .done
.c3:
    cmp ah, 0x4B
    jne .done
      mov byte [dir], 3
.done:
    ret

clear_old:
    call calc_pos
    mov al, 0x00
    mov [es:di], al
    ret

move_snake:
    mov al, [dir]
    or al, al
    jnz .c1
      dec word [y]
      ret
.c1:
    cmp al, 1
    jne .c2
      inc word [x]
      ret
.c2:
    cmp al, 2
    jne .c3
      inc word [y]
      ret
.c3:
    dec word [x]
    ret

check_food:
    mov ax, [x]
    sub ax, [food_x]
    cmp ax, 3
    jg .no
    cmp ax, -3
    jl .no
    mov ax, [y]
    sub ax, [food_y]
    cmp ax, 3
    jg .no
    cmp ax, -3
    jl .no
    inc word [score]
    call spawn_food
.no:
    ret

spawn_food:
    xor ah, ah
    int 0x1A
    mov ax, dx
    and ax, 0xFF
    add ax, 20
    mov [food_x], ax
    int 0x1A
    mov ax, dx
    shr ax, 8
    add ax, 20
    mov [food_y], ax
    ret

draw_pixel:
    call calc_pos
    mov al, 0x0A
    mov [es:di], al
    ret

draw_food:
    push word [x]
    push word [y]
    mov ax, [food_x]
    mov [x], ax
    mov ax, [food_y]
    mov [y], ax
    call calc_pos
    mov al, 0x0C
    mov [es:di], al
    pop word [y]
    pop word [x]
    ret

calc_pos:
    push ax
    push cx
    mov ax, 0xA000
    mov es, ax
    mov ax, [y]
    mov cx, 320
    mul cx
    add ax, [x]
    mov di, ax
    pop cx
    pop ax
    ret

draw_score:
    push ax
    push bx
    push cx
    push di
    
    mov ax, 0xA000
    mov es, ax
    mov di, 10
    mov cx, 30
    xor al, al
.clr:
    stosb
    loop .clr
    
    mov ax, [score]
    mov bx, 10
    xor cx, cx
.dv:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .dv
    
    mov di, 10
.pr:
    pop ax
    add al, '0'
    sub al, 0x30
    shl al, 1
    add al, 0x0E
    mov [es:di], al
    add di, 2
    loop .pr
    
    pop di
    pop cx
    pop bx
    pop ax
    ret

delay:
    push ax
    push cx
    push dx
    mov cx, 0x0000
    mov dx, 0xC350
    mov ah, 0x86
    int 0x15
    pop dx
    pop cx
    pop ax
    ret

x       dw 160
y       dw 100
dir     db 1
score   dw 0
food_x  dw 80
food_y  dw 50

times 510-($-$$) db 0
dw 0xAA55