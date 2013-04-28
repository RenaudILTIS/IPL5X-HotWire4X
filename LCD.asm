; ============================================================================
;
; Author: Pascal Langer
; Web site: http://5xproject.dyndns.org/
;
; ============================================================================
;
; Software Licence Agreement:
;
; This file is part of IPL5X.
;
; IPL5X is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; IPL5X is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with IPL5X.  If not, see <http://www.gnu.org/licenses/>
;
; ============================================================================

; ******************************************************************
; ******************************************************************
; 								LCD
; ******************************************************************
; ******************************************************************

; ******************************************************************
; Init LCD
; ******************************************************************
Init_LCD
	; First delay for at least 15ms after power on
	clrf	WREG
	rcall	LCD_Delay

	;	Set for 4-bit LCD mode
	bcf		FLAG_LCD_DATA			; COMMAND
	movlw	0x03
	rcall	LCD_Write_Nibble		; Write 0x3
	movlw	.78
	rcall	LCD_Delay				; wait 5ms
	movlw	0x03
	rcall	LCD_Write_Nibble		; Write 0x3
	movlw	.78
	rcall	LCD_Delay				; wait 5ms
	movlw	0x03
	rcall	LCD_Write_Nibble		; Write 0x3
	movlw	.78
	rcall	LCD_Delay				; wait 5ms
	movlw	0x02
	rcall	LCD_Write_Nibble		; Write 0x2
	movlw	.78
	rcall	LCD_Delay				; wait 5ms

	; Function set
	movlw	0x28					; Write 0x28
	rcall	LCD_Write_Byte
	movlw	.193
	rcall	LCD_Delay				; wait 12.5ms
	
	; Turn display on, no cursor
	movlw	0x0C
	rcall	LCD_Write_Byte			; Write 0x08
	
	; Cursor increment after each byte
	movlw	0x06
	rcall	LCD_Write_Byte			; Write 0x06

	; Clear LCD and return home
	movlw	0x01					; Write 0x01
	rcall	LCD_Write_Byte
	movlw	.40						;26 -> 40 for slow LCD
	rcall	LCD_Delay				; wait 1.64ms

	; IPL5X
	movtblptr STR_IPL5X
	rcall	LCD_String

	; TABLE
	movlw	' '
	rcall	LCD_Write_Byte
	movlw	'T'
	rcall	LCD_Write_Byte
	movlw	':'
	rcall	LCD_Write_Byte

	; NAME
	movlw	0x07
	movwf	iBUFFER, ACCESS
	movff	TABLE_PTR,EEADR
	rcall	LCD_String_EE

	; 2nd line
	bsf		FLAG_LCD_LINE
	movlw	0x00
	rcall	LCD_Pos_DDRAM

	; Enter Menu
	movtblptr STR_ENTER_MENU
	rcall	LCD_String

	return

; ******************************************************************
LCD_Clear							; Clear LCD and return home
	bcf		FLAG_LCD_DATA			; COMMAND
	movlw	0x01
	rcall	LCD_Write_Byte
	bsf		FLAG_LCD_DATA			; DATA
	movlw	.26
	bra		LCD_Delay				; wait 1.64ms

; ******************************************************************
LCD_Pos_DDRAM
	bcf		FLAG_LCD_DATA			; CMD
	btfsc	FLAG_LCD_2LINE
	addlw	.20
	btfsc	FLAG_LCD_LINE
	iorlw	0x40
	iorlw	0x80
	rcall	LCD_Write_Byte			; Write the command
	bsf		FLAG_LCD_DATA			; DATA
	return

; ******************************************************************
LCD_Pos_CGRAM
	bcf		FLAG_LCD_DATA			; CMD
	iorlw	0x40
    andlw   0x7F
	rcall	LCD_Write_Byte			; Write the command
	bsf		FLAG_LCD_DATA			; DATA
	return

; ******************************************************************
LCD_Decimal
	movwf	BIN_LCD, ACCESS
	swapf	BIN_LCD, W, ACCESS
	addwf	BIN_LCD, W, ACCESS
	andlw	B'00001111'
	btfsc	STATUS, DC, ACCESS
	addlw	0x16
	daw
	btfsc	BIN_LCD, 4, ACCESS
	addlw	0x16 - 1
	btfsc	BIN_LCD, 5, ACCESS
	addlw	0x30
	btfsc	BIN_LCD, 6, ACCESS
	addlw	0x60
	btfsc	BIN_LCD, 7, ACCESS
	addlw	0x20
	daw
	movwf	NBR_LCD, ACCESS
	clrf	WREG, ACCESS
	rlcf	WREG, F, ACCESS
	btfsc	BIN_LCD,7, ACCESS
	incf	WREG, F, ACCESS
	bnz		LCD_Decimal_1
	movlw	' '
	rcall	LCD_Write_Byte				; Write ' ' on hundreds
	swapf	NBR_LCD,W, ACCESS
	andlw	0x0F
	btfsc	STATUS,Z,ACCESS
	movlw	' '-'0'						; Write ' ' on tens
	bra		LCD_Decimal_2
LCD_Decimal_1
	addlw	'0'
	rcall	LCD_Write_Byte				; Write hundreds
	swapf	NBR_LCD,W, ACCESS
	andlw	0x0F
LCD_Decimal_2
	addlw	'0'
	rcall	LCD_Write_Byte				; Write tens
	movf	NBR_LCD,W, ACCESS
	andlw	0x0F
	addlw	'0'
	rcall	LCD_Write_Byte				; Write tens
	return

; ******************************************************************
LCD_String
	bsf		FLAG_LCD_DATA				; DATA
	bcf		EECON1, CFGS, ACCESS		; select program/data memory (not configuration)
	bsf		EECON1, EEPGD, ACCESS		; select flash program memory (not eeprom data)
	tblrd*+								; read a byte and increment TBLPTR
	movf	TABLAT, W, ACCESS			; read the byte
	btfsc	STATUS,Z, ACCESS
	return								; stop the display if the byte is 0x00 end of string
	rcall	LCD_Write_Byte				; Write the character
	bra		LCD_String					; loop until done

LCD_String_EE
	bsf		FLAG_LCD_DATA				; DATA
	bcf		EECON1, CFGS, ACCESS		; select program/data memory (not configuration)
	bcf		EECON1, EEPGD, ACCESS		; select data memory (not program)
LCD_String_EE_1
	bsf		EECON1, RD, ACCESS			; Read
	movf	EEDATA, W, ACCESS
	rcall	LCD_Write_Byte				; Write the character
	incf	EEADR,F, ACCESS				; ADR=ADR+1
	decfsz	iBUFFER, F, ACCESS
	bra		LCD_String_EE_1				; loop until done
	return

; ******************************************************************
LCD_Write_Byte
	movwf	TEMP_LCD, ACCESS
	swapf	TEMP_LCD,W,ACCESS
	rcall	LCD_Write_Nibble		; Write upper 4 bits
	movf	TEMP_LCD,W,ACCESS
	rcall	LCD_Write_Nibble		; Write lower 4 bits
	movlw	1
	rcall	LCD_Delay				; wait 65µs
	return

; ******************************************************************
LCD_Write_Nibble
	bcf		LCD_RS					; COMMAND
	btfsc	FLAG_LCD_DATA		
	bsf		LCD_RS					; DATA
	bsf		LCD_E
	iorlw	0xF0
	andwf	PORTD,F,ACCESS
	andlw	0x0F					; Write value
	iorwf	PORTD,F,ACCESS
	nop								; nops are for slow LCD compatibility
	nop
	nop
	nop
	nop
	bcf		LCD_E
	return

; ******************************************************************
LCD_Delay
	clrf	DELAY,ACCESS
LCD_Delay1
	decfsz	DELAY,F,ACCESS
	bra		LCD_Delay1
	decfsz	WREG,F,ACCESS
	bra		LCD_Delay
	return

; ******************************************************************
;Display 16-BIT BINARY TO FIVE BCD DIGITS (65 cycles, 69 program memory)
;Input bytes:   BARGB1:BARGB0
; ******************************************************************
LCD_16_Decimal
	rcall	Bin16_BCD
	movf	AARGB2,W,ACCESS
	addlw	'0'
	call	LCD_Write_Byte
	movf	AARGB1,W,ACCESS
	addlw	'0'
	call	LCD_Write_Byte
	movf	AARGB0,W,ACCESS
	addlw	'0'
	call	LCD_Write_Byte
	movf	BARGB1,W,ACCESS
	addlw	'0'
	call	LCD_Write_Byte
	movf	BARGB0,W,ACCESS
	addlw	'0'
	call	LCD_Write_Byte
	return

;**********************************************************************************************
;CONVERT 16-BIT BINARY TO FIVE BCD DIGITS (65 cycles, 69 program memory)
;Input bytes:   BARGB1:BARGB0
;Output digits: AARGB2:AARGB1:AARGB0:BARGB1:BARGB0
;Trashes:       PRODH, PRODL
;**********************************************************************************************
Bin16_BCD
	rrcf    BARGB1,w,ACCESS        ;Divide by 1000
	rrcf    WREG,f,ACCESS          ;Start with divide by 1024
	andlw   B'00111111'     ;
	movwf   AARGB1,ACCESS          ;Result to AARGB1
	mullw   d'24'           ;Correction factor = 24 (1024-1000)
	movlw   B'00000011'     ;Calculate /1024 remainder
	andwf   BARGB1,f,ACCESS        ;
	movf    PRODL,w,ACCESS         ;Add correction factor
	addwf   BARGB0,f,ACCESS        ;to remainder
	movf    PRODH,w,ACCESS         ;(maximum possible value is 2535)
	addwfc  BARGB1,f,ACCESS        ;
Do11Bit
	movlw   low d'1000'     ;
	subwf   BARGB0,f,ACCESS        ;Subtract 1000
	movlw   high d'1000'    ;
	subwfb  BARGB1,f,ACCESS        ;
	bnc     Fix1000         ;Abort if negative
	incf    AARGB1,f,ACCESS        ;Still positive, increment thousands
	movlw   low d'1000'     ;
	subwf   BARGB0,f,ACCESS        ;Subtract 1000
	movlw   high d'1000'    ;
	subwfb  BARGB1,f,ACCESS        ;
	bnc     Fix1000         ;Abort if negative
	incf    AARGB1,f,ACCESS        ;Still positive, increment thousands
	bra     End1000         ;Done
Fix1000
	movlw   low d'1000'     ;Negative, add 1000
	addwf   BARGB0,f,ACCESS        ;
	movlw   high d'1000'    ;
	addwfc  BARGB1,f,ACCESS        ;
End1000
	rlcf    BARGB0,w,ACCESS        ;Divide remainder by 100
	rlcf    BARGB1,w,ACCESS        ;Start with divide by 128
	andlw   B'00000111'     ;
	movwf   AARGB0,ACCESS          ;Result to AARGB0
	mullw   d'28'           ;Correction factor = 28 (128-100)
	bcf     BARGB0,7,ACCESS        ;Calculate /128 remainder
	movf    PRODL,w,ACCESS         ;Add correction factor to remainder
	addwf   BARGB0,f,ACCESS        ;(maximum possible value is 299)
	bnc     Less256         ;No carry, ramainder < 256
	movlw   -d'200'         ;Remainder >=256
	addwf   BARGB0,f,ACCESS        ;Subtract 200
	incf    AARGB0,f,ACCESS        ;Increment hundreds twice
	incf    AARGB0,f,ACCESS        ;
	bra     End100          ;Done
Less256
	movlw   d'100'          ;
	subwf   BARGB0,f,ACCESS        ;Subtract 100
	bnc     Fix100          ;Abort if negative
	incf    AARGB0,f,ACCESS        ;Still positive, increment hundreds
	subwf   BARGB0,f,ACCESS        ;Subtract 100
	bnc     Fix100          ;Abort if negative
	infsnz  AARGB0,f,ACCESS        ;Positive, incr. hundreds, skip next
Fix100
	addwf   BARGB0,f,ACCESS        ;Negative, add 100
End100
	movf    AARGB1,w,ACCESS        ;Now we have: TT:H:OO
	mullw   d'205'          ;AARGB1*1000 + AARGB0*100 + BARGB0*1
	movlw   d'32'           ;Split AARGB1 to two digits
	mulwf   PRODH,ACCESS           ;Multiply by 0.1
	movf    PRODH,w,ACCESS         ;(205/256 * 32/256)
	movwf   AARGB2,ACCESS          ;Result to AARGB2
	mullw   d'10'           ;Multiply by 10
	movf    PRODL,w,ACCESS         ;Subtract from original AARGB1
	subwf   AARGB1,f,ACCESS        ;Remainder is AARGB1
	movf    BARGB0,w,ACCESS        ;Split BARGB0 to two digits
	mullw   d'205'          ;
	movlw   d'32'           ;Multiply by 0.1
	mulwf   PRODH,ACCESS           ;(205/256 * 32/256)
	movf    PRODH,w,ACCESS         ;
	movwf   BARGB1,ACCESS          ;Result to BARGB1
	mullw   d'10'           ;Multiply by 10
	movf    PRODL,w,ACCESS         ;Subtract from original BARGB0
	subwf   BARGB0,f,ACCESS        ;Remainder is BARGB0
	return	  ;Done
