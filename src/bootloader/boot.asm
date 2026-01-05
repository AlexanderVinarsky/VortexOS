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


putc_strynges:
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

    mov si, msg_hello
    call putc_strynges
    

	hlt

.halt:
	jmp .halt

msg_hello: db 'Hello, world!', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h
