   10 REM ADS1115 I2C-Compatible, 860 SPS, 16-bit ADC
   20 REM eZ80 Assembly/BASIC test program for the Agon Light 2
   21 REM This version is for 16-bit basic but you could adapt
   22 REM Check if we are running in 24-bit BASIC
   24 :
   25 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
   30 REM
   31 REM ---------------------------------------------------------
   32 REM This is the i2c assembly code 
   33 REM ---------------------------------------------------------
   36 :
   38 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
   39 :
   40 DIM openi2c% 64
   50 DIM closei2c% 32
   60 DIM setupi2c% 128
   70 DIM readi2c% 64
   80 DIM hidecursor% 32
   90 DIM showcursor% 32
   95 DIM debugA% 64
   97 DIM multiPurposeDelay% 64
  100 REM This routine is for setting up and include statements
  110 FOR I%=0 TO 3 STEP 3
  120   P%=setupi2c%
  130   [
  140   OPT I%
  145   push af : push bc : push hl
  150   ;include "macros.inc"
  160   ;include "debug_routines.asm"
  170   ;include "delay_routines.asm"
  180   ;
  185   ld a, 12 : rst &10 : ;CLS
  190   call hidecursor%
  200   ld hl, string
  210   ld bc, endstring - string
  220   rst &18
  230   call openi2c%
  235   pop hl : pop bc : pop af
  240   ret
  241   .string
  242   DEFB 31 : DEFB 0 : DEFB 0 : DEFM "Testing i2c adc"
  243   DEFB 31 : DEFB 4 : DEFB 1 : DEFM "ADC MSB"
  244   DEFB 31 : DEFB 4 : DEFB 2 : DEFM "ADC LSB"
  245   .endstring
  246   .i2c_read_buffer
  247   DEFM "00000000000000000000000000000000"
  248   .i2c_write_buffer
  249   DEFM "00000000000000000000000000000000"
  250   .MSB
  251   DEFB 0
  252   .LSB
  253   DEFB 0
  260   ]
  270 NEXT
  280 REM
  300 FOR I%=0 TO 3 STEP 3
  310   P%=hidecursor%
  320   [
  330   OPT I%
  340   push af
  350   ld a, 23
  360   rst &10
  370   ld a, 1
  380   rst &10
  390   ld a, 0
  400   rst &10
  410   pop af
  420   ret
  430   ]
  440 NEXT
  450 REM
  500 FOR I%=0 TO 3 STEP 3
  510   P%=showcursor%
  520   [
  530   OPT I%
  540   push af
  550   ld a, 23
  560   rst &10
  570   ld a, 1
  580   rst &10
  590   ld a, 1
  600   rst &10
  610   pop af
  620   ret
  630   ]
  640 NEXT
  650 REM
  690 REM This routine is for opening the i2c device
  700 FOR I%=0 TO 3 STEP 3
  710   P%=openi2c%
  720   [
  730   OPT I%
  735   push af : push bc : push hl
  740   ld c, 3
  750   ld a, &1F : rst &08 : ;MOSCALL &1F
  760   ld c, &48
  770   ld b, 3
  780   ld hl, i2c_write_buffer
  790   ld (hl), &01 : ;00000001b
  800   inc hl
  810   ld (hl), &02 : ;00000010b
  820   inc hl
  830   ld (hl), &42 : ; 01000010b
  840   ld hl, i2c_write_buffer
  850   ld a, &21 : rst &08 : ;MOSCALL &21
  860   ;ld a, &02 : ;00000010b
  870   ;call multiPurposeDelay%
  880   ld c, &48
  890   ld b, 1
  900   ld hl, i2c_write_buffer
  910   ld (hl), &00 : ;00000000b
  920   ld hl, i2c_write_buffer
  930   ld a, &21 : rst &08 : ;MOSCALL &21
  940   ;ld a, &02 : ;00000010b
  950   ;call multiPurposeDelay%
  955   pop hl : pop bc : pop af
  960   ret
  970   ]
  980 NEXT
 1000 :
 1010 REM This routine is to close the i2c device
 1020 FOR I%=0 TO 3 STEP 3
 1030   P%=closei2c%
 1040   [
 1050   OPT I%
 1055   push af
 1060   ld a, &20 : rst &08 : ;MOSCALL &20
 1065   pop af
 1070   ret
 1080   ]
 1090 NEXT
 1200 REM
 1210 FOR I%=0 TO 3 STEP 3
 1220   P%=readi2c%
 1230   [
 1240   OPT I%
 1245   push af : push bc : push hl
 1250   ld c, &48
 1260   ld b, 2
 1270   ld hl, i2c_read_buffer
 1280   ld a, &22 : rst &08 : ;MOSCALL &22
 1290   ;ld a, &02 : ;00000010b
 1300   ;call multiPurposeDelay%
 1310   ld hl, i2c_read_buffer
 1320   ld a, (hl)
 1330   ld (MSB), a
 1340   inc hl
 1350   ld a, (hl)
 1360   ld (LSB), a
 1370   ld b, 0
 1380   ld c, 1
 1390   ld a, (MSB)
 1400   call debugA%
 1410   ld b, 0
 1420   ld c, 2
 1430   ld a, (LSB)
 1440   call debugA%
 1445   pop hl : pop bc : pop af
 1450   ret
 1460   ]
 1470 NEXT
 1500 REM
 1510 REM
 1520 FOR I%=0 TO 3 STEP 3
 1530   P%=debugA%
 1540   [
 1550   OPT I%
 1560   .debugA
 1570   push af : push bc
 1580   ld (debug_char), a
 1590   ld a, 31 : rst &10 : ld a, b : rst &10 : ld a, c : rst &10
 1600   ld a, (debug_char)
 1610   and &F0 : ;11110000b
 1620   rra : rra : rra : rra
 1630   add a, 48
 1640   cp 58
 1650   jr c, nextbd1
 1660   add a, 7
 1670   .nextbd1
 1680   rst &10
 1690   ld a, (debug_char)
 1700   and &0F : ; 00001111b
 1710   add a, 48
 1720   cp 58
 1730   jp c, nextbd2
 1740   add a, 7
 1750   .nextbd2
 1760   rst &10
 1770   ld a, (debug_char)
 1780   pop bc : pop af
 1790   ret
 1800   .debug_char
 1810   DEFB 0
 1820   ; NO ret here
 1830   ]
 1840 NEXT
 1900 FOR I%=0 TO 3 STEP 3
 1910   P%=multiPurposeDelay%
 1920   [
 1930   OPT I%
 1940   .multiPurposeDelay
 1950   push af : push bc
 1960   ld b, a
 1970   ld a, &08 : rst &08 : ;MOSCALL &08
 1980   .waitLoop
 1990   ld a, (ix + 0)
 2000   and b
 2010   ld c, a
 2020   ld a, (oldTimeStamp)
 2030   cp c
 2040   jr z, waitLoop
 2050   ld a, c
 2060   ld (oldTimeStamp), a
 2070   pop bc : pop af
 2080   ret
 2090   .oldTimeStamp
 2095   DEFB &00
 2100   .miniDelay
 2110   push bc
 2120   ld bc, 0
 2130   ld b, 10
 2140   .miniLoop
 2150   djnz miniLoop
 2160   pop bc
 2170   ret
 2180   ]
 2190 NEXT
 2300 REM This routine is to read i2c data
 2601 :
 2999 :
 3000 REM ---------------------------------------------------------
 3001 REM This is the user Basic program
 3002 REM ---------------------------------------------------------
 3010 REM
 3015 I = 0
 3020 CALL setupi2c%
 3030 CALL openi2c%
 3040 REM LOOP HERE
 3050 IF INKEY(-113) THEN GOTO 3080
 3052 REM VOLTAGE CONVERT ADC: PRINT (VREF * SAMPLE)/RANGE
 3053 REM EXAMPLE: PRINT (3.3 * &1DFA)/&FFFF
 3060 CALL readi2c%
 3065 PRINT (3.3 * (readi2c% + I))/&FFFF
 3067 I=I+1
 3070 GOTO 3040
 3080 CALL closei2c%
 3090 CALL showcursor%
 3100 CLS
