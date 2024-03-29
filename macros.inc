; ---------------------------------------------
;
;	ROUTINES SENT AS A STRING
;
; ---------------------------------------------

	macro DEFSPRITE arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 16, 16
	incbin file
	endmacro

	macro DEFBITMAP arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 16, 16
	incbin file
	endmacro

	macro DEFBITMAP6439 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 64, 39
	incbin file
	endmacro

	macro DEFBITMAP32 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 32, 32
	incbin file
	endmacro

	macro DEFBITMAP8x8 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 8, 8
	incbin file
	endmacro

	macro DEFBITMAP24x24 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 24, 24
	incbin file
	endmacro

	macro DEFBITMAP8x40 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 8, 40
	incbin file
	endmacro

	macro DEFBITMAP24x40 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 24, 40
	incbin file
	endmacro

	macro DEFBITMAP64 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 64, 32
	incbin file
	endmacro

	macro DEFBITMAP40 arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 40, 40
	incbin file
	endmacro


	macro DEFBITMAPMOLE arg, file
	.db 23, 27, 0
	.db arg
	.db 23, 27, 1
	.dw 64, 48
	incbin file
	endmacro

	macro SELECTBITMAP arg
	.db 23, 27, 0
	.db arg
	endmacro

	macro DRAWBITMAPAT bitx, bity
	.db 23, 27, 3
	.dw bitx,bity
	endmacro


	macro ADD_SPRITE_FRAME bitmapNum
	.db 23,27,6			; add bitmap data as frame to current sprite.
	.db bitmapNum		; with ID bitmapNum
	endmacro

	macro SELECT_SPRITE spriteNum
	.db 23,27,4			; select sprite...
	.db spriteNum		; with ID spriteNum
	endmacro

	macro CLEAR_CURRENT_SPRITE 
	.db 23,27,5			; clear frames in current sprite
	endmacro

	macro SHOW_CURRENT_SPRITE 
	.db 23,27,11		; show current sprite
	endmacro

	macro HIDE_CURRENT_SPRITE 
	.db 23,27,12		; show current sprite
	endmacro

	macro MAKE_SPRITE spriteNum, bitmapNum
	.db 23,27,4			; select sprite...
	.db spriteNum		; with ID spriteNum
	.db 23,27,5			; clear frames in current sprite
	.db 23,27,6			; add bitmap data as frame to current sprite.
	.db bitmapNum		; with ID bitmapNum
	.db 23,27,11		; show current sprite
	endmacro

	macro ACTIVATE_SPRITES num
	.db 23,27,7		; activate
	.db num 		; this many
	.db 23,27,15	; update sprites in GPU.
	endmacro



	macro MAKEARECT top, left, bottom, right, colour
	ld bc, top
	ld (rectTop), bc 
	ld bc, left
	ld (rectLeft), bc 
	ld bc, bottom
	ld (rectBottom), bc 
	ld bc, right
	ld (rectRight), bc 

	ld a, colour
	ld (rectColour), a 

	call drawRect		; defined in display_routines.asm
	endmacro


; ---------------------------------------------
;
;	BUFFERED BITMAP ROUTINES
;
; ---------------------------------------------

	macro MAKEBUFFEREDBITMAP id, width, height, data, colourCode

	; create buffer

	.db 	23,0,$A0 							; write block
	.dw 	64000 + id 							; ID (word)
	.db 	3	 								; 'create' command
	.dw 	width *  height / 8 				; data size = length 320 x 64 / 8 bits as b/w

	; clear in case VDP already has one

	.db 	23,0,$A0 							; write block
	.dw 	64000 + id 							; ID (word)
	.db 	2	 								; 'create' command

	; write data to the buffer

	.db 	23,0,$A0 							; write block
	.dw 	64000 + id 							; ID (word)
	.db 	0	 								; 'write' command

	.dw 	width *  height / 8 				; data size = length 320 x 64 / 8 bits as b/w
			
	incbin data

	; convert the buffer to a single colour bitmap

	.db 	18,0 								; select colour to use
	.db 	colourCode							; 1 of 64 possible colours from palette

	; convert buffer block to bitmap with ID

	.db 	23,27,$20 							; select buffer bitmap to use
	.dw 	64000 + id 							; ID (word)

	; create a bitmap from that ID

	.db 	23,27,$21 							; create bitmap from buffer
	.dw 	width, height				 		; width, height (both words)
	.db 	2 		

	endmacro



	macro CLS
	ld a, 12
	rst.lil $10
	endmacro


; ---------------------------------------------
;
;	FUNCTION ROUTINES
;
; ---------------------------------------------

	macro MOSCALL afunc
	ld a, afunc
	rst.lil $08
	endmacro

	macro FN_SELECT_SPRITE spriteNum
	push af
	ld a, 23
	rst.lil $10
	ld a, 27
	rst.lil $10
	ld a, 4
	rst.lil $10
	ld a, spriteNum
	rst.lil $10
	pop af
	endmacro


	macro 	MOSCALL2 afunc
	ld a, afunc
	rst.lis $08
	endmacro



