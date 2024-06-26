extern string_equals

section .text
global find_word



find_word:
    .gen_loop:
        add rsi, 8          ; прибавляем к началу 8
        push rdi            ; пушим rdi (вдруг кто-то перепишет string_equals с использованием этих регистров...)
        push rsi            ; пушим rsi
        call string_equals  ; сравниваем строки
        pop rsi             ; снимаем rsi
        pop rdi             ; снимаем rdi
        cmp rax, 1          ; сравниваем на равенство
        je .end_ok          ; если равны, то бежим закончить прогу 

        sub rsi, 8          ; возвращаемся в начало вхождения (те самые 8 байт, в которых ссылка на след вхождение)
        mov r8, [rsi]       ; в r8 фигачим ссылку на след вхождение
        mov rsi, r8         ; кладем эту ссылку в rsi (т е теперь rsi указывает на след вхождение)
        test r8, r8         ; проверяем на то, что мы дошли до последнего вхождения
        jnz .gen_loop       ; если ссылка есть, то идем дальше
        
    .end_er:
        mov rax, 0          ; возврат 0, если ничего не нашли
        ret
    .end_ok:
        sub rsi, 8          ; возвращаемся на начало нужного нам вхождения (т к до этого rsi указывает на ключ)
        mov rax, rsi        ; возврат адреса начала вхождения
        ret
        
