; ============================================================================
; 
; Author: Pascal Langer
; Web site: http://5xproject.dyndns.org/
;
; ============================================================================
; 
; Peripheral Description:
; 
; IPL5X is an interface to connect a CNC to a PC using USB.
; This peripheral enumerates as a USB full speed composite device and is seen
; by the host as HID.
; This program use Bradley A. Minch USB framework for 18f2455/2550
; (lab2 firmware) you can find here: http://pe.ece.olin.edu/ece/projects.html
; 
; ============================================================================
;
; Software Licence Agreement:
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>;
;
#include <p18F4550.inc>
#include "ipl5x_defs.inc"
#include "usb_defs.inc"
#include "ENGR2210.inc"
#include "Config.inc"

#define	E_POT		PORTA,0,ACCESS
#define	E_PC_MANU	PORTA,1,ACCESS
#define	ORIGIN		PORTA,2,ACCESS
#define	IEND		PORTA,3,ACCESS
#define	PWM_ONOFF	PORTA,4,ACCESS
#define	IO1			PORTA,5,ACCESS

#define	SDI			PORTB,0,ACCESS
#define	SCK			PORTB,1,ACCESS
#define	OUT6		PORTB,2,ACCESS
#define	OUT5		PORTB,3,ACCESS
#define	OUT4		PORTB,4,ACCESS
#define	MM_PGC		PORTB,4,ACCESS
#define	OUT3		PORTB,5,ACCESS
#define	OUT2		PORTB,6,ACCESS
#define	MM_PGD		PORTB,6,ACCESS
#define	OUT1		PORTB,7,ACCESS
#define	MM_LVP		PORTB,7,ACCESS

#define	M_ONOFF		PORTE,0,ACCESS
#define	LCD_RS		PORTE,1,ACCESS
#define	LCD_E		PORTE,2,ACCESS
#define	E_PROG		PORTE,3,ACCESS

#define K1			PORTC,0,ACCESS
#define S_CHAUFFE	PORTC,1,ACCESS
#define K2			PORTC,2,ACCESS
#define CS			PORTC,6,ACCESS
#define SDO			PORTC,7,ACCESS

#define D0			PORTD,0,ACCESS
#define D1			PORTD,1,ACCESS
#define D2			PORTD,2,ACCESS
#define D3			PORTD,3,ACCESS
#define OUT10		PORTD,4,ACCESS
#define OUT9		PORTD,5,ACCESS
#define OUT8		PORTD,6,ACCESS
#define OUT7		PORTD,7,ACCESS

BANKED_DATA		udata		; banked data

; USB variables
USB_buffer_desc		res	4
USB_buffer_data		res	8
USB_error_flags		res 1
USB_curr_config		res	1
USB_device_status	res	1
USB_protocol		res	1
USB_idle_rate		res	1
USB_dev_req			res	1
USB_address_pending	res	1
USB_desc_ptrL		res	1
USB_desc_ptrH		res	1
USB_desc_ptrU		res	1
USB_bytes_left		res	1
USB_loop_index		res 1
USB_packet_length	res	1
USB_USTAT			res	1
USB_USWSTAT			res	1
; main USB buffers
BUFFER1				res W_MAX_PACKET_SIZE1			; location for data to be sent via USB via EP1
BUFFER2				res W_MAX_PACKET_SIZE1			; location for data to be received via USB via EP1

; SEGMENTS BUFFER
SEGMENTS_1			udata 0x100		; banked data 0x100-0x1FF
SEG_1				res .256
;00 -
;01 -
;02 -
;03 -
;04 -
;05 -
;06 -
;07 -
;08 DELTA1L
;09 DELTA1M
;0A DELTA1H
;0B DELTA1U
;0C DELTA2L
;0D DELTA2M
;0E DELTA2H
;0F DELTA2U
;10 DELTA3L
;11 DELTA3M
;12 DELTA3H
;13 DELTA3U
;14 DELTA4L
;15 DELTA4M
;16 DELTA4H
;17 DELTA4U
;18 DELTA5L
;19 DELTA5M
;1A DELTA5H
;1B DELTA5U
;1C -
;1D -
;1E -
;1F -
KEY_OK_W			equ 0x100
KEY_ESC_W			equ 0x101
KEY_LEFT_W			equ 0x102
KEY_DOWN_W			equ 0x103
KEY_UP_W			equ 0x104
KEY_RIGHT_W			equ 0x105

SEGMENTS_2			udata 0x200		; banked data 0x200-0x2FF
SEG_2				res .256
;00 NBRL
;01 NBRM
;02 NBRH
;03 NBRU
;04 DECL
;05 DECM
;06 DECH
;07 DECU
;08 STEP1L
;STEP1M
;STEP1H
;STEP1U
;STEP2L
;STEP2M
;STEP2H
;STEP2U
;STEP3L
;STEP3M
;STEP3H
;STEP3U
;STEP4L
;STEP4M
;STEP4H
;STEP4U
;STEP5L
;STEP5M
;STEP5H
;1B STEP5U
;1C -
;1D -
;1E -
;1F -
SEGMENTS_3			udata 0x300		; banked data 0x300-0x3FF
SEG_3				res .256
;00 CMD
;01 DIR_B
;02 DIR_D
;03 PWM
;04 FREQ_ACC
;05 FREQ_DEC
;06 FREQH
;07 FREQL
;08 COEF1L
;09 COEF1M
;COEF1H
;COEF1U
;COEF2L
;COEF2M
;COEF2H
;COEF2U
;COEF3L
;COEF3M
;COEF3H
;COEF3U
;COEF4L
;COEF4M
;COEF4H
;COEF4U
;COEF5L
;COEF5M
;COEF5H
;1B COEF5U
;1C -
;1D -
;1E -
;1F -

OUTPUTS_TBL			udata 0x780		; banked data 0x780-0x7FF
DIRS_TBL			res .64
STEPS_TBL			res .64

ACCESS_DATA		udata_acs	; access data (0x000-0x05F=96 bytes)

; generic variables
iBUFFER				res 1	; index for BUFFER1 and BUFFER2
i					res 1
j					res 1
TEMP				res 1
TEMP1				res 1
TEMP2				res 1
TEMP3				res 1
PWM_PC				res 1
PWM_PIC				res 1
PWM_CUR				res 1
PWM_OLD				res 1
PWM_OLD_FLAG		res 1
OLD_CNV				res 1
FLAG_OLD			res 1
KEYB				res 1
#define	KEYB_ESC		KEYB,0,ACCESS
#define KEYB_OK			KEYB,1,ACCESS
#define KEYB_LEFT		KEYB,4,ACCESS
#define	KEYB_DOWN		KEYB,5,ACCESS
#define	KEYB_UP			KEYB,6,ACCESS
#define KEYB_RIGHT		KEYB,7,ACCESS
#define	K_ESC	0x01
#define K_OK	0x02
#define K_LEFT	0x10
#define	K_DOWN	0x20
#define	K_UP	0x40
#define K_RIGHT	0x80
BIN_LCD				res 1
NBR_LCD				res 1
DELAY				res 1
TEMP_LCD			res 1
FLAG_LCD			res 1
#define FLAG_LCD_DATA	FLAG_LCD,0,ACCESS
#define FLAG_LCD_LINE	FLAG_LCD,1,ACCESS
#define FLAG_LCD_2LINE	FLAG_LCD,2,ACCESS
#define FLAG_LCD_UPDATE	FLAG_LCD,6,ACCESS
#define FLAG_LCD_DISP	FLAG_LCD,7,ACCESS

; ISR variables
FSR0L_HIGH_save		res 1	; for ISR HIGH context saving (FSR0L)
FSR0H_HIGH_save		res 1	; for ISR HIGH context saving (FSR0H)
FSR1L_HIGH_save		res 1	; for ISR HIGH context saving (FSR1L)
FSR1H_HIGH_save		res 1	; for ISR HIGH context saving (FSR1H)
PRODL_HIGH_save		res 1	; for ISR HIGH context saving (PRODL)
PRODH_HIGH_save		res 1	; for ISR HIGH context saving (PRODH)
FSR1L_LOW_save		res 1	; for ISR LOW context saving (FSR1L)
FSR1H_LOW_save		res 1	; for ISR LOW context saving (FSR1H)
FSR2L_LOW_save		res 1	; for ISR LOW context saving (FSR2L)
FSR2H_LOW_save		res 1	; for ISR LOW context saving (FSR2H)
TABLAT_LOW_save		res 1
TBLPTRL_LOW_save	res 1
TBLPTRH_LOW_save	res 1
W_save				res 1	; for ISR LOW context saving (W)
STATUS_save			res 1	; for ISR LOW context saving (STATUS)
BUF_CUR				res 1
BUF_WR				res 1
COMP_TMP			res 1
COMP_CNT			res 1
FLAG_ISR			res 1
#define FLAG_GO_ISR			FLAG_ISR,0,ACCESS
#define	FLAG_STOP_ISR		FLAG_ISR,1,ACCESS
#define	FLAG_STEP_ISR		FLAG_ISR,2,ACCESS
#define	FLAG_USB_ISR		FLAG_ISR,3,ACCESS
#define FLAG_PWM_ISR		FLAG_ISR,4,ACCESS
#define FLAG_SW_OVER_ISR	FLAG_ISR,5,ACCESS
#define FLAG_M_ONOFF_ISR	FLAG_ISR,6,ACCESS
#define FLAG_SW_FILTER_ISR	FLAG_ISR,7,ACCESS
FILTER_ISR			res 1
NBR_SEG_H			res 1
NBR_SEG_M			res 1
NBR_SEG_L			res 1
NBRU				res 1
NBRH				res 1
NBRM				res 1
NBRL				res 1
DIR_B				res 1
DIR_D				res 1
CMD_ISR				res 1
OUTPUT_ISR			res 1
FREQ_ACC			res 1
FREQ_DEC			res 1
MOTOR_L				res 1
MOTOR_M				res 1
MOTOR_H				res 1

TABLE_PTR			res	1
; => do not move the order of registers from here
TABLE_FREQ			res	1
TABLE_SLOPE			res	1
TABLE_PWMMAX		res	1
TABLE_SEC_OFF		res 1
TABLE_FLAGS			res 1
#define TABLE_FLAGS_SW_OVER		TABLE_FLAGS,1,ACCESS
#define TABLE_FLAGS_ORIENTATION	TABLE_FLAGS,1,ACCESS
#define TABLE_FLAGS_MOTORS_REV	TABLE_FLAGS,2,ACCESS
TABLE_IO1			res 1
TABLE_LANG			res 1
; => to here
TABLE_FREQL			res	1
TABLE_FREQH			res	1
TABLE_SECL			res	1
TABLE_SECH			res	1

MENU_POS			res 1
KEYB_OUT			res 1
#define	KEYB_OUT_ESC		KEYB_OUT,0,ACCESS
#define KEYB_OUT_OK			KEYB_OUT,1,ACCESS
#define KEYB_OUT_LEFT		KEYB_OUT,4,ACCESS
#define	KEYB_OUT_DOWN		KEYB_OUT,5,ACCESS
#define	KEYB_OUT_UP			KEYB_OUT,6,ACCESS
#define KEYB_OUT_RIGHT		KEYB_OUT,7,ACCESS
KEYB_OUT2			res 1
#define	KEYB_OUT2_ESC		KEYB_OUT2,0,ACCESS
#define KEYB_OUT2_OK		KEYB_OUT2,1,ACCESS
#define KEYB_OUT2_LEFT		KEYB_OUT2,4,ACCESS
#define	KEYB_OUT2_DOWN		KEYB_OUT2,5,ACCESS
#define	KEYB_OUT2_UP		KEYB_OUT2,6,ACCESS
#define KEYB_OUT2_RIGHT		KEYB_OUT2,7,ACCESS
#define KEYB_OUT2_TMR		KEYB_OUT2,2,ACCESS
AARGB0				res 1
AARGB1				res 1
AARGB2				res 1
BARGB0				res 1
BARGB1				res 1
REMB0				res 1
REMB1				res 1

	ORG		0x0A00
			goto		Main					; Reset vector
			nop
			nop
			goto		ISR_HIGH				; High-priority interrupt vector trap
			db			'I', 'P'
			db			'L', '5'
			db			'X', ' '
			db			'v', high BCD_DEVICE+'0'
			db			'.', (((low BCD_DEVICE)&0xF0)/.16)+'0'
			db			((low BCD_DEVICE)&0x0F)+'0', 0x00
			goto		ISR_LOW					; Low-priority interrupt vector trap

STARTUP		code			; reset and interrupt vectors
			goto		Main					; Reset vector
			nop
			nop
			goto		ISR_HIGH				; High-priority interrupt vector trap
			db			'I', 'P'
			db			'L', '5'
			db			'X', ' '
			db			'v', high BCD_DEVICE+'0'
			db			'.', (((low BCD_DEVICE)&0xF0)/.16)+'0'
			db			((low BCD_DEVICE)&0x0F)+'0', 0x00
			goto		ISR_LOW					; Low-priority interrupt vector trap

APPLICATION	code
; ******************************************************************
; ******************************************************************
; ISR HIGH PRIORITY
;	Interrupt Service Routine
; ******************************************************************
; ******************************************************************
ISR_HIGH
	; W, STATUS and BSR are automatically saved on interrupt
	bcf		PIR1, CCP1IF, ACCESS		; clear int flag

	; PWM Hz only
	bsf		T2CON,TMR2ON				; enable TIMER2
	bcf		T2CON,TMR2ON				; disable TIMER2

	; Is there something to do
	btfss	FLAG_GO_ISR					; GO (process data)?
	bra		Turn_M_OFF					; =0 -> No, turn motors off

	btfss	FLAG_M_ONOFF_ISR
	bra		Turn_M_ON

Turn_M_AUTO_OFF
	btfss	FLAG_STEP_ISR				; if FLAG_STEP==0    -> PROCESS_ISR
	bra		PROCESS_ISR					; else calc and set steps
	bcf		FLAG_STEP_ISR				; next time do PROCESS

	; Is the PROG button pushed?
	btfss	E_PROG
	bra		PROG_ISR
	; Switches
	btfsc	FLAG_SW_OVER_ISR			; FLAG_OVER ==1->ignore switches
	bra		Switch_ISR
	movf	PORTA, W, ACCESS
	andlw	0x0C						; If both switches are closed
	bz		Switch_ISR					; then
PROG_ISR
	incf	FILTER_ISR, F, ACCESS
	btfsc	FILTER_ISR, 2, ACCESS
    bra     Exit_Switch_ISR
	bra		Switch_ISR2
Switch_ISR
	clrf	FILTER_ISR,ACCESS
Switch_ISR2

	movff	FSR0L, FSR0L_HIGH_save		; save FSR0L
	movff	FSR0H, FSR0H_HIGH_save		; save FSR0H
	movff	FSR1L, FSR1L_HIGH_save		; save FSR1L
	movff	FSR1H, FSR1H_HIGH_save		; save FSR1H
	movlw	HIGH SEG_1					; 0x100
	movwf	FSR0H, ACCESS
	movlw	HIGH SEG_2					; 0x200
	movwf	FSR1H,ACCESS
	movf	BUF_CUR,W,ACCESS
	addlw	0x08
	movwf	FSR1L, ACCESS
	movwf	FSR0L, ACCESS

	movlw	LOW	STEPS_TBL
	movwf	OUTPUT_ISR, ACCESS

	; CALC STEPS
	; if DELTA_M>0
	;	 Set step M
	;    DELTA_M=DELTA_M+COEF_M
	; else
	;    DELTA_M=DELTA_M+STEP_M
	; M1
	movlw	0x03
	btfss	PLUSW0, 7, ACCESS
	bsf		OUTPUT_ISR, 1, ACCESS	; M1 step should go out
	btfss	PLUSW0, 7, ACCESS
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movf	POSTINC1, W, ACCESS
	addwf	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	bcf		FSR1H, 0, ACCESS		; change to bank 2
	; M2
	movlw	0x03
	btfss	PLUSW0, 7, ACCESS
	bsf		OUTPUT_ISR, 2, ACCESS	; M2 step should go out
	btfss	PLUSW0, 7, ACCESS
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movf	POSTINC1, W, ACCESS
	addwf	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	bcf		FSR1H, 0, ACCESS
	; M3
	movlw	0x03
	btfss	PLUSW0, 7, ACCESS
	bsf		OUTPUT_ISR, 3, ACCESS	; M3 step should go out
	btfss	PLUSW0, 7, ACCESS
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movf	POSTINC1, W, ACCESS
	addwf	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	bcf		FSR1H, 0, ACCESS
	; M4
	movlw	0x03
	btfss	PLUSW0, 7, ACCESS
	bsf		OUTPUT_ISR, 4, ACCESS	; M4 step should go out
	btfss	PLUSW0, 7, ACCESS
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movf	POSTINC1, W, ACCESS
	addwf	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	bcf		FSR1H, 0, ACCESS
	; M5
	movlw	0x03
	btfss	PLUSW0, 7, ACCESS
	bsf		OUTPUT_ISR, 5, ACCESS	; M5 step should go out
	btfss	PLUSW0, 7, ACCESS
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movf	POSTINC1, W, ACCESS
	addwf	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	movf	POSTINC1, W, ACCESS
	addwfc	POSTINC0, F, ACCESS
	bcf		FSR1H, 0, ACCESS

	; Output steps
	movlw	HIGH STEPS_TBL
	movwf	FSR0H,ACCESS
	movff	OUTPUT_ISR,FSR0L
	movf	POSTINC0,W,ACCESS
	xorwf	PORTB, F, ACCESS
	movf	POSTINC0,W,ACCESS
	xorwf	PORTD, F, ACCESS

EndISR_H
	movff	FSR0L_HIGH_save,FSR0L	; restore FSR0L
	movff	FSR0H_HIGH_save,FSR0H	; restore FSR0H
	movff	FSR1L_HIGH_save,FSR1L	; restore FSR1L
	movff	FSR1H_HIGH_save,FSR1H	; restore FSR1H
	retfie	FAST					; return restoring W, STATUS and BSR

Turn_M_ON
	movf	TABLE_SEC_OFF,F,ACCESS	; if TABLE_SEC_OFF
	bz		Turn_M_AUTO_OFF			;   =0 continue without turning on the motors
	movf	PORTE,W,ACCESS
	andlw	0x01
	btfsc	TABLE_FLAGS_MOTORS_REV
	xorlw	0x01
	btfss	STATUS,Z,ACCESS			; if Motors on
	bra		Turn_M_ON1				;   decrement timer
	movff	TABLE_SECL,MOTOR_L		; reload MOTOR with TABLE_SEC = 0.5sec
	movff	TABLE_SECH,MOTOR_M
	clrf	MOTOR_H,ACCESS
	bcf		M_ONOFF					; turn motors on
	btfss	TABLE_FLAGS_MOTORS_REV
	bsf		M_ONOFF
Turn_M_ON1
	decf	MOTOR_L, F, ACCESS		; MOTOR--
	bc		Turn_M_ON_Exit
	decf	MOTOR_M, F, ACCESS
	bc		Turn_M_ON_Exit
	bsf		FLAG_M_ONOFF_ISR		; if MOTOR<0 -> FLAG_M_ONOFF_ISR=1
	setf	MOTOR_H,ACCESS
Turn_M_ON_Exit
	retfie	FAST					; return restoring W, STATUS and BSR

Exit_Switch_ISR
	clrf    FILTER_ISR, ACCESS
    btfss	E_PROG                  ; Stop/prog button
	bsf 	FILTER_ISR, 6, ACCESS
	; Switches
	btfsc	FLAG_SW_OVER_ISR		; FLAG_OVER ==1->ignore switches
	bra		Exit_Switch_ISR1
	movf	PORTA, W, ACCESS
	andlw	0x0C					; Filter switches
    rlncf   WREG,F,ACCESS
    rlncf   WREG,F,ACCESS
    iorwf   FILTER_ISR,F,ACCESS
Exit_Switch_ISR1
	bcf		FLAG_GO_ISR				; no more data
	bcf		FLAG_PWM_ISR			; PWM OFF
	movff	TABLE_FREQL,CCPR1L		; CCPR1=TABLE_FREQ
	movff	TABLE_FREQH,CCPR1H
    bcf     FLAG_PWM_ISR
	retfie	FAST					; return restoring W, STATUS and BSR

PROCESS_ISR
	movff	FSR1L, FSR1L_HIGH_save		; save FSR1L
	movff	FSR1H, FSR1H_HIGH_save		; save FSR1H
	movlw	HIGH SEG_2					; 0x200
	movwf	FSR1H,ACCESS

PROCESS_ISR0
	bcf		PIR1, CCP1IF, ACCESS		; clear int flag

	; Outputs = 0
	movlw	b'00000011'
	andwf	PORTB,W,ACCESS
	iorwf	DIR_B,W,ACCESS
	movwf	PORTB,ACCESS
	movlw	b'00001111'
	andwf	PORTD,W,ACCESS
	iorwf	DIR_D,W,ACCESS
	movwf	PORTD,ACCESS
	; Do steps next time
	bsf		FLAG_STEP_ISR

	bsf		MOTOR_H,7,ACCESS		; force MOTOR reload

	movf	BUF_CUR,W,ACCESS
	movwf	FSR1L, ACCESS

	; Nbr interrupts
	decf	POSTINC1, F, ACCESS	; NBR_ISR--
	bc		Nbr_ISR
	decf	POSTINC1, F, ACCESS
	bc		Nbr_ISR
	decf	POSTINC1, F, ACCESS
	bc		Nbr_ISR
	decf	POSTINC1, F, ACCESS
	bc		Nbr_ISR

	; *** Reload ***
	btfss	FLAG_USB_ISR			; if using FLASH
	bsf		PIR2, CMIF, ACCESS		;  enable software int COMP to load new data

	btfsc	FLAG_STOP_ISR			; if Stop=1
	bra		No_Reload				;  then stop

	movwf	FSR1L, ACCESS
	addlw	0x20
	cpfseq	BUF_WR, ACCESS			; if BUF_WR==BUF_CUR+0x20 -> buffer empty
	bra		Reload_ISR0				; else reload
No_Reload
	clrf	POSTINC1, ACCESS
	clrf	POSTINC1, ACCESS
	clrf	POSTINC1, ACCESS
	clrf	POSTINC1, ACCESS
	bcf		FLAG_STEP_ISR			; do not calc the steps
	btfsc	FLAG_STOP_ISR			; if Stop=1
	bcf		FLAG_GO_ISR				;  then stop
	bra		EndISR_H2				; Exit

	; Reload all values
Reload_ISR0
	bsf		FSR1H, 0, ACCESS		; change to bank 3
	movwf	BUF_CUR, ACCESS			; Increment BUF_CUR
	movwf	FSR1L, ACCESS

	movff	POSTINC1, CMD_ISR		; Load CMD
	btfss	CMD_ISR,7,ACCESS		; ? END
	bra		Reload_ISR1
	bcf		FLAG_GO_ISR				; Stop processing data
	bcf		FLAG_STEP_ISR			; do not calc the steps
	bcf		PIR2, CMIF, ACCESS		; No need for data anymore
	btfss	FLAG_USB_ISR			; if using FLASH
	bsf		CS						;  stop current read
	clrf	BUF_CUR, ACCESS			; Reset Buffer indexes
	movlw	0x20
	movwf	BUF_WR, ACCESS
	clrf	NBR_SEG_H, ACCESS		; NBR_SEG=0
	clrf	NBR_SEG_M, ACCESS
	clrf	NBR_SEG_L, ACCESS
    movlw   0x80
    movwf   FILTER_ISR, ACCESS      ; Stop due to end of data
	bcf		T0CON, TMR0ON, ACCESS	; Disable TIMER 0
	bcf		INTCON, TMR0IF, ACCESS	; clear TMR0 int flag
	movff	TABLE_FREQL,CCPR1L		; CCPR1=TABLE_FREQ
	movff	TABLE_FREQH,CCPR1H
    bcf     FLAG_PWM_ISR			; PWM OFF
	bra		EndISR_H2				; Exit

Reload_ISR1
	bcf		STATUS,C, ACCESS
	infsnz	NBR_SEG_L,F, ACCESS		; Increment NBR_SEG
	incf	NBR_SEG_M,F, ACCESS
	btfsc	STATUS,C, ACCESS
	incf	NBR_SEG_H,F, ACCESS
    bsf     FLAG_LCD_UPDATE         ; Update display

	; Change directions
	movff	POSTINC1, DIR_B			; Load DIR_B
	movff	POSTINC1, DIR_D			; Load DIR_D
	movlw	b'00000011'
	andwf	PORTB,W,ACCESS
	iorwf	DIR_B,W,ACCESS
	movwf	PORTB,ACCESS
	movlw	b'00001111'
	andwf	PORTD,W,ACCESS
	iorwf	DIR_D,W,ACCESS
	movwf	PORTD,ACCESS

	movf	POSTINC1, W, ACCESS		; PWM value
;	btfsc	CMD_ISR,6,ACCESS		; ? PWM data valid
;	movwf	PWM_PC, ACCESS			; store it
	btfss	CMD_ISR,6,ACCESS		; ? PWM data valid
    bra     Reload_ISR1a
	movwf	PWM_PC, ACCESS			; store it
    btfss   PWM_ONOFF				; PWM_ONOFF 1=OFF 0=ON
	bsf		FLAG_PWM_ISR            ; If PWM_ONOFF=ON -> PWM ON
Reload_ISR1a
	btfss	CMD_ISR,5, ACCESS		; ? Accel
	bra		Reload_ISR2				;  non -> Reload_ISR2
	movff	POSTINC1,FREQ_ACC
	movff	POSTINC1,FREQ_DEC
	movff	POSTINC1,CCPR1H			; CCPR1=FREQ
	movff	POSTINC1,CCPR1L
	clrf	TMR0H, ACCESS
	clrf	TMR0L, ACCESS			; clear TIMER 0
	bsf		T0CON, TMR0ON, ACCESS	; Enable TIMER 0
	bcf		INTCON, TMR0IF, ACCESS	; clear TMR0 int flag
	bra		EndISR_H2				; Exit
Reload_ISR2
	movff	TABLE_FREQL,CCPR1L		; CCPR1=TABLE_FREQ
	movff	TABLE_FREQH,CCPR1H
	bcf		T0CON, TMR0ON, ACCESS	; Disable TIMER 0
	bcf		INTCON, TMR0IF, ACCESS	; clear TMR0 int flag
	bra		EndISR_H2				; Exit

Nbr_ISR
	btfss	CMD_ISR,5, ACCESS		; ? Accel
	bra		EndISR_H2
	addlw	0x04
	movwf	FSR1L, ACCESS
	decf	POSTINC1, F, ACCESS		; END_ISR--
	bc		EndISR_H2
	decf	POSTINC1, F, ACCESS
	bc		EndISR_H2
	decf	POSTINC1, F, ACCESS
	bc		EndISR_H2
	decf	POSTINC1, F, ACCESS
	bc		EndISR_H2
	bsf		CMD_ISR,4, ACCESS		; Decel
	bsf		CMD_ISR,3, ACCESS		; Decel
	clrf	TMR0H, ACCESS
	clrf	TMR0L, ACCESS			; clear TIMER 0
	bsf		T0CON, TMR0ON, ACCESS	; Enable TIMER 0
	bcf		INTCON, TMR0IF, ACCESS	; clear TMR0 int flag
EndISR_H2
	movff	FSR1L_HIGH_save,FSR1L	; restore FSR1L
	movff	FSR1H_HIGH_save,FSR1H	; restore FSR1H
	retfie	FAST					; return restoring W, STATUS and BSR

Turn_M_OFF
	btfss	FLAG_M_ONOFF_ISR		; if FLAG_M_ONOFF_ISR=0
	retfie	FAST					; return restoring W, STATUS and BSR
	movf	TABLE_SEC_OFF,F,ACCESS	; if TABLE_SEC_OFF=0
	bz		Turn_M_OFF_Exit			;   -> exit...
	btfss	MOTOR_H,7,ACCESS		; if MOTOR>0
	bra		Turn_M_OFF1				;   decrement timer
	movff	PRODL, PRODL_HIGH_save	; save PRODL
	movff	PRODH, PRODH_HIGH_save	; save PRODH

	rlncf	TABLE_SEC_OFF,W,ACCESS
	mulwf	TABLE_SECL,ACCESS
	movff	PRODL,MOTOR_L			; reload MOTOR with TABLE_SEC * 2 * TABLE_SEC_OFF
	movff	PRODH,MOTOR_M
	clrf	MOTOR_H,ACCESS
	rlncf	TABLE_SEC_OFF,W,ACCESS
	mulwf	TABLE_SECH,ACCESS
	movf	PRODL,W, ACCESS
	addwf	MOTOR_M,F,ACCESS
	movf	PRODH,W, ACCESS
	addwfc	MOTOR_H,F,ACCESS

	movff	PRODL_HIGH_save, PRODL	; restore PRODL
	movff	PRODH_HIGH_save, PRODH	; restore PRODH
Turn_M_OFF1
	decf	MOTOR_L, F, ACCESS		; MOTOR--
	bc		Turn_M_OFF_Exit
	decf	MOTOR_M, F, ACCESS
	bc		Turn_M_OFF_Exit
	decf	MOTOR_H, F, ACCESS
	bc		Turn_M_OFF_Exit
	bsf		M_ONOFF					; if MOTOR<0 -> Motors off
	btfss	TABLE_FLAGS_MOTORS_REV
	bcf		M_ONOFF
	bcf		FLAG_M_ONOFF_ISR		; FLAG_M_ONOFF_ISR=0
Turn_M_OFF_Exit
	retfie	FAST					; return restoring W, STATUS and BSR

; ******************************************************************
; ******************************************************************
; ISR LOW PRIORITY
;	Interrupt Service Routine
;
; ******************************************************************
; ******************************************************************
ISR_LOW
	; save context W, STATUS and FSR0
	movwf	W_save, ACCESS
	swapf	STATUS, W, ACCESS
	movwf	STATUS_save, ACCESS

Test_COMP	; used as software interrupt
	btfsc	PIE2, CMIE, ACCESS	; COMP int. enabled...
	btfss	PIR2, CMIF, ACCESS	; ...and COMP int. occurred?
	bra		Test_TMR0			; no, nothing to be done here
	bcf		PIR2, CMIF, ACCESS	; yes, clear int flag

	btfsc	CS						; is the flash selected ?
	bra		Test_TMR0				; no, nothing to be done here
COMP_0
	movf	BUF_WR, W, ACCESS		; Is buffer full?
	cpfseq	BUF_CUR, ACCESS
	bra		COMP_1
	bra		Test_TMR0				; yes, nothing more to do
COMP_1
	movff	FSR1L, FSR1L_LOW_save
	movff	FSR1H, FSR1H_LOW_save
	movff	FSR2L, FSR2L_LOW_save
	movff	FSR2H, FSR2H_LOW_save
    movlw	HIGH SEG_3
    movwf	FSR1H, ACCESS
    movff	BUF_WR,FSR1L			; FSR1=0x03:Write buffer
	movflfnxt	COMP_TMP
    movlw	B'11100000'
    andwf   COMP_TMP,W,ACCESS
    movwf	POSTINC1,ACCESS			; Store CMD
    btfsc	COMP_TMP, 7, ACCESS
    bra     COMP_End
    ; Setup direction bits
    lfsr	2,DIRS_TBL
    rlncf	COMP_TMP,W,ACCESS
    andlw	0x3E
    addwf	FSR2L,F,ACCESS
    movff	POSTINC2,POSTINC1
    movff	POSTINC2,POSTINC1
    ; Nbr
	bcf		FSR1H,0,ACCESS          ; 0x200
	movff	BUF_WR, FSR1L
	movflfnxt	NBRL            	; copy NBR in RAM for calc
	decf	NBRL,W, ACCESS      	; Dec NBR counter for interrupt
	movwf	POSTINC1, ACCESS
	movflfnxt	NBRM
    movf    NBRM,W,ACCESS
	btfss	STATUS,C, ACCESS
	decf	NBRM,W, ACCESS
	movwf	POSTINC1, ACCESS
	movflfnxt	NBRH
    movf    NBRH,W,ACCESS
	btfss	STATUS,C, ACCESS
	decf	NBRH,W, ACCESS
	movwf	POSTINC1, ACCESS
	movflfnxt	NBRU
    movf    NBRU,W,ACCESS
	btfss	STATUS,C, ACCESS
	decf	NBRU,W, ACCESS
	movwf	POSTINC1, ACCESS
	btfss	STATUS, C, ACCESS
	bra		COMP_End2			; if NBR=0x0000000 -> exit...
	movlw	0x04
	addwf	FSR1L,F,ACCESS
	movflfnxt   POSTINC1        ; copy STEP1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1        ; copy STEP2
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1        ; copy STEP3
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1        ; copy STEP4
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1        ; copy STEP5
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1

	movlw	HIGH SEG_1
	movwf	FSR2H, ACCESS		; 0x1
	movf	BUF_WR,W,ACCESS
	addlw	0x08
	movwf	FSR2L, ACCESS
	movwf	FSR1L, ACCESS

	movlw	.5
	movwf	COMP_CNT, ACCESS
COMP_2
	bcf		FSR1H,0,ACCESS		; 0x2
	; DELTA_M=STEP_M-NBR
	movf	NBRL, W,ACCESS
	subwf	POSTINC1, W, ACCESS
	movwf	POSTINC2, ACCESS
	movf	NBRM, W, ACCESS
	subwfb	POSTINC1, W, ACCESS
	movwf	POSTINC2, ACCESS
	movf	NBRH, W, ACCESS
	subwfb	POSTINC1, W, ACCESS
	movwf	POSTINC2, ACCESS
	movf	NBRU, W, ACCESS
	subwfb	POSTINC1, W, ACCESS
	movwf	POSTINC2, ACCESS

	movlw	0x04
	subwf	FSR2L,F,ACCESS
	subwf	FSR1L,F,ACCESS
	bsf		FSR1H,0,ACCESS		; 0x3
	; COEF_M=DELTA_M-NBR
	movf	NBRL, W,ACCESS
	subwf	POSTINC2, W, ACCESS
	movwf	POSTINC1, ACCESS
	movf	NBRM, W, ACCESS
	subwfb	POSTINC2, W, ACCESS
	movwf	POSTINC1, ACCESS
	movf	NBRH, W, ACCESS
	subwfb	POSTINC2, W, ACCESS
	movwf	POSTINC1, ACCESS
	movf	NBRU, W, ACCESS
	subwfb	POSTINC2, W, ACCESS
	movwf	POSTINC1, ACCESS
	decfsz	COMP_CNT,F,ACCESS
	bra		COMP_2

	movf	BUF_WR,W,ACCESS
	addlw	0x03
	movwf	FSR1L, ACCESS

	btfss	COMP_TMP, 6, ACCESS     ; ?PWM data
    bra     COMP_4
	movflfnxt   WREG
COMP_4
    movwf   POSTINC1, ACCESS

	btfss	COMP_TMP, 5, ACCESS		; ?ACC data
	bra		COMP_End1
	movflfnxt   WREG
	movff	TABLAT,TABLAT_LOW_save
	movff	TBLPTRL,TBLPTRL_LOW_save
	movff	TBLPTRH,TBLPTRH_LOW_save
	movwf	POSTINC1,ACCESS			; copy FREQ_ACC
	movwf	TBLPTRL, ACCESS
	movflfnxt   POSTINC1			; copy FREQ_DEC
	movff	TABLE_FREQ,TBLPTRH
	tblrd*
	movff	TABLAT,POSTINC1			; copy FREQH
	incf	TBLPTRH, F, ACCESS
	tblrd*
	movff	TABLAT,POSTINC1			; copy FREQL
	movff	TABLAT_LOW_save,TABLAT
	movff	TBLPTRL_LOW_save,TBLPTRL
	movff	TBLPTRH_LOW_save,TBLPTRH
	bcf		FSR1H,0,ACCESS			; 0x200
	movlw	0x04
	subwf	FSR1L,F,ACCESS
	movflfnxt   POSTINC1			; copy END
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	movflfnxt   POSTINC1
	bra		COMP_End1
COMP_End2
	bcf		FLAG_GO_ISR				; Stop processing data
COMP_End
	bsf		CS						; no more read
COMP_End1
	movlw	0x20
	addwf	BUF_WR, F, ACCESS		; Data available to process
    bsf     FLAG_LCD_UPDATE         ; Update display

	movff	FSR1L_LOW_save, FSR1L	; restore FSR1L
	movff	FSR1H_LOW_save, FSR1H	; restore FSR1H
	movff	FSR2L_LOW_save, FSR2L	; restore FSR2L
	movff	FSR2H_LOW_save, FSR2H	; restore FSR2H
    btfss   CS
    bra     COMP_0
Test_TMR0
	; ACCEL/DECEL
	btfsc	INTCON, TMR0IE, ACCESS		; TMR0 int. enabled...
	btfss	INTCON, TMR0IF, ACCESS		; TMR0 int. occurred?
	bra		EndISR_L					; no, nothing to be done here
	bcf		INTCON, TMR0IF, ACCESS		; yes, clear int flag

	btfsc	FLAG_GO_ISR					; GO =0->disable
	btfss	CMD_ISR, 5, ACCESS			; CMD_ISR.5 =1->enable, =0->disable
	bra		TMR0_DISABLE				;   ..=0 -> disable TMR0 and exit

	btfsc	CMD_ISR, 4, ACCESS			; CMD_ISR.4 =0->accel, =1->decel
	bra		TMR0_DECEL

TMR0_ACCEL
	infsnz	FREQ_ACC,W,ACCESS
	bra		TMR0_DISABLE				; disable TMR0 and exit
TMR0_CCP_DEC
	movff	TABLAT,TABLAT_LOW_save
	movff	TBLPTRL,TBLPTRL_LOW_save
	movff	TBLPTRH,TBLPTRH_LOW_save
	movwf	FREQ_ACC, ACCESS
	movwf	TBLPTRL, ACCESS
	movff	TABLE_FREQ,TBLPTRH
	tblrd*
	movf	TABLAT,W,ACCESS
	incf	TBLPTRH, F, ACCESS
	tblrd*
	bcf		INTCON, GIEH, ACCESS		; disable High int
	movff	TABLAT,CCPR1L				; Update CCPR1
	movwf	CCPR1H,ACCESS
	movf	TMR1L, W, ACCESS
	subwf	CCPR1L, W, ACCESS
	movf	TMR1H, W, ACCESS
	subwfb	CCPR1H, W, ACCESS
	bnn		EndISR_L1					; If TMR1<CCPR1 -> exit
	clrf	TMR1H, ACCESS
	clrf	TMR1L, ACCESS				; TMR1=0
	bsf		PIR1, CCP1IF, ACCESS		; set CCPR1 int flag
EndISR_L1
	bsf		INTCON, GIEH, ACCESS		; enable High int
EndISR_L2
	movff	TABLAT_LOW_save,TABLAT
	movff	TBLPTRL_LOW_save,TBLPTRL
	movff	TBLPTRH_LOW_save,TBLPTRH
	bra		EndISR_L					; exit

TMR0_DECEL
	decf	FREQ_ACC,W,ACCESS
	cpfslt	FREQ_DEC, ACCESS			; ?FREQ_ACC>FREQ_DEC
	bra		TMR0_DECEL_1				; no -> disable TMR0 and exit
TMR0_CCP_INC
	movff	TABLAT,TABLAT_LOW_save
	movff	TBLPTRL,TBLPTRL_LOW_save
	movff	TBLPTRH,TBLPTRH_LOW_save
	movwf	FREQ_ACC,ACCESS
	movwf	TBLPTRL, ACCESS
	movff	TABLE_FREQ,TBLPTRH
	tblrd*
	movf	TABLAT,W,ACCESS
	incf	TBLPTRH, F, ACCESS
	tblrd*
	bcf		T1CON, TMR1ON, ACCESS		; Turn TIMER1 off
	clrf	CCP1CON, ACCESS				; stop compare
	movff	TABLAT,CCPR1L				; Update CCPR1
	movwf	CCPR1H,ACCESS
	movlw	B'00001011'
	movwf	CCP1CON, ACCESS				; CCP1 in compare mode with TIMER1 Reset
	bsf		T1CON, TMR1ON, ACCESS		; Turn TIMER1 on
	bra		EndISR_L2
TMR0_DECEL_1
	btfss	FLAG_STOP_ISR				; ?STOP=1
	bra		TMR0_DISABLE
	bcf		FLAG_GO_ISR					;   -> GO=0
	movff	TABLE_FREQL,CCPR1L			; CCPR1=TABLE_FREQ
	movff	TABLE_FREQH,CCPR1H
TMR0_DISABLE
	bcf		T0CON, TMR0ON, ACCESS		; disable TMR0
EndISR_L
	; restore context W, STATUS
	swapf	STATUS_save, W, ACCESS
	movwf	STATUS, ACCESS
	swapf	W_save, F, ACCESS
	swapf	W_save, W, ACCESS
	retfie

; ******************************************************************
; ******************************************************************
; Main
; ******************************************************************
; ******************************************************************
Main
	;	Special Function Registers and General Purpose Registers main initialization
	call		Init
	call		Init_LCD					; initialize the LCD registers
	call		InitUSB						; initialize the USB registers and serial interface engine

	repeat
		call	Read_PWM
		call	Read_Keys
		movlw	0x02
		xorwf	KEYB,W,ACCESS				; Jump to manual menu if only OK is pressed
		btfsc	STATUS,Z,ACCESS
		goto	Main_Menu
		call	ServiceUSB					; service USB requests...
		banksel	USB_USWSTAT
	until USB_USWSTAT, ==, CONFIG_STATE		; ...until the host configures the peripheral

	; Write MODE USB on LCD
	bsf		FLAG_LCD_LINE
	movlw	0x00
	call	LCD_Pos_DDRAM							; 2nd line
	movtblptr STR_MODE_USB
	call	LCD_String						; Write string
    ; Backup FLAG_ISR to display only when a change happen
    movf    FLAG_ISR, W, ACCESS
    andlw   B'01001001'
    movwf   FLAG_OLD, ACCESS
	; Main loop
    repeat
		call	ServiceUSB					; service USB requests...

		call	Read_PWM
		call	Update_LCD
		call	Read_Keys

		call	ServiceUSB					; service USB requests...

		banksel		BD1OST
		ifclr BD1OST, UOWN, BANKED			; check to see if the PIC owns the EP1 OUT buffer
			call	GetBUFFER1
			call	ServiceUSB				; service USB requests...
			call	Commands
			repeat
				call		ServiceUSB		; service USB requests...
				banksel		BD1IST
			untilclr BD1IST, UOWN, BANKED	; ...until the PIC owns the EP1 IN buffer
			call	SendBUFFER2
		endi
	forever

; ******************************************************************
; ******************************************************************
; 							COMMANDS
; ******************************************************************
; ******************************************************************
Commands
	banksel		BUFFER1
	movf		BUFFER1, W, BANKED
	select
		; 0x42 Buffer
		case 'B'
			movlw	'B'
			movwf	BUFFER2+0,BANKED
			setf	BUFFER2+1,BANKED
			tstfsz	BUFFER1+1,BANKED		; if BUFFER1[1]==0 -> reset buffer 
			bra		COMMAND_B_1
			; Reset Buffer
			bcf		FLAG_GO_ISR
			bcf		FLAG_STEP_ISR
			bcf		PIR2, CMIF, ACCESS		;  disable software int COMP
			bcf		FLAG_STOP_ISR
			clrf	FILTER_ISR
			bsf		CS
			movlw	0x20
			movwf	BUF_WR, ACCESS
			clrf	BUF_CUR, ACCESS
			movlw	HIGH	SEG_2
			movwf	FSR0H, ACCESS
			clrf	FSR0L, ACCESS
			clrf	POSTINC0, ACCESS		; NBR=0
			clrf	POSTINC0, ACCESS
			clrf	POSTINC0, ACCESS
			clrf	POSTINC0, ACCESS
			clrf	NBR_SEG_H, ACCESS		; NBR_SEG=0
			clrf	NBR_SEG_M, ACCESS
			clrf	NBR_SEG_L, ACCESS
			bcf		FLAG_USB_ISR
			; Reset Accel
			clrf	CMD_ISR, ACCESS			; No accel
			bcf		T0CON, TMR0ON, ACCESS	; Disable TIMER 0
			movff	TABLE_FREQL,CCPR1L		; CCPR1=TABLE_FREQ
			movff	TABLE_FREQH,CCPR1H
			break
COMMAND_B_1											; else
			btfss	BUFFER1+1,7,BANKED		; if BUFFER1[1]==0x80 -> GO
			bra		COMMAND_B_2
			bsf		FLAG_GO_ISR
			break
COMMAND_B_2											; else
			btfss	BUFFER1+1,0,BANKED		; if BUFFER1[1]==0x01 -> Source = USB
			bra		COMMAND_B_3
			bsf		FLAG_USB_ISR
			break
COMMAND_B_3											; else
			btfss	BUFFER1+1,1,BANKED		; if BUFFER1[1]==0x02 -> Source = FLASH
			bra		COMMAND_B_4
			bsf		CS
			bcf		FLAG_USB_ISR
			; Read flash
			bcf		CS
			movlw	0x03					; Read command
			call	RW_FLASH
			movf	BUFFER1+2,W,BANKED		; BYTE1 = BLOCK
			call	RW_FLASH
			movf	BUFFER1+3,W,BANKED		; BYTE2 = ADRH
			call	RW_FLASH
			movf	BUFFER1+4,W,BANKED		; BYTE3 = ADRL
			call	RW_FLASH
        	bcf		PIR1, SSPIF, ACCESS     ; Preload 1st byte
            clrf	SSPBUF, ACCESS
			bsf		PIR2, CMIF, ACCESS		;  enable software int COMP to load new data
			break
COMMAND_B_4											; else
			clrf	BUFFER2+1,BANKED		; Error send 0
			break
		
		; 0x44 Data
		case 'D'
			movlw	'D'
			movwf	BUFFER2+0,BANKED
			btfss	FLAG_USB_ISR			; Data only allowed if Source=USB
			bra		COMMAND_I_1				; if not exit with code 0x00
			setf	BUFFER2+1,BANKED
			movf	BUF_WR, W, ACCESS
			cpfseq	BUF_CUR, ACCESS
			bra		COMMAND_D_0
			bra		COMMAND_I_1				; Buffer is full exit with code 0xFF
COMMAND_D_0
			lfsr	0,BUFFER1+1				; FSR0=BUFFER1
			movlw	HIGH SEG_3
			movwf	FSR1H, ACCESS
			movff	BUF_WR,FSR1L			; FSR1=0x03:Write buffer
			movf	INDF0,W,ACCESS
			andlw	B'11100000'
			movwf	POSTINC1,ACCESS			; Store CMD
			movwf	TEMP, ACCESS
			btfsc	TEMP, 7, ACCESS
			bra		COMMAND_D_9				; Exit if last data
		
			; Setup direction bits
			lfsr	2,DIRS_TBL
			rlncf	POSTINC0,W,ACCESS
			andlw	0x3E
			addwf	FSR2L,F,ACCESS	
			movff	POSTINC2,POSTINC1
			movff	POSTINC2,POSTINC1
		
			bcf		FSR1H,0,ACCESS		; 0x200
			movff	BUF_WR, FSR1L
			movf	POSTINC0,W, ACCESS	; copy NBR in RAM for calc
			movwf	NBRL, ACCESS
			decf	NBRL,W, ACCESS		; Dec NBR counter for interrupt
			movwf	POSTINC1, ACCESS
			movf	POSTINC0,W, ACCESS
			movwf	NBRM, ACCESS
			btfss	STATUS,C, ACCESS
			decf	NBRM,W, ACCESS
			movwf	POSTINC1, ACCESS
			movf	POSTINC0,W, ACCESS
			movwf	NBRH, ACCESS
			btfss	STATUS,C, ACCESS
			decf	NBRH,W, ACCESS
			movwf	POSTINC1, ACCESS
			movf	POSTINC0,W, ACCESS
			movwf	NBRU, ACCESS
			btfss	STATUS,C, ACCESS
			decf	NBRU,W, ACCESS
			movwf	POSTINC1, ACCESS
			clrf	BUFFER2+1,BANKED
			btfss	STATUS, C, ACCESS
			bra		COMMAND_I_1			; if NBR=0x0000000 -> exit with error code 0x00
		
			movlw	0x04
			addwf	FSR1L,F,ACCESS
			movff	POSTINC0, POSTINC1	; copy STEP1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1	; copy STEP2
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1	; copy STEP3
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1	; copy STEP4
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1	; copy STEP5
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
		
			movlw	HIGH SEG_1
			movwf	FSR2H, ACCESS		; 0x1
			movf	BUF_WR,W,ACCESS
			addlw	0x08
			movwf	FSR2L, ACCESS
			movwf	FSR1L, ACCESS
		
			movlw	.5
			movwf	iBUFFER, ACCESS
COMMAND_D_2
			bcf		FSR1H,0,ACCESS			; 0x2
			; DELTA_M=STEP_M-NBR
			movf	NBRL, W,ACCESS
			subwf	POSTINC1, W, ACCESS
			movwf	POSTINC2, ACCESS
			movf	NBRM, W, ACCESS
			subwfb	POSTINC1, W, ACCESS
			movwf	POSTINC2, ACCESS
			movf	NBRH, W, ACCESS
			subwfb	POSTINC1, W, ACCESS
			movwf	POSTINC2, ACCESS
			movf	NBRU, W, ACCESS
			subwfb	POSTINC1, W, ACCESS
			movwf	POSTINC2, ACCESS
		
			movlw	0x04
			subwf	FSR2L,F,ACCESS
			subwf	FSR1L,F,ACCESS
			bsf		FSR1H,0,ACCESS			; 0x3
			; COEF_M=DELTA_M-NBR
			movf	NBRL, W,ACCESS
			subwf	POSTINC2, W, ACCESS
			movwf	POSTINC1, ACCESS
			movf	NBRM, W, ACCESS
			subwfb	POSTINC2, W, ACCESS
			movwf	POSTINC1, ACCESS
			movf	NBRH, W, ACCESS
			subwfb	POSTINC2, W, ACCESS
			movwf	POSTINC1, ACCESS
			movf	NBRU, W, ACCESS
			subwfb	POSTINC2, W, ACCESS
			movwf	POSTINC1, ACCESS
		
			decfsz	iBUFFER,F,ACCESS
			bra		COMMAND_D_2
		
			movf	BUF_WR,W,ACCESS
			addlw	0x03
			movwf	FSR1L, ACCESS
		
			btfsc	TEMP, 6, ACCESS				; ?PWM data
			movf	POSTINC0, W, ACCESS
			movwf	POSTINC1, ACCESS

			btfss	TEMP, 5, ACCESS				; ?ACC data
			bra		COMMAND_D_9
			movf	POSTINC0,W,ACCESS
			movwf	POSTINC1,ACCESS				; copy FREQ_ACC
			movwf	TBLPTRL, ACCESS
			movff	POSTINC0,POSTINC1			; copy FREQ_DEC
			movff	TABLE_FREQ,TBLPTRH
			tblrd*
			movff	TABLAT,POSTINC1				; copy FREQH
			incf	TBLPTRH, F, ACCESS
			tblrd*
			movff	TABLAT,POSTINC1				; copy FREQL

			bcf		FSR1H,0,ACCESS				; 0x200
			movlw	0x04
			subwf	FSR1L,F,ACCESS
			movff	POSTINC0, POSTINC1			; copy END
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
			movff	POSTINC0, POSTINC1
COMMAND_D_9
			movlw	0x20
			addwf	BUF_WR, F, ACCESS			; Data available for process
			movlw	0x01
			movwf	BUFFER2+1, BANKED			; Data has been stored
            bsf     FLAG_LCD_UPDATE             ; Update display
			bra		COMMAND_I_1
		
		; 0x49 Information
		case 'I'
			movlw	'I'
			movwf	BUFFER2+0,BANKED
			setf	BUFFER2+1,BANKED
			movf	BUF_WR, W, ACCESS
			cpfseq	BUF_CUR, ACCESS				; Is buffer full?
			clrf	BUFFER2+1,BANKED			; no send 0x00, yes send 0xFF
COMMAND_I_1
			movf	BUF_CUR,W,ACCESS
			subwf	BUF_WR,W,ACCESS
			swapf	WREG,F,ACCESS
			rrncf	WREG,F,ACCESS
			decf	WREG,F, ACCESS
			andlw	B'00000111'
			movwf	BUFFER2+2,BANKED			; BYTE 2 => Buffer load from 0(empty) to 7(full)
			movff	FLAG_ISR, BUFFER2+6
			rrncf	PORTA, W, ACCESS
			andlw	B'00011111'					; BYTE 7 => b0=AUTO/MANU,b1=ORIGIN,b2=END,b3=IO0,b4=IO1
			btfsc	E_PROG
			bsf		WREG, 5, ACCESS
			movwf	BUFFER2+7, BANKED
			movff	PWM_PC,BUFFER2+8			; BYTE 8 => PWM_PC
			movff	PWM_PIC, BUFFER2+9			; BYTE 9 => PWM_PIC
			movff	KEYB, BUFFER2+.10			; BYTE 10 => KEYB
			; Stop
            btfss	FLAG_GO_ISR
			bsf		BUFFER2+.11,1,BANKED
			btfsc	FLAG_STOP_ISR
			bsf		BUFFER2+.11,2,BANKED
            movf    FILTER_ISR,W,ACCESS
            andlw   0xF0
            iorwf   BUFFER2+.11,F,BANKED
			; copy position
            movlw	HIGH SEG_2					; 0x200
			movwf	FSR1H,ACCESS
            bcf     INTCON, GIEH, ACCESS
			movff	BUF_CUR,FSR1L
			movff	NBR_SEG_L, BUFFER2+3        ; NBR_SEG
			movff	NBR_SEG_M, BUFFER2+4
			movff	NBR_SEG_H, BUFFER2+5
			movff	POSTINC1, BUFFER2+.12			; NBR_PULSE
			movff	POSTINC1, BUFFER2+.13
			movff	POSTINC1, BUFFER2+.14
			movff	POSTINC1, BUFFER2+.15
            bsf     INTCON, GIEH, ACCESS
			break
		
		; 0x56 Version
		case 'V'
			movtblptr STR_IPL5X
			lfsr	0,BUFFER2
			movlw	'V'
			movwf	POSTINC0, ACCESS
			bcf		EECON1, CFGS, ACCESS		; select program/data memory (not configuration)
			bsf		EECON1, EEPGD, ACCESS		; select flash program memory (not eeprom data)
COMMAND_V_1
			tblrd*+								; read a byte and increment TBLPTR
			movf	TABLAT,W, ACCESS			; read the byte
			btfsc	STATUS,Z, ACCESS
			break								; end if the byte is 0x00 end of string
			movwf	POSTINC0, ACCESS			; write the byte to the Buffer
			bra		COMMAND_V_1					; loop until done
			break
		
		; 0x4F Override
		case 'O'
			bcf		EECON1, EEPGD, ACCESS		; Point to EEPROM memory
			bcf		EECON1, CFGS, ACCESS		; Access EEPROM
			movf	BUFFER1+1,W,BANKED
			bnz		COMMAND_O_1
			btfsc	TABLE_FLAGS, 0, ACCESS		; cannot remove override if table does not support it...
			bcf		FLAG_SW_OVER_ISR			; ?BYTE 1 == 0 -> NO Override
			bra		COMMAND_O_2
COMMAND_O_1
			decfsz	BUFFER1+1,W,BANKED
			bra		COMMAND_O_2
			bsf		FLAG_SW_OVER_ISR			; ?BYTE 1 == 1 -> Override
COMMAND_O_2
			movlw	'O'
			movwf	BUFFER2+0,BANKED
			btfsc	FLAG_SW_OVER_ISR			; override=1 -> BUFFER2+1=1 else BUFFER2+1=0
			bsf		BUFFER2+1,0,BANKED
			btfsc	TABLE_FLAGS, 0, ACCESS		; table setting
			bsf		BUFFER2+1,1,BANKED
			btfsc	ORIGIN						; ORIGIN
			bsf		BUFFER2+1,2,BANKED
			btfsc	IEND						; END
			bsf		BUFFER2+1,3,BANKED
			break
		
		; 0x47 General IO1
		case 'G'
			movf	BUFFER1+1,F,BANKED
			bnz		COMMAND_G_1
			;CMD=0 Set IO1 pin low (0)
			movf	TABLE_IO1,F,ACCESS
			bnz		COMMAND_G_9
			bcf		IO1
			bra		COMMAND_G_9
COMMAND_G_1
			decfsz	BUFFER1+1,F,BANKED
			bra		COMMAND_G_2
			;CMD=1 Set IO1 pin high (1)
			movf	TABLE_IO1,F,ACCESS
			bnz		COMMAND_G_9
			bsf		IO1
			bra		COMMAND_G_9
COMMAND_G_2
			decfsz	BUFFER1+1,F,BANKED
			bra		COMMAND_G_3
			;CMD=2	Read IO1 pin setting
			bra		COMMAND_G_9
COMMAND_G_3
			decfsz	BUFFER1+1,F,BANKED
			break
			movff	BUFFER1+2,TABLE_IO1
			;CMD=3	Change IO1 pin setting
COMMAND_G_9
			movlw	'G'
			movwf	BUFFER2+0,BANKED
			btfsc	IO1
			bsf		BUFFER2+1,0,BANKED
			movff	TABLE_IO1,BUFFER2+2
			break
		
		; 0x4D Motors ON/OFF
		case 'M'
			movf	BUFFER1+1,F,BANKED
			bnz		COMMAND_M_1
			;CMD=0 Set M_ON/OFF pin low (0)
			bcf		FLAG_M_ONOFF_ISR			; FLAG_M_ONOFF_ISR=0
			btfsc	TABLE_FLAGS_MOTORS_REV
			bsf		M_ONOFF
			btfss	TABLE_FLAGS_MOTORS_REV
			bcf		M_ONOFF
			bra		COMMAND_M_9
COMMAND_M_1
			decfsz	BUFFER1+1,F,BANKED
			bra		COMMAND_M_2
			;CMD=1 Set M_ON/OFF pin high (1)
			bsf		FLAG_M_ONOFF_ISR			; FLAG_M_ONOFF_ISR=1
			btfss	TABLE_FLAGS_MOTORS_REV
			bsf		M_ONOFF
			btfsc	TABLE_FLAGS_MOTORS_REV
			bcf		M_ONOFF
			bra		COMMAND_M_9
COMMAND_M_2
			decfsz	BUFFER1+1,F,BANKED
			bra		COMMAND_M_3
			;CMD=2	Read the current status
			bra		COMMAND_M_9
COMMAND_M_3
			decfsz	BUFFER1+1,F,BANKED
			break
			;CMD=3	Set auto motors on/off value
			movf	BUFFER1+2,W,BANKED
			andlw	0x7F
			movwf	TABLE_SEC_OFF, ACCESS
COMMAND_M_9
			movlw	'M'
			movwf	BUFFER2+0,BANKED
			btfsc	FLAG_M_ONOFF_ISR			; FLAG_M_ONOFF_ISR==0 -> BUFFER2+1=0 else BUFFER2+1=1
			bsf		BUFFER2+1,0,BANKED
			movff	TABLE_SEC_OFF,BUFFER2+2
			break
		
		; 0x50 PWM Value
		case 'P'
			movf	BUFFER1+1,W,BANKED
			bnz		COMMAND_P_1
			bcf		FLAG_PWM_ISR				; ?BYTE 1 == 0 -> PWM OFF
			bra		COMMAND_P_3
COMMAND_P_1
			decfsz	BUFFER1+1,W,BANKED
			bra		COMMAND_P_2
			btfss	PWM_ONOFF					; do not turn PWM ON if PWM_ONOFF is on OFF
			bsf		FLAG_PWM_ISR				; ?BYTE 1 == 1 -> PWM ON
COMMAND_P_3
			movf	BUFFER1+2,W,BANKED
			cpfsgt	TABLE_PWMMAX, ACCESS
			movf	TABLE_PWMMAX,W,ACCESS
			movwf	PWM_PC, ACCESS
COMMAND_P_2
			movlw	'P'
			movwf	BUFFER2+0,BANKED
			btfsc	FLAG_PWM_ISR				; PWM OFF -> BUFFER2+1=0 else BUFFER2+1=1
			bsf		BUFFER2+1,0,BANKED
			btfss	E_PC_MANU					; AUTO/MAN: MAN  -> BUFFER2+2=0
			bsf		BUFFER2+2,0,BANKED			;           AUTO -> BUFFER2+2=1
			btfss	PWM_ONOFF					; ON/OFF: OFF -> BUFFER2+2=BUFFER2+2
			bsf		BUFFER2+2,1,BANKED			;         ON  -> (BUFFER2+2=BUFFER2+2)+2
			movff	PWM_PC,BUFFER2+3			; BUFFER2+3=PWM_PC
			movff	PWM_PIC,BUFFER2+4			; BUFFER2+4=PWM_PIC
			break
		
		; 0x53 Start/stop
		case 'S'
			movf	BUFFER1+1,W,BANKED
			btfss	STATUS,Z, ACCESS			; ?BYTE 1 == 0 = Fast stop
			bra		COMMAND_S_1
COMMAND_S_0
			btfss	FLAG_GO_ISR					; Nothing to do if not running...
			bra		COMMAND_S_9
			bcf		FLAG_GO_ISR					; GO=0
			bsf		FLAG_STOP_ISR
			movff	TABLE_FREQL,CCPR1L			; CCPR1=TABLE_FREQ
			movff	TABLE_FREQH,CCPR1H
			bra		COMMAND_S_9
COMMAND_S_1
			decfsz	BUFFER1+1,F,BANKED			; ?BYTE1 == 1 = Slow stop
			bra		COMMAND_S_2					;  -> no
			btfss	FLAG_GO_ISR					; Nothing to do if not running...
			bra		COMMAND_S_9
			bsf		FLAG_STOP_ISR
			btfss	CMD_ISR, 5, ACCESS			; ?CMD_ISR.5 =1->enable, =0->disable
			bra		COMMAND_S_1a				;   no -> deceleration
			btfss	CMD_ISR, 4, ACCESS			; ?CMD_ISR.4=1->decel
			bra		COMMAND_S_1b				;   no -> accel is in progress
			movff	BUFFER1+2,FREQ_DEC			; Decelerate to the max value
			bsf		T0CON, TMR0ON, ACCESS		; Enable TIMER 0
			bra		COMMAND_S_9
COMMAND_S_1a	; No deceleration in progress
			movlw	0xFF
			movwf	FREQ_ACC, ACCESS
COMMAND_S_1b
			movff	BUFFER1+2,FREQ_DEC			; Decelerate to the max value
			bsf		CMD_ISR, 4, ACCESS			; CMD_ISR.4=1->decel
			bsf		CMD_ISR, 5, ACCESS			; CMD_ISR.5=1->decel
			bsf		T0CON, TMR0ON, ACCESS		; Enable TIMER 0
			bra		COMMAND_S_9
COMMAND_S_2
			decfsz	BUFFER1+1,F,BANKED			; ?BYTE1 == 2 = Resume
			bra		COMMAND_S_3					;  -> no
			break
COMMAND_S_3
			decfsz	BUFFER1+1,F,BANKED			; ?BYTE1 == 3 = Status
			break								;  -> no
COMMAND_S_9
			movlw	'S'
			movwf	BUFFER2+0,BANKED
            btfss	FLAG_GO_ISR
			bsf		BUFFER2+1,1,BANKED
			btfsc	FLAG_STOP_ISR
			bsf		BUFFER2+1,2,BANKED
            movf    FILTER_ISR,W,ACCESS
            andlw   0xF0
            iorwf   BUFFER2+1,F,BANKED
			movlw	HIGH SEG_2					; 0x200
			movwf	FSR1H,ACCESS
            bcf     INTCON, GIEH, ACCESS
			movff	BUF_CUR,FSR1L
			movff	NBR_SEG_L, BUFFER2+2
			movff	NBR_SEG_M, BUFFER2+3		; NBR_SEG
			movff	NBR_SEG_H, BUFFER2+4
			movff	POSTINC1, BUFFER2+5
			movff	POSTINC1, BUFFER2+6			; NBR
			movff	POSTINC1, BUFFER2+7
			movff	POSTINC1, BUFFER2+8
            bsf     INTCON, GIEH, ACCESS
			break
		
		; 0x54 Table
		case 'T'
			movlw	0x03
			cpfslt	BUFFER2+2,BANKED			; exit if table number > 2
			break
			movlw	'T'
			movwf	BUFFER2+0, BANKED
			movf	BUFFER1+1,W,BANKED
			movwf	BUFFER2+1, BANKED
			bnz		COMMAND_T_1
			; CMD=0 Send current table number
			bcf		EECON1, EEPGD, ACCESS
			bcf		EECON1, CFGS, ACCESS
			clrf	EEADR, ACCESS				; Read 1st byte of EEPROM
			bsf		EECON1, RD, ACCESS			; TABLE_NBR
			movff	EEDATA, BUFFER2+2			; and store it
			break
COMMAND_T_1
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_2
			; CMD=1 Write table number
			clrf	EEADR, ACCESS				; Write 1st byte of EEPROM
			movff	BUFFER1+2,EEDATA			; with the table number
			call	WriteEEByte
			bcf		EECON1, EEPGD, ACCESS
			bcf		EECON1, CFGS, ACCESS
			bsf		EECON1, RD, ACCESS
			movf	EEDATA, W, ACCESS			; Read the written byte
			clrf	BUFFER2+1, BANKED
			cpfseq	BUFFER1+2, BANKED
			setf	BUFFER2+1, BANKED
			cpfseq	BUFFER1+2, BANKED			; if table number written correctly continue			
			break								; otherwise output 0xFF
			; Load table
			rcall	Load_Table0
			btfss	FLAG_LCD_DISP
			break
			; Update Table name on LCD
			bcf		FLAG_LCD_LINE
			movlw	.14
			call	LCD_Pos_DDRAM
			movlw	0x07
			movwf	iBUFFER, ACCESS
			movff	TABLE_PTR,EEADR
			call	LCD_String_EE
			break
COMMAND_T_2
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_3
			; CMD=2 not used
			break
COMMAND_T_3
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_4
			; CMD=3 Read low table
			lfsr	0,BUFFER2+2
			movf	BUFFER1+2,W, BANKED
			movwf	POSTINC0, ACCESS			; Store table number in buffer
			mullw	0x55
			incf	PRODL, W, ACCESS
			movwf	EEADR, ACCESS
			movlw	.33							; 33 bytes to send
			rcall	EE2MEM
			break
COMMAND_T_4
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_5
			; CMD=4 Write low table
			clrf	BUFFER2+1, BANKED
			lfsr	0,BUFFER1+2
			movf	POSTINC0,W
			mullw	0x55
			incf	PRODL, W, ACCESS
			movwf	EEADR, ACCESS
			; Write table content
			movlw	.33							; 33 bytes to write
			rcall	MEM2EE
			btfss	WREG,0,ACCESS
			setf	BUFFER2+1,BANKED
			break
COMMAND_T_5
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_6
			; CMD=5 Read high table
			lfsr	0,BUFFER2+2
			movf	BUFFER1+2,W,BANKED
			movwf	POSTINC0, ACCESS			; Store table number in buffer
			mullw	0x55
			incf	PRODL, W, ACCESS
			addlw	.35
			movwf	EEADR, ACCESS
			movlw	.30							; 30 bytes to send
			rcall	EE2MEM
			break
COMMAND_T_6
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_7
			; CMD=6 Write high table
			clrf	BUFFER2+1, BANKED
			lfsr	0,BUFFER1+2
			movf	POSTINC0,W
			mullw	0x55
			incf	PRODL, W, ACCESS
			addlw	.35
			movwf	EEADR, ACCESS
			; Write table content
			movlw	.30							; 30 bytes to write
			rcall	MEM2EE
			btfss	WREG,0,ACCESS
			setf	BUFFER2+1,BANKED
			break
COMMAND_T_7
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_8
			; CMD=7 Read upper table
			lfsr	0,BUFFER2+2
			movf	BUFFER1+2,W,BANKED
			movwf	POSTINC0, ACCESS			; Store table number in buffer
			mullw	0x55
			incf	PRODL, W, ACCESS
			addlw	.65
			movwf	EEADR, ACCESS
			movlw	.20							; 20 bytes to send
			rcall	EE2MEM
			break
COMMAND_T_8
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_T_9
			; CMD=6 Write high table
			clrf	BUFFER2+1, BANKED
			lfsr	0,BUFFER1+2
			movf	POSTINC0,W
			mullw	0x55
			incf	PRODL, W, ACCESS
			addlw	.65
			movwf	EEADR, ACCESS
			; Write table content
			movlw	.20							; 20 bytes to write
			rcall	MEM2EE
			btfss	WREG,0,ACCESS
			setf	BUFFER2+1,BANKED
COMMAND_T_9
			break
		; 0x4C LCD
		case 'L'
			movlw	'L'
			movwf	BUFFER2+0,BANKED
            bcf     FLAG_LCD_2LINE
			btfsc	BUFFER1+1,4,BANKED  ; CMD = 0x1x -> 4 lines display
            bsf     FLAG_LCD_2LINE
            bcf     BUFFER1+1,4,BANKED
			bcf		FLAG_LCD_LINE		; CMD = 0 Write on line 0
			movf	BUFFER1+1,W,BANKED
			bz		COMMAND_L_0
			bsf		FLAG_LCD_LINE		; CMD = 1 Write on line 1
			decf	BUFFER1+1,F,BANKED
			bz		COMMAND_L_0
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_L_3
			bcf		FLAG_LCD_DISP		; CMD = 2 Disable
			clrf	BUFFER2+1, BANKED
			break
COMMAND_L_3
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_L_4
			bsf		FLAG_LCD_DISP		; CMD = 3 Enable
			movlw	0x01
			movwf	BUFFER2+1, BANKED
			; Restore display
			; NAME
			bcf		FLAG_LCD_LINE
			movlw	.12
			call	LCD_Pos_DDRAM
			movlw	'T'
			call	LCD_Write_Byte
			movlw	':'
			call	LCD_Write_Byte
			movlw	0x07
			movwf	iBUFFER, ACCESS
			movff	TABLE_PTR,EEADR
			call	LCD_String_EE
			rcall	Print_PWM
			break
COMMAND_L_4
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_L_5
			movlw	0x00
			btfsc	FLAG_LCD_DISP		; CMD = 4 Read enable/disable
			movlw	0x01
			movwf	BUFFER2+1, BANKED
			break
COMMAND_L_5         					; CMD = 5 Clear display
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_L_6
			call	LCD_Clear
			movlw	0x00
			btfsc	FLAG_LCD_DISP
			movlw	0x01
			movwf	BUFFER2+1, BANKED
			break
COMMAND_L_6         					; CMD = 6 Write Character
			movf	BUFFER1+2,W,BANKED
            andlw   0x07
            rlncf   WREG,F,ACCESS
            rlncf   WREG,F,ACCESS
            rlncf   WREG,F,ACCESS
			call	LCD_Pos_CGRAM		; Change Pos
            movlw	0x08
			movwf	iBUFFER, ACCESS		; String size
			lfsr	0,BUFFER1+3
COMMAND_L_6b
			movf	POSTINC0,W, ACCESS
			call	LCD_Write_Byte		; Write characters
			decfsz	iBUFFER, F, ACCESS
			bra	 	COMMAND_L_6b
			break
COMMAND_L_0
			movf	BUFFER1+2,W,BANKED
			call	LCD_Pos_DDRAM				; Change Pos
			movf	BUFFER1+3,W,BANKED
			movwf	iBUFFER, ACCESS		; String size
			lfsr	0,BUFFER1+4
COMMAND_L_1
			movf	POSTINC0,W, ACCESS
			call	LCD_Write_Byte		; Write characters
			decfsz	iBUFFER, F, ACCESS
			bra	 	COMMAND_L_1
            bcf     FLAG_LCD_2LINE
			break
		
		; 0x59 Prog PIC
		case 'Y'
			movlw	'Y'
			movwf	BUFFER2+0,BANKED
			movf	BUFFER1+1,W,BANKED
			bnz		COMMAND_Y_1
			; Command 0 Enter_LVP
			call	Enter_LVP
			break
COMMAND_Y_1
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_Y_2
			; Command 1 Exit_LVP
			call	Exit_LVP
			break
COMMAND_Y_2
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_Y_3
			; Command 2 Read data
			movf	BUFFER1+2,W,BANKED
			call	Read_LVP
			movff	ADRESH, BUFFER2+1
			movff	ADRESL, BUFFER2+2
			break
COMMAND_Y_3
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_Y_4
			; Command 3 Write command
			movf	BUFFER1+2,W,BANKED
			call	Write_LVP_CMD
			break
COMMAND_Y_4
			decf	BUFFER1+1,F,BANKED
			bnz		COMMAND_Y_5
			; Command 4 Write command + data
			movf	BUFFER1+2,W,BANKED
			movff	BUFFER1+3,ADRESH
			movff	BUFFER1+4,ADRESL
			call	Write_LVP_DATA
COMMAND_Y_5
			break
		
		; 0x5A Reset
		case 'Z'
			movlw	0x55
			xorwf	BUFFER1+1,W,BANKED
			btfss	STATUS,Z,ACCESS
			break
			movlw	0xAA
			xorwf	BUFFER1+2,W,BANKED
			btfss	STATUS,Z,ACCESS
			break
			btfsc	BUFFER1+3,0,BANKED			; if Buffer1+3=0
			bsf		RCON,POR,ACCESS				;   POR=0 -> reboot en normal
			btfss	BUFFER1+3,0,BANKED			; else
			bcf		RCON,POR,ACCESS 			;   POR=1 -> reboot en bootloader
			reset
			break
		
		; 0x46 FLASH
		case 'F'
			bsf		CS
			movlw	'F'
			movwf	BUFFER2,BANKED
			bcf		CS
			movlw	0x9F				; Read ID
			rcall	RW_FLASH
			movlw	0x00
			rcall	RW_FLASH
			movwf	BUFFER2+1, BANKED	; Manufacturer
			movlw	0x00
			rcall	RW_FLASH
			movwf	BUFFER2+2, BANKED	; Model
			movlw	0x00
			rcall	RW_FLASH
			movwf	BUFFER2+3, BANKED	; Size
			bsf		CS
			nop
			bcf		CS
			movlw	0x05				; RDSR command
			rcall	RW_FLASH
			movlw	0x00
			rcall	RW_FLASH
			movwf	BUFFER2+4, BANKED	; Status
			bsf		CS
			break
		
		; 0x45 ERASE BLOCK
		case 'E'
			bsf		CS
			movlw	'E'
			movwf	BUFFER2+0,BANKED
			; Read block
			bcf		CS
			movlw	0x03				; Read command
			rcall	RW_FLASH
			movf	BUFFER1+1,W,BANKED	; BYTE1 = BLOCK
			rcall	RW_FLASH
			movlw	0x00				; ADRH
			rcall	RW_FLASH
			movlw	0x00				; ADRL
			rcall	RW_FLASH
			clrf	TEMP, ACCESS		; retrieve 256 *
LOOP_E0
			clrf	iBUFFER, ACCESS		;     256 bytes
LOOP_E1
			movlw	0x00				; Write 0x00
			rcall	RW_FLASH
			incfsz	WREG,F,ACCESS		; if byte!=0xFF
			bra		LOOP_E2				;  -> Erase
			decfsz	iBUFFER, F, ACCESS
			bra		LOOP_E1
			decfsz	TEMP, F, ACCESS
			bra		LOOP_E0
			movlw	0x01
			movwf	BUFFER2+1,BANKED
			bsf		CS
			break
LOOP_E2
			bsf		CS
			nop
			; Set WEL
			bcf		CS
			movlw	0x06				; Write enable command
			rcall	RW_FLASH
			bsf		CS
			nop
			; Erase Block
			bcf		CS
			movlw	0xD8				; Block ERASE
			rcall	RW_FLASH
			movf	BUFFER1+1,W,BANKED	; BYTE1 = Block number (ADH)
			rcall	RW_FLASH
			movlw	0x00				; ADRH
			rcall	RW_FLASH
			movlw	0x00				; ADRL
			rcall	RW_FLASH
			bsf		CS
			nop
			; Read Status
			bcf		CS
			movlw	0x05				; RDSR command
			rcall	RW_FLASH
LOOP_E3
			movlw	0x00
			rcall	RW_FLASH
			btfsc	WREG, 0, ACCESS		; Write in progress ?
			bra		LOOP_E3				; yes
			bsf		CS
			nop
			; Read block
			bcf		CS
			movlw	0x03				; Read command
			rcall	RW_FLASH
			movf	BUFFER1+1,W,BANKED	; BYTE1 = BLOCK
			rcall	RW_FLASH
			movlw	0x00				; ADRH
			rcall	RW_FLASH
			movlw	0x00				; ADRL
			rcall	RW_FLASH
			clrf	TEMP, ACCESS		; retrieve 256 *
LOOP_E4
			clrf	iBUFFER, ACCESS		;     256 bytes
LOOP_E5
			movlw	0x00				; Write 0x00
			rcall	RW_FLASH
			incfsz	WREG,F,ACCESS		; if byte!=0xFF
			bra		LOOP_E6				;  -> Error
			decfsz	iBUFFER, F, ACCESS
			bra		LOOP_E5
			decfsz	TEMP, F, ACCESS
			bra		LOOP_E4
			setf	BUFFER2+1,BANKED
			bsf		CS
			break
LOOP_E6
			clrf	BUFFER2+1,BANKED
			bsf		CS
			break
		
		; 0x52 Read
		case 'R'
			bsf		CS
			nop
			; Read flash
			bcf		CS
			movlw	0x03				; Read command
			rcall	RW_FLASH
			movf	BUFFER1+1,W,BANKED	; BYTE1 = BLOCK
			movwf	BUFFER2+1,BANKED
			rcall	RW_FLASH
			movf	BUFFER1+2,W,BANKED	; BYTE2 = ADRH
			movwf	BUFFER2+2,BANKED
			rcall	RW_FLASH
			movf	BUFFER1+3,W,BANKED	; BYTE3 = ADRL
			movwf	BUFFER2+3,BANKED
			rcall	RW_FLASH
			movlw	'R'
			movwf	BUFFER2+0,BANKED
			lfsr	0, BUFFER2+4		; put BUFFER2+1 address into FSR0
			movlw	.32					; retrieve 32 bytes
			movwf	TEMP, ACCESS
LOOP_R1
			movlw	0x00				; Write 0x00
			rcall	RW_FLASH
			movwf	POSTINC0, ACCESS	; Store data in Buffer2
			decfsz	TEMP, F, ACCESS
			bra		LOOP_R1
			bsf		CS
			break
		
		; 0x57 Write
		case 'W'
			bsf		CS
			nop
			; Write enable command
			bcf		CS
			movlw	0x06
			rcall	RW_FLASH
			bsf		CS
			nop
			; Write Buffer
			bcf		CS
			movlw	0x02				; Page program command
			rcall	RW_FLASH
			lfsr	0, BUFFER1+1		; put BUFFER2+1 address into FSR0
			movlw	.35					; write 32 bytes + 3 bytes for the address
			movwf	TEMP, ACCESS
LOOP_W1
			movf	POSTINC0,W,ACCESS	; Read data from Buffer1 and send it
			rcall	RW_FLASH
			decfsz	TEMP, F, ACCESS
			bra		LOOP_W1
			bsf		CS
			nop
			; Wait for write to complete
			bcf		CS
			movlw	0x05				; RDSR command
			rcall	RW_FLASH
LOOP_W2
			movlw	0x00
			rcall	RW_FLASH
			btfsc	WREG, 0, ACCESS		; Write in progress ?
			bra		LOOP_W2				; Loop until write is completed
			bsf		CS
			; Verify
			movlw	'W'
			movwf	BUFFER2+0,BANKED
			bcf		CS
			movlw	0x03				; Read command
			rcall	RW_FLASH
			movf	BUFFER1+1,W,BANKED	; BYTE1 = BLOCK
			rcall	RW_FLASH
			movf	BUFFER1+2,W,BANKED	; BYTE2 = ADRH
			rcall	RW_FLASH
			movf	BUFFER1+3,W,BANKED	; BYTE3 = ADRL
			rcall	RW_FLASH
			lfsr	0, BUFFER1+4		; put BUFFER1+4 address into FSR0
			movlw	.32					; retrieve 32 bytes
			movwf	TEMP, ACCESS
LOOP_W3
			movlw	0x00				; Write 0x00
			rcall	RW_FLASH
			xorwf	POSTINC0,W, ACCESS	; ? read==write
			btfss	STATUS,Z,ACCESS
			bra		LOOP_W4				;     no -> exit
			decfsz	TEMP, F, ACCESS
			bra		LOOP_W3
			setf	BUFFER2+1,BANKED	; Verify OK
LOOP_W4
			bsf		CS
			break
		
		default
			movlw	0
			movwf	BUFFER2,BANKED
			break
		ends
	return

; ******************************************************************
; RW Flash procedure
; ******************************************************************
RW_FLASH
	bcf		PIR1, SSPIF, ACCESS
	movwf	SSPBUF, ACCESS
	btfss	PIR1, SSPIF, ACCESS
	bra		$-2
	movf	SSPBUF,W,ACCESS
	return

; ******************************************************************
; Update LCD
; ******************************************************************
Update_LCD
	btfss	FLAG_LCD_DISP
	return
    btfss   FLAG_LCD_UPDATE
    bra     Update_LCD_1
    bcf     FLAG_LCD_UPDATE
    ;Print segment number
    movff   NBR_SEG_L,BARGB0
    movff   NBR_SEG_M,BARGB1
	bcf		FLAG_LCD_LINE
	movlw	.0
	call	LCD_Pos_DDRAM		; 1st line pos 0
	movlw	'S'
	call	LCD_Write_Byte
	movlw	':'
	call	LCD_Write_Byte
    call   LCD_16_Decimal       ; Write NBR_SEG_M:NBR_SEG_L
	movlw	' '
	call	LCD_Write_Byte
    ;Print buffer information
	movlw	'B'
	call	LCD_Write_Byte
	movlw	':'
	call	LCD_Write_Byte
    movf	BUF_CUR,W,ACCESS
    subwf	BUF_WR,W,ACCESS
    swapf	WREG,F,ACCESS
    rrncf	WREG,F,ACCESS
    decf	WREG,F, ACCESS
    andlw	B'00000111'
    addlw   '0'
	call	LCD_Write_Byte
Update_LCD_1
    movf    FLAG_ISR, W, ACCESS
    andlw   B'01001001'
    cpfseq  FLAG_OLD, ACCESS
    bra     Update_LCD_2
    return
Update_LCD_2
    movwf   FLAG_OLD, ACCESS
    btfsc   FLAG_OLD, 0, ACCESS
    bra     Update_LCD_3
	bcf		FLAG_LCD_LINE
	movlw	.0
	call	LCD_Pos_DDRAM		; 1st line pos 0
	movtblptr STR_IDLE
    btfss   FLAG_STOP_ISR       ; Stop command
    bra     Update_LCD_2_ORIGIN
	movtblptr STR_IDLE_STOP
    bra     Update_LCD_2z
Update_LCD_2_ORIGIN
    btfss   FILTER_ISR,4,ACCESS ; Origin/end switch
    bra     Update_LCD_2_SENSOR
	movtblptr STR_IDLE_ORIGIN
    bra     Update_LCD_2z
Update_LCD_2_SENSOR
    btfss   FILTER_ISR,5,ACCESS ; Sensor switch
    bra     Update_LCD_2_BUTTON
	movtblptr STR_IDLE_SENSOR
    bra     Update_LCD_2z
Update_LCD_2_BUTTON
    btfss   FILTER_ISR,6,ACCESS ; Stop button
    bra     Update_LCD_2_END
	movtblptr STR_IDLE_BUTTON
    bra     Update_LCD_2z
Update_LCD_2_END
    btfss   FILTER_ISR,7,ACCESS ; Buffer end
    bra     Update_LCD_2z
	movtblptr STR_IDLE_END
Update_LCD_2z
    call    LCD_String
Update_LCD_3
	bsf		FLAG_LCD_LINE
	movlw	.0
	call	LCD_Pos_DDRAM		; 2nd line pos 0
    btfss   FLAG_OLD, 3, ACCESS
    bra     Update_LCD_Flash
	movtblptr STR_SRC_USB
    bra     Update_LCD_Flash1
Update_LCD_Flash
	movtblptr STR_SRC_FLASH
Update_LCD_Flash1
    call    LCD_String
Update_LCD_Motor_On
    btfss   FLAG_OLD, 6, ACCESS
    bra     Update_LCD_Motor_Off
	movtblptr STR_MOTOR_ON
    bra     Update_LCD_Motor_Off1
Update_LCD_Motor_Off
	movtblptr STR_MOTOR_OFF
Update_LCD_Motor_Off1
    call    LCD_String
    return

; ******************************************************************
; Read Keyboard
; ******************************************************************
Read_Keys
	bcf		LATD,0,ACCESS
	bcf		LATD,1,ACCESS
	bcf		LATD,2,ACCESS
	bcf		LATD,3,ACCESS
	movlw	0x0F
	iorwf	TRISD,F,ACCESS		; D0..D3 inputs
	bsf		LATC,0,ACCESS		; K1=1
	nop
	nop
	nop
	movlw	0x0F
	andwf	PORTD, W, ACCESS
	bcf		LATC,0,ACCESS		; K1=0
	bsf		LATC,2,ACCESS		; K2=1
	nop
	nop
	movwf	KEYB, ACCESS
	swapf	PORTD, W, ACCESS
	andlw	0xF0
	iorwf	KEYB, F, ACCESS

	bcf		LATC,0,ACCESS	; K1=0
	bcf		LATC,2,ACCESS	; K2=0
	movlw	0xF0
	andwf	TRISD,F,ACCESS					; D0..D3 outputs
	return

; ******************************************************************
; Read PWM and Filter the returned value
; ******************************************************************
Read_PWM
	; ReadAnalogInput
	bsf		ADCON0, ADON, ACCESS		; enable converter module
	; acquire and convert analog input to 10 bits
	bsf		ADCON0, GO_DONE, ACCESS		; start acquisition/conversion process
	btfsc	ADCON0, GO_DONE, ACCESS		; repeat until acquisition/conversion process is done
	bra		$-2							; result is in ADRESH/L
	bcf		ADCON0, ADON, ACCESS		; disable converter module
	rlcf	ADRESL,F, ACCESS
	rlcf	ADRESH,W, ACCESS
	rlcf	ADRESL,F, ACCESS
	rlcf	WREG,W, ACCESS
	movwf	TEMP, ACCESS
	subwf	OLD_CNV, W, ACCESS
	btfsc	STATUS, N, ACCESS
	comf	WREG, W, ACCESS
	sublw	0x03
	bc		Read_PWM_Filter
	movff	TEMP, OLD_CNV				; Change the PWM value only if abs(CUR-OLD)>3
	movf	ADRESH,W,ACCESS
	cpfsgt	TABLE_PWMMAX, ACCESS
	movf	TABLE_PWMMAX,W,ACCESS		; Limit the PWM MAN value
	movwf	PWM_PIC, ACCESS
Read_PWM_Filter
	movf	PWM_PC, W, ACCESS			; E_PC_MANU = 0 => PWM_PC
	cpfsgt	TABLE_PWMMAX, ACCESS
	movf	TABLE_PWMMAX,W,ACCESS		; Limit the PWM PC value
	movwf	PWM_PC, ACCESS
	btfsc	E_PC_MANU
	movf	PWM_PIC, W, ACCESS			; E_PC_MANU = 1 => PWM_PIC
	movwf	PWM_CUR, ACCESS

	; Start in PWM ON position protection
	btfsc	PWM_ONOFF					; PWM_ONOFF 1=OFF 0=ON
	bcf		FLAG_PWM_ISR
	btfsc	PWM_ONOFF					; PWM_ONOFF 1=OFF 0=ON
	bra		Read_PWM_0
	btfsc	PWM_OLD_FLAG, 4, ACCESS
	bsf		FLAG_PWM_ISR
Read_PWM_0

	; Change/Display PWM only if it's needed
	movlw	b'00010010'
	andwf	PORTA,W, ACCESS
	btfsc	FLAG_PWM_ISR
	bsf		WREG,0,ACCESS
	subwf	PWM_OLD_FLAG, F, ACCESS
	movwf	PWM_OLD_FLAG, ACCESS
	btfss	STATUS,Z,ACCESS
	bra		Read_PWM_1
	movf	PWM_CUR, W, ACCESS
	subwf	PWM_OLD, F, ACCESS
	movwf	PWM_OLD, ACCESS
	btfsc	STATUS, Z, ACCESS
	return
Read_PWM_1

	; Set PWM
	movf	PWM_OLD,W,ACCESS
	btfss	PWM_OLD_FLAG,4,ACCESS		; PWM_ONOFF 1=OFF 0=ON
	btfss	FLAG_PWM_ISR			; FLAG_PWM==1->ON, ==0->OFF
	movlw	0x00
	movwf	CCPR2L, ACCESS			; Set PWM

	; PWM kHz only
	;movf	CCP2CON, W, ACCESS
	;andlw	B'11001111'
	;btfsc	CCPR2L, 7, ACCESS		; Fill the last 2 bits of 10 bit 
	;iorlw	B'00110000'				; value of the PWM with
	;movwf	CCP2CON, ACCESS			; the bit 7 of the PWM

	btfss	TABLE_IO1,2,ACCESS
	bra		Read_PWM_2
	movf	CCPR2L,W,ACCESS
	btfss	STATUS,Z,ACCESS
	bsf		IO1
	btfsc	STATUS,Z,ACCESS
	bcf		IO1
Read_PWM_2

	; Display PWM
	btfss	FLAG_LCD_DISP
	return
Print_PWM
	bsf		FLAG_LCD_LINE
	movlw	.14
	rcall	LCD_Pos_DDRAM					; 2nd line pos 16

	movlw	'M'
	btfss	PWM_OLD_FLAG,1,ACCESS
	movlw	'A'
	rcall	LCD_Write_Byte
	movlw	':'
	rcall	LCD_Write_Byte
	movf	PWM_CUR, W, ACCESS
	mullw	.100
	movff	PRODH,BIN_LCD			; %
	btfsc	PRODL,7, ACCESS
	incf	BIN_LCD, F, ACCESS
	; print result on LCD
	movf	BIN_LCD, W, ACCESS
	rcall	LCD_Decimal				; display PWMPIC
	movlw	'%'
	btfss	FLAG_PWM_ISR			; FLAG_PWM==1->ON, ==0->OFF
	movlw	'#'
	bra		LCD_Write_Byte

; ******************************************************************
; Init
;	Special Function Registers and General Purpose Registers main initialization
; ******************************************************************
Init
	; interrupts		
	clrf	INTCON, ACCESS				; disable global interrupts
	clrf	INTCON2, ACCESS
	clrf	INTCON3, ACCESS
	clrf	PIE1, ACCESS
	clrf	PIE2, ACCESS
	clrf	IPR1, ACCESS
	clrf	IPR2, ACCESS
	bsf		RCON, IPEN, ACCESS			; enable priority levels on interrupts

	; ports direction and value
	clrf	PORTA, ACCESS				; clear PORTA
	movlw	B'00111111'
	movwf	TRISA, ACCESS				; PORTA 0..5 inputs

	clrf	PORTB, ACCESS				; clear PORTB
	movlw	B'00000001'
	movwf	TRISB, ACCESS				; PORTB 0 input, 1..7 output
	bcf		INTCON2, RBPU, ACCESS		; weak pull-up enabled

	clrf	PORTC, ACCESS				; clear PORTC
	bsf		CS							; Do not select Flash
	movlw	B'00000000'
	movwf	TRISC, ACCESS				; PORTC outputs
	bsf		CS							; Do not select Flash

	clrf	PORTD, ACCESS				; clear PORTD
	movlw	B'00000000'
	movwf	TRISD, ACCESS				; PORTD 0..7 pins output

	clrf	PORTE, ACCESS				; clear PORTE
	movlw	B'00001001'
	movwf	TRISE, ACCESS				; PORTE 1,2 outputs, 0,3 inputs

	; SPI
	movlw	B'00000000'					; b6=Transmit occurs on transition from Idle to active clock state
	movwf	SSPSTAT, ACCESS				; b7=Input data sampled at middle of data output time
										
	movlw	B'00110000'					; b5=Enables serial port
	movwf	SSPCON1,ACCESS				; b4=Idle state for clock is a high level
										; SPI Master mode, clock = FOSC/4
	movf	SSPBUF,W,ACCESS				; clear buffer

	; A/D
	clrf	ADRESL, ACCESS				; clear ADRESH/L result register
	clrf	ADRESH, ACCESS

	movlw	B'00000000'					; AN0 selected; GO_DONE = 0 (conversion stopped); ADON = 0: converter module disabled (enabled only when needed)
	movwf	ADCON0, ACCESS

	movlw	B'00001110'					; Vref- = VSS; Vref+ = VDD; AN0 analog input, others digital input
	movwf	ADCON1, ACCESS
									
	movlw	B'00111110'					; left justified result; acq. time = 20*Tad (max acq. time) = 26.6uS; Tad (conversion time per bit) = 64*Tosc = 1.33uS > 0.7uS;
	movwf	ADCON2, ACCESS				; (total GO time = acquisition time + conversion time = 20*Tad + 11*Tad = 26,6uS + 14,63uS = 41,23uS)
										
	; TIMER1
	movlw	B'00000000'
	movwf	T1CON, ACCESS				; TIMER1: two 8 bit operation,  1:1 prescaling, input Fosc/4 (48MHz/4=12Mhz=>83,33ns), disabled
	clrf	TMR1H, ACCESS
	clrf	TMR1L, ACCESS				; clear TIMER1

	; CCP1
	movlw	B'00001011'
	movwf	CCP1CON, ACCESS				; CCP1 in compare mode with TIMER1 Reset
	movlw	B'10111001'					; CCP1 source=TIMER1, CCP2 source=TIMER3
	movwf	T3CON, ACCESS				; TIMER3 enabled, 1:8 prescaling, 16bits

	; TIMER3
	; configured in CCP1
	clrf	TMR3H, ACCESS
	clrf	TMR3L, ACCESS

	; TIMER2
	; PWM kHz only
	;movlw	B'00000011'					; TIMER2,  1:16 prescaling, input Fosc/4 (48MHz/4/16=750Khz), disabled
	; PWM Hz only
	movlw	B'00000000'					; TIMER2,  1:1 prescaling, input Fosc/4 (48MHz/4/16=750Khz), disabled
	movwf	T2CON, ACCESS				; TIMER2,  1:16 prescaling, input Fosc/4 (48MHz/4/16=750Khz), disabled
	clrf	TMR2, ACCESS
	setf	PR2, ACCESS					; =>3KHz for rollover
	; CCP2
	movlw	B'00001111'
	movwf	CCP2CON, ACCESS				; CCP2 in PWM mode
	clrf	CCPR2H, ACCESS
	clrf	CCPR2L, ACCESS				; set CCP2 to 0000H
	
	; ANALOG COMPARATOR
	movlw	B'00000111'
	movwf	CMCON, ACCESS				; disable comparator module
	clrf	CVRCON, ACCESS				; disable voltage ref

	; others
	clrf	TBLPTRU, ACCESS
	clrf	OLD_CNV, ACCESS
	clrf	PWM_PIC, ACCESS
	clrf	PWM_PC, ACCESS
	clrf	PWM_CUR, ACCESS
	movlw	0x01
	movwf	PWM_OLD, ACCESS
	clrf	PWM_OLD_FLAG, ACCESS
	clrf	FLAG_ISR, ACCESS
	clrf	FLAG_LCD, ACCESS
	bsf		FLAG_LCD_DISP
	clrf	BUF_CUR, ACCESS				; Init Buffer pointers
	movlw	0x20
	movwf	BUF_WR, ACCESS
	clrf	NBR_SEG_H, ACCESS			; NBR_SEG=0
	clrf	NBR_SEG_M, ACCESS
	clrf	NBR_SEG_L, ACCESS
    clrf    FILTER_ISR, ACCESS

	; init TABLE values
	rcall	Load_Table

	; Clear BUFFER1 and BUFFER2
	lfsr	0, BUFFER1					; load BUFFER1 address into FSR0
	lfsr	1, BUFFER2					; load BUFFER2 address into FSR1
	banksel iBUFFER						; for macro uses banked instructions
	for		iBUFFER, 1, W_MAX_PACKET_SIZE1
		clrf	POSTINC0, ACCESS		; clear BUFFER1 byte and increment FSR0
		clrf	POSTINC1, ACCESS		; clear BUFFER2 byte and increment FSR1 
		banksel iBUFFER					; next macro uses banked instructions
	next	iBUFFER

	; CCP1 interrupt (used as main timing)
	bcf		PIR1, CCP1IF, ACCESS		; reset ccp1 int flag
	bsf		PIE1, CCP1IE, ACCESS		; enable int from ccp1
	bsf		IPR1, CCP1IP, ACCESS		; high priority
	; TIMER0 interrupt (used for accel)
	bcf		INTCON, TMR0IF, ACCESS		; reset TIMER0 int flag
	bsf		INTCON, TMR0IE, ACCESS		; enable int from TIMER0
	bcf		INTCON2, TMR0IP, ACCESS		; low priority
	; COMP interrupt (used as software int)
	bcf		PIR2, CMIF, ACCESS			; reset COMP int flag
	bsf		PIE2, CMIE, ACCESS			; enable int from COMP
	bcf		IPR2, CMIP, ACCESS			; low priority

	bsf		INTCON, GIEL, ACCESS		; enable global low interrupts
	bsf  	INTCON, GIEH, ACCESS		; enable global high interrupts
	; Go
	;PWM kHz only
	;bsf		T2CON,TMR2ON				; enable TIMER2
	bsf		T1CON,TMR1ON				; enable TIMER1
	return

; ******************************************************************
; Load table description from EEPROM to memory
; ******************************************************************
Load_Table
	bcf		EECON1, EEPGD, ACCESS		; Point to EEPROM memory
	bcf		EECON1, CFGS, ACCESS		; Access EEPROM
	clrf	EEADR, ACCESS				; EEPROM ADR
	bsf		EECON1, RD, ACCESS			; EEPROM Read
	movf	EEDATA, W, ACCESS			; W = EEDATA
Load_Table0
	mullw	0x55
	incf	PRODL, W, ACCESS
	movwf	TABLE_PTR, ACCESS
	addlw	Table0_OUT-Table0_STR
	movwf	EEADR, ACCESS

	; Clear steps and dirs ouput
	lfsr	0,DIRS_TBL
	movlw	.128
	movwf	iBUFFER
Load_Table11
	clrf	POSTINC0, ACCESS
	decfsz	iBUFFER,F,ACCESS
	bra		Load_Table11
	movtblptr OUT_TBL
	movlw	.10							; Size of description table in EE
	movwf	i, ACCESS
Load_Table12
	clrf	TEMP, ACCESS				; output_bit
	bsf		EECON1, RD, ACCESS			; Read EE
	movlw	0x07
	andwf	EEDATA, F, ACCESS
	bz		Load_Table14				; axe=0
	bsf		STATUS,C,ACCESS
Load_Table13
	rlcf	TEMP,F,ACCESS				; axe -> output_bit
	decfsz	EEDATA,F,ACCESS
	bra		Load_Table13
Load_Table14
	bsf		EECON1, EEPGD, ACCESS		; Point to PROG memory
	tblrd*+
	movff	TABLAT, TEMP1				; read OUTB
	tblrd*+
	movff	TABLAT, TEMP2				; read OUTD
	bcf		EECON1, EEPGD, ACCESS		; Point to EEPROM memory
	bsf		EECON1, RD, ACCESS			; Read
	movf	EEDATA,W,ACCESS
	bz		Load_Table19				; nothing to do axe=0 and not reversed
	lfsr	0,DIRS_TBL
	clrf	iBUFFER, ACCESS
Load_Table15
	btfss	EEDATA,6,ACCESS				; EE.6=1 -> Reversed
	bra		Load_Table16
	movf	TEMP1,W,ACCESS
	iorwf	POSTINC0,F,ACCESS			; store OUTB
	movf	TEMP2,W,ACCESS
	iorwf	POSTDEC0,F,ACCESS			; store OUTD
Load_Table16
	movf	TEMP,W,ACCESS
	andwf	iBUFFER,W,ACCESS
	bnz		Load_Table16a				; output_bit is set
	incf 	FSR0L,F,ACCESS
	incf 	FSR0L,F,ACCESS
	bra		Load_Table18
Load_Table16a
	btfsc	EEDATA,7,ACCESS				; EE.7=0 -> DIR
	bra		Load_Table17
	movf	TEMP1,W,ACCESS
	xorwf	POSTINC0,F,ACCESS			; DIRB=DIRB xor OUTB
	movf	TEMP2,W,ACCESS
	xorwf	POSTINC0,F,ACCESS			; DIRD=DIRD xor OUTD
	bra		Load_Table18
Load_Table17							; EE.7=1 -> STEP
	bsf		FSR0L,6,ACCESS				; FSR0+64
	movf	TEMP1,W,ACCESS
	xorwf	POSTINC0,F,ACCESS			; STEPB=STEPB xor OUTB
	movf	TEMP2,W,ACCESS
	xorwf	POSTINC0,F,ACCESS			; STEPD=STEPD xor OUTD
	bcf		FSR0L,6,ACCESS				; FSR0-64
Load_Table18
	incf	iBUFFER,F,ACCESS
	movlw	.32
	xorwf	iBUFFER,W,ACCESS
	bnz		Load_Table15
Load_Table19
	incf	EEADR,F,ACCESS
	decfsz	i,F,ACCESS
	bra		Load_Table12

	; Read table content in memory
	lfsr	0,TABLE_FREQ
	movlw	.7
	movwf	iBUFFER
Load_Table2
	bsf		EECON1, RD, ACCESS			; Read
	movff	EEDATA, POSTINC0			; Store in TABLE
	incf	EEADR,F, ACCESS
	decfsz	iBUFFER,F,ACCESS
	bra		Load_Table2

	; *** Load data ***
	; Motors off
	bcf		FLAG_M_ONOFF_ISR			; FLAG_M_ONOFF_ISR=0
	btfsc	TABLE_FLAGS_MOTORS_REV
	bsf		M_ONOFF
	btfss	TABLE_FLAGS_MOTORS_REV
	bcf		M_ONOFF
	bcf		TRISE,0						; PORTE.1=OUTPUT
	; set default directions
	lfsr	0,DIRS_TBL
	movlw	b'00000011'
	andwf	PORTB,W,ACCESS
	iorwf	POSTINC0,W,ACCESS
	movwf	PORTB,ACCESS
	movlw	b'00001111'
	andwf	PORTD,W,ACCESS
	iorwf	POSTINC0,W,ACCESS
	movwf	PORTD,ACCESS
	; Interpolation frequency
	decf	TABLE_FREQ,F,ACCESS
	rlncf	TABLE_FREQ,W,ACCESS
	addlw	high TBL_FREQ_1
	movwf	TABLE_FREQ,ACCESS
	movwf	TBLPTRH, ACCESS
	movlw	0xFF
	movwf	TBLPTRL, ACCESS
	tblrd*
	movf	TABLAT,W
	movwf	CCPR1H, ACCESS
	movwf	TABLE_FREQH, ACCESS
	incf	TBLPTRH, F, ACCESS
	tblrd*
	movf	TABLAT,W
	movwf	CCPR1L, ACCESS
	movwf	TABLE_FREQL, ACCESS
	; calc sec
	movlw	0x80
	movwf	AARGB2, ACCESS
	movlw	0x8D
	movwf	AARGB1, ACCESS
	movlw	0x5B
	movwf	AARGB0, ACCESS
	movff	TABLE_FREQL,BARGB1
	movff	TABLE_FREQH,BARGB0
	call	FXD2416U
	movff	AARGB2,TABLE_SECL
	movff	AARGB1,TABLE_SECH
	; set auto Motors on/off
	movlw	0x7F
	andwf	TABLE_SEC_OFF,F,ACCESS
	; set FLAGS
	bsf		FLAG_SW_OVER_ISR			; FLAG_OVER ==1->ignore switches
	btfsc	TABLE_FLAGS, 0, ACCESS
	bcf		FLAG_SW_OVER_ISR			; FLAG_OVER ==0->use switches
	; set IO1 PORTA,5,ACCESS
	btfss	TABLE_IO1, 0, ACCESS		; INPUT?
	bra		Load_Table30
	bsf		TRISA,5,ACCESS				; IO1=INPUT
	bra		Load_Table39
Load_Table30
	btfss	TABLE_IO1,2,ACCESS			; Follow PWM?
	bra		Load_Table31
	bcf		IO1
	bcf		TRISA,5, ACCESS				; IO1=OUTPUT
	bra		Load_Table39
Load_Table31
	btfss	TABLE_IO1,1,ACCESS			; ?default value=1
	bcf		IO1
	btfsc	TABLE_IO1,1,ACCESS			; ?default value=0
	bsf		IO1
	bcf		TRISA,5, ACCESS				; IO1=OUTPUT
Load_Table39
	; TIMER0
	clrf	T0CON, ACCESS				; TIMER0 16 bits disabled, FOSC/4
	movf	TABLE_SLOPE, W, ACCESS
	btfss	WREG, 3, ACCESS
	bsf		T0CON, T08BIT, ACCESS		; switch to 8 bits
	andlw	B'00000111'
	iorwf	T0CON, F, ACCESS			; prescale with table parameter
	clrf	TMR0H, ACCESS
	clrf	TMR0L, ACCESS
	return

OUT_TBL
	db		b'10000000',0x00	; OUT1
	db		b'01000000',0x00	; OUT2
	db		b'00100000',0x00	; OUT3
	db		b'00010000',0x00	; OUT4
	db		b'00001000',0x00	; OUT5
	db		b'00000100',0x00	; OUT6
	db		0x00,b'10000000'	; OUT7
	db		0x00,b'01000000'	; OUT8
	db		0x00,b'00100000'	; OUT9
	db		0x00,b'00010000'	; OUT10

; ******************************************************************
; Read EEPROM in memory
; EEADR points to the source
; FSR0 points to the destination
; W equals the number of bytes to transfer
; ******************************************************************
EE2MEM
	movwf	iBUFFER
	bcf		EECON1, EEPGD, ACCESS
	bcf		EECON1, CFGS, ACCESS
EE2MEM_1
	bsf		EECON1, RD, ACCESS			; Read table and
	movff	EEDATA, POSTINC0			; store in Buffer
	incf	EEADR,F, ACCESS
	decfsz	iBUFFER,F,ACCESS
	bra		EE2MEM_1
	return

; ******************************************************************
; Write memory in EEPROM + Verify
; FSR0 points to the source
; EEADR points to the destination
; W equals the number of bytes to transfer
; Return:
;   0: Verification failed
;   1: Write ok
; ******************************************************************
MEM2EE
	movwf	iBUFFER
	bcf		EECON1, EEPGD, ACCESS
	bcf		EECON1, CFGS, ACCESS
MEM2EE_1
	bsf		EECON1, RD, ACCESS
	movf	EEDATA, W, ACCESS			; Read the written byte
	cpfseq	INDF0, ACCESS
	bra		MEM2EE_2
	bra		MEM2EE_3
MEM2EE_2
	movff	INDF0,EEDATA
	call	WriteEEByte					; Write value
	bcf		EECON1, EEPGD, ACCESS
	bcf		EECON1, CFGS, ACCESS
	bsf		EECON1, RD, ACCESS
	movf	EEDATA, W, ACCESS			; Read the written byte
MEM2EE_3
	cpfseq	POSTINC0, ACCESS
	retlw	0x00
	incf	EEADR,F, ACCESS
	decfsz	iBUFFER,F,ACCESS
	bra		MEM2EE_1
	retlw	0x01

; ******************************************************************
; WriteEEByte
;	write an eeprom byte; address and data byte must be already set
;   in EEADR and EEDATA before calling this; wait for write to complete
;
; ******************************************************************
WriteEEByte
	bcf		EECON1, CFGS, ACCESS		; select program/data memory (not configuration)
	bcf		EECON1, EEPGD, ACCESS		; select data memory (not program)
	bsf		EECON1, WREN, ACCESS		; enable writes
	bcf		INTCON, GIEH, ACCESS		; disable interrupts (it is strongly recommended during start of write sequence)
	bcf		INTCON, GIEL, ACCESS		; disable interrupts (it is strongly recommended during start of write sequence)
	movlw	0x55;						; start of write sequence...
	movwf	EECON2, ACCESS
	movlw	0xAA;
	movwf	EECON2, ACCESS
	bsf		EECON1, WR, ACCESS			; set WR bit to begin write
	bsf		INTCON, GIEH, ACCESS		; re-enable Interrupts
	bsf		INTCON, GIEL, ACCESS		; re-enable Interrupts
	btfsc	EECON1, WR, ACCESS			; wait for write to complete: WR cleared in hardware at the write cycle completion (and EEIF set)
	bra		$-2
	bcf		EECON1, WREN, ACCESS		; write complete... disable writes
	return

; ******************************************************************
; ******************************************************************
; ******************************************************************
; 							Manual Menu
; ******************************************************************
; ******************************************************************
; ******************************************************************
Manual_Menu
	clrf	MENU_POS,ACCESS
	call	LCD_Clear
	movtblptr	STR_MAIN_MENU
	call	LCD_String
	call	Filter_Keys
	clrf	KEYB_OUT,ACCESS
	bra		Main_Menu1
Main_Menu
	; Update display
	clrf	MENU_POS,ACCESS
	bcf		FLAG_LCD_DISP	; Disable PWM display
	bcf		FLAG_LCD_LINE	; 1st line
	call	LCD_Clear
	movtblptr	STR_MAIN_MENU
	call	LCD_String
	call	Filter_Init_Release
Main_Menu1
	; Update display based on position
	bsf		FLAG_LCD_LINE
	movlw	0x00
	call	LCD_Pos_DDRAM					; 2nd line
	movf	MENU_POS,W,ACCESS
	select
		case 0x00
			movtblptr STR_MENU_DEPL
			call	LCD_String
			break
		case 0x01
			movtblptr STR_MENU_TABLE
			call	LCD_String
			break
	ends

	call	Filter_Keys

	; Do action based on key
	movf	KEYB_OUT,W,ACCESS
	select
		case K_OK
			movf	MENU_POS,F,ACCESS
			btfsc	STATUS,Z,ACCESS
			bra		Move_Menu
			bra		Table_Menu
			break
		case K_ESC
			bcf		RCON,POR,ACCESS		;   POR=0 -> reboot en normal
			reset
			break
		case K_UP
			decf	MENU_POS,F,ACCESS
			btfss	STATUS,N,ACCESS
			break
			movlw	0x01
			movwf	MENU_POS,ACCESS
			break
		case K_DOWN
			incf	MENU_POS,F,ACCESS
			movlw	0x02
			xorwf	MENU_POS,W,ACCESS
			btfsc	STATUS,Z,ACCESS
			clrf	MENU_POS,ACCESS
			break
	ends
	clrf	KEYB_OUT,ACCESS
	bra		Main_Menu1

Table_Menu
	; Update display
	bcf		EECON1, EEPGD, ACCESS
	bcf		EECON1, CFGS, ACCESS
	clrf	EEADR, ACCESS				; Read 1st byte of EEPROM
	bsf		EECON1, RD, ACCESS			; TABLE_NBR
	movff	EEDATA, MENU_POS
	bcf		FLAG_LCD_LINE				; 1st line
	call	LCD_Clear
	movtblptr	STR_TABLE_MENU
	call	LCD_String
	call	Filter_Keys
	clrf	KEYB_OUT,ACCESS
Table_Menu1
	; Update display based on position
	bsf		FLAG_LCD_LINE
	movlw	0x00
	call	LCD_Pos_DDRAM					; 2nd line
	movlw	'^'
	rcall	LCD_Write_Byte
	movlw	'v'
	rcall	LCD_Write_Byte
	movlw	' '
	rcall	LCD_Write_Byte
	movlw	0x08
	movwf	iBUFFER, ACCESS
	movf	MENU_POS,W,ACCESS
	mullw	0x55
	incf	PRODL, W, ACCESS
	movwf	EEADR, ACCESS
	xorwf	TABLE_PTR,W,ACCESS
	btfss	STATUS,Z,ACCESS
	bra		Table_Menu_Not_Current
	call	LCD_String_EE
	movlw	' '
	rcall	LCD_Write_Byte
	movlw	'<'
	rcall	LCD_Write_Byte
	movlw	'-'
	rcall	LCD_Write_Byte
	bra		Table_Menu2
Table_Menu_Not_Current
	call	LCD_String_EE
	movlw	' '
	rcall	LCD_Write_Byte
	movlw	' '
	rcall	LCD_Write_Byte
	movlw	' '
	rcall	LCD_Write_Byte
Table_Menu2
	call	Filter_Keys
	; Do action based on key
	movf	KEYB_OUT,W,ACCESS
	select
		case K_OK
			clrf	EEADR, ACCESS				; Write 1st byte of EEPROM
			movff	MENU_POS,EEDATA			; with the table number
			call	WriteEEByte
			call	Load_Table
			call	LCD_Clear
			bcf		FLAG_LCD_LINE	; 1st line
			movlw	0x08
			movwf	iBUFFER, ACCESS
			movff	TABLE_PTR,EEADR
			call	LCD_String_EE
			movtblptr	STR_TABLE_MENU_SELECT
			call	LCD_String
			movlw	0x22			; Wait 1,5s
			call	Wait_ms
			bra 	Manual_Menu
		case K_ESC
			bra 	Manual_Menu
		case K_UP
TABLE_Menu_K_UP
			decf	MENU_POS,W,ACCESS
			btfsc	STATUS,N,ACCESS
			movlw	0x02
			movwf	MENU_POS,ACCESS
			mullw	0x55
			incf	PRODL, W, ACCESS
			movwf	EEADR, ACCESS
			bsf		EECON1, RD, ACCESS
			tstfsz	EEDATA, ACCESS
			break
			bra		TABLE_Menu_K_UP
		case K_DOWN
TABLE_Menu_K_DOWN
			incf	MENU_POS,W,ACCESS
			xorlw	0x03
			btfss	STATUS,Z,ACCESS
			xorlw	0x03
			movwf	MENU_POS,ACCESS
			mullw	0x55
			incf	PRODL, W, ACCESS
			movwf	EEADR, ACCESS
			bsf		EECON1, RD, ACCESS
			tstfsz	EEDATA, ACCESS
			break
			bra		TABLE_Menu_K_DOWN
	ends
	clrf	KEYB_OUT,ACCESS
	bra		Table_Menu1

Move_Menu
	; Update display
	clrf	MENU_POS,ACCESS
	bcf		FLAG_LCD_DISP	; Disable PWM display
	call	LCD_Clear
	movtblptr	STR_MOVE_MENU
	call	LCD_String
;	call	Move_Axe_Disp
	call	Filter_Keys
	clrf	KEYB_OUT,ACCESS
Move_Menu1
	; Update display based on position
;	bsf		FLAG_LCD_LINE
;	movlw	0x00
;	call	LCD_Pos_DDRAM					; 2nd line
;	movf	MENU_POS,W,ACCESS
;	select
;		case 0x00
;			movtblptr STR_MENU_DEPL
;			call	LCD_String
;			break
;		case 0x01
;			movtblptr STR_MENU_TABLE
;			call	LCD_String
;			break
;	ends
	call	Filter_Keys
	; Do action based on key
	movf	KEYB_OUT,W,ACCESS
	select
		case K_ESC
			bra		 Manual_Menu
			break
	ends
	clrf	KEYB_OUT,ACCESS
	bra		Move_Menu1

; ******************************************************************
; ******************************************************************
; 							Key filters
; ******************************************************************
; ******************************************************************
Wait_ms		; i*43.76 ms
	movwf	i, ACCESS
Wait_ms_1
	call	Read_PWM
	call	Read_Keys
	btfss	PIR2,TMR3IF			; if timer3 rollover
	bra		Wait_ms_1
	bcf		PIR2,TMR3IF
	decfsz	i,F,ACCESS
	bra		Wait_ms_1
	return

Filter_Init_Release
	call	Read_PWM
	call	Read_Keys
	tstfsz	KEYB,ACCESS
	bra		Filter_Init_Release
Filter_Init
	clrf	KEYB_OUT,ACCESS
	clrf	KEYB_OUT2,ACCESS
	lfsr	0,KEY_OK_W
	movlw	.6					; 6 Keys
	movwf	TEMP, ACCESS
Filter_Init_Loop
	clrf	POSTINC0,ACCESS		; clear wait counters
	decfsz	TEMP,F,ACCESS
	bra		Filter_Init_Loop
	return

	#define	KEYB_WAIT_H1	0xF	; slow wait pressed time
	#define	KEYB_WAIT_H2	0x7 ; fast wait pressed time
	#define	KEYB_WAIT_L		0x5 ; wait unpressed time
Filter_Keys
	call	Read_PWM
	call	Read_Keys
	lfsr	0,KEY_OK_W			; FSR0 point to the key wait counters
	movlw	0x10
	movwf	i,ACCESS			; i is used as a key mask
	movlw	.6					; 6 Keys
	movwf	TEMP, ACCESS

	btfss	PIR2,TMR3IF			; if timer3 rollover
	bra		Filter_Keys_Loop
	bsf		KEYB_OUT2_TMR		;   this is the right time to decrement wait counters
	bcf		PIR2,TMR3IF

Filter_Keys_Loop
	movf	KEYB,W,ACCESS		; Check if key[i] is pressed
	andwf	i,W,ACCESS
	btfsc	STATUS,Z,ACCESS
	bra		Filter_Keys_No_Push	;   no jump to No Push
	movf	INDF0,W,ACCESS		; Is the key just released ?
	andlw	0x0F
	btfsc	STATUS,Z,ACCESS
	bra		Filter_Keys_Push_1	;   no jump to Push_1
	btfsc	KEYB_OUT2_TMR		; Is it the right timing to decrement ?
	decf	INDF0,F,ACCESS		;   yes decrement counter
	bra		Filter_Keys_Next	; exit
Filter_Keys_Push_1
	movlw	0x0F
	cpfsgt	INDF0, ACCESS		; Is the key pressed counter was already set ?
	bra		Filter_Keys_Push_2	;   no jump to Push_2
	btfss	KEYB_OUT2_TMR		; Is it the right timing to decrement ?
	bra		Filter_Keys_Next
	movlw	0x10
	subwf	INDF0,F,ACCESS		;   yes decrement counter
	bra		Filter_Keys_Next	; exit
Filter_Keys_Push_2
	movf	KEYB_OUT2,W,ACCESS	; Is it the first time the key is pressed ?
	andwf	i,W,ACCESS
	btfss	STATUS,Z,ACCESS
	movlw	KEYB_WAIT_H2 * 0x10	;   already pressed -> quick repeat
	btfsc	STATUS,Z,ACCESS
	movlw	KEYB_WAIT_H1 * 0x10 ;   1st time pressed -> slow start
	iorwf	INDF0,F,ACCESS
	movf	i,W,ACCESS	
	iorwf	KEYB_OUT,F,ACCESS	; Inform main that this key is pressed
	iorwf	KEYB_OUT2,F,ACCESS
	bra		Filter_Keys_Next	; exit
Filter_Keys_No_Push
	movf	KEYB_OUT2,W,ACCESS	; Is this key was pressed ?
	andwf	i,W,ACCESS
	btfsc	STATUS,Z,ACCESS
	bra		Filter_Keys_No_Push_1	; no jump to No_Push_1
	movf	i,W,ACCESS	
	xorwf	KEYB_OUT2,F,ACCESS	;  clear the key pressed flag
	movlw	KEYB_WAIT_L
	movwf	INDF0, ACCESS		; load wait time not pressed
	bra		Filter_Keys_Next	; exit
Filter_Keys_No_Push_1
	movf	INDF0,W,ACCESS
	andlw	0x0F
	btfsc	KEYB_OUT2_TMR		; Is it the right timing to decrement ?
	btfsc	STATUS,Z,ACCESS
	bra		Filter_Keys_Next
	decf	INDF0,F,ACCESS		;   yes decrement counter
Filter_Keys_Next
	movf	POSTINC0,F,ACCESS	; increment FSR0
	rlncf	i,F,ACCESS			; rotate the mask i to go to next key
	decfsz	TEMP,F,ACCESS
	bra		Filter_Keys_Loop	; loop until the 6 keys are done
Filter_Keys_END
	bcf		KEYB_OUT2_TMR
	tstfsz	KEYB_OUT,ACCESS		; if a key is pressed return
	return
	bra		Filter_Keys			; else loop

;***************************** ASM CODE INCLUDES HERE *************************************
#include "LCD.asm"

#include "LVP.asm"

#include "Math.asm"

#include "USB.asm"

;***************************** TEXT STRINGS HERE *************************************
STR_IPL5X
	db			'I','P','L','5','X',' ','v',high BCD_DEVICE+'0','.',(((low BCD_DEVICE)&0xF0)/.16)+'0',((low BCD_DEVICE)&0x0F)+'0',0x00
STR_ENTER_MENU
	db			'O','K','=','M','e','n','u',0x00
STR_MODE_USB
	db			'M','O','D','E',' ','U','S','B',0x00
STR_ERR_TMR1
	db			'E','r','r',' ','T','M','R','1',0x00
STR_MAIN_MENU
	db			'M','e','n','u',' ','P','r','i','n','c','i','p','a','l',0x00
STR_MENU_DEPL
	db			'^','v',' ','D','e','p','l','a','c','e','m','e','n','t','s',' ',' ',' ',0x00
STR_MENU_FILE
	db			'^','v',' ','D','e','c','o','u','p','e',' ','f','i','c','h','i','e','r',0x00
STR_MENU_TABLE
	db			'^','v',' ','C','h','a','n','g','e',' ','t','a','b','l','e',' ',' ',' ',0x00
STR_TABLE_MENU
	db			'T','a','b','l','e',':',' ',' ',' ',' ','O','K','=','S','e','l','e','c','t',0x00
STR_TABLE_MENU_SELECT
	db			' ','C','h','a','r','g','e',' ','O','K',0x00
STR_MOVE_MENU
	db			'A','x','e','s',' ','<','>',0x00
STR_IDLE
	db			'I','d','l','e',' ',' ',' ',' ',' ',' ',' ',0x00
STR_IDLE_STOP
	db			'I','d','l','e',' ','S',':','S','t','o','p',0x00
STR_IDLE_ORIGIN
	db			'I','d','l','e',' ','S',':','F','D','C',' ',0x00
STR_IDLE_END
	db			'I','d','l','e',' ','S',':','F','i','n',' ',0x00
STR_IDLE_SENSOR
	db			'I','d','l','e',' ','S',':','P','a','l','p',0x00
STR_IDLE_BUTTON
	db			'I','d','l','e',' ','S',':','P','r','o','g',0x00
STR_SRC_USB
	db			'U','S','B',' ',' ',' ',0x00
STR_SRC_FLASH
	db			'F','l','a','s','h',' ',0x00
STR_MOTOR_ON
	db			'M','o','t',':','O','N',' ',0x00
STR_MOTOR_OFF
	db			'M','o','t',':','O','F','F',0x00

;***************************** ACCELERATION TABLES HERE *************************************
#include "ipl5x_acc.asm"

;***************************** EEPROM HERE *************************************
#include "ipl5x_eeprom.asm"

	end
