; ----------------------------------------------------------------------
; Reading from the disk. The table below explains the asm instructions!|
; ----------------------------------------------------------------------
; ---------------------------------------
; REGISTER  Paramater                   |
; AH        Mode (0x02 = read from disk)|
; AL        Number of sectors to read   |
; CH        Cylinder number             |
; CL        Sector number               |
; DH        Head number                 |
; DL        Drive number                |
; ES:BX     Buffer address              |
; ---------------------------------------

disk_load:
    pusha
    push dx

    mov ah, 0x02        ; Read mode
    mov al, dh          ; Number of sectors to read
    mov cl, 0x02        ; Start read at sector 2 <- currently this will go to sector 17
                        ; This is due to the fact that the first sector is our boot loader!

    mov ch, 0x00         ; Start read at cylinder 0
    mov dh, 0x00         ; Start read at head 0

    int 0x13            ; Call the BIOS interrupt
    jc disk_error       ; If the carry flag is set, then there was an error!

    pop dx              ; Get the original number of sectors to read
    cmp al, dh          ; Compare the number of sectors read with the number of sectors to read
                        ; If the number of sectors read is less than the number of sectors to read then there was an error!

    jne sectors_error   ; Jump to the sectors_error label if the number of sectors read is less than the number of sectors to read

    popa
    ret

sectors_error:
    mov bx, SECTOR_ERROR
    jmp disk_loop       ; If there was an error, then jump back to the disk_loop label

disk_error:
    mov bx, DISK_ERROR
    call print16
    call print16_nl
    mov dh, ah
    call print16_hex
    jmp disk_loop       ; If there was an error, then jump back to the disk_loop label

disk_loop:
    jmp $               ; If there was an error, then jump back to the beginning of the code

DISK_ERROR: db "Disk read error: ", 0
SECTOR_ERROR: db "Sector read error: ", 0