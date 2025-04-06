%include "data.inc"

; push registers on the stack
%macro push_registers 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

; pop registers from the stack
%macro pop_registers 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; clears registers from the stack
%macro clear_registers 0
    mov rax, 0
    mov rbx, 0
    mov rcx, 0
    mov rdx, 0
    mov rsi, 0
    mov rdi, 0
%endmacro

; module operation
%macro module 1
    mov edx, 0             
    mov ebx, %1            
    div ebx 
%endmacro

; ascii to decimal conversion
%macro ascii2dec 2
    mov  rdx, %1                
    mov  rbx, %2                
    mov  rcx, 0      

%%a2d_loop:
    mov  rax, 0                 
    mov  al, byte[rdx]          
    sub     rax, 48             
    push    rdx                 
    mul     rbx                 
    add     rcx, rax            
    pop     rdx                 
    push    rax                 
    mov     rax, rbx            
    push    rdx                 
    module     10                  
    mov     rbx, rax            
    pop     rdx                 
    pop     rax                 

    cmp     rbx, 0              
    jz      %%a2db       

    inc     rdx                 
    jmp     %%a2d_loop

%%a2db:
    inc     rdx               
    mov   rax, rcx            
%endmacro

; decimal to ascii conversion
%macro dec2ascii 0
    mov rcx, 10                     
    mov r8, 2
    mov rsi, numRes         

 %%d2a:
    xor rdx, rdx                    
    div rcx                         
    add dl, '0'                     
    lea rbx, [rsi+r8]                  
    mov [rbx], dl                   
    mov r11,rdx
    sub r8, 1
    test rax, rax                   
    jnz %%d2a                    
    mov rax, numRes         
%endmacro

; concatenate number to array
%macro concatenate 2
    mov  rbx,[%2]          
    mov  [%1+rbx], al      
%endmacro

; write line in file
%macro writeFile 2
    mov rax, 4                  ; sys_write
    mov rbx, [interpolatedm]           
    mov rcx, %1                 
    mov rdx, %2                  
    int 0x80                     ; execute
%endmacro

; interpolation algorithm
%macro linear_interpolation 2
    xor  rax, rax           
    xor  rcx, rcx           
    mov  al, %1             
    mov  dl, 2              
    mul  dl                 
    mov  dl, 3              
    div  dl                 
    mov cl, al              

    xor  rax, rax           
    mov  al, %2             
    mov  dl, 3              
    div  dl                 
    add  cl, al             
    xor  rax, rax           
%endmacro