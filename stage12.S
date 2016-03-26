
.extern printf@PLT
.extern dlopen@PLT
.extern dlsym@PLT

.section .rodata
Lpregreet:
.asciz  "Stage 12: %s\n"
Lpostgreet:
.asciz  "Return value[12]: %s\n"
Lstage13so:
.asciz  "./libstage13.so"
Lstage13_blep:
.asciz  "stage13_blep"

.text
.globl stage12_blep
.type  stage12_blep, @function
stage12_blep:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r12
    movq    %rdi, %r12

    leaq    Lpregreet(%rip), %rdi
    movq    %r12, %rsi
    xor     %rax, %rax
    call    printf@PLT

    leaq    Lstage13so(%rip), %rdi
    movq    $2, %rsi # RTLD_NOW | RTLD_LOCAL
    call    dlopen@PLT

    movq    %rax, %rdi
    leaq    Lstage13_blep(%rip), %rsi
    call    dlsym@PLT

    mov     %r12, %rdi
    call    *%rax
    mov     %rax, %r12

    leaq    Lpostgreet(%rip), %rdi
    movq    %r12, %rsi
    xor     %rax, %rax
    call    printf@PLT

    mov     %r12, %rax
    popq    %r12
    movq    %rbp, %rsp
    popq    %rbp
    ret
