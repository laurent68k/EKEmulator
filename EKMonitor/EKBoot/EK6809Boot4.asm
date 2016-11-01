;
;	6809 Boot Code for ReadBoard 6809 
;	Created:	2012/02/24	Laurent68k
;	Updated:	2013/02/24
;
;   print "Hello" text on the remote console with status bit test and wait for a char to echo it for ever.
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
;	Start of Boot Code ROM

					org		RomStart					
								
BootCode:	
					lds		#$100
					ldu		#$100

					;	CMOS 4060 has a crystal of 2457600 Hz => Q4: 2457600/16=153600 so need 153600/16=9600
					
					lda		#$03						;	ACIA master reset
					sta		Uart
					
					lda		#%00010101                  ;   %0001 0110 => 8N1, div by 16					
                    sta		Uart


;	Print "Hello" text on the remote console with 					
_PutChar1:			lda		Uart
					bita	#$02
					beq		_PutChar1
					
					lda		#'H'
					sta		UartTDR
					
_PutChar2:			lda		Uart
					bita	#$02
					beq		_PutChar2
					
					lda		#'e'
					sta		UartTDR

_PutChar3:			lda		Uart
					bita	#$02
					beq		_PutChar3
					
					lda		#'l'
					sta		UartTDR

_PutChar4:			lda		Uart
					bita	#$02
					beq		_PutChar4
					
					lda		#'l'
					sta		UartTDR
					
_PutChar5:			lda		Uart
					bita	#$02
					beq		_PutChar5
					
					lda		#'o'
					sta		UartTDR					
					
_PutChar6:			lda		Uart
					bita	#$02
					beq		_PutChar6
					
					lda		#$0A
					sta		UartTDR	

				
;	Test RAM				

					ldx		#$0000
					lda		#$AA
					sta		0,x
					lda		0,x
					cmpa	#$AA
					bne		failed

_PutChar8:			lda		Uart
					bita	#$02
					beq		_PutChar8
					
					lda		#'K'
					sta		UartTDR	
					
					bra		GetChar

failed:				lda		Uart
					bita	#$02
					beq		failed
					
					lda		#'F'
					sta		UartTDR	
					
					
;	Main loop
GetChar:			lda		Uart
					bita	#$01
					beq		GetChar
					
                    lda		UartRDR                 ;   read the char
					tfr		a,b
					
_PutChar20:			lda		Uart
					bita	#$02
					beq		_PutChar20
					
					stb		UartTDR	
					
					bra		GetChar
;	----------------------------------------------------------------------------------------------------

Vector:             rti

marque:				fcc "LAURENT BOOTCODE TEST #4, 20130224"
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

