%define next_el 0

%macro colon 2
    %ifid %2
        %2: dq next_el
    %else
        %error "второй аргумент должен быть идентификатором"
    %endif
    %ifstr %1
        db %1, 0
    %else
        %error "первый аргумент должен быть строкой"
    %endif
    %define next_el %2
%endmacro                
