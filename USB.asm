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
; 								USB
; ******************************************************************
; ******************************************************************

USBDESCRIPTORS	code_pack

Descriptor
			banksel		USB_desc_ptrL
			movlw		low Descriptor_begin
			addwf		USB_desc_ptrL, W, BANKED
			movwf		TBLPTRL, ACCESS
			movlw		high Descriptor_begin
			addwfc		USB_desc_ptrH, W, BANKED
			movwf		TBLPTRH, ACCESS
			;movlw		upper Descriptor_begin
			;addwfc		USB_desc_ptrU, W, BANKED
			;movwf		TBLPTRU, ACCESS
			tblrd*
			movf		TABLAT, W, ACCESS
			return

Descriptor_begin
Device
			db			0x12							; bLength (length of this descriptor)
			db			DEVICE							; bDescriptorType
			db			0x00, 0x02						; bcdUSB (low byte, high byte; revision 2.00)
			db			0x00							; bDeviceClass (zero means each interface operates idepedently; for HID must be specified in the interface descriptor, not here)
			db			0x00							; bDeviceSubClass (for HID must be specified in the interface descriptor, not here)
			db			0x00							; bDeviceProtocl
			db			B_MAX_PACKET_SIZE0				; bMaxPacketSize0: max packet size for EP0
			db			low ID_VENDOR, high ID_VENDOR	; idVendor (low byte, high byte; 0x04D8 is Microchip)
			db			low ID_PRODUCT, high ID_PRODUCT	; idProduct (low byte, high byte)
			db			low BCD_DEVICE, high BCD_DEVICE	; bcdDevice (low byte, high byte; 0xJJMN: JJ.M.N: JJ major version number, M minor, N sub-minor)
			db			0x01							; iManufacturer (manufacturer string index)
			db			0x02							; iProduct (product string index)
			db			0x00							; iSerialNumber (none)
			db			NUM_CONFIGURATIONS				; bNumConfigurations

Configuration1
			db			0x09							; bLength (length of this descriptor)
			db			CONFIGURATION					; bDescriptorType
			db			0x29, 0x00						; wTotalLength (low byte, high byte)
			db			NUM_INTERFACES					; bNumInterfaces
			db			0x01							; bConfigurationValue
			db			0x00							; iConfiguration (string index for this config = none)
			db			0x80							; bmAttributes (bus powered, no remote wakeup)
			db			0x32							; bMaxPower (self-powered draws 0 mA from the bus)

Interface1
			db			0x09							; bLength (length of this descriptor)
			db			INTERFACE						; bDescriptorType
			db			0x00							; bInterfaceNumber (number of interface, 0 based array)
			db			0x00							; bAlternateSetting
			db			0x02							; bNumEndpoints (number of endpoints used in this interface excluding EP0)
			db			0x03							; bInterfaceClass (always 3 for HID devices)
			db			0x00							; bInterfaceSubClass (for HID: boot device; in this case not a boot device: not a keyboard or mouse)
			db			0x00							; bInterfaceProtocol (Keyboard protocol)
			db			0x00							; iInterface (index of string descriptor describing this interface = none)
HID1
			db			0x09							; bLength (length of this descriptor)
			db			HID								; bDescriptorType
			db			0x01, 0x01						; bcdHID (low byte, high byte; HID release number = 1.01)
			db			0x00							; bCountryCode (none)
			db			0x01							; bNumDescriptors (number of HID descriptor to follow)
			db			REPORT							; bDescriptorType
			db			Report1_end-Report1, 0x00		; wDescriptorLength (low byte, high byte)
Endpoint1
			db			0x07							; bLength (length of this descriptor)
			db			ENDPOINT						; bDescriptorType
			db			0x81							; bEndpointAddress (EP1, IN)
			db			0x03							; bmAttributes (Interrupt)
			db			low W_MAX_PACKET_SIZE1, high W_MAX_PACKET_SIZE1	; wMaxPacketSize (low byte, high byte)
			db			B_INTERVAL1						; bInterval (polling interval)

Endpoint2
			db			0x07							; bLength (length of this descriptor)
			db			ENDPOINT						; bDescriptorType
			db			0x01							; bEndpointAddress (EP1, OUT)
			db			0x03							; bmAttributes (Interrupt)
			db			low W_MAX_PACKET_SIZE1, high W_MAX_PACKET_SIZE1	; wMaxPacketSize (low byte, high byte)
			db			B_INTERVAL1						; bInterval (polling interval)

Report1
			db			0x06, 0xA0, 0xFF				;	USAGE_PAGE(Vendor-Defined 161)
			db			0x09, 0x01						;	USAGE(Vendor-Defined 1)
			db			0xA1, 0x01						;	COLLECTON(Application)

			db			0x09, 0x03						;		USAGE(Vendor-Defined 3)
			db			0x15, 0x00						;		LOGICAL_MINIMUM (0)
			db			0x26, 0xFF, 0x00				;		LOGICAL_MAXIMUM (255)
			db			0x75, 0x08						;		REPORT_SIZE (8)
			db			0x95, low REPORT_LEN_IN			;		REPORT_COUNT (REPORT_LEN_IN)
			db			0x81, 0x02						;		INPUT(Data,Var,Abs)

			db			0x09, 0x04						;		USAGE(Vendor-Defined 4)
			db			0x15, 0x00						;		LOGICAL_MINIMUM (0)
			db			0x26, 0xFF, 0x00				;		LOGICAL_MAXIMUM (255)
			db			0x75, 0x08						;		REPORT_SIZE (8)
			db			0x95, low REPORT_LEN_OUT		;		REPORT_COUNT (REPORT_LEN_OUT)
			db			0x91, 0x02						;		OUTPUT(Data,Var,Abs)

			db			0xC0							;	END_COLLECTION
Report1_end

String0
			db			String1-String0, STRING	; bLength, bDescriptorType
			db			0x09, 0x04			; wLANGID[0] (low byte), wLANGID[0] (high byte)
String1
			db			String2-String1, STRING	; bLength, bDescriptorType
			db			'5', 0x00			; bString
			db			'X', 0x00
			db			'-', 0x00
			db			'P', 0x00
			db			'R', 0x00
			db			'O', 0x00
			db			'J', 0x00
			db			'E', 0x00
			db			'C', 0x00
			db			'T', 0x00
String2
			db			Descriptor_end-String2, STRING	; bLength, bDescriptorType
			db			'I', 0x00			; bString
			db			'P', 0x00
			db			'L', 0x00
			db			'5', 0x00
			db			'X', 0x00
			db			' ', 0x00
			db			'v', 0x00
			db			high BCD_DEVICE+'0', 0x00
			db			'.', 0x00
			db			(((low BCD_DEVICE)&0xF0)/.16)+'0', 0x00
			db			((low BCD_DEVICE)&0x0F)+'0', 0x00
Descriptor_end



USBSTUFF	code

InitUSB
			clrf		UIE, ACCESS				; mask all USB interrupts
			clrf		UIR, ACCESS				; clear all USB interrupt flags

			movlw		B'00010100'				; FSEN = 1, UTRDIS = 0, UPUEN = 1, all others = 0
			movwf		UCFG, ACCESS			; configure USB for full-speed transfers and to use the on-chip transciever and pull-up resistor

			movlw		B'00001000'				; USBEN = 1, all others = 0
			movwf		UCON, ACCESS			; enable the USB module and its supporting circuitry
			banksel		USB_curr_config
			clrf		USB_curr_config, BANKED
			clrf		USB_idle_rate, BANKED
			clrf		USB_USWSTAT, BANKED		; default to powered state
			movlw		0x01
			movwf		USB_device_status, BANKED
			movwf		USB_protocol, BANKED	; default protocol to report protocol initially
			movlw		NO_REQUEST
			movwf		USB_dev_req, BANKED		; No device requests in process
			repeat								; do nothing...
			untilclr UCON, SE0, ACCESS			; ...until initial SE0 condition clears 
			return

ServiceUSB
			select
				caseset	UIR, UERRIF, ACCESS
					clrf		UEIR, ACCESS
					break
				caseset UIR, SOFIF, ACCESS
					bcf			UIR, SOFIF, ACCESS
					break
				caseset	UIR, IDLEIF, ACCESS
					bcf			UIR, IDLEIF, ACCESS
					bsf			UCON, SUSPND, ACCESS
					break
				caseset UIR, ACTVIF, ACCESS
					bcf			UIR, ACTVIF, ACCESS
					bcf			UCON, SUSPND, ACCESS
					break
				caseset	UIR, STALLIF, ACCESS
					bcf			UIR, STALLIF, ACCESS
					break
				caseset	UIR, URSTIF, ACCESS
					banksel		USB_curr_config
					clrf		USB_curr_config, BANKED
					bcf			UIR, TRNIF, ACCESS		; clear TRNIF four times to clear out the USTAT FIFO
					bcf 		UIR, TRNIF, ACCESS
					bcf			UIR, TRNIF, ACCESS
					bcf			UIR, TRNIF, ACCESS
					clrf		UEP0, ACCESS			; clear all EP control registers to disable all endpoints
					clrf		UEP1, ACCESS
					clrf		UEP2, ACCESS
					clrf		UEP3, ACCESS
					clrf		UEP4, ACCESS
					clrf		UEP5, ACCESS
					clrf		UEP6, ACCESS
					clrf		UEP7, ACCESS
					clrf		UEP8, ACCESS
					clrf		UEP9, ACCESS
					clrf		UEP10, ACCESS
					clrf		UEP11, ACCESS
					clrf		UEP12, ACCESS
					clrf		UEP13, ACCESS
					clrf		UEP14, ACCESS
					clrf		UEP15, ACCESS
					banksel		BD0OBC
					movlw		B_MAX_PACKET_SIZE0
					movwf		BD0OBC, BANKED
					movlw		low USB_Buffer			; EP0 OUT gets a buffer...
					movwf		BD0OAL, BANKED
					movlw		high USB_Buffer
					movwf		BD0OAH, BANKED			; ...set up its address
					movlw		0x88					; set UOWN bit (USB can write)
					movwf		BD0OST, BANKED
					movlw		low (USB_Buffer+B_MAX_PACKET_SIZE0)	; EP0 IN gets a buffer...
					movwf		BD0IAL, BANKED
					movlw		high (USB_Buffer+B_MAX_PACKET_SIZE0)
					movwf		BD0IAH, BANKED			; ...set up its address
					movlw		0x08					; clear UOWN bit (MCU can write)
					movwf		BD0IST, BANKED
					clrf		UADDR, ACCESS			; set USB Address to 0
					clrf		UIR, ACCESS				; clear all the USB interrupt flags
					movlw		ENDPT_CONTROL
					movwf		UEP0, ACCESS			; EP0 is a control pipe and requires an ACK
					movlw		0xFF					; enable all error interrupts
					movwf		UEIE, ACCESS
					banksel		USB_USWSTAT
					movlw		DEFAULT_STATE
					movwf		USB_USWSTAT, BANKED
					movlw		0x01
					movwf		USB_device_status, BANKED	; self powered, remote wakeup disabled
					break
				caseset	UIR, TRNIF, ACCESS
					movlw		0x04
					movwf		FSR0H, ACCESS
					movf		USTAT, W, ACCESS
					andlw		0x7C					; mask out bits 0, 1, and 7 of USTAT
					movwf		FSR0L, ACCESS
					banksel		USB_buffer_desc
					movf		POSTINC0, W
					movwf		USB_buffer_desc, BANKED
					movf		POSTINC0, W
					movwf		USB_buffer_desc+1, BANKED
					movf		POSTINC0, W
					movwf		USB_buffer_desc+2, BANKED
					movf		POSTINC0, W
					movwf		USB_buffer_desc+3, BANKED
					movf		USTAT, W, ACCESS
					movwf		USB_USTAT, BANKED		; save the USB status register
					bcf			UIR, TRNIF, ACCESS		; clear TRNIF interrupt flag
					clrf		USB_error_flags, BANKED	; clear USB error flags
					movf		USB_buffer_desc, W, BANKED
					andlw		0x3C					; extract PID bits
					select
						case TOKEN_SETUP
							call		ProcessSetupToken
							break
						case TOKEN_IN
							call		ProcessInToken
							break
						case TOKEN_OUT
							call		ProcessOutToken
							break
					ends
					banksel USB_error_flags
					ifset USB_error_flags, 0, BANKED	; if there was a Request Error...
						banksel		BD0OBC
						movlw		B_MAX_PACKET_SIZE0
						movwf		BD0OBC, BANKED			; ...get ready to receive the next Setup token...
						movlw		0x84
						movwf		BD0IST, BANKED
						movwf		BD0OST, BANKED			; ...and issue a protocol stall on EP0
					endi
					break
			ends
			return

ProcessSetupToken
			banksel		USB_buffer_data
			movf		USB_buffer_desc+ADDRESSH, W, BANKED
			movwf		FSR0H, ACCESS
			movf		USB_buffer_desc+ADDRESSL, W, BANKED
			movwf		FSR0L, ACCESS
			movf		POSTINC0, W
			movwf		USB_buffer_data, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+1, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+2, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+3, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+4, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+5, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+6, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_data+7, BANKED
			banksel		BD0OBC
			movlw		B_MAX_PACKET_SIZE0
			movwf		BD0OBC, BANKED					; reset the byte count
			movlw		0x08
			movwf		BD0IST, BANKED					; return the in buffer to us (dequeue any pending requests)
			banksel		USB_buffer_data+bmRequestType
			ifclr USB_buffer_data+bmRequestType, 7, BANKED
				ifl USB_buffer_data+wLength, !=, 0
            	orif USB_buffer_data+wLengthHigh, !=, 0
					movlw		0xC8
				otherwise
					movlw		0x88
				endi
			otherwise
				movlw		0x88
			endi
			banksel		BD0OST
			movwf		BD0OST, BANKED					; set EP0 OUT UOWN back to USB and DATA0/DATA1 packet according to request type
			bcf			UCON, PKTDIS, ACCESS			; assuming there is nothing to dequeue, clear the packet disable bit
			banksel		USB_dev_req
			movlw		NO_REQUEST
			movwf		USB_dev_req, BANKED				; clear the device request in process
			movf		USB_buffer_data+bmRequestType, W, BANKED
			andlw		0x60							; extract request type bits
			select
				case STANDARD
					call		StandardRequests
					break
				case CLASS
					call		ClassRequests
					break
				case VENDOR
					call		VendorRequests
					break
				default
					bsf			USB_error_flags, 0, BANKED	; set Request Error flag
			ends
			return

StandardRequests
			movf		USB_buffer_data+bRequest, W, BANKED
			select
				case GET_STATUS
					movf		USB_buffer_data+bmRequestType, W, BANKED
					andlw		0x1F					; extract request recipient bits
					select
						case RECIPIENT_DEVICE
							banksel		BD0IAH
							movf		BD0IAH, W, BANKED
							movwf		FSR0H, ACCESS
							movf		BD0IAL, W, BANKED				; get buffer pointer
							movwf		FSR0L, ACCESS
							banksel		USB_device_status
							movf		USB_device_status, W, BANKED	; copy device status byte to EP0 buffer
							movwf		POSTINC0
							clrf		INDF0
							banksel		BD0IBC
							movlw		0x02
							movwf		BD0IBC, BANKED					; set byte count to 2
							movlw		0xC8
							movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
							break
						case RECIPIENT_INTERFACE
							movf		USB_USWSTAT, W, BANKED
							select
								case ADDRESS_STATE
									bsf			USB_error_flags, 0, BANKED		; set Request Error flag
									break
								case CONFIG_STATE
									ifl USB_buffer_data+wIndex, <, NUM_INTERFACES
										banksel		BD0IAH
										movf		BD0IAH, W, BANKED
										movwf		FSR0H, ACCESS
										movf		BD0IAL, W, BANKED				; get buffer pointer
										movwf		FSR0L, ACCESS
										clrf		POSTINC0
										clrf		INDF0
										movlw		0x02
										movwf		BD0IBC, BANKED					; set byte count to 2
										movlw		0xC8
										movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit																								
									otherwise
										bsf			USB_error_flags, 0, BANKED		; set Request Error flag
									endi
									break
							ends
							break
						case RECIPIENT_ENDPOINT
							movf		USB_USWSTAT, W, BANKED
							select
								case ADDRESS_STATE
									movf		USB_buffer_data+wIndex, W, BANKED	; get EP
									andlw		0x0F								; strip off direction bit
									ifset STATUS, Z, ACCESS							; see if it is EP0
										banksel		BD0IAH
										movf		BD0IAH, W, BANKED				; put EP0 IN buffer pointer...
										movwf		FSR0H, ACCESS
										movf		BD0IAL, W, BANKED
										movwf		FSR0L, ACCESS					; ...into FSR0
										banksel		USB_buffer_data+wIndex
										ifset USB_buffer_data+wIndex, 7, BANKED		; if the specified direction is IN...
											banksel		BD0IST
											movf		BD0IST, W, BANKED
										otherwise
											banksel		BD0OST
											movf		BD0OST, W, BANKED
										endi
										andlw		0x04							; extract the BSTALL bit
										movwf		INDF0
										rrncf		INDF0, F
										rrncf		INDF0, F						; shift BSTALL bit into the lsb position
										clrf		PREINC0
										movlw		0x02
										movwf		BD0IBC, BANKED					; set byte count to 2
										movlw		0xC8
										movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
									otherwise
										bsf			USB_error_flags, 0, BANKED		; set Request Error flag
									endi
									break
								case CONFIG_STATE
									banksel		BD0IAH
									movf		BD0IAH, W, BANKED					; put EP0 IN buffer pointer...
									movwf		FSR0H, ACCESS
									movf		BD0IAL, W, BANKED
									movwf		FSR0L, ACCESS						; ...into FSR0
									movlw		high UEP0							; put UEP0 address...
									movwf		FSR1H, ACCESS
									movlw		low UEP0
									movwf		FSR1L, ACCESS						; ...into FSR1
									movlw		high BD0OST							; put BDndST address...
									movwf		FSR2H, ACCESS
									banksel		USB_buffer_data+wIndex
									movf		USB_buffer_data+wIndex, W, BANKED
									andlw		0x8F								; mask out all but the direction bit and EP number
									movwf		FSR2L, ACCESS
									rlncf		FSR2L, F, ACCESS
									rlncf		FSR2L, F, ACCESS
									rlncf		FSR2L, F, ACCESS					; FSR2L now contains the proper offset into the BD table for the specified EP
									movlw		low BD0OST
									addwf		FSR2L, F, ACCESS					; ...into FSR2
									ifset STATUS, C, ACCESS
										incf		FSR2H, F, ACCESS
									endi
									movf		USB_buffer_data+wIndex, W, BANKED	; get EP and...
									andlw		0x0F								; ...strip off direction bit
									ifset USB_buffer_data+wIndex, 7, BANKED			; if the specified EP direction is IN...
									andifclr PLUSW1, EPINEN, ACCESS					; ...and the specified EP is not enabled for IN transfers...
										bsf			USB_error_flags, 0, BANKED		; ...set Request Error flag
									elsifclr USB_buffer_data+wIndex, 7, BANKED		; otherwise, if the specified EP direction is OUT...
									andifclr PLUSW1, EPOUTEN, ACCESS				; ...and the specified EP is not enabled for OUT transfers...
										bsf			USB_error_flags, 0, BANKED		; ...set Request Error flag
									otherwise
										movf		INDF2, W						; move the contents of the specified BDndST register into WREG
										andlw		0x04							; extract the BSTALL bit
										movwf		INDF0
										rrncf		INDF0, F
										rrncf		INDF0, F						; shift BSTALL bit into the lsb position
										clrf		PREINC0										
										banksel		BD0IBC
										movlw		0x02
										movwf		BD0IBC, BANKED					; set byte count to 2
										movlw		0xC8
										movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
									endi
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							break
						default
							bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					ends
					break
				case CLEAR_FEATURE
				case SET_FEATURE
					movf		USB_buffer_data+bmRequestType, W, BANKED
					andlw		0x1F					; extract request recipient bits
					select
						case RECIPIENT_DEVICE
							movf		USB_buffer_data+wValue, W, BANKED
							select
								case DEVICE_REMOTE_WAKEUP
									ifl USB_buffer_data+bRequest, ==, CLEAR_FEATURE
										bcf			USB_device_status, 1, BANKED
									otherwise
										bsf			USB_device_status, 1, BANKED
									endi
									banksel		BD0IBC
									clrf		BD0IBC, BANKED					; set byte count to 0
									movlw		0xC8
									movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
									break
								default
									bsf			USB_error_flags, 0, BANKED		; set Request Error flag
							ends
							break
						case RECIPIENT_ENDPOINT
							movf		USB_USWSTAT, W, BANKED
							select
								case ADDRESS_STATE
									movf		USB_buffer_data+wIndex, W, BANKED	; get EP
									andlw		0x0F								; strip off direction bit
									ifset STATUS, Z, ACCESS							; see if it is EP0
										banksel		BD0IBC
										clrf		BD0IBC, BANKED					; set byte count to 0
										movlw		0xC8
										movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
									otherwise
										bsf			USB_error_flags, 0, BANKED		; set Request Error flag
									endi
									break
								case CONFIG_STATE
									movlw		high UEP0							; put UEP0 address...
									movwf		FSR0H, ACCESS
									movlw		low UEP0
									movwf		FSR0L, ACCESS						; ...into FSR0
									movlw		high BD0OST							; put BD0OST address...
									movwf		FSR1H, ACCESS
									movlw		low BD0OST
									movwf		FSR1L, ACCESS						; ...into FSR1
									movf		USB_buffer_data+wIndex, W, BANKED	; get EP
									andlw		0x0F								; strip off direction bit
									ifclr STATUS, Z, ACCESS							; if it was not EP0...
										addwf		FSR0L, F, ACCESS					; add EP number to FSR0
										ifset		STATUS, C, ACCESS
											incf		FSR0H, F, ACCESS
										endi
										rlncf		USB_buffer_data+wIndex, F, BANKED
										rlncf		USB_buffer_data+wIndex, F, BANKED
										rlncf		USB_buffer_data+wIndex, W, BANKED	; WREG now contains the proper offset into the BD table for the specified EP
										andlw		0x7C								; mask out all but the direction bit and EP number (after three left rotates)
										addwf		FSR1L, F, ACCESS					; add BD table offset to FSR1
										ifset		STATUS, C, ACCESS
											incf		FSR1H, F, ACCESS
										endi
										ifset USB_buffer_data+wIndex, 1, BANKED			; if the specified EP direction (now bit 1) is IN...
											ifset INDF0, EPINEN, ACCESS						; if the specified EP is enabled for IN transfers...
												ifl USB_buffer_data+bRequest, ==, CLEAR_FEATURE
													clrf		INDF1					; clear the stall on the specified EP
												otherwise
													movlw		0x84
													movwf		INDF1					; stall the specified EP
												endi
											otherwise
												bsf			USB_error_flags, 0, BANKED		; set Request Error flag
											endi
										otherwise										; ...otherwise the specified EP direction is OUT, so...
											ifset INDF0, EPOUTEN, ACCESS					; if the specified EP is enabled for OUT transfers...
												ifl USB_buffer_data+bRequest, ==, CLEAR_FEATURE
													movlw		0x88
													movwf		INDF1					; clear the stall on the specified EP													
												otherwise
													movlw		0x84
													movwf		INDF1					; stall the specified EP
												endi
											otherwise
												bsf			USB_error_flags, 0, BANKED		; set Request Error flag
											endi
										endi
									endi
									ifclr USB_error_flags, 0, BANKED	; if there was no Request Error...
										banksel		BD0IBC
										clrf		BD0IBC, BANKED			; set byte count to 0
										movlw		0xC8
										movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
									endi
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							break
						default
							bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					ends
					break
				case SET_ADDRESS
					ifset USB_buffer_data+wValue, 7, BANKED		; if new device address is illegal, send Request Error
						bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					otherwise
						movlw		SET_ADDRESS
						movwf		USB_dev_req, BANKED			; processing a SET_ADDRESS request
						movf		USB_buffer_data+wValue, W, BANKED
						movwf		USB_address_pending, BANKED	; save new address
						banksel		BD0IBC
						clrf		BD0IBC, BANKED				; set byte count to 0
						movlw		0xC8
						movwf		BD0IST, BANKED				; send packet as DATA1, set UOWN bit
					endi
					break
				case GET_DESCRIPTOR
					movwf		USB_dev_req, BANKED				; processing a GET_DESCRIPTOR request
					movf		USB_buffer_data+(wValue+1), W, BANKED
					select
						case DEVICE
							movlw		low (Device-Descriptor_begin)
							movwf		USB_desc_ptrL, BANKED
							movlw		high (Device-Descriptor_begin)
							movwf		USB_desc_ptrH, BANKED
							;movlw		upper (Device-Descriptor_begin)
							;movwf		USB_desc_ptrU, BANKED
							call		Descriptor				; get descriptor length
							movwf		USB_bytes_left, BANKED
							ifl USB_buffer_data+(wLength+1), ==, 0
							andiff USB_buffer_data+wLength, <, USB_bytes_left
								movf		USB_buffer_data+wLength, W, BANKED
								movwf		USB_bytes_left, BANKED
							endi
							call		SendDescriptorPacket
							break
						case CONFIGURATION
							movf		USB_buffer_data+wValue, W, BANKED
							select
								case 0
									movlw		low (Configuration1-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (Configuration1-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (Configuration1-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							ifclr USB_error_flags, 0, BANKED
								movlw		0x02
								addwf		USB_desc_ptrL, F, BANKED
								movlw		0x00
								addwfc		USB_desc_ptrH, F, BANKED
								;addwfc		USB_desc_ptrU, F, BANKED
								call		Descriptor			; get total descriptor length
								movwf		USB_bytes_left, BANKED
								movlw		0x02
								subwf		USB_desc_ptrL, F, BANKED	; subtract offset for wTotalLength
								movlw		0x00
								subwfb		USB_desc_ptrH, F, BANKED
								;subwfb		USB_desc_ptrU, F, BANKED
								ifl USB_buffer_data+(wLength+1), ==, 0
								andiff USB_buffer_data+wLength, <, USB_bytes_left
									movf		USB_buffer_data+wLength, W, BANKED
									movwf		USB_bytes_left, BANKED
								endi
								call		SendDescriptorPacket
							endi
							break
						case STRING
							movf		USB_buffer_data+wValue, W, BANKED
							select
								case 0
									movlw		low (String0-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (String0-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (String0-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								case 1
									movlw		low (String1-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (String1-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (String1-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								case 2
									movlw		low (String2-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (String2-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (String2-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							ifclr USB_error_flags, 0, BANKED
								call		Descriptor		; get descriptor length
								movwf		USB_bytes_left, BANKED
								ifl USB_buffer_data+(wLength+1), ==, 0
								andiff USB_buffer_data+wLength, <, USB_bytes_left
									movf		USB_buffer_data+wLength, W, BANKED
									movwf		USB_bytes_left, BANKED
								endi
								call		SendDescriptorPacket
							endi
							break
						case HID
							movf		USB_buffer_data+wValue, W, BANKED
							select
								case 0
									movlw		low (HID1-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (HID1-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (HID1-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							ifclr USB_error_flags, 0, BANKED
								call		Descriptor				; get descriptor length
								movwf		USB_bytes_left, BANKED
								ifl USB_buffer_data+(wLength+1), ==, 0
								andiff USB_buffer_data+wLength, <, USB_bytes_left
									movf		USB_buffer_data+wLength, W, BANKED
									movwf		USB_bytes_left, BANKED
								endi
								call		SendDescriptorPacket
							endi
							break
						case REPORT
							movf		USB_buffer_data+wValue, W, BANKED
							select
								case 0
								case 1
									movlw		Report1_end-Report1
									movwf		USB_bytes_left, BANKED	; set descriptor length
									movlw		low (Report1-Descriptor_begin)
									movwf		USB_desc_ptrL, BANKED
									movlw		high (Report1-Descriptor_begin)
									movwf		USB_desc_ptrH, BANKED
									;movlw		upper (Report1-Descriptor_begin)
									;movwf		USB_desc_ptrU, BANKED
									break
								default
									bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							ends
							ifclr USB_error_flags, 0, BANKED
								ifl USB_buffer_data+(wLength+1), ==, 0
								andiff USB_buffer_data+wLength, <, USB_bytes_left
									movf		USB_buffer_data+wLength, W, BANKED
									movwf		USB_bytes_left, BANKED
								endi
								call		SendDescriptorPacket
							endi
							break
						default
							bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					ends
					break
				case GET_CONFIGURATION
					banksel		BD0IAH
					movf		BD0IAH, W, BANKED
					movwf		FSR0H, ACCESS
					movf		BD0IAL, W, BANKED
					movwf		FSR0L, ACCESS
					banksel		USB_curr_config
					movf		USB_curr_config, W, BANKED
					movwf		INDF0					; copy current device configuration to EP0 IN buffer
					banksel		BD0IBC
					movlw		0x01
					movwf		BD0IBC, BANKED			; set EP0 IN byte count to 1
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				case SET_CONFIGURATION
					ifl USB_buffer_data+wValue, <=, NUM_CONFIGURATIONS
						clrf		UEP1, ACCESS		; clear all EP control registers except for EP0 to disable EP1-EP15 prior to setting configuration
						clrf		UEP2, ACCESS
						clrf		UEP3, ACCESS
						clrf		UEP4, ACCESS
						clrf		UEP5, ACCESS
						clrf		UEP6, ACCESS
						clrf		UEP7, ACCESS
						clrf		UEP8, ACCESS
						clrf		UEP9, ACCESS
						clrf		UEP10, ACCESS
						clrf		UEP11, ACCESS
						clrf		UEP12, ACCESS
						clrf		UEP13, ACCESS
						clrf		UEP14, ACCESS
						clrf		UEP15, ACCESS
						movf		USB_buffer_data+wValue, W, BANKED
						movwf		USB_curr_config, BANKED
						select
							case 0
								movlw		ADDRESS_STATE
								movwf		USB_USWSTAT, BANKED
								break
							default
								movlw		CONFIG_STATE
								movwf		USB_USWSTAT, BANKED
								banksel		BD1OBC

								movlw		W_MAX_PACKET_SIZE1
								movwf		BD1OBC, BANKED			; set EP1 OUT byte count to W_MAX_PACKET_SIZE1
								movlw		low (USB_Buffer+2*B_MAX_PACKET_SIZE0) ; EP1 OUT gets a buffer...
								movwf		BD1OAL, BANKED			
								movlw		high (USB_Buffer+2*B_MAX_PACKET_SIZE0)
								movwf		BD1OAH, BANKED			; ...set its address
								movlw		0x88
								movwf		BD1OST, BANKED			; set UOWN bit (USB can write EP1 OUT buffer)

								movlw		W_MAX_PACKET_SIZE1
								movwf		BD1IBC, BANKED			; set EP1 IN byte count to W_MAX_PACKET_SIZE1
								movlw		low (USB_Buffer+2*B_MAX_PACKET_SIZE0+W_MAX_PACKET_SIZE1)
								movwf		BD1IAL, BANKED			; set EP1 IN buffer address (over EP1 OUT buffer)
								movlw		high (USB_Buffer+2*B_MAX_PACKET_SIZE0+W_MAX_PACKET_SIZE1)
								movwf		BD1IAH, BANKED
								movlw		0x48
								movwf		BD1IST, BANKED			; clear UOWN bit (PIC can write EP1 OUT/IN buffer)

								movlw		ENDPT_NON_CONTROL
								movwf		UEP1, ACCESS			; enable EP1 for interrupt in transfers

						ends
						banksel		BD0IBC
						clrf		BD0IBC, BANKED			; set byte count to 0
						movlw		0xC8
						movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					otherwise
						bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					endi
					break
				case GET_INTERFACE
					movf		USB_USWSTAT, W, BANKED
					select
						case CONFIG_STATE
							ifl USB_buffer_data+wIndex, <, NUM_INTERFACES
								banksel		BD0IAH
								movf		BD0IAH, W, BANKED
								movwf		FSR0H, ACCESS
								movf		BD0IAL, W, BANKED		; get buffer pointer
								movwf		FSR0L, ACCESS
								clrf		INDF0					; always send back 0 for bAlternateSetting
								movlw		0x01
								movwf		BD0IBC, BANKED			; set byte count to 1
								movlw		0xC8
								movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
							otherwise
								bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							endi
							break
						default
							bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					ends
					break
				case SET_INTERFACE
					movf		USB_USWSTAT, W, BANKED
					select
						case CONFIG_STATE
							ifl USB_buffer_data+wIndex, <, NUM_INTERFACES
								movf		USB_buffer_data+wValue, W, BANKED
								select
									case 0									; currently support only bAlternateSetting of 0
										banksel		BD0IBC
										clrf		BD0IBC, BANKED			; set byte count to 0
										movlw		0xC8
										movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
										break
									default
										bsf			USB_error_flags, 0, BANKED	; set Request Error flag
								ends
							otherwise
								bsf			USB_error_flags, 0, BANKED	; set Request Error flag
							endi
							break
						default
							bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					ends
					break
				case SET_DESCRIPTOR
				case SYNCH_FRAME
				default
					bsf			USB_error_flags, 0, BANKED	; set Request Error flag
					break
			ends
			return

ClassRequests
			movf		USB_buffer_data+bRequest, W, BANKED
			select
				case GET_REPORT

					; copy BUFFER1 to EP0 IN buffer (as a compound device get_report is implemented
					; here only to report BUFFER1; BUFFER2 only via EP1 interrupt transfer)
					lfsr		0, BUFFER1				; put BUFFER1 address into FSR0
					movff		BD0IAH, FSR1H			; put EP0 IN buffer pointer...
					movff		BD0IAL, FSR1L			; ...into FSR1
					banksel iBUFFER						; for macro uses banked instructions
					for 		iBUFFER, 1, REPORT_LEN_OUT	; for 1 <= iBUFFER <= REPORT_LEN_OUT
						movff	POSTINC0, POSTINC1		; copy BUFFER1 byte to EP0 IN buffer byte, then increment FSR0 and FSR1
						banksel iBUFFER					; next macro uses banked instructions
					next		iBUFFER

					banksel		BD0IBC
					movlw		REPORT_LEN_OUT
					movwf		BD0IBC, BANKED			; set EP0 IN buffer byte count to REPORT_LEN
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				case SET_REPORT
					movwf		USB_dev_req, BANKED		; processing a SET_REPORT request
					break
				case GET_PROTOCOL
					banksel		BD0IAH
					movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
					movwf		FSR0H, ACCESS
					movf		BD0IAL, W, BANKED
					movwf		FSR0L, ACCESS			; ...into FSR0
					banksel		USB_protocol
					movf		USB_protocol, W, BANKED
					movwf		INDF0
					banksel		BD0IBC
					movlw		0x01
					movwf		BD0IBC, BANKED			; set byte count to 1
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				case SET_PROTOCOL
					movf		USB_buffer_data+wValue, W, BANKED
					movwf		USB_protocol, BANKED	; update the new protocol value
					banksel		BD0IBC
					clrf		BD0IBC, BANKED			; set byte count to 0
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				case GET_IDLE
					banksel		BD0IAH
					movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
					movwf		FSR0H, ACCESS
					movf		BD0IAL, W, BANKED
					movwf		FSR0L, ACCESS			; ...into FSR0
					banksel		USB_idle_rate
					movf		USB_idle_rate, W, BANKED
					movwf		INDF0
					banksel		BD0IBC
					movlw		0x01
					movwf		BD0IBC, BANKED			; set byte count to 1
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				case SET_IDLE
					movf		USB_buffer_data+wValue, W, BANKED
					movwf		USB_idle_rate, BANKED	; update the new idle rate
					banksel		BD0IBC
					clrf		BD0IBC, BANKED			; set byte count to 0
					movlw		0xC8
					movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
					break
				default
					bsf			USB_error_flags, 0, BANKED	; set Request Error flag
			ends
			return

VendorRequests
			bsf			USB_error_flags, 0, BANKED	; set Request Error flag
			return

ProcessInToken
			banksel		USB_USTAT
			movf		USB_USTAT, W, BANKED
			andlw		0x18		; extract the EP bits
			select
				case EP0
					movf		USB_dev_req, W, BANKED
					select
						case SET_ADDRESS
							movf		USB_address_pending, W, BANKED
							movwf		UADDR, ACCESS
							select
								case 0
									movlw		DEFAULT_STATE
									movwf		USB_USWSTAT, BANKED
									break
								default
									movlw		ADDRESS_STATE
									movwf		USB_USWSTAT, BANKED
							ends
							break
						case GET_DESCRIPTOR
							call		SendDescriptorPacket
							break
					ends
					break
				case EP1
					break
				case EP2
					break
			ends
			return

ProcessOutToken
			banksel		USB_USTAT
			movf		USB_USTAT, W, BANKED
			andlw		0x18		; extract the EP bits
			select
				case EP0
					movf		USB_dev_req, W, BANKED
					select
						case SET_REPORT
							movlw		NO_REQUEST
							movwf		USB_dev_req, BANKED	; clear device request
							banksel		BD0OAH
							movf		BD0OAH, W, BANKED	; put EP0 OUT buffer pointer...
							movwf		FSR0H, ACCESS
							movf		BD0OAL, W, BANKED
							movwf		FSR0L, ACCESS		; ...into FSR0
					ends
					banksel		BD0OBC
					movlw		B_MAX_PACKET_SIZE0
					movwf		BD0OBC, BANKED
					movlw		0x88
					movwf		BD0OST, BANKED
					clrf		BD0IBC, BANKED		; set byte count to 0
					movlw		0xC8
					movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
					break
				case EP1
					break
				case EP2
					break
			ends
			return

SendDescriptorPacket
			banksel		USB_bytes_left
			ifl USB_bytes_left, <, B_MAX_PACKET_SIZE0
				movlw		NO_REQUEST
				movwf		USB_dev_req, BANKED		; sending a short packet, so clear device request
				movf		USB_bytes_left, W, BANKED
			otherwise
				movlw		B_MAX_PACKET_SIZE0
			endi
			subwf		USB_bytes_left, F, BANKED
			movwf		USB_packet_length, BANKED
			banksel		BD0IBC
			movwf		BD0IBC, BANKED			; set EP0 IN byte count with packet size
			movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS			; ...into FSR0
			banksel		USB_loop_index
			forlf USB_loop_index, 1, USB_packet_length
				call		Descriptor			; get next byte of descriptor being sent
				movwf		POSTINC0			; copy to EP0 IN buffer, and increment FSR0
				incf		USB_desc_ptrL, F, BANKED	; increment the descriptor pointers
				movlw		0x00
				addwfc		USB_desc_ptrH, F, BANKED
				;addwfc		USB_desc_ptrU, F, BANKED
			next USB_loop_index
			banksel		BD0IST
			movlw		0x40
			xorwf		BD0IST, W, BANKED		; toggle the DATA01 bit
			andlw		0x40					; clear the PIDs bits
			iorlw		0x88					; set UOWN and DTS bits
			movwf		BD0IST, BANKED
			return

GetBUFFER1
			; copy EP1 OUT buffer to BUFFER1
			lfsr		0, BUFFER1				; put BUFFER1 address into FSR0
			movff		BD1OAH, FSR1H			; put EP1 IN buffer pointer...
			movff		BD1OAL, FSR1L			; ...into FSR1
			banksel iBUFFER						; for macro uses banked instructions
			for 		iBUFFER, 1, REPORT_LEN_OUT	; for 1 <= iBUFFER <= REPORT_LEN_OUT
				movff	POSTINC1, POSTINC0		; copy EP1 OUT byte to BUFFER1 byte,then increment FSR0 and FSR1
;				banksel iBUFFER					; next macro uses banked instructions
			next		iBUFFER

			banksel		BD1OST
			movlw	    REPORT_LEN_OUT
			movwf		BD1OBC				; reset the EP1 OUT byte count
			movf		BD1OST, W, BANKED	; get the EP1 OUT status register
			andlw		0x40				; extract the DATA01 bit
			xorlw		0x40				; toggle the DATA01 bit
			iorlw		0x88				; set UOWN and DTS bits
			movwf		BD1OST, BANKED		; turn the buffer back over to USB
			return

SendBUFFER2
			; copy BUFFER2 to EP1 IN buffer
			lfsr		0, BUFFER2				; put BUFFER2 address into FSR0
			movff		BD1IAH, FSR1H			; put EP1 IN buffer pointer...
			movff		BD1IAL, FSR1L			; ...into FSR1
			banksel iBUFFER						; for macro uses banked instructions
			for 		iBUFFER, 1, REPORT_LEN_IN	; for 1 <= iBUFFER <= REPORT_LEN_IN
				movff	INDF0, POSTINC1			; copy BUFFER2 byte to EP1 IN buffer byte,clear BUFFER2 then increment FSR0 and FSR1
				clrf	POSTINC0,ACCESS
;				banksel iBUFFER					; next macro uses banked instructions
			next		iBUFFER

			banksel		BD1IBC
			movlw		REPORT_LEN_IN
			movwf		BD1IBC, BANKED			; set EP1 IN buffer byte count to REPORT_LEN (number of bytes to be transmitted, can be less than endpoint WMaxPacketSize)
			movf		BD1IST, W, BANKED		; get EP1 IN status register
			andlw		0x40					; extract the DATA01 bit
			xorlw		0x40					; toggle the DATA01 bit
			iorlw		0x88					; set UOWN and DTS bits
			movwf		BD1IST, BANKED			; send packet
			return
