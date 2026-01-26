org 0x7C00
bits 16

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

EnableA20:
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
    pop eat

A20WaitInput:
    ; wait until status bit 2 (input buffer) is 0
    ; readding status byte via command port
    in al, KbdControllerCommandPort
    test al, 2
    jnz A20WaitInput
    ret

A20WaitOutput:
    ; waint until satus bit 1, so it can be read
    in al, KbdControllerCommandPort
    test al, 1
    jz A20WaitOutput
    ret

.halt:
    jmp .halt

KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64
KbdControllerDisableKeyboard        equ 0xAD
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1

times 510-($-$$) db 0
dw 0AA55h
