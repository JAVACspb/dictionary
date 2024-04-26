%include "colon.inc"
%include "words.inc"
%include "lib.inc"


%define SIZE_OF_BUF 255




global _start

extern find_word


section .rodata
error_size_mes: db "Ошибка: Йоу, вы ввели слишком много символов. Норма для ключа - 255 символов", 0
error_name_key: db "Ошибка: Йоу, по вашему ключу значения нету. Попробуйте другой ключ.", 0

buffer: times SIZE_OF_BUF db 0


section .text

_start:
    mov rdi, buffer               ; кладем в rdi адрес начала буфера (аргумент read_word)
    mov rsi, SIZE_OF_BUF          ; кладем в rsi размер буфера (аргумент read_word)
    call read_word                ; читаем слово (rax - адрес где лежит слово, rdx длина слова)
    test rax, rax                 ; проверка на то, что слишком больой ключ
    jz .error_of_size_msg         ; выводим ошибку

    mov rdi, rax                  ; кладем в rdi адрес ключа
    mov rsi, next_el                 ; в rsi кладем указатель на следующуее вхождение
    push rdx                      ; пушим rdx (т к там длина ключа)
    call find_word                ; ищем слово
    pop rdx                       ; снимаем rdx
    test rax, rax                 ; проверка на то, что нету значения по такому ключу
    je .error_of_key

    mov rdi, rax                  ; кладем адрес нужного вхождения в rdi

    
  	add rdi, 8                    ; добавляем 8 (пропускаем указатель на след вхождение)
  	add rdi, 1                     
    add rdi, rdx                  ; пропускаем ключ
  	call print_string
    jmp .end
    .error_of_size_msg:
        mov rdi, error_size_mes
        call print_error
        jmp .end
    .error_of_key:
        mov rdi, error_name_key
        call print_error
    .end:
      call print_newline
      call exit




