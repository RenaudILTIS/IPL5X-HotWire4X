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
EEPROM_DATA		code_pack	0xf00000
	de .1			; Table number to use
Table0_STR
	de	'P'			;	NAME[0]
	de	'a'			;	NAME[1]
	de	's'			;	NAME[2]
	de	'c'			;	NAME[3]
	de	'a'			;	NAME[4]
	de	'l'			;	NAME[5]
	de	' '			;	NAME[6]
	de	' '			;	NAME[7]
Table0_A1
	de	0x05		;	TABLE_A1
Table0_A2
	de	0x09		;	TABLE_A2
Table0_A3
	de	0x06		;	TABLE_A3
Table0_A4
	de	0x0A		;	TABLE_A4
Table0_A5
	de	0x00		;	TABLE_A5
Table0_OUT
	de	0xC2		;	TABLE_OUT1
	de	0x02		;	TABLE_OUT2
	de	0xC1		;	TABLE_OUT3
	de	0x01		;	TABLE_OUT4
	de	0x00		;	TABLE_OUT5
	de	0x00		;	TABLE_OUT6
	de	0xC4		;	TABLE_OUT7
	de	0x04		;	TABLE_OUT8
	de	0xC3		;	TABLE_OUT9
	de	0x03		;	TABLE_OUT10
Table0_DATA
	de	0x05		;	TABLE_FREQ
	de	0x08		;	TABLE_SLOPE
	de	0x64		;	TABLE_PWMMAX
	de	0x0A		;	TABLE_SEC_OFF
	de	0x01		;	TABLE_FLAGS
	de	0x04		;	TABLE_IO1
	de	0x00		;	TABLE_LANG

EEPROM_DATA_TABLE1	code_pack	0xf00056
Table1_STR
	de	'M'			;	NAME[0]
	de	'M'			;	NAME[1]
	de	'2'			;	NAME[2]
	de	'0'			;	NAME[3]
	de	'0'			;	NAME[4]
	de	'1'			;	NAME[5]
	de	' '			;	NAME[6]
	de	' '			;	NAME[7]
Table1_A1
	de	0x05		;	TABLE_A1
Table1_A2
	de	0x09		;	TABLE_A2
Table1_A3
	de	0x06		;	TABLE_A3
Table1_A4
	de	0x0A		;	TABLE_A4
Table1_A5
	de	0x00		;	TABLE_A5
Table1_OUT
	de	0x02		;	TABLE_OUT1
	de	0x82		;	TABLE_OUT2
	de	0x01		;	TABLE_OUT3
	de	0x81		;	TABLE_OUT4
	de	0x04		;	TABLE_OUT5
	de	0x84		;	TABLE_OUT6
	de	0x03		;	TABLE_OUT7
	de	0x83		;	TABLE_OUT8
	de	0x00		;	TABLE_OUT9
	de	0x00		;	TABLE_OUT10
Table1_DATA
	de	0x03		;	TABLE_FREQ
	de	0x08		;	TABLE_SLOPE
	de	0xCC		;	TABLE_PWMMAX
	de	0x0A		;	TABLE_SEC_OFF
	de	0x00		;	TABLE_FLAGS
	de	0x04		;	TABLE_IO1
	de	0x00		;	TABLE_LANG

EEPROM_DATA_TABLE2	code_pack	0xf000AA
	de	0x00
Table2_STR
	de	0x00		;	NAME[0]

