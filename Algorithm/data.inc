px equ 3*n-2
len equ px*px
px2 equ 2*px
px3 equ 3*px
fixedLen equ len - px3 
mult  equ 100
space       equ 32
newline     equ 10
tab         equ 09
flag          equ 70
n equ 97

section .data
    baseImg   db  '../imgIn.img', 0      
    interpolatedImg    db  '../imgOut.img', 0    
    varSpace db	'',32
    varNewline db	'',0xA
    res TIMES len db 0       
    numRes TIMES 3 db 0x30

section .bss
    basem       resb    4      
    interpolatedm      resb    4      
    buffer      resd     1     
    interpolationIndex1    resd     4     
    interpolationIndex2    resd     4     
    index            resd     4     