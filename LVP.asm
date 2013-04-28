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
; 								LVP
; ******************************************************************
; ******************************************************************

; ******************************************************************
; Enter LVP used to program MM2001 PIC
; ******************************************************************
Enter_LVP
	bcf		MM_PGD
	bcf		MM_PGC
	bsf		MM_LVP
	movlw	.1
	bra		Delay_LVP

; ******************************************************************
; Exit LVP mode used to program MM2001 PIC
; ******************************************************************
Exit_LVP
	bcf		MM_PGD
	bcf		MM_PGC
	bcf		MM_LVP
	movlw	.1
	bra		Delay_LVP

; ******************************************************************
; Write command
; In : W=Command
; ******************************************************************
Write_LVP_CMD
	movwf	TEMP, ACCESS
	movlw	.6				; Transmit 6 bits of command
	movwf	i, ACCESS
Write_LVP_CMD_1
	bcf		MM_PGD
	btfsc	TEMP,0,ACCESS	; Set PGD
	bsf		MM_PGD
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	rcall	Delay_LVP
	rrcf	TEMP,F,ACCESS	; Next bit
	decfsz	i, F, ACCESS
	bra		Write_LVP_CMD_1	; Repeat 6 times
	return

; ******************************************************************
; Write data, command placed in W
; In : W=Command
;      ADRESH:ADRESL=data to write
; ******************************************************************
Write_LVP_DATA
	rcall	Write_LVP_CMD
	bcf		STATUS,C,ACCESS
	rlcf	ADRESL,F,ACCESS
	rlcf	ADRESH,F,ACCESS
	movlw	.8				; Transmit 8 first bits of data
	movwf	i, ACCESS
Write_LVP_DATA_1
	bcf		MM_PGD
	btfsc	ADRESL,0,ACCESS	; Set PGD
	bsf		MM_PGD
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	rcall	Delay_LVP
	rrcf	ADRESL,F,ACCESS	; Next bit
	decfsz	i, F, ACCESS
	bra		Write_LVP_DATA_1; Repeat 8 times
	movlw	.8				; Transmit 8 first bits of data
	movwf	i, ACCESS
Write_LVP_DATA_2
	bcf		MM_PGD
	btfsc	ADRESH,0,ACCESS	; Set PGD
	bsf		MM_PGD
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	rcall	Delay_LVP
	rrcf	ADRESH,F,ACCESS	; Next bit
	decfsz	i, F, ACCESS
	bra		Write_LVP_DATA_2; Repeat 8 times
	return

; ******************************************************************
; Read data
; In : W=Command
; Out: ADRESH:ADRESL=read
; ******************************************************************
Read_LVP
	rcall	Write_LVP_CMD
	clrf	ADRESL,ACCESS	; Use ADRESL for Low part of the data
	movlw	.9
	movwf	i, ACCESS
Read_LVP_1
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	rcall	Delay_LVP
	bsf		TRISB,6,ACCESS	; PGD in
	rrncf	ADRESL,F,ACCESS	; Rotate right ADRESL
	btfsc	MM_PGD			; if MM_PGD=1
	bsf		ADRESL,7,ACCESS	;   ADRESL.7=1
	decfsz	i, F, ACCESS
	bra		Read_LVP_1		; Repeat 8 times
	clrf	ADRESH,ACCESS	; Use ADREH for High part of the data
	movlw	.6
	movwf	i, ACCESS
Read_LVP_2
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	rcall	Delay_LVP
	rrncf	ADRESH,F,ACCESS	; Rotate right ADRESH
	btfsc	MM_PGD			; if MM_PGD=1
	bsf		ADRESH,5,ACCESS	;   ADRESH.7=1
	decfsz	i, F, ACCESS
	bra		Read_LVP_2		; Repeat 8 times
	bsf		MM_PGC			; PGC=1
	rcall	Delay_LVP
	bcf		MM_PGC			; PGC=0
	bcf		TRISB,6,ACCESS	; PGD OUT
	bcf		MM_PGD
	bra		Delay_LVP

; ******************************************************************
; Delay...
; ******************************************************************
Delay_LVP
	movlw	.6				; 2µs
	nop
Delay_LVP1
	movwf	DELAY,ACCESS
	decfsz	DELAY,F,ACCESS
	bra		$-2
	return
