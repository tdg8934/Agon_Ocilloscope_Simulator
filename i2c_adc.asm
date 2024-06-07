;   ADS1115 I2C-Compatible, 860 SPS, 16-Bit ADC 
;   eZ80 Assembly Test program for Agon Light 2



    .assume adl=1       ; ez80 ADL memory mode
    .org $40000         ; load code here
    include "myMacros.inc"

    jp start_here       ; jump to start of code

    .align 64           ; MOS header
    .db "MOS",0,1     

    include "debug_routines.asm"
    include "delay_routines.asm"
    include "math_routines.asm"


start_here:
            
    push af             ; store all the registers
    push bc
    push de
    push ix
    push iy

; ------------------
; This is our actual code in ez80 assembly


    SET_MODE 0		; mode 0 640x480, 16 colours
    
    ;Set Non Scaled Graphics (0,0 in upper left screen)

    ld hl, VDUdataNonScaledGraphics
    ld bc, endVDUdataNonScaledGraphics - VDUdataNonScaledGraphics
    rst.lil $18
    
    ;Set pixel color to red
    
    ld hl, VDUdataGCOLmode
    ld bc, endVDUdataGCOLmode - VDUdataGCOLmode
    rst.lil $18

   
    call hidecursor     ; hide the cursor

   ; Keep but not used for now...
   ; ld hl, string       ; address of string to use
   ; ld bc, endString - string             ; length of string, or 0 if a delimiter is used
   ; rst.lil $18         ; Call the MOS API to send data to VDP 

; need to setup i2c port

    call open_i2c



    ld d, 255     	 ; (dec d) counter for waveform - 255 to 0 on x axis 
    ld e, 0		 ; used to draw waveform left->right - 0 to 255 
    
LOOP_HERE:
    MOSCALL $1E          ; get IX pointer to keyvals, currently pressed keys
    ld a, (ix + $0E)    
    bit 0, a    
    jp nz, EXIT_HERE            ; ESC key to exit

    ld a, 00000010b
    call multiPurposeDelay      ; wait a bit

    
LOOPD:
    call read_i2c		;set delay here for loose or tight waveform
  
     
    ld a, (hl)
    ld (MSB), a			;put MSB value into pixel Y location
    ld (VDUdataY), a		;MSB waveform

    inc hl			;increment h (MSB) to l (LSB) 
    ld a, (hl)
    ld (LSB), a
   ; ld (VDUdataY), a		;LSB waveform
       
    ld a, e    			;put e value into a for pixel X location
    ld (VDUdataX), a    
  

  
    ld hl, VDUdataPixel         ;plot out the waveform with e (x) and MSB (y)
    ld bc, endVDUdataPixel - VDUdataPixel
    rst.lil $18
  

    inc e
    dec d 
    jr nz, LOOPD    
    
  ; jr LOOP_HERE		;for now just run the waveform one time


; ------------------

EXIT_HERE:

; need to close i2c port
    call close_i2c
    call showcursor

   ;CLS			; For now dont clear the screen 

    pop iy              ; Pop all registers back from the stack
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0             ; Load the MOS API return code (0) for no errors.   

    ret                 ; Return to MOS


; ------------------

open_i2c:

    ld c, 3                     ; making assumption based on Jeroen's code
    MOSCALL $1F                 ; open i2c

; write to ADC Config register
    ld c, $48	                ; i2c address ($48)
    ld b, 3                     ; number of bytes to send
    ld hl, i2c_write_buffer
    
    ; Write the MSB + LSB of Config Register
    ; MSB: Bits 15:8
    ; Bit  15      0=No effect, 1=Begin Single Conversion (in power down mode)
    ; Bits 14:12   How to configure A0 to A3 (comparitor or single ended)
    ; Bits 11:9    Programmable Gain 000=6.144v 001=4.096v 010=2.048v.. 111=0.256v
    ; Bit  8       0=Continuous conversion mode, 1=Power down single shot

    ld (hl), 00000001b		; 1st byte ($01) points to Config register    
    inc hl

    ; LSB: Bits 7:0
    ; Bits 7:5 Data Rate (Samples per second) 000=8, 001=16, 010=32, 011=64
    ;          100=128, 101=250, 110=475, 111=860
    ; Bit  4   Comparitor Mode 0=Traditional, 1=Window
    ; Bit  3   Comparitor Polarity 0=low, 1=high
    ; Bit  2   Latching 0=No, 1=Yes
    ; Bits 1:0 Comparitor # before Alert pin goes high
    ;          00=1, 01=2, 10=4, 11=Disable this feature
   

                  		; 2nd byte ($42) MSB of Config reg to write 
    ld (hl), 00000010b          ; switch MSB with LSB - little endian?
    inc hl

                        	; 3rd byte ($02) LSB of Config reg to write
    ld (hl), 01000010b          ; switch LSB with MSB - little endian?
    ld hl, i2c_write_buffer
    MOSCALL $21


    ld a, 00000010b
    call multiPurposeDelay      ; wait a bit


; write to Address Pointer register
    ld c, $48   		; i2c address ($48)
    ld b, 1			; number of bytes to send
    ld hl, i2c_write_buffer

    ld (hl), 00000000b		; 1st byte ($00) points to Conversion reg
    ld hl, i2c_write_buffer
    MOSCALL $21

    ld a, 00000010b
    call multiPurposeDelay	; wait a bit

    ret 

read_i2c:

    ; ask for data

    ld c, $48   		; i2c address ($48)
    ld b,2			; number of bytes to receive
    ld hl, i2c_read_buffer
    MOSCALL $22
   


    ;This is the delay that allows a loose or tight waveform of samples
    ; ie... ld a, 00000010b loose  ld a, 00010000b tight depending on LSB/MSB
    ;

   ; ld a, 00010000b
    ld a, 00000010b
    call multiPurposeDelay      ; wait a bit
   
  
    ret 



close_i2c:

    MOSCALL $20

    ret 

 ; ------------------


hidecursor:
    push af
    ld a, 23
    rst.lil $10
    ld a, 1
    rst.lil $10
    ld a,0
    rst.lil $10                 ; VDU 23,1,0
    pop af
    ret


showcursor:
    push af
    ld a, 23
    rst.lil $10
    ld a, 1
    rst.lil $10
    ld a,1
    rst.lil $10                 ; VDU 23,1,1
    pop af
    ret

 ; ------------------

VDUdataNonScaledGraphics:	; VDU 23,0,192,0 - Non scaled Graphics
    .db 23, 0, 192, 0		; coord system (0,0) in upper left screen
endVDUdataNonScaledGraphics:


VDUdataGCOLmode:		; VDU 18,0,9 - pixels are red color (9)
    .db 18, 0, 9
endVDUdataGCOLmode:



VDUdataPixel:			; VDU 25,69,x,y - plot waveform 
    .db 25, 69			; Use 0 to 255 x axis but must use dw (word)
VDUdataX:
    .dw 0
VDUdataY:
    .dw 0
endVDUdataPixel:
 


				;keep here but not used anymore
string:
    .db 31, 0,0,"Testing i2c adc"
    .db 31, 4,1,"ADC MSB"
    .db 31, 4,2,"ADC LSB"
   
endString:

i2c_read_buffer:		;i2c useage - keep
    .ds 32,0

i2c_write_buffer:
    .ds 32,0

MSB:       .db     0		;store ADC MSB and LSB values
LSB:       .db     0
  































