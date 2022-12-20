; Define constants
%define KERNEL_LOAD_ADDRESS 0x9000       ; Load kernel at this address in memory
%define KERNEL_SECTOR_COUNT 8            ; Number of sectors to load (starting from sector 2)
%define KERNEL_SECTOR_SIZE  512          ; Size of each sector in bytes
%define DISK_SERVICE_READ_SECTORS 0x02   ; BIOS function code for reading sectors
%define INT_VECTOR_DISK_SERVICE  0x13    ; BIOS interrupt vector for disk services
%define GRAPHICS_SERVICE_SET_VGA_MODE 0x00 ; BIOS function code for setting the VGA graphics mode
%define INT_VECTOR_GRAPHICS_SERVICE 0x10  ; BIOS interrupt vector for graphics services

; Set up BIOS disk services input structure
disk_service_input:
  drive_number    db  ?
  sector_count    dw  ?
  cylinder        dw  ?
  sector          db  ?
  head            db  ?
  sector_size     dw  ?
  lba             dd  ?
  memory_address  dd  ?

; Set up BIOS disk services output structure
disk_service_output:
  status  db  ?
  error   db  ?

; Set up BIOS graphics services input structure
graphics_service_input:
  mode   dw  ?

; Set up BIOS graphics services output structure
; graphics_service_output:
;   status  db  ?
;   error   db  ?

; Read sectors from the disk
%macro read_sectors 1
  mov eax, DISK_SERVICE_READ_SECTORS
  mov ebx, %1
  int INT_VECTOR_DISK_SERVICE
%endmacro

; Set the VGA graphics mode
%macro set_vga_mode 1
  mov eax, GRAPHICS_SERVICE_SET_VGA_MODE
  mov ebx, %1
  int INT_VECTOR_GRAPHICS_SERVICE
%endmacro

; Set up the stack and data segments
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x9000

; Set the VGA graphics mode
call set_vga_mode 0x13

; Set up the BIOS disk services input structure
mov byte [disk_service_input.drive_number], 0      ; Drive number (e.g. 0x00 for floppy, 0x80 for hard drive)
mov word [disk_service_input.sector_count], KERNEL_SECTOR_COUNT   ; Number of sectors to read
mov dword [disk_service_input.lba], 1            ; LBA (logical block address) of the first sector (sector 2)
mov dword [disk_service_input.memory_address], KERNEL_LOAD_ADDRESS ; Memory address to load the sectors to
mov word [disk_service_input.sector_size], KERNEL_SECTOR_SIZE     ; Size of each sector in bytes

; Read the kernel sectors from the disk
call read_sectors disk_service_input

; Check the BIOS disk services output structure for errors
mov al, [disk_service_output.status]
cmp al, 0
jne .error

; Jump to the kernel entry point
jmp KERNEL_LOAD_ADDRESS

; Display an error message and halt
.error:
  mov ah, 0x0E
  mov al, 'E'
  int 0x10
  jmp .error