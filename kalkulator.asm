thx equ end

dane segment
	dataerror db "Bledne dane", 10, 13, "$"
	prompt db "Podaj dzialanie: $"
	userinput db 25, 0, 25 dup ("$")
	numbers db "zero$$$$$$$$$$$$$$$$", "jeden$$$$$$$$$$$$$$$", "dwa$$$$$$$$$$$$$$$$$", "trzy$$$$$$$$$$$$$$$$", "cztery$$$$$$$$$$$$$$", "piec$$$$$$$$$$$$$$$$", "szesc$$$$$$$$$$$$$$$", "siedem$$$$$$$$$$$$$$", "osiem$$$$$$$$$$$$$$$", "dziewiec$$$$$$$$$$$$", "dziesiec$$$$$$$$$$$$", "jedenascie$$$$$$$$$$", "dwanascie$$$$$$$$$$$", "trzynascie$$$$$$$$$$", "czternascie$$$$$$$$$", "pietnascie$$$$$$$$$$", "szesnascie$$$$$$$$$$", "siedemnascie$$$$$$$$", "osiemnascie$$$$$$$$$"
	numbersten db "zero$$$$$$$$$$$$$$$$", "dziesiec$$$$$$$$$$$$", "dwadziescia$$$$$$$$$", "trzydziesci$$$$$$$$$", "czterdziesci$$$$$$$$", "piecdziesiat$$$$$$$$", "szescdziesiat$$$$$$$", "siedemdziesiat$$$$$$", "osiemdziesiat$$$$$$$"
	firstnumber db 20 dup ('$')   
	secondnumber db 20 dup ('$')
	operator db 6 dup('$')
	operators db "plus$$", "minus$", "razy$$"
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
	
	; rozdziel slowa do zmiennych firstnumber, operator, secondnumber po spacjach
	mov ax, offset userinput         ; ax tylko posredniczy dla przepisania do si
	mov si, ax                       ; w si wskazanie na poczatek wejscia
	add si, 2                        ; poczatek wlasciwego wejscia na 3. bicie
	xor cx, cx
	mov cl, byte ptr ds:[userinput+1]   ; w cl poczatkowo liczba liter w wejsciu
	mov di, offset firstnumber          ; w di wskazanie na zmienna gdzie przepisujemy
split:
    mov bl, byte ptr ds:[si]     ; zapisz do bl aktualnie rozpatrywany bajt wejscia
	cmp bl, ' '                  ; jesli to spacja to zmien adres
	je changeaddress
	mov byte ptr ds:[di], bl     ; zapisz do zmiennej biezacy bajt
	inc di
	splitloopend:
	inc si                  
loop split

    ; sparsuj pierwsza liczbe
    mov ax, 0                     ; ax - ktora cyfra jest obecnie sprawdzana
    mov bx, ds
    mov es, bx                    ; ustawiamy es na ds
    mov di, offset numbers
    mov dx, di                    ; w dx kopia di (bo di sie zmienia przy repe cmpsb)
    cld                           ; wyczysc flage kierunku zeby porownywaly sie bajty w rosnacej kolejnosci
parse1:     
    mov si, offset firstnumber       
    mov cx, 20                    ; porownaj 20 liter z [DS:SI] oraz [ES:DI]
    repe cmpsb
    cmp cx, 0
    je parsed1                    ; wszystkie rowne - skocz do parsed1
    add dx, 20
    mov di, dx                    ; jesli nie ustaw di w odleglosci 20 od pozycji przed iteracja
    inc ax    
    cmp ax, 10                    ; jesli probowano liczby 0-9 to zle dane
    je baddata
    jmp parse1                    ; petla
parsed1:
    mov bl, al                    ; zapisz pierwsza cyfre do bl
    
    ; sparsuj druga liczbe
    mov ax, 0                   ;;;
    mov di, offset numbers        ;
    mov dx, di                    ;
parse2:                           ;
    mov si, offset secondnumber   ;
    mov cx, 20                    ;
    repe cmpsb                    ;
    cmp cx, 0                     ;;  JAK WYZEJ
    je parsed2                    ;
    add dx, 20                    ;
    mov di, dx                    ;
    inc ax                        ;
    cmp ax, 10                    ;
    je baddata                    ;
    jmp parse2                  ;;;
parsed2:
    mov bh, al                    ; zapisz druga cyfre do bh
    
    ; sparsuj operator
    mov ax, 0
    mov di, offset operators
    mov dx, di
parseop:
    mov si, offset operator
    mov cx, 6
    repe cmpsb
    je parsedop
    add dx, 6
    mov di, dx
    inc ax
    cmp ax, 3
    je baddata
    jmp parseop

parsedop:
    mov dh, 0 ;; pozniej dh bedzie oznaczalo czy dodatnie czy ujemne
    ; w zaleznosci od zawartosci ax, dokonaj odpowiedniej operacji
    cmp ax, 0
    je adding
    cmp ax, 1
    je subtracting
    jmp multiplying
    
    ; w bl bedzie wartosc bezwzgledna wyniku, w bh jedynka jesli wynik ujemny, a zero jesli dodatni
adding:              ;;;
    add bl, bh        ;
    jmp opdone         ;
subtracting: 
    cmp bl, bh          ;
    sub bl, bh         ; jesli wynik ujemny to dh <- 1
    jl negsubres         ;
    jmp opdone
    negsubres:
    neg bl
    mov dh, 1
    jmp opdone         
multiplying:           ;
    mov al, bl         ;
    mul bh             ;
    mov bl, al       ;;;
    
opdone:
    ; sprawdzamy czy wartosc w bl < 19. Jesli tak to korzystamy z tablicy numbers zeby wypisac wynik
    ; jesli nie to najpierw z tablicy numbersten, a potem dopiero numbers
    cmp bl, 19
    jg over19
    jmp less19
    
over19:
    xor ax, ax
    xor cx, cx
    mov al, bl
    mov cl, 10                     ; dzielenie liczby przez 10 -- w al wynik bez reszty, w ah reszta
    div cl
    mov ch, ah
    mov cl, al
    mov dx, offset numbersten
    mov bh, 20
    xor ax, ax
    mov al, cl
    mul bh
    add dx, ax
    call print1                    ; wydrukowanie liczby dziesiatek
    mov dx, offset space           ; wydrukowanie spacji
    call print1
    cmp ch, 0                      ; omin jesli liczba dziesiatek to 0
    je jobdone
    mov al, ch
    mul bh
    mov dx, offset numbers         ; wydrukuj liczbe jednosci
    add dx, ax
    call print1
    call clrf
    jmp jobdone
less19:
    cmp dh, 1
    jne nominus                       ; jesli dh = 1 (wynik ujemny) to drukuj minus
    mov dx, offset operators
    add dx, 6
    call print1
    mov dx, offset space
    call print1
    nominus:
    mov bh, 20
    xor ax, ax
    mov cx, offset numbers            ; znajdz w offset do prawidlowej liczby w bloku numbers
    mov al, bl
    mul bh
    add cx, ax
    mov dx, cx
    call print1
    call clrf
    
jobdone:
	
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
    mov ax, offset secondnumber
    mov si, ax
    cmp byte ptr ds:[si], '$'
    jne baddata                  ; blad jesli trzecia spacja w wejsciu
    mov di, offset secondnumber  ; jesli nie (operator zapisany) to zaczynamy zapis do secondnumber
    jmp changeaddressend
    dolar:                       
    mov di, offset operator
    changeaddressend:
    mov si, dx                   ; przywrocenie dobrej wartosci do si
    jmp splitloopend
code1 ends

stack1 segment stack
		db 200 dup (?)
	ws1 db ?
stack1 ends

thx start1