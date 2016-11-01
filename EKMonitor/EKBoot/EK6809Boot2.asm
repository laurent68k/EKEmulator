;
;	6809 Boot Code Test 2 for ReadBoard 6809 
;	Created:	2012/01/18	Laurent68k
;	Updated:	2013/01/18
;
;	Send an 'A' on the console forever
;
;	CCR:	7 6 5 4 3 2 1 0
;			E F H I N Z V C
;
;	Change log:
;
;	----------------------------------------------------------------------------------------------------

;	----------------------------------------------------------------------------------------------------
RamStart			equ	$0000
RamEnd				equ	$7FFF
Cartridge           equ $8000
RomStart			equ	$E000
RomEnd				equ	$FFFF
ROMVectors			equ	$FFF0
;	----------------------------------------------------------------------------------------------------
Uart				equ	$D000
UartTDR				equ Uart+1
UartRDR				equ Uart+1
;	----------------------------------------------------------------------------------------------------
Pia					equ	$D004
PiaDDRA				equ	Pia
PiaORA				equ	Pia
PiaCRA				equ	Pia+1
PiaDDRB				equ	Pia+2
PiaORB				equ	Pia+2
PiaCRB				equ	Pia+3
PIA_INPUTS			equ	$00
PIA_OUTUTS			equ	$FF
;	----------------------------------------------------------------------------------------------------
;	Start of Boot Code ROM

					org		RomStart					
								
BootCode:           orcc    #$50
					lds		#$100
					ldu		#$100

					;	Init Uart for format 8N1, using E = 7.3728 Mhz  => 7372800 / 64 = 115200 bps
					lda		#$03						;	ACIA master reset
					sta		Uart

					lda		#%00010110                  ;   %0001 0110
					sta		Uart
                    
					;	Init PIA
					lda		#%11111011					;	clear bit DDR to access to DDR register
					anda	PiaCRA
					sta		PiaCRA
					
					lda		#PIA_INPUTS					;	pins are input
					sta		PiaDDRA						;	set Direction register
										
                    lda		#%00000100					;	Set the DDR bit to enable next access to Data Register
					ora		PiaCRA
					sta		PiaCRA			

Loop:               lda		#%10101010
					sta		PiaORA

					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					
					lda     #'A'
					sta		UartTDR
                    
					lda		#%01010101
					sta		PiaORA
					
					bra		Loop
					
;	----------------------------------------------------------------------------------------------------

Vector:             rti

marque:				fcc "LAURENT BOOTCODE TEST #2, 20130222"
;	----------------------------------------------------------------------------------------------------
					spaceto ROMVectors				; special LFD directive: fill from last PC = * to here 
					org	ROMVectors

Vectors:			
					fdb	Vector		
					fdb	Vector
					fdb	Vector
					fdb	Vector
					fdb	Vector
					fdb	Vector
					fdb	Vector
					fdb	RomStart            

					end
;	----------------------------------------------------------------------------------------------------

