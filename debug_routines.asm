; ---------------------------------------------
;
;	DEBUG ROUTINES
;
; ---------------------------------------------
	
debugA:				; debug A to screen as HEX byte pair at pos BC
	push af 
	ld (debug_char), a	; store A
				; first, print 'A=' at TAB 36,0
	ld a, 31		; TAB at x,y
	rst.lil $10
	ld a, b			; x=b
	rst.lil $10
	ld a,c			; y=c
	rst.lil $10		; put tab at BC position

	ld a, (debug_char)	; get A from store, then split into two nibbles
	and 11110000b		; get higher nibble
	rra
	rra
	rra
	rra			; move across to lower nibble
	add a,48		; increase to ascii code range 0-9
	cp 58			; is A less than 10? (58+)
	jr c, nextbd1		; carry on if less
	add a, 7		; add to get 'A' char if larger than 10
nextbd1:	
	rst.lil $10		; print the A char

	ld a, (debug_char)	; get A back again
	and 00001111b		; now just get lower nibble
	add a,48		; increase to ascii code range 0-9
	cp 58			; is A less than 10 (58+)
	jp c, nextbd2		; carry on if less
	add a, 7		; add to get 'A' char if larger than 10	
nextbd2:	
	rst.lil $10		; print the A char
	
	ld a, (debug_char)
	pop af 
	ret			; head back

debug_char: 	.db 0


; ---------------------------------------------

printBin:
				; take A as number and print out as binary, B,C as X,Y position
				; take D as number of bits to do
	push af 

	ld a, 31		; TAB at x,y
	rst.lil $10
	ld a, b			; x=b
	rst.lil $10
	ld a,c			; y=c
	rst.lil $10		; put tab at BC position

	pop af 


	ld b, d
	ld hl, binString
rpt:
	ld (hl), 48 	; ASCII 0 is 48, 1 is 49 ; reset first

	bit 7, a
	jr z, nxt
	ld (hl), 49
nxt:	
	inc hl	; next position in string
	rla 
	djnz rpt


	ld hl, printStr
	ld bc, endPrintStr - printStr

	rst.lil $18


	ret

			; print binary
printStr:
binString:	.db 	"00000000"
endPrintStr:
