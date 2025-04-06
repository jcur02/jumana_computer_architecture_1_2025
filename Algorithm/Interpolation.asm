%include "macros.inc"

section .text
        global _start

_start:
    call _open
    call _read
    call _bilinear_interpolation
    call _write
    call _close
    call _exit

; Open file
_open:
    ; input
    mov rax, 5          ; sys_open
    mov rbx, baseImg    
    mov rcx, 0          
    mov rdx, 0777       
    int 0x80            ; execute
    mov [basem], rax    ; store 

    ; output
    mov rax, 8          ; sys_create
    mov rbx, interpolatedImg   
    mov rcx, 0          
    mov rdx, 0777o      
    int 0x80            ; execute
    mov [interpolatedm], rax   ; store 
    
    xor r9, 0  ; counter.

    ret

; Read file 
_read:
    mov rax, 3                ; sys_read
    mov rbx, [basem]          
    mov rcx, buffer           
    mov rdx, 4                
    int 0x80                   ; execute
    ; load 
    ascii2dec buffer, mult        
    mov  r10b, byte[rdx]      
    ; manage spaces
    cmp  r10, space             
    jz   _space             
    ; manage new line
    cmp  r10, newline           
    jz   _newLine           
    ; manage end of file
    cmp  r10, flag                 
    jne   _read                 

    mov [index], r15            
    concatenate res, index  
    xor r10, r10                
    xor r15, r15                
    mov [index], r15            
t:
    ret

; Load spaces
_space:
    mov [index], r15            
    concatenate res, index  
    add r15, 0x3                  
    jmp     _read

; Load new lines
_newLine:
    mov [index], r15            
    concatenate res, index  
    add r15, 0x1                
    add r15, px2    
    jmp     _read

; coordinate bilinear interpolation 
_bilinear_interpolation:
    call _vertical
    call _horizontal
    ret

; calculate vertical pixels
_vertical:
    clear_registers
    xor r15, 0                  
    mov [index], r15            
    jmp _vertical_columns
_vertical_end:
    ret

; Vertical pixels in columns
_vertical_columns:
    cmp r15, px             
    jge _vertical_end    
    push r15
    mov r14, 0                  
    add r14, r15                
    jmp _vertical_rows
_vertical_columns_aux:
    pop r15
    add r15, 3                  
    jmp _vertical_columns

; vertical pixels in rows
_vertical_rows:
    cmp r14, fixedLen             
    jge _vertical_columns_aux        ;
    push r14
    call _calculate_vertical
    pop r14
    add r14, px3    
    jmp _vertical_rows

; calculates vertical pixels values
_calculate_vertical:
    clear_registers
    mov bl, byte[res+r14]     
    mov rax, r14                
    add rax, px3    
    mov bh, byte[res+rax]     
    mov rax, r14                
    add rax, px             
    mov [interpolationIndex1], rax    
    mov rax, r14                
    add rax, px2    
    mov [interpolationIndex2], rax  
    linear_interpolation bl, bh
    mov al, cl
    push rbx
    concatenate res, interpolationIndex1      
    pop rbx
    linear_interpolation bh, bl
    mov al, cl
    concatenate res, interpolationIndex2      ; store value
    ret

; calculate horizontal pixels
_horizontal:
    clear_registers
    mov r15, 0                      
    mov r14, 0
    jmp _horizontal_columns
_horizontal_end:
    ret

; Horizontal pixels in columns
_horizontal_columns:
    cmp r15, len-3
    jge _horizontal_end      
    push r15
    call _calculate_horizontal
    pop r15
    add r15, 3                      
    test r15, r15                   
    jz _horizontal_columns
    xor rdx, rdx
    mov rax, r15
    add ax, 1
    mov ebx, px
    div ebx
    test edx, edx                    
    jnz _horizontal_columns          
    add  r15, 1                     
    jmp _horizontal_columns

; calculates horizontal pixels values
_calculate_horizontal:
    clear_registers
    mov bl, byte[res+r15]     
    mov rax, r15                
    add rax, 3                  
    mov bh, byte[res+rax]     
    mov rax, r15                
    add rax, 1                  
    mov [interpolationIndex1], rax    
    mov rax, r15                
    add rax, 2                  
    mov [interpolationIndex2], rax  
    linear_interpolation bl, bh
    mov al, cl
    push rbx
    concatenate res, interpolationIndex1      
    pop rbx
    linear_interpolation bh, bl
    mov al, cl
    concatenate res, interpolationIndex2      
    ret

; Write file
_write:
    mov r15, 1                  
    mov rax, 0                  
    mov rcx, 0                  
    mov rbx, 0                  
    mov rdx, 0                  
    mov r14, res       

_writing:
    movzx rax, byte[r14]           
    push_registers
    dec2ascii                    
    call _writeNumber
    mov rcx, px                 
    mov rax, r15                    
    mov rdx, 0                      
    div rcx                         
    cmp dx, 0
    jz _writing_newline
    writeFile varSpace, 1

_writing_aux:
    pop_registers
    add r15d, 1
    add r14, 1
    mov r13, len
    add r13, 1
    cmp r15, r13             
    jne _writing                    
    ret

; Write number
_writeNumber:
    mov sil, 3                      
    xor cl, cl                      
    mov rdx, buffer                 
_writeNumber_aux:
    mov bl, [rax+rcx]               
    mov byte[rax+rcx], 0x30         
    mov [rdx], bl                   
    push_registers
    writeFile buffer, 1                    
    pop_registers
    inc cl
    cmp cl, sil
    jne _writeNumber_aux 
    ret

; Write new line
_writeNewline:
    push_registers
    writeFile varNewline, 1
    pop_registers
    jmp _writing_aux

; Close file
_close:
    ; input
    mov rbx, [basem]    
    mov rax, 6          ; sys_close
    int 0x80             ; execute
    
    ; output
    mov rax, 6          ; sys_close
    mov rbx, [interpolatedm]   
    int 0x80             ; execute
    
    ret

_exit:
    mov rax, 1          ; sys_close
    mov rbx, 0
    int 0x80