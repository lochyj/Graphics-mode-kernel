[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x9000    ; Load the kernel into memory with an offset of 0x9000 to allow for the boot loader


mov [BOOT_DRIVE], dl        ; Get the boot drive from the bios stored at dl


mov bp, 0xF000              ; Setting up the stack
mov sp, bp                  ; "


call load_kernel            ; Calling to the kernel loader


call switch_to_32bit        ; Switching to 32 bit protected mode so we can load c code

jmp $

%include "boot/print_16bit.asm"
%include "boot/print_32bit.asm"
%include "boot/disk.asm"
%include "boot/gdt.asm"
%include "boot/switch_to_32bit.asm"

[bits 16]

; Loading the kernel
load_kernel:
    mov bx, KERNEL_OFFSET   ; bx --> offset of the kernel
    mov dh, 31              ; dh --> number of sectors to read ; This was the source of many many hours of suffering
    mov dl, [BOOT_DRIVE]    ; dl --> boot drive
    call disk_load          ; call disk_load to load the kernel
    ret

[bits 32]
BEGIN_32BIT:
    mov ebx, MSG_32BIT_MODE
    call print32
    call KERNEL_OFFSET      ; call the kernel
    jmp $                   ; jump to the end of the file

BOOT_DRIVE db 0 ; The boot drive
MSG_16BIT_MODE db "16 bit real mode", 0
MSG_32BIT_MODE db "32 bit protected mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

times 510 - ($-$$) db 0      ; Padding to make the file 510 bytes

dw 0xaa55                   ; The MAGIC NUMBER!! The boot loader will check for this to make sure it is a boot loader