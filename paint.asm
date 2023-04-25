; fasm code..............
org 100h
jmp start
 
color   db    0          ;<--------; переменная с цветом
 
start:  
		;push es
		mov   ax,13h               ; ставим режим 320х200/256
        int   10h                  ;
        push  0A000h               ; настроимся на видео/буфер
        pop   es                   ;
        call  CreatePalette        ; рисуем палитру
 
        xor   ax,ax                ; сброс мыши
        int   33h                  ;
        mov   ax,1                 ; покажем курсор
        int   33h                  ;
waitSnub:
        mov   ax,3                 ; ждём мышиный щелчок
        int   33h                  ;
        test  bx,001b              ; левая?
        jnz   wr
        test  bx,010b              ; правая?
                jnz  getColor 
		; jnz   get   
        test  bx,100b              ; средняя?
        jnz   exit                 ; да - выход из программы
        jmp   waitSnub             ; мотаем, если нет щелчка
wr:
        cmp  dx, 15
        jg   writeLine            ; да - рисуем линию
		jmp  waitSnub
; get:
;         cmp  dx, 10
;         jl   getColor             ; да - выбираем цвет   
; 		jmp  waitSnub

;------ Функция рисования линии! (щелчок возвращает координаты X/Y)
writeLine:                         ;
        shr   cx,1                 ; нужно разделить координату(Х) на 2
        dec   dx                   ; (Y)-1, чтоб курсор не затёр линию
        mov   bp,5                 ; длина линии
		
        mov   ah,0ch               ;
        mov   al,[color]           ; передаём цвет линии

write:  
		push  bp
		push  dx
		mov   bp,5
height:
		int   10h                  ; выводим точку!
		cmp   bp, 1
		jl    next
		dec   dx
		dec   bp
		jmp   height
next:
		pop   dx
		pop   bp
        inc   cx                   ; сл.позиция(Х)
        dec   bp                   ; мотаем BP-раз..
        jnz   write                ;

        push  0		               ;
        pop   cx	               ; сбрасываем регистры в нуль
        push  0		               ;
        pop   dx	               ; сбрасываем регистры в нуль
        push  0		               ;
        pop   bx  		           ; сбрасываем регистры в нуль
        jmp   waitSnub             ;
 


;------ Функция читает/сохраняет цвет точки!
getColor:                          ;
        shr   cx,1                 ; принимаем координаты щелчка
        dec   dx                   ;
        xor   bx,bx                ; страница нуль
        mov   ah,0dh               ;
        int   10h                  ; читать точку!
        mov   [color],al           ; сохраняем значение цвета в переменной
        push  0		               ;
        pop   cx	               ; сбрасываем регистры в нуль
        push  0		               ;
        pop   dx	               ; сбрасываем регистры в нуль
        push  0		               ;
        pop   bx  		           ; сбрасываем регистры в нуль
        jmp   waitSnub             ;
 
exit:   ;pop   es                   ;
        mov   ax,3                 ; возвращаем в/режим
        int   10h                  ;
        int   20h                  ; на выход!
 
;=================== П Р О Ц Е Д У Р Ы ==================================
;------------------------------------------------------------------------
CreatePalette:                     ; Создаём палитру цветов
        mov   dx,10                ; заполнять будем 10 строк
        mov   di,0                ; стартовая позиция в окне
palet:  
		push  di                   ;    ...запомним для следующей строки
        mov   bx,070fh             ; 7 цветов, начиная с белого (0fh)
        mov   cx,40                ; каждый цвет 20 pix в ширину
cycle:  
		push  cx                   ;    ..запомним
        mov   al,bl                ; AL - цвет точки
        rep   stosb                ; рисуем 20 пикселей в строке(1)
        pop   cx                   ; восстановим счётчик
        dec   bl                   ; меняем цвет,
        dec   bh                   ;    ..и счётчик цветов
        jnz   cycle                ; все цвета вывели? нет - мотаем..
        pop   di                   ;
        add   di,320               ; сл.строка!
        dec   dx                   ; 10 строк вывели?
        jnz   palet                ;
        ret                        ;
