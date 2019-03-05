dane segment
	dataerror db "Bledne dane", 10, 13, "$"
	prompt db "Podaj dzialanie: $"
	userinput db 25 dup ("$")
	numbers db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$", "dziesiec$", "jedenascie$", "dwanascie$", "trzynascie$", "czternascie$", "pietnascie$", "szesnascie$", "siedemnascie$", "osiemnascie$"
	numberslen db 5, 6, 4, 5, 7, 5, 6, 7, 6, 9, 9, 11, 10, 11, 12, 11, 11, 13, 12
	numbersten db "zero$", "dziesiec$", "dwadziescia$", "trzydziesci$", "czterdziesci$", "piecdziesiat$", "szescdziesiat$", "siedemdziesiat$", "osiemdziesiat$"
	numberstenlen db 5, 9, 12, 12, 13, 13, 14, 15, 14, 17
	addition db "plus$"
	substraction db "minus$"
	multiplication db "razy$"
dane ends

code1 segment
start1:
	; inicjalizacja stosu
	mov ax, seg ws1
	mov ss, ax
	mov sp, offset ws1
	; inicjalizacja segmentu danych
	mov ax, seg dane
	mov ds, ax
	; drukuj prosbe o wejscie
	mov dx, offset prompt
	call print1
	; pobierz dzialanie od uzytkownika
	mov dx, offset userinput
	mov ah, 0ah
	int 21h
	; koniec programu
	mov ah, 4ch
	int 21h
	
; =====================	
print1:
	mov ah, 9
	int 21h
	ret
code1 ends

stack1 segment stack
		db 200 dup (?)
	ws1 db ?
stack1 ends

end start1