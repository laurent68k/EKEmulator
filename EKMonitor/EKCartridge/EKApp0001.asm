;
;	Example of Application Cartridge for ReadBoard 6809
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
					fcc		"AP"							;	Applications Cartridge Header
;	----------------------------------------------------------------------------------------------------				
CA_Next00:			fdb		CA_Next01
					fdb		CARun00
					fdb		CAInit00						;	Code to execute for init
					fdb		%0100001001110110				;	2013/03/22
					fdb		%0111100000000000				;	15h00:00
					fcc		"Program00\0"
					
CARun00:			ldy		#MonitorStart                   ;   find adr of functions table
                    ldy     OffTableRoutines,y              ;   Y = @ of functions table
                    ldy     WriteString,y                	;   add offset to point WriteString

					ldx		#STRExample00					;	string to display
					jsr     0,y						

					rts

CAInit00:			pshs    x,y

                    ldy		#MonitorStart                   ;   find adr of functions table
                    ldy     OffTableRoutines,y              ;   Y = @ of functions table
                    ldy     WriteString,y                	;   add offset to point WriteString

					ldx		#STRInit00						;	string to display
					jsr     0,y						

                    puls    x,y
                    
					rts
					
STRExample00		fcc     "Program 00 started\015\012\0"					
STRInit00			fcc     "Program 00 init\015\012\0"	
;	----------------------------------------------------------------------------------------------------				
CA_Next01:			fdb		CA_Next02
					fdb		CA_Run01
					fdb		$0000							;	CA_Init null
					fdb		%0100001001110110				;	2013/03/22
					fdb		%0111100111100000				;	15h15:00
					fcc		"Program01\0"
					
CA_Run01:			ldy		#MonitorStart
					ldy     OffTableRoutines,y
                    ldy     WriteString,y                	;  add offset to point WriteString

					ldx		#STRExample01
					jsr     0,y
					
					rts
					
STRExample01		fcc     "Program 01 started\015\012\0"	
;	----------------------------------------------------------------------------------------------------				
CA_Next02:			fdb		$0000
					fdb		CA_Run02
					fdb		CA_Init02						;	Code to execute for init
					fdb		%0100001001110110				;	2013/03/22
					fdb		%0111101111000000				;	15h15:00
					fcc		"Program01\0"
					
CA_Run02:			ldy		#MonitorStart
					ldy     OffTableRoutines,y
                    ldy     WriteString,y                	;  add offset to point WriteString

					ldx		#STRExample01
					jsr     0,y
					
					rts

CA_Init02:			pshs    x,y

                    ldy		#MonitorStart
					ldy     OffTableRoutines,y
                    ldy     WriteString,y                	;  add offset to point WriteString

					ldx		#STRInit02
					jsr     0,y

                    puls    x,y
                    
					rts
					
STRExample02		fcc     "Program 02 started\015\012\0"	
STRInit02			fcc     "Program 02 init\015\012\0"	
;	----------------------------------------------------------------------------------------------------				

					