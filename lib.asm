section .text

global exit
global string_length
global print_string
global print_newline
global print_char
global print_uint
global print_int
global string_equals
global read_char
global print_error
global print 
global read_word
global parse_uint
global parse_int
global string_copy


%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define DES_STDOUT 1
%define DES_STDIN 0
%define DES_STDERR 2
%define TAB 9
%define NEW_LINE 0xA
%define SPACE ' '
%define DECIMAL_SYSTEM 10

; Принимает код возврата и завершает текущий процесс
exit:
    mov rax, SYS_EXIT
    syscall
 
; Принимает указатель на нуль-терминированную строку, возвращает её длину     
string_length:                                  
    xor rax, rax                                
    .loop:                                          
        cmp byte [rdi+rax], 0                       
        je .end_func                                     
        inc rax                                     
        jmp .loop
    .end_func:
        ret      


; функция print_error выводит в stderr
print_error:
    mov rcx, DES_STDERR          
    jmp print

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
; функция print_string выводит в stdout
print_string:
    mov rcx, DES_STDOUT

print:
    push rcx
    call string_length
    pop rcx
    mov rdx, rax
    mov rsi, rdi
    mov rdi, rcx
    mov rax, SYS_WRITE  ; номер системного вызова
    syscall
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, NEW_LINE            ; передаем аргумент функции print_char (код переноса строки), так как она будет выполняться следующей

; Принимает код символа и выводит его в stdout 
print_char:
    push rdi               ; кладем на стек, что бы получить через rsp ссылку
    mov rsi, rsp           ; ссылка на начало кода символа
    pop rdi                ; снимаем со стека - за собой надо убирать
    mov rdi, DES_STDOUT             ; дескрпитор stdout
    mov rax, SYS_WRITE             ; syscall 'whrite'
    mov rdx, 1             ; кол-во байтов для записи
    syscall
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    cmp rdi, 0
    jge print_uint
    neg rdi
    push rdi
    mov rdi, "-"
    call print_char
    pop rdi

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:                 
    mov rax, rdi            ; в rax у нас беззнаковое 8-байтовое число   
    mov r8, DECIMAL_SYSTEM              ; в r8 кладем 10, что бы отсекать число 
    mov rsi, rsp            ; сохраняем изначальное состояние стека
    dec rsp     
    mov byte [rsp], 0       ; нуль-шварцнейгер 
    
    .loop:
        xor rdx, rdx        ; rdx в 0
        div r8             ; делим rax на 10: целая часть -> rax; остаток -> rdx
        add rdx, '0'        ; переводим число в ASCII код
        dec rsp             ; уменьшеам стек, что бы в дальнейшем положить код
        mov [rsp], dl       ; кладем код в стек 
        test rax, rax       ; проверяем на 0
        jnz .loop           ; если не 0, то идем дальше
    .general_print:
        mov rdi, rsp        ; кладем указатель на начало строки в rdi (на вход функции)
        push rsi            ; кладем на стек, что бы сохранить изначальное значение 
        call print_string   ; вызываем печать строки 
        pop rsp             ; возвразаем изначальное состояние стека
        ret
    

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе

string_equals:
    ; rdi - указатель на первую строку
    ; rsi - указатель на вторую строку
    xor r8, r8      ; счетсик для первой строки
    xor r9, r9      ; счетчик для второй строки

    .loop:
        mov dl, byte [rdi]
        cmp dl, byte [rsi]
        jne .end_error
        inc rdi
        inc rsi
        cmp dl, 0
        jne .loop
        jmp .end_ok
    .end_ok:
        xor rax, rax
        inc rax
        ret
    .end_error:
        xor rax, rax
        ret


; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    mov rax, SYS_READ                  ; read syscall
    push rax
    mov rdi, DES_STDIN                  ; дескрпитор stdin
    mov rdx, 1                  ; кол-во байт
    mov rsi, rsp
    syscall
    pop rax
    ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
; rdi - адрес начала буфера, rsi - размер буфера

read_word:
    push r8            ; регистр для хранения адреса буфера 
    push r9            ; регистр для хранения размера буфера
    push r10           ; счётчик
    mov r8, rdi        ; помещаем в r8 адрес начала буфера
    mov r9, rsi        ; помещаем в r9 размер буфера
    xor r10, r10
    .start_loop:
        call read_char
        cmp rax, SPACE
        je .start_loop
        cmp rax, TAB
        je .start_loop
        cmp rax, NEW_LINE
        je .start_loop
    .general_read:
        cmp r10, r9
        je .end_error
        cmp rax, 0x0
        je .end_ok
        cmp rax, SPACE
        je .end_ok
        cmp rax, TAB
        je .end_ok
        cmp rax, NEW_LINE
        je .end_ok
        mov byte[r8], al
        inc r10
        cmp r10, r9         ; на всякий чекаем, хватит ли места для нуль-шварцнейгера?
        je .end_error  
        inc r8
        call read_char
        jmp .general_read
    .end_error:
        pop r10
        pop r9
        pop r8
        xor rax, rax
        ret
    .end_ok:
        mov byte [r8], 0
        sub r8, r10
        mov rax, r8
        mov rdx, r10
        pop r10
        pop r9
        pop r8 
        ret
 

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rax, rax
    xor r8, r8
    mov rcx, 0xA
    .loop:
        movzx rsi, byte [rdi]
        cmp sil, 0
        je .end
        cmp sil, '9'
        ja .end
        cmp sil, '0'
        jb .end
        mul rcx
        sub sil, '0'
        add rax, rsi
        inc rdi
        inc r8
        jmp .loop
    .end:
        mov rdx, r8
        ret




; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    cmp byte [rdi], '-'
    jne parse_uint
    inc rdi
    call parse_uint ; парсим беззнаковое
    neg rax         ; меняем знак
    inc rdx         ; увеличиваем кол-во
    ret    

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    test rdx, rdx               ; делаем логическое 'И' и устанавливаем флаги
    jz .error_length            ; если флаг zero есть, то переходим к возврату нуля
    push rdi                    ; указатель на строку на стек
    push rsi                    ; указаель на буфер на стек
    push rdx                    ; длина буфера на стек
    call string_length          ; считаем длину строки -> результат в rax
    pop rdx                     ; длину буфера снимаем со стека
    pop rsi                     ; указатель на буфер снимаем со стека
    pop rdi                     ; указатель на строку снимаем со стека
    inc rax                     ; инкремент rax, что бы учитывать нуль-терминатор
    cmp rax, rdx                ; сравниваем длину строки и длину буфера
    ja .error_length
    push rax                            ; если длина строки больше длины буфера, то переходим к возврату нуля
    .loop:                      ; цикл для копирования
        mov cl, byte [rdi]      ; копируем строку в буфер через регистр cl (младший байт rcx)
        mov byte [rsi], cl      ; копируем строку в буфер через регистр cl (младший байт rcx)
        inc rdi                 ; увеличиваем указатель строки 
        inc rsi                 ; увеличиваем указатель буфера
        dec rax                 ; уменьшаем rax (значнеие в rax в качестве итерационной переменной)
        test rax, rax           ; установка флагов после операции побитового 'И'
        jz .return_length       ; Если 0, то заканчиваем
        jmp .loop               ; безусловный переход
    .error_length:
        mov rax, 0              ; возврат 0, т к размер буфера меньше размера строки
        ret
    .return_length:
        pop rax                 ; достаем длину строки из стека
        dec rax                 
        ret
