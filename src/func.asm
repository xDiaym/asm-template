bits 64
default rel

extern log

section .text
global f

%define PI 314
kA      dd 2.0
kHalfA  dd 1.0
kSignMask dd 0x7fffffff

; x^4+2x^3-2x-6=0 [-3,-2] newton eps=1e-3,1e-4,1e-5,1e-6 table+plot

f:
    push    rbp
    mov     rbp, rsp

    subss   xmm0, [kHalfA]
    
    ; xmm0 := abs(xmm0)
    movss   xmm1, [kSignMask]
    andps   xmm0, xmm1

    ; xmm0 := log(xmm0)
    cvtss2sd xmm0, xmm0
    call log wrt ..plt
    cvtsd2ss xmm0, xmm0

    pop     rbp
    ret