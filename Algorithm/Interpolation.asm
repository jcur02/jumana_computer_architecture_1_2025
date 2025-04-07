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
    mov  r8b, byte[rdx]      
    ; manage spaces
    cmp  r8, space             
    jz   _space             
    ; manage new line
    cmp  r8, newline           
    jz   _newLine           
    ; manage end of file
    cmp  r8, flag                 
    jne   _read                 

    mov [index], r13            
    concatenate res, index  
    xor r8, r8                
    xor r13, r13                
    mov [index], r13            
t:
    ret

; Load spaces
_space:
    mov [index], r13            
    concatenate res, index  
    add r13, 0x3                  
    jmp     _read

; Load new lines
_newLine:
    mov [index], r13            
    concatenate res, index  
    add r13, 0x1                
    add r13, px2    
    jmp     _read

; coordinate bilinear interpolation 
_bilinear_interpolation:
    call _vertical ; First do vertical pixels, doing intermediate pixels also in the process
    call _horizontal ; then horizontal pixels
    ret

; calculate vertical pixels
_vertical:
    clear_registers
    xor r13, 0                  
    mov [index], r13 ; store index value        
    jmp _intermediate_columns 
_vertical_end:
    ret

; Vertical and intermediate pixels in columns
_intermediate_columns:
    cmp r13, px             
    jge _vertical_end ; finished 
    push r13
    mov r12, 0                  
    add r12, r13                
    jmp _intermediate_rows  ; start interpolating on the row
_intermediate_columns_aux:
    pop r13
    add r13, 3                  
    jmp _intermediate_columns ; move to next column

; vertical and intermediate pixels in rows
_intermediate_rows:
    cmp r12, fixedLen             
    jge _intermediate_columns_aux ; finished interpolating row
    push r12
    call _calculate_vertical    ; get vertical values then get intermediate value
    pop r12
    add r12, px3    
    jmp _intermediate_rows  ; next row

; calculates vertical and intermediate pixels values
_calculate_vertical:
    clear_registers
    mov bl, byte[res+r12]   ; get near value x     
    mov rax, r12                
    add rax, px3    
    mov bh, byte[res+rax]   ; get near value y
    mov rax, r12                
    add rax, px             
    mov [interpolationIndex1], rax ; index where calculated value goes   
    mov rax, r12                
    add rax, px2    
    mov [interpolationIndex2], rax ; index where second calculated value goes  
    linear_interpolation bl, bh ; interpolate x and y
    mov al, cl ; store result
    push rbx
    concatenate res, interpolationIndex1 ; put result on the pixels array   
    pop rbx
    linear_interpolation bh, bl ; same as before but now interpolating y and x
    mov al, cl
    concatenate res, interpolationIndex2 ; put result on the pixels array
    ret

; calculate horizontal pixels
_horizontal:
    clear_registers
    mov r13, 0                      
    mov r12, 0
    jmp _horizontal_aux ; start getting horizontal pixels
_horizontal_end:
    ret

; Horizontal pixels
_horizontal_aux:
    cmp r13, len-3 
    jge _horizontal_end ; finished       
    push r13
    call _calculate_horizontal    ; get horizontal values
    pop r13
    add r13, 3                      
    test r13, r13                   
    jz _horizontal_aux ; base case
    xor rdx, rdx
    mov rax, r13
    add ax, 1
    mov ebx, px
    div ebx
    test edx, edx                    
    jnz _horizontal_aux ; finished set of horizontal values?          
    add  r13, 1                       
    jmp _horizontal_aux ; move onto the next set of horizontal values

; calculates horizontal pixels values
_calculate_horizontal:
    clear_registers
    mov bl, byte[res+r13] ; get near value x     
    mov rax, r13                
    add rax, 3                  
    mov bh, byte[res+rax] ; get near value y     
    mov rax, r13                
    add rax, 1                  
    mov [interpolationIndex1], rax ; index where calculated value goes    
    mov rax, r13                
    add rax, 2                  
    mov [interpolationIndex2], rax ; index where second calculated value goes 
    linear_interpolation bl, bh ; interpolate x and y
    mov al, cl
    push rbx
    concatenate res, interpolationIndex1 ; put result on the pixels array       
    pop rbx
    linear_interpolation bh, bl ; interpolate y and x
    mov al, cl
    concatenate res, interpolationIndex2 ; put result on the pixels array       
    ret

; Write file
_write:
    mov r13, 1                  
    mov rax, 0                  
    mov rcx, 0                  
    mov rbx, 0                  
    mov rdx, 0                  
    mov r12, res       

_writing:
    movzx rax, byte[r12]           
    push_registers
    dec2ascii                    
    call _writeNumber
    mov rcx, px                 
    mov rax, r13                    
    mov rdx, 0                      
    div rcx                         
    cmp dx, 0
    jz _writeNewline
    writeFile varSpace, 1

_writing_aux:
    pop_registers
    add r13d, 1
    add r12, 1
    mov r10, len
    add r10, 1
    cmp r13, r10             
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