; ============================================================================
;
; Author: Microchip
;
; ============================================================================

; ******************************************************************
; ******************************************************************
; 								Math
; ******************************************************************
; ******************************************************************

MSB		equ	7
LSB		equ	0

; ******************************************************************
NDIV2416	macro
;
; Max Timing: 10+23*15+6 = 361 clks
;
; Min Timing: 10+23*14+3 = 335 clks
;
; PM: 10+23*19+6 = 450	DM: 8
;
	variable index

	CLRF	TEMP,ACCESS
	RLCF	AARGB0,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG,ACCESS
	SUBWFB	TEMP, F, ACCESS
	RLCF	AARGB0, F, ACCESS

	variable index = D'1'

	while index < D'8'

	RLCF	AARGB0,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	RLCF	TEMP, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	BTFSS	AARGB0,LSB, ACCESS
	GOTO	NADD46#v(index)
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	SUBWFB	TEMP, F, ACCESS
	GOTO	NOK46#v(index)

NADD46#v(index)
	ADDWF	 REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	ADDWFC	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	ADDWFC	TEMP, F, ACCESS
	
NOK46#v(index)
	RLCF	AARGB0, F, ACCESS

	variable index=index+1

	endw

	RLCF	AARGB1,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	RLCF	TEMP, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	BTFSS	AARGB0,LSB, ACCESS
	GOTO	NADD468
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	SUBWFB	TEMP, F, ACCESS
	GOTO	NOK468

NADD468
	ADDWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	ADDWFC	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	ADDWFC	TEMP, F, ACCESS
	
NOK468
	RLCF	AARGB1, F, ACCESS

	variable index = D'9'

	while index < D'16'

	RLCF	AARGB1,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	RLCF	TEMP, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	BTFSS	AARGB1,LSB, ACCESS
	GOTO	NADD46#v(index)
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	SUBWFB	TEMP, F, ACCESS
	GOTO	NOK46#v(index)

NADD46#v(index)
	ADDWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	ADDWFC	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	ADDWFC	TEMP, F, ACCESS
	
NOK46#v(index)
	RLCF	AARGB1, F, ACCESS

	variable index=index+1

	endw

	RLCF	AARGB2,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	RLCF	TEMP, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	BTFSS	AARGB1,LSB, ACCESS
	GOTO	NADD4616
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	SUBWFB	TEMP, F, ACCESS
	GOTO	NOK4616

NADD4616
	ADDWF	REMB1, F, ACCESS
	MOVF	BARGB0,W
	ADDWFC	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	ADDWFC	TEMP, F, ACCESS
	
NOK4616
	RLCF	AARGB2, F, ACCESS

	variable index = D'17'

	while index < D'24'

	RLCF	AARGB2,W, ACCESS
	RLCF	REMB1, F, ACCESS
	RLCF	REMB0, F, ACCESS
	RLCF	TEMP, F, ACCESS
	MOVF	BARGB1,W, ACCESS
	BTFSS	AARGB2,LSB, ACCESS
	GOTO	NADD46#v(index)
	SUBWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	SUBWFB	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	SUBWFB	TEMP, F, ACCESS
	GOTO	NOK46#v(index)

NADD46#v(index)
	ADDWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	ADDWFC	REMB0, F, ACCESS
	CLRF	WREG, ACCESS
	ADDWFC	TEMP, F, ACCESS
	
NOK46#v(index)
	RLCF	AARGB2, F, ACCESS

	variable index=index+1

	endw
	
	BTFSC	AARGB2,LSB, ACCESS
	GOTO	NOK46
	MOVF	BARGB1,W, ACCESS
	ADDWF	REMB1, F, ACCESS
	MOVF	BARGB0,W, ACCESS
	ADDWFC	REMB0, F, ACCESS

NOK46
	endm

;**********************************************************************************************
;**********************************************************************************************
;
; 24/16 Bit Unsigned Fixed Point Divide 24/16 -> 24.16
;
; Input:24 bit unsigned fixed point dividend in AARGB0, AARGB1, AARGB2
;	 16 bit unsigned fixed point divisor in BARGB0, BARGB1
;
; Use:CALLFXD2416U
;
; Output: 24 bit unsigned fixed point quotient in AARGB0, AARGB1, AARGB2
;	 16 bit unsigned fixed point remainder in REMB0, REMB1
;
; Result: AARG, REM<--AARG / BARG
;
; Max Timing: 2+361+2 = 365 clks
;
; Min Timing: 2+335+2 = 339 clks
;
; PM: 2+450+1 = 453	 DM: 8
;
FXD2416U
		CLRF	REMB0, ACCESS
		CLRF	REMB1, ACCESS

		NDIV2416

		RETLW	0x00
