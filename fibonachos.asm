; nasm -f elf64 fib1.asm; ld fib1.o -o fib1.x
; Trabalho: Fibonacci em ASSEMBLY
; ALUNO: Vinicius Vieir Viana

section .data
    fibo : dq 0
    quest db "Insira o número do termo que vc quer: "
    questL   :  equ $-quest
    msgerro db "Entrada ivalida, range de números vai de 1 a 2 digitos.", 10
    msgerroL :  equ $-msgerro
    excedido db "Valores maiores que 94 não são suportados.", 10
    bgnarch : db "fib(", 0
    endarch: db ").bin", 0

section .bss
    xtermo  : resb 3
    buffer  : resb 3
    fib_arq : resq 1
    txtarch : resb 30

section .text
    global _start

_start:
    ; write(fd, buf, size)
    mov rax, 1
    mov rdi, 1
    lea rsi, [quest]
    mov rdx, questL
    syscall

    ; read(fd, buf, size)
    mov rax, 0 ; inserindo a string do numero na variavel
    mov rdi, 0
    lea rsi, [xtermo]
    mov edx, 3
    syscall

comparation:
    cmp byte[xtermo + 1], 10 ; Comparando se foi lido apenas 1 digito
    je umdigito
    cmp byte[xtermo + 2], 10 ; Comparando se foi lido 2 digitos
    je doisdigitos

    sub al, '0'
    mov [buffer], al
    jne erro

umdigito:
    mov al, [xtermo]
    mov rbx, [bgnarch]
    mov [txtarch], rbx
    mov [txtarch + 4], al
    mov rbx, [endarch]
    mov [txtarch + 5], rbx
    mov bl, [endarch + 4]
    mov [txtarch + 9], bl  ; esses passos anteriores estão arrumando o nome do arquivo
    sub al, '0'
    mov [buffer], al
    mov [fib_arq], al

    cmp al, 0
    je arquivo
    cmp al, 1 ; caso especial para lidar com a inserção do numero 1
    je fib_1
    mov r15, 1
    mov r14, 0
    jmp fibonacci

doisdigitos:
    mov cl, [xtermo + 1]
    mov al, [xtermo]
    mov rbx, [bgnarch]
    mov [txtarch], rbx
    mov [txtarch + 4], al 
    mov [txtarch + 5], cl 
    mov rbx, [endarch] 
    mov [txtarch  + 6], rbx
    mov bl, [endarch + 4]
    mov [txtarch + 10], bl
    sub al, '0'
    sub cl, '0'
    imul ax, 10
    add al, cl
    mov [buffer], al
    cmp al, 94
    jge excedeu
    mov [fib_arq], al ; fib_arq = al
    mov r15, 1
    mov r14, 0

fibonacci: 
    mov r13, r15
    add r15, r14
    mov [fibo], r15
    mov r14, r13
    dec qword[fib_arq]
    cmp qword[fib_arq], 1 
    jne fibonacci 
    jmp arquivo

fib_1:
    mov qword[fibo], 1

arquivo:
    mov rax, 2
    lea rdi, [txtarch ]
    mov edx, 664o ; modo do arquivo
    mov esi, 102o ; flags 
    syscall

    mov r9, rax
    mov rax, 1
    mov rdi, r9
    mov rsi, fibo
    mov rdx, 8
    syscall

    mov rax, 3
    mov rdi, r9
    syscall ; fechando o arquivo

    jmp fim

erro:
    buffer_cleaner1:
        mov rax, 0 
        mov rdi, 0 
        lea rsi, [buffer]
        mov rdx, 1 
        syscall
        cmp byte [buffer], 10 
        jne buffer_cleaner1
        
    mov rax, 1
    mov rdi, 1
    mov rsi, msgerro
    mov rdx, msgerroL
    syscall
    jmp fim

excedeu:
    buffer_cleaner2: 
        mov rax, 0 
        mov rdi, 0 
        lea rsi, [buffer]
        mov rdx, 1
        syscall
        cmp byte [buffer], 10 ; verificando se o caractere é uma nova linha
        jne buffer_cleaner2
        
    mov rax, 1
    mov rdi, 1
    mov rsi, excedido
    mov rdx, 46
    syscall

fim:
    mov rax, 60
    mov rdi, 0
    syscall