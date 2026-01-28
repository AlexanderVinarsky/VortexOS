org 0x7C00
bits 16


; from Intel® 64 and IA-32 Architectures Software Developer Manuals

; stack setup 
entry:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 7C00h

    ; switch to protected mode
    cli                 ; 1 - disable interrupts
    call EnableA20      ; 2 - Enable A20 Gate
    call LoadGDT        ; 3 - Load Global Descriptor Table

    ; 4 - set protection enable flag in CR0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; 5 - far jump into protected mode
    jmp dword 08h:.pmode





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.pmode:
    ; now opeating in 32-bit protected mode
    [bits 32]
    
    ; 6 - segment registers setup 
    mov ax, 0x10
    mov ds, ax 
    mov ss, ax

    ; print a message
    mov esi, g_Chloe
    mov edi, ScreenBuffer
    cld 









.loop:
    lodsb
    or al, al
    jz .done 

    mov [edi], al 
    inc edi 

    mov [edi], byte 0x3
    inc edi 
    jmp .loop






.done:


.halt:
    hlt
    jmp .halt


EnableA20:
    [bits 16]
    ; disable keyboardd
    call A20WaitInput
    mov al, KbdControllerDisableKeyboard
    out KbdControllerCommandPort, al


    ; read control output port
    call A20WaitInput
    mov al, KbdControllerReadCtrlOutputPort
    out KbdControllerCommandPort, al

    call A20WaitOutput
    in al, KbdControllerDataPort
    push eax


    ; write control output port
    call A20WaitInput
    mov al, KbdControllerWriteCtrlOutputPort
    out KbdControllerCommandPort, al
    
    call A20WaitInput
    pop eax
    or al, 2
    out KbdControllerDataPort, al


    ; reenabling the keyboard
    call A20WaitInput
    mov al, KbdControllerEnableKeyboard
    out KbdControllerCommandPort, al

    call A20WaitInput
    ret


;
;(mask 0x02) IBF (Input Buffer Full)
;   1 -> cant write into 0x64/0x60 (not yet received the previous byte)
;   0 -> can write
;(mask 0x01) OBF (Output Buffer Full)
;   1 -> 0x60 can be read
;   0 -> nothing to read
;

A20WaitInput:
    [bits 16]
    ; wait until status bit 2 (input buffer) is 0
    ; readding status byte via command port
    in al, KbdControllerCommandPort
    test al, 2
    jnz A20WaitInput
    ret

A20WaitOutput:
    [bits 16]
    ; waint until satus bit 1, so it can be read
    in al, KbdControllerCommandPort
    test al, 1
    jz A20WaitOutput
    ret

LoadGDT:
    [bits 16]
    lgdt [g_GDTDesc]
    ret

KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64
KbdControllerDisableKeyboard        equ 0xAD
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1

ScreenBuffer                        equ 0xB8000

g_GDT:      ; NULL descriptor
            dq 0

            ; 32-bit code segment
            dw 0FFFFh               ; limit (bits 0-15)  = 0xFFFFFFFF for full 32-bit range
            dw 0                    ; base  (bits 0-15)  = 0x0
            db 0                    ; base  (bits 16-23)
            db 10011010b            ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 11001111b            ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                    ; base high

            ; 32-bit code segment
            dw 0FFFFh              
            dw 0                    
            db 0                    
            db 10010010b            ; access (present, ring 0,      -> data <-    segment, executable, direction 0, readable)
            db 11001111b            
            db 0                    

            ; 16-bit code segment
            dw 0FFFFh             
            dw 0                    
            db 0                    
            db 10011010b            ; access (...,      -> code <-    segment, ...)
            db 00001111b            ; granularity (     -> 1b pages, 16-bit <-     pmode) ...
            db 0                   

            ; 16-bit code segment
            dw 0FFFFh               
            dw 0                    
            db 0                    
            db 10010010b            ; access (...,      -> data <-    segment, ...)
            db 00001111b            ; granularity (     -> 1b pages, 16-bit <-     pmode) ...
            db 0         


g_GDTDesc:  dw g_GDTDesc - g_GDT - 1 ; limit = size of GDT
            dd g_GDT                 ; address of GDT      

g_Chloe:    db "Hiii, Max! Look, I dyed my hair blue!", 0

times 510-($-$$) db 0
dw 0AA55h
