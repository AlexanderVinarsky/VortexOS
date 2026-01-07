org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A


;
; FAT12 header
;
jmp short start
nop

bdb_oem:					db 'MSVIN4.1'			; W->V! (8 bytes)
bdb_bytes_per_sector:		dw 512
bdb_sectors_per_cluster: 	db 1
bdb_reserved_sectors:		dw 1
bdb_fat_count:				db 2
bdb_dir_entries_count:		dw 0E0h
bdb_total_sectors: 			dw 2880					; 2880 * 512 = 1.44MB
bdb_media_descriptor:		db 0F0h					; F0 = 3.5" floppy disk
bdb_sectors_per_fat:		dw 9
bdb_sectrors_per_track:		dw 18
bdb_heads:  				dw 2
bdb_hidden_sectors:			dd 0
bdb_large_sectors_count:	dd 0



;
; extended boot record
;
ebr_drive_number:			db 0					; 0x00 = floppy
							db 0
ebr_signature:				db 29h
ebr_volume_id:				db 27h, 03h, 20h, 03h	; serial number, ml
ebr_volume_label:			db 'VORTEX   OS'		; 11 bytes padded
ebr_system_id:				db 'FAT12   '			; 8 bytes




start:
	jmp main


puts:
	push si
	push ax

.loop:
	lodsb
	or al, al
	jz .done

	

	mov ah, 0x0e
	mov bh,0
	int 0x10

    jmp .loop

.done:
	pop ax
	pop si
	ret


main:

    mov ax, 0
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00

	; read something from floppy disk
	; BIOS should set DL to drive number
	mov [ebr_drive_number], dl


	mov ax, 1							; LBA=1, second sector from disk
	mov cl, 1							; 1 sector to read
	mov bx, 0x7E00						; data after the bootloader
	call disk_read


    mov si, msg_hello
    call puts
    
	cli 								; disable interrupts, so CPU won't get out of the halt state
	hlt

;
; Error handlers
;

floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h								; wait for keypress
	jmp 0FFFFFh:0						; jump to the begginning of BIOS, should reboot

.halt:
	cli 								; disable interrupts, so CPU won't get out of the halt state
	hlt 



;
;	Disk routines
;

;
; Converts an LBA address to a CHS (cylinder, head, sector) address
; Parameters:
;	-ax: LBA address
; Returns:
;	-cx [bits 0-5]:  sector number
;	-cx [bits 6-15]: cylinder

lba_to_chs:
	
	push ax
	push dx

	xor dx, dx							
	div word [bdb_sectrors_per_track]	; ax = LBA / sectors_per_track
										; dx = LBA % sectors_per_track
										; dx = (LBA % sectors_per_track + 1) = sector
	
	inc dx								; dx = (LBA % sectors_per_track)
	mov cx, dx							; cx = sector

	xor dx, dx							; dx = 0
	div word [bdb_heads]				; ax = (LBA / sectors_per_track) / heads = cylinder
										; dx = (LBA / sectors_per_track) % heads = head
	mov dh, dl							; dh = head
	mov ch, al							; ch = cylinder (lower 8 bits)
	shl ah, 6			
	or cl, ah							; put upper 2 bits of cylinder in CL

	pop ax
	mov dl, al
	pop ax
	ret



;
; Reads sectors from the disk
; Parameters:
;	- ax: LBA address
;	- cl: number of sectors to read (<=128)
;	- dl: drive number
;	- es:bx: memory address to store read data in
;
disk_read:
	push ax								; saving registers before moifying
	push bx
	push cx
	push dx
	push di

	push cx								; temporarily sa
	call lba_to_chs						; compute CHS
	pop ax								; AL - numbeer of sectors to read

	mov ah, 02h
	mov di, 3

.retry:
	pusha								; save all registers
	stc 								; set carry flag
	int 13h								; carry flag created -> success
	jnc .done							; jump iff carry not set

	; read failed
	popa
	call disk_reset

	dec di 
	test di, di
	jnz .retry

.fail:
	jmp floppy_error

.done:
	popa

	pop di								; saving registers before moifying
	pop dx
	pop cx
	pop bx
	pop ax
	ret

;
; Resets disk controller
; Params:
;	dl: drive number
;
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret

msg_hello: 				db 'Hello, world!', ENDL, 0
msg_read_failed:	 	db 'Read from disk failed', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h
