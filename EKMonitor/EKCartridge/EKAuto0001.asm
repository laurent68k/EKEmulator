;
;	Example of Automatic Cartridge for ReadBoard 6809
;	Created:	2012/09/04	Laurent68k
;	Updated:	2013/03/22
;
;
;	CCR:	7 6 5 4 3 2 1 0
;			E F H I N Z V C

;	----------------------------------------------------------------------------------------------------

RomCartidgeStart	equ		$8000
MonitorStart		equ		$E000
;	----------------------------------------------------------------------------------------------------
;	Offsets in ROM header
CPUCode				equ		2
Version				equ		6
Date				equ		8
OffTableRoutines	equ		12
;	----------------------------------------------------------------------------------------------------
;	Offsets of subroutines in functions's Monitor
PutChar				equ		0
PutHexChar			equ		PutChar+2
GetChar				equ		PutHexChar+2
GetCharUntil		equ		GetChar+2
WriteHexByte		equ		GetCharUntil+2
WriteBinByte		equ		WriteHexByte+2
WriteString			equ		WriteBinByte+2
ReadString			equ		WriteString+2
ReadHexFromString	equ		ReadString+2
;	----------------------------------------------------------------------------------------------------
					org		RomCartidgeStart		
					fcc		"AT"							;	Automatic Cartridge Header
;	----------------------------------------------------------------------------------------------------				
					
Startup:			pshs	x								;	save return address

					ldy		#MonitorStart                   ;   find adr of functions table
                    ldy     OffTableRoutines,y              ;   Y = @ of functions table
                    ldy     WriteString,y                	;   add offset to point WriteString
										
					ldx		#STRExample00					;	string to display
					jsr     0,y						

					puls	x								;	restore return address
					jmp		0,x								;	return to the monitor
					
STRExample00		fcc     "Automatic Cartridge started\015\012\0"					
;	----------------------------------------------------------------------------------------------------				

					