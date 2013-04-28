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

	; the clock configuration below gives:
	; for CPU: 48MHz
	; for USB module: FSEN=1 (full speed) 48MHz 
	; see also clock diagram in datasheet and comment below from P18F4550.INC
	config FOSC = HSPLL_HS		; XT with PLL enabled used by CPU and USB
	config PLLDIV = 5			; PLL prescaler set to no prescale: 20 MHz crystal (96MHz PLL needs 4 MHz input from prescaler)
	config CPUDIV = OSC1_PLL2	; PLL divided by 2 (96/2=48MHz) to feed CPU
	config USBDIV = 2			; FSEN=1 USB is fed by PLL divided by 2 (96/2=48MHz)

	config FCMEN = OFF
	config IESO = OFF
	config PWRT = OFF
	config BOR = ON
	config BORV = 3
	config VREGEN = ON
	config WDT = OFF
	config WDTPS = 32768
	config MCLRE = OFF			; RE3 input pin enabled; MCLR disabled
	config LPT1OSC = OFF
	config PBADEN = OFF
	config CCP2MX = ON
	config STVREN = ON
	config LVP = OFF
;	config ICPRT = OFF
	config XINST = OFF
	config DEBUG = OFF
	config CP0 = OFF
	config CP1 = OFF
	config CP2 = OFF
;	config CP3 = OFF
	config CPB = OFF
	config CPD = OFF
	config WRT0 = OFF
	config WRT1 = OFF
	config WRT2 = OFF
;	config WRT3 = OFF
	config WRTB = OFF
	config WRTC = OFF
	config WRTD = OFF
	config EBTR0 = OFF
	config EBTR1 = OFF
	config EBTR2 = OFF
;	config EBTR3 = OFF
	config EBTRB = OFF

;==========================================================================
; from P18F4550.INC
;==========================================================================
;==========================================================================
;
;   IMPORTANT: For the PIC18 devices, the __CONFIG directive has been
;              superseded by the CONFIG directive.  The following settings
;              are available for this device.
;
;   PLL Prescaler Selection bits:
;     PLLDIV = 1           No prescale (4 MHz oscillator input drives PLL directly)
;     PLLDIV = 2           Divide by 2 (8 MHz oscillator input)
;     PLLDIV = 3           Divide by 3 (12 MHz oscillator input)
;     PLLDIV = 4           Divide by 4 (16 MHz oscillator input)
;     PLLDIV = 5           Divide by 5 (20 MHz oscillator input)
;     PLLDIV = 6           Divide by 6 (24 MHz oscillator input)
;     PLLDIV = 10          Divide by 10 (40 MHz oscillator input)
;     PLLDIV = 12          Divide by 12 (48 MHz oscillator input)
;
;   CPU System Clock Postscaler:
;     CPUDIV = OSC1_PLL2   [OSC1/OSC2 Src: /1][96 MHz PLL Src: /2]
;     CPUDIV = OSC2_PLL3   [OSC1/OSC2 Src: /2][96 MHz PLL Src: /3]
;     CPUDIV = OSC3_PLL4   [OSC1/OSC2 Src: /3][96 MHz PLL Src: /4]
;     CPUDIV = OSC4_PLL6   [OSC1/OSC2 Src: /4][96 MHz PLL Src: /6]
;
;   USB Clock Selection bit (used in Full Speed USB mode only; UCFG:FSEN = 1):
;     USBDIV = 1           USB clock source comes directly from the primary oscillator block with no postscale
;     USBDIV = 2           USB clock source comes from the 96 MHz PLL divided by 2
;
;   Oscillator Selection bits:
;     FOSC = XT_XT         XT oscillator, XT used by USB
;     FOSC = XTPLL_XT      XT oscillator, PLL enabled, XT used by USB
;     FOSC = ECIO_EC       External clock, port function on RA6, EC used by USB
;     FOSC = EC_EC         External clock, CLKOUT on RA6, EC used by USB
;     FOSC = ECPLLIO_EC    External clock, PLL enabled, port function on RA6, EC used by USB
;     FOSC = ECPLL_EC      External clock, PLL enabled, CLKOUT on RA6, EC used by USB
;     FOSC = INTOSCIO_EC   Internal oscillator, port function on RA6, EC used by USB
;     FOSC = INTOSC_EC     Internal oscillator, CLKOUT on RA6, EC used by USB
;     FOSC = INTOSC_XT     Internal oscillator, XT used by USB
;     FOSC = INTOSC_HS     Internal oscillator, HS used by USB
;     FOSC = HS            HS oscillator, HS used by USB
;     FOSC = HSPLL_HS      HS oscillator, PLL enabled, HS used by USB
;
;   Fail-Safe Clock Monitor Enable bit:
;     FCMEN = OFF          Fail-Safe Clock Monitor disabled
;     FCMEN = ON           Fail-Safe Clock Monitor enabled
;
;   Internal/External Oscillator Switchover bit:
;     IESO = OFF           Oscillator Switchover mode disabled
;     IESO = ON            Oscillator Switchover mode enabled
;
;   Power-up Timer Enable bit:
;     PWRT = ON            PWRT enabled
;     PWRT = OFF           PWRT disabled
;
;   Brown-out Reset Enable bits:
;     BOR = OFF            Brown-out Reset disabled in hardware and software
;     BOR = SOFT           Brown-out Reset enabled and controlled by software (SBOREN is enabled)
;     BOR = ON_ACTIVE      Brown-out Reset enabled in hardware only and disabled in Sleep mode (SBOREN is disabled)
;     BOR = ON             Brown-out Reset enabled in hardware only (SBOREN is disabled)
;
;   Brown-out Voltage bits:
;     BORV = 0             Maximum setting
;     BORV = 1             
;     BORV = 2             
;     BORV = 3             Minimum setting
;
;   USB Voltage Regulator Enable bit:
;     VREGEN = OFF         USB voltage regulator disabled
;     VREGEN = ON          USB voltage regulator enabled
;
;   Watchdog Timer Enable bit:
;     WDT = OFF            HW Disabled - SW Controlled
;     WDT = ON             HW Enabled - SW Disabled
;
;   Watchdog Timer Postscale Select bits:
;     WDTPS = 1            1:1
;     WDTPS = 2            1:2
;     WDTPS = 4            1:4
;     WDTPS = 8            1:8
;     WDTPS = 16           1:16
;     WDTPS = 32           1:32
;     WDTPS = 64           1:64
;     WDTPS = 128          1:128
;     WDTPS = 256          1:256
;     WDTPS = 512          1:512
;     WDTPS = 1024         1:1024
;     WDTPS = 2048         1:2048
;     WDTPS = 4096         1:4096
;     WDTPS = 8192         1:8192
;     WDTPS = 16384        1:16384
;     WDTPS = 32768        1:32768
;
;   MCLR Pin Enable bit:
;     MCLRE = OFF          RE3 input pin enabled; MCLR disabled
;     MCLRE = ON           MCLR pin enabled; RE3 input pin disabled
;
;   Low-Power Timer 1 Oscillator Enable bit:
;     LPT1OSC = OFF        Timer1 configured for higher power operation
;     LPT1OSC = ON         Timer1 configured for low-power operation
;
;   PORTB A/D Enable bit:
;     PBADEN = OFF         PORTB<4:0> pins are configured as digital I/O on Reset
;     PBADEN = ON          PORTB<4:0> pins are configured as analog input channels on Reset
;
;   CCP2 MUX bit:
;     CCP2MX = OFF         CCP2 input/output is multiplexed with RB3
;     CCP2MX = ON          CCP2 input/output is multiplexed with RC1
;
;   Stack Full/Underflow Reset Enable bit:
;     STVREN = OFF         Stack full/underflow will not cause Reset
;     STVREN = ON          Stack full/underflow will cause Reset
;
;   Single-Supply ICSP Enable bit:
;     LVP = OFF            Single-Supply ICSP disabled
;     LVP = ON             Single-Supply ICSP enabled
;
;   Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit:
;     ICPRT = OFF          ICPORT disabled
;     ICPRT = ON           ICPORT enabled
;
;   Extended Instruction Set Enable bit:
;     XINST = OFF          Instruction set extension and Indexed Addressing mode disabled (Legacy mode)
;     XINST = ON           Instruction set extension and Indexed Addressing mode enabled
;
;   Background Debugger Enable bit:
;     DEBUG = ON           Background debugger enabled, RB6 and RB7 are dedicated to In-Circuit Debug
;     DEBUG = OFF          Background debugger disabled, RB6 and RB7 configured as general purpose I/O pins
;
;   Code Protection bit Block 0:
;     CP0 = ON             Block 0 (000800-001FFFh) code-protected
;     CP0 = OFF            Block 0 (000800-001FFFh) not code-protected
;
;   Code Protection bit Block 1:
;     CP1 = ON             Block 1 (002000-003FFFh) code-protected
;     CP1 = OFF            Block 1 (002000-003FFFh) not code-protected
;
;   Code Protection bit Block 2:
;     CP2 = ON             Block 2 (004000-005FFFh) code-protected
;     CP2 = OFF            Block 2 (004000-005FFFh) not code-protected
;
;   Code Protection bit Block 3:
;     CP3 = ON             Block 3 (006000-007FFFh) code-protected
;     CP3 = OFF            Block 3 (006000-007FFFh) not code-protected
;
;   Boot Block Code Protection bit:
;     CPB = ON             Boot block (000000-0007FFh) code-protected
;     CPB = OFF            Boot block (000000-0007FFh) not code-protected
;
;   Data EEPROM Code Protection bit:
;     CPD = ON             Data EEPROM code-protected
;     CPD = OFF            Data EEPROM not code-protected
;
;   Write Protection bit Block 0:
;     WRT0 = ON            Block 0 (000800-001FFFh) write-protected
;     WRT0 = OFF           Block 0 (000800-001FFFh) not write-protected
;
;   Write Protection bit Block 1:
;     WRT1 = ON            Block 1 (002000-003FFFh) write-protected
;     WRT1 = OFF           Block 1 (002000-003FFFh) not write-protected
;
;   Write Protection bit Block 2:
;     WRT2 = ON            Block 2 (004000-005FFFh) write-protected
;     WRT2 = OFF           Block 2 (004000-005FFFh) not write-protected
;
;   Write Protection bit Block 3:
;     WRT3 = ON            Block 3 (006000-007FFFh) write-protected
;     WRT3 = OFF           Block 3 (006000-007FFFh) not write-protected
;
;   Boot Block Write Protection bit:
;     WRTB = ON            Boot block (000000-0007FFh) write-protected
;     WRTB = OFF           Boot block (000000-0007FFh) not write-protected
;
;   Configuration Register Write Protection bit:
;     WRTC = ON            Configuration registers (300000-3000FFh) write-protected
;     WRTC = OFF           Configuration registers (300000-3000FFh) not write-protected
;
;   Data EEPROM Write Protection bit:
;     WRTD = ON            Data EEPROM write-protected
;     WRTD = OFF           Data EEPROM not write-protected
;
;   Table Read Protection bit Block 0:
;     EBTR0 = ON           Block 0 (000800-001FFFh) protected from table reads executed in other blocks
;     EBTR0 = OFF          Block 0 (000800-001FFFh) not protected from table reads executed in other blocks
;
;   Table Read Protection bit Block 1:
;     EBTR1 = ON           Block 1 (002000-003FFFh) protected from table reads executed in other blocks
;     EBTR1 = OFF          Block 1 (002000-003FFFh) not protected from table reads executed in other blocks
;
;   Table Read Protection bit Block 2:
;     EBTR2 = ON           Block 2 (004000-005FFFh) protected from table reads executed in other blocks
;     EBTR2 = OFF          Block 2 (004000-005FFFh) not protected from table reads executed in other blocks
;
;   Table Read Protection bit Block 3:
;     EBTR3 = ON           Block 3 (006000-007FFFh) protected from table reads executed in other blocks
;     EBTR3 = OFF          Block 3 (006000-007FFFh) not protected from table reads executed in other blocks
;
;   Boot Block Table Read Protection:
;     EBTRB = ON           Boot block (000000-0007FFh) protected from table reads executed in other blocks
;     EBTRB = OFF          Boot block (000000-0007FFh) not protected from table reads executed in other blocks
;
;==========================================================================
;==========================================================================
;
;       Configuration Bits
;
;   NAME            Address
;   CONFIG1L        300000h
;   CONFIG1H        300001h
;   CONFIG2L        300002h
;   CONFIG2H        300003h
;   CONFIG3H        300005h
;   CONFIG4L        300006h
;   CONFIG5L        300008h
;   CONFIG5H        300009h
;   CONFIG6L        30000Ah
;   CONFIG6H        30000Bh
;   CONFIG7L        30000Ch
;   CONFIG7H        30000Dh
;
;==========================================================================