global start

section .text
bits 32
start:
    ; Point the first entry of the level 4 page table to the first entry in 
    ; the p3 table
    mov eax, p3_table   ; copies the contents of p3_table entry into the eax register
    or eax, 0b11        ; or contents of eax with 0b11, result written to eax
    mov dword [p4_table + 0], eax
    ; Point the first entry of the level 3 page table to the first entry in
    ; the p2 table
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each p2_table entry to a page (using a loop)

    ; Here’s the basic outline of loop in assembly:

    ; Create a counter variable to track how many times we’ve looped
    ; make a label to define where the loop starts
    ; do the body of the loop
    ; add one to our counter
    ; check to see if our counter is equal to the number of times we want to loop
    ; if it’s not, jump back to the top of the loop
    ; if it is, we’re done

    mov ecx, 0  ; counter var
.map_p2_table:  ; loop's label
    mov eax, 0x200000   ; 2MiB (each page is two megabytes in size)
    mul ecx             ; multiply ecx with eax, store result in eax
    or eax, 0b10000011  ; or operation
    mov [p2_table + ecx * 8], eax ; each entry is 8 bits long

    ; The inc instruction increments the register it’s given by one. ecx is our loop counter, so we’re
    ; adding to it. Then, we ‘compare’ with cmp. We’re comparing ecx with 512: we want to map 512 page
    ; entries overall. This will give us 512 * 2 mebibytes: one gibibyte of memory. 
    ; The jne instruction is short for ‘jump if not equal’.
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; ENABLE PAGING
    ; steps:
    ; - We have to put the address of the level four page table in a special register
    ; move page table address to cr3 (control register)
    mov eax, p4_table
    mov cr3, eax
    ; - enable ‘physical address extension’
    mov eax, cr4
    or eax, 1 << 5  ; left shifting
    mov cr4, eax
    ; - set the ‘long mode bit’
    mov ecx, 0xC0000080
    rdmsr   ; read model specific register
    or eax, 1 << 8
    wrmsr   ; write model specific register
    ; - enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    mov word [0xb8000], 0x0248 ; H
    mov word [0xb8002], 0x0265 ; e
    mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ; 
    mov word [0xb800e], 0x0277 ; w
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
    hlt

section .bss    ; block started by symbol

align 4096      ; addresses here will be set to a multiple of 4096

p4_table:
    resb 4096   ; reserve bytes
p3_table:
    resb 4096
p2_table:
    resb 4096
