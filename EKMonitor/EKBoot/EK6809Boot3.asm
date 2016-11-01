;
;	6809 Boot Code for ReadBoard 6809 
;	Created:	2012/02/22	Laurent68k
;	Updated:	2013/02/22
;
;
;	Send double 'A' wihout testing and print "Hello" text on the remote console with status bit test for ever.
;   Play with the port A too.
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
PiaCRB				equ	Pia+3PIA_INPUTS			equ	$00
PIA_OUTUTS			equ	$FF
;	----------------------------------------------------------------------------------------------------
;	Start of Boot Code ROM

					org		RomStart					
								
BootCode:	
					lds		#$100
					ldu		#$100

					;	CMOS 4060 has a crystal of 2457600 Hz => Q4: 2457600/16=153600 so need 153600/64=2400
					
					lda		#$03						;	ACIA master reset
					sta		Uart
					
					lda		#%00010110                  ;   %0001 0110 => 2400 bauds
					sta		Uart
					
					;	Init PIA
					lda		#%11111011					;	clear bit DDR to access to DDR register
					anda	PiaCRA
					sta		PiaCRA
					
					lda		#PIA_OUTUTS					;	pins are input
					sta		PiaDDRA						;	set Direction register
										
                    lda		#%00000100					;	Set the DDR bit to enable next access to Data Register
					ora		PiaCRA
					sta		PiaCRA			

;	Send wihout test
					lda     #'A'
					sta		UartTDR

					lda		#%10101010
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

					lda     #'B'
					sta		UartTDR		

;	Print "Hello" text on the remote console with status bit test for ever
Loop:				nop

_PutChar1:			lda		Uart
					bita	#$02
					beq		_PutChar1
					
					lda		#%00000001
					sta		PiaORA
					
					lda		#'H'
					sta		UartTDR
					
_PutChar2:			lda		Uart
					bita	#$02
					beq		_PutChar2
					
					lda		#%00000010
					sta		PiaORA

					lda		#'e'
					sta		UartTDR

_PutChar3:			lda		Uart
					bita	#$02
					beq		_PutChar3
					
					lda		#%00000100
					sta		PiaORA

					lda		#'l'
					sta		UartTDR

_PutChar4:			lda		Uart
					bita	#$02
					beq		_PutChar4
					
					lda		#%00001000
					sta		PiaORA

					lda		#'l'
					sta		UartTDR
					
_PutChar5:			lda		Uart
					bita	#$02
					beq		_PutChar5
					
					lda		#%00010000
					sta		PiaORA

					lda		#'o'
					sta		UartTDR					
					
_PutChar6:			lda		Uart
					bita	#$02
					beq		_PutChar6
					
					lda		#%00100000
					sta		PiaORA

					lda		#$0A
					sta		UartTDR	

_PutChar7:			lda		Uart
					bita	#$02
					beq		_PutChar7
					
					lda		#%00100000
					sta		PiaORA

					lda		#$0D
					sta		UartTDR	
				
					bra		Loop
;	----------------------------------------------------------------------------------------------------

Vector:             rti

marque:				fcc "LAURENT BOOTCODE TEST #3, 20130222"
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

