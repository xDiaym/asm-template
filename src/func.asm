bits 64
default rel

section .text
global f

kA      dd 2.0
kHalfA  dd 1.0

f:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    ; load 1st into fpu
    movss   dword [rbp-4], xmm0
    fld     dword [rbp-4]

    ; unload result from fpu
    fst     dword [rbp-4]
    movss   xmm0, dword [rbp-4]

    add     rsp, 16
    pop     rbp
    ret