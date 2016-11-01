;
;	6809 Boot Code HCF for ReadBoard 6809 
;	Created:	2012/01/18	Laurent68k
;	Updated:	2013/01/18
;
;	Execute small init, send an 'H' on the console and perform a Sync instruction
;	we must have BA = 1 and BS = 0
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

										
loop:				sync							;	BA = 1 and BS = 0
					fcb		$14						;	HCF
					bra	loop
					
;	----------------------------------------------------------------------------------------------------

Vector:             rti

marque:				fcc "LAURENT BOOTCODE TEST #1, 20130201"
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

