thx equ end

dane segment
	dataerror db "Bledne dane", 10, 13, "$"
	prompt db "Podaj dzialanie: $"
	userinput db 25, 0, 25 dup ("$")
	numbers db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$", "dziesiec$", "jedenascie$", "dwanascie$", "trzynascie$", "czternascie$", "pietnascie$", "szesnascie$", "siedemnascie$", "osiemnascie$"
	numberslen db 5, 6, 4, 5, 7, 5, 6, 7, 6, 9, 9, 11, 10, 11, 12, 11, 11, 13, 12
	numbersten db "zero$", "dziesiec$", "dwadziescia$", "trzydziesci$", "czterdziesci$", "piecdziesiat$", "szescdziesiat$", "siedemdziesiat$", "osiemdziesiat$"
	numberstenlen db 5, 9, 12, 12, 13, 13, 14, 15, 14, 17
	firstnumber db 25 dup ('$')   ;; 25 dla celow testu - przepisanie calego wejscia -- zmienic na 10
	secondnumber db 10 dup ('$')
	operator db 10 dup('$')
	addition db "plus$"
	substraction db "minus$"
	multiplication db "razy$"
	space db ' $'
	newline db 0ah, 0dh, '$'
dane ends

code1 segment
start1:
	; inicjalizacja stosu
	mov ax, seg ws1
	mov ss, ax
	mov sp, offset ws1
	
	; inicjalizacja segmentu danych
	mov ax, seg dataerror
	mov ds, ax
	
	; drukuj prosbe o wejscie
	mov dx, offset prompt
	call print1
	
	; pobierz dzialanie od uzytkownika
	mov dx, offset userinput
	mov ah, 0ah
	int 21h
	mov dx, offset newline
	call print1
	
	; wyrzuc blad jesli pierwszy znak to spacja
	mov bh, byte ptr ds:[userinput+2]    ; bo dopiero od 3. bitu wlasciwe wejscie dla funkcji '0ah' int 21h
	cmp bh, ' '
	je baddata
	
	; rozdziel slowa do zmiennych firstnumber, operator, secondnumber po spacjach
	mov ax, offset userinput         ; ax tylko posredniczy dla przepisania do si
	mov si, ax                       ; w si wskazanie na poczatek wejscia
	add si, 2                        ; poczatek wlasciwego wejscia na 3. bicie
	xor cx, cx
	mov cl, byte ptr ds:[userinput+1]   ; w cl poczatkowo liczba liter w wejsciu
	mov di, offset firstnumber          ; w di wskazanie na zmienna gdzie przepisujemy
parse:
    mov bl, byte ptr ds:[si]     ; zapisz do bl aktualnie rozpatrywany bajt wejscia
	cmp bl, ' '                  ; jesli to spacja to zmien adres
	je changeaddress
	mov byte ptr ds:[di], bl     ; zapisz do zmiennej biezacy bajt
	inc di
	parseloopend:
	inc si                  
loop parse

	; test
	mov dx, offset firstnumber
	call print1
	call clrf
	mov dx, offset operator
	call print1
	call clrf
	mov dx, offset secondnumber
	call print1
	call clrf
	mov dx, offset addition
	call print1
	call clrf
	
	; koniec programu
	call exit
	
; ===== PROCEDURY =====
print1:
	mov ah, 9h
	int 21h
	ret
baddata:
	mov dx, offset dataerror
	call print1
	call exit
	ret
exit:
	mov ah, 4ch
	int 21h
	ret
clrf:
    mov dx, offset newline
    call print1
    ret
changeaddress:
    mov ax, offset operator      ; zapisujemy do ax poczatek bloku zmiennej operator
    mov dx, si                   ; kopia zapasowa obecnego si (czyli pointera na wejscie)
    mov si, ax                   ; zapisujemy do si adres bloku zmiennej operator
    cmp byte ptr ds:[si], '$'    ; czy pierwszy znak operatora to '$' ?
    je dolar                     ; jesli tak to zaczynamy zapisywac do operatora
    mov di, offset secondnumber  ; jesli nie (operator zapisany) to zaczynamy zapis do secondnumber
    jmp changeaddressend
    dolar:                       
    mov di, offset operator
    changeaddressend:
    mov si, dx                   ; przywrocenie dobrej wartosci do si
    jmp parseloopend
code1 ends

stack1 segment stack
		db 200 dup (?)
	ws1 db ?
stack1 ends

thx start1