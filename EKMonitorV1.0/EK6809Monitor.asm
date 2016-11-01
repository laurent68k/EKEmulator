;
;	Small Monitor for ReadBoard 6809 + tinyBasic embedded.
;	Created:	2012/09/04	Laurent68k
;	Updated:	2013/01/16
;
;	CCR:	7 6 5 4 3 2 1 0
;			E F H I N Z V C
;
;	Change log:
;
;   2013/02/24	-	FIRST VERSION BURNED ! The Boards Works
;               -   Updated to peform a Master Reset on the 6850
;   2013/01/16	-	Updated to divide by 16 the clock of 6850
;	2013/01/12	-	Updated, uppercase all received characters from UART when between [a,z]
;	2013/01/05	-	Updated disable and reenable inerrupts
;               -   Bug fixed, PIA was set as out instead of In mode.
;	2012/12/19	-	Added init of UART, 8 bits 1 stop Parity None
;	2012/12/10	-	Added MEMSIZE
;				-	Added SETPIA CTRX: to finish
;				-	Using of DispatchCommands for the CLI
;	----------------------------------------------------------------------------------------------------

;	----------------------------------------------------------------------------------------------------
RamStart			equ	$0000
RamEnd				equ	$7FFF
Cartridge           equ $8000
RomStart			equ	$E000
RomEnd				equ	$FFFF
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
Major				equ	RomStart+$06
Minor				equ	RomStart+$07
;	----------------------------------------------------------------------------------------------------
MagicCartHigh		equ	Cartridge
MagicCartLow		equ	MagicCartHigh+1
AutoCartEntry		equ	MagicCartLow+1
;	----------------------------------------------------------------------------------------------------
CA_Next				equ	0
CA_Run				equ	CA_Next+2
CA_Date				equ	CA_Run+2
CA_Time				equ	CA_Date+2
CA_Name				equ	CA_Time+2
;	----------------------------------------------------------------------------------------------------
ROMVectors			equ	$FFF0
;	----------------------------------------------------------------------------------------------------
STACK_SIZE_S		equ	64
STACK_SIZE_U		equ	STACK_SIZE_S
PRTLINE_SIZE		equ	16
NLCHAR				equ	$0A
CRCHAR				equ	$0D
BACKSPACECHAR		equ	$08
DELETECHAR			equ	$7F
RDSTRBUFSTART		equ	2
RDSTRBUFEND			equ	0
;	----------------------------------------------------------------------------------------------------
;	Stack pointer while boot sequence before RAM size evaluation
BootSSP				equ	$100									;	size = 64 bytes
BootUSP				equ	BootSSP-STACK_SIZE_S					;	size = 64 bytes

;	----------------------------------------------------------------------------------------------------
;	BOTTOM RAM

                    ORG $0000
                    
RamSize				rmb	2										;	Size of the RAM 
RamTop				rmb	2										;	Top RAM address
Swi3Vector			rmb	2										;	Vector address to SW3
Swi2Vector			rmb	2										;	Vector address to SW2
FirqVector			rmb	2										;	Vector address to FIRQ
IrqVector			rmb	2										;	Vector address to IRQ
SwiVector			rmb	2										;	Vector address to SWI
NmiVector			rmb	2										;	Vector address to NMI
Pia_CR				rmb 2										;	Scratch variable
Pia_DDR				rmb 2										;	Scratch variable
save_regB			rmb	1										;	Scratch variable
save_count			rmb	1										;	Scratch variable
promptLine			rmb PRTLINE_SIZE							;	CLI line buffer

;	----------------------------------------------------------------------------------------------------
;	tinyBasic equates
EOL					EQU	$04
ETX					EQU	$03
SPACE				EQU	$20
CR					EQU	$0D
LF					EQU	$0A
BS					EQU	$08
CAN					EQU	$18
BELL				EQU	$07
FILL				EQU	$00
DEL					EQU	$7F
BSIZE				EQU	73
STKCUS				EQU	48
;
ACIA				EQU	Uart
RMCR				EQU	ACIA
TRCS				EQU	ACIA
RECEV				EQU	ACIA+1
TRANS				EQU	ACIA+1
CNTL1				EQU	$03
CNTL2				EQU	$15
RDRF				EQU	$01
ORFE				EQU	$20
TDRE				EQU	$02

; EDIT THE FOLLOWING EQUATES TO REFLECT THE DESIRED ROM AND RAM LAYOUT
LORAM				EQU	$0080	;ADDRESS OF DIRECT PAGE SCRATCH RAM
BUFFER				EQU	$0100	;ADDRESS OF MAIN RAM
;RAMSIZ				EQU	$0600	;SIZE OF MAIN RAM
;ROMADR				EQU	$E000	;ADDRESS OF TINY BASIC ROM
;
RAMBEG				EQU	BUFFER+BSIZE
;RAMEND				EQU	$7EFF  ;   BUFFER+RAMSIZ
;

					ORG	LORAM
USRBAS				RMB	2
USRTOP				RMB	2
STKLIM				RMB	2
STKTOP				RMB	2
CURSOR				RMB	2
SAVESP				RMB	2
LINENB				RMB	2
SCRTCH				RMB	2
CHAR				RMB	2
ZONE				RMB	1
MODE				RMB	1
RESRVD				RMB	1
LOEND				EQU	*
;	----------------------------------------------------------------------------------------------------
;	----------------------------------------------------------------------------------------------------

;	----------------------------------------------------------------------------------------------------
;	Start of System ROM

					org		RomStart					
					
					bra		OSStart
					fcc		"6809"
					fcb		1,0
					fcb		20,12,01,16
					fdb		FunctionsTable
					
OSStart:			;	Strategic init temporaly Stack pointer
					lds		#BootSSP
					ldu		#BootUSP
					andcc	#$f0
					orcc	#$50                        ;   Disable all interrupts IRQ and FIRQ (E F H I N Z V C)
				
					;	Set the interrupts vectors in RAM
					ldx		#Vector_swi3
					stx		Swi3Vector
					
					ldx		#Vector_swi2
					stx		Swi2Vector
					
					ldx		#Vector_firq
					stx		FirqVector
					
					ldx		#Vector_irq
					stx		IrqVector
					
					ldx		#Vector_swi
					stx		SwiVector
					
					ldx		#Vector_nmi
					stx		NmiVector
					
					;	Init Uart for format 8N1 and dib by 16
                    ;	CMOS 4060 has a crystal of 2457600 Hz => Q4: 2457600/16=153600 so need 153600/16=9600
					lda		#$03						;	ACIA master reset
					sta		Uart
					
					lda		#%00010101                  ;   %0001 0110 => 8N1, div by 16					
                    sta		Uart
					
                    ;   Automatic cartdridge inserted ?
                    lda		MagicCartHigh
					cmpa	#'A'
					bne		RetAutoCart
					
					lda		MagicCartLow
					cmpa	#'T'
					bne		RetAutoCart
					
					ldx		#STRAutCartOk
					lbsr	WriteString
					
					ldx		#RetAutoCart				;	Load in X the return address in case of...				
					jmp		AutoCartEntry				;	Jump to the first instruction
										
                    ;   Display system started
RetAutoCart:		andcc	#$A0                        ;   Disable all interrupts IRQ and FIRQ (E F H I N Z V C)

                    ldx		#STRSystemStart
					lbsr	WriteString
						
					;	Automatic memory checking and size compute by step of 512 bytes
					ldx		#$0000
MemCheck:    		lda  	511,x
					coma                			
					sta  	511,x
					cmpa 	511,x            			;	IS IT RAM?
					bne  	MemCheckEnd        			;	BRANCH IF NOT (ROM, BAD RAM OR NO RAM)
					
					leax 	512,x            			;	MOVE POINTER UP ONE
					com  	512,x            			;	RE-COMPLEMENT TO RESTORE BYTE
					bra  	MemCheck          			;	KEEP LOOKING FOR END OF RAM 
		  
MemCheckEnd:   		
					stx  	RamSize   
                    leax    -1,x						;	for 32Kb: $8000
                    stx  	RamTop         				;	for 32Kb: $7FFF
                    				
					tfr		x,d
					
					ldx		#STRMemCalculated
					lbsr	WriteString
					
					lbsr	WriteHexByte				;	print A
					tfr		b,a
					lbsr	WriteHexByte				;	print B
					
					ldx		#STRNewLine
					lbsr	WriteString
					
					;	use the calculated RAM size to set the stacks to the good location
					lds		RamTop						;	set System stack
					leax	-STACK_SIZE_S,s				;	x = x - STACK_SIZE_S
					tfr		x,u							;	store x in User stack
					
                    ;	add here init of any additionnal hardware	
					;	Set port as input
					lda		#%11111011                  ;	clear bit DDR to access to DDR register
					anda	PiaCRA
					sta		PiaCRA
					
					lda		#PIA_INPUTS					;	pins are input
					sta		PiaDDRA						;	set Direction register, b contains the good value
										
                    lda		#%00000100                  ;	Set the DDR bit to enable next access to Data Register
					ora		PiaCRA
					sta		PiaCRA			
								
					;	Set port as input
					lda		#%11111011					;	clear bit DDR to access to DDR register
					anda	PiaCRB
					sta		PiaCRB
					
					lda		#PIA_INPUTS					;	pins are input
					sta		PiaDDRB						;	set Direction register, b contains the good value
										
                    lda		#%00000100                  ;	Set the DDR bit to enable next access to Data Register
					ora		PiaCRB
					sta		PiaCRB			

					;	check for an application cartridge
                    lda		MagicCartHigh
					cmpa	#'A'
					bne		NoCartApp
					
					lda		MagicCartLow
					cmpa	#'P'
					bne		NoCartApp
					
					ldx		#STRAppCartOk
					lbsr	WriteString
					
                    ldx		#STRCountApp
					lbsr	WriteString
					
					ldy		#AutoCartEntry				;	Y = $8002		
					lda		#1							;	count of applications
					
_mnAppLoop:         pshs    a
                    ldd     CA_Next,y					
                    
					cmpd	#$0000
					beq		_mnAppLoopEnd
					
                    tfr     d,y
                    puls    a
                    adda	#1
					bra		_mnAppLoop
					
_mnAppLoopEnd:		puls    a
                    lbsr	WriteHexByte
					ldx		#STRNewLine
					lbsr	WriteString

					;	Ready
NoCartApp:			ldx		#STRSystemReady
					lbsr	WriteString
													
					
;	----------------------------------------------------------------------------------------------------
;   Monitor Main loop to handle interaction with user
;	Command Line Interpreter

Mainloop:			ldx		#STRPromptCLI
					lbsr	WriteString
					
					ldx		#promptLine		
					ldb		#PRTLINE_SIZE
					lbsr	ReadString
					
					ldx		#STRNewLine
					lbsr	WriteString

					;	experimentation
					ldy		#DispatchCommands				;	Y = jumps table
FindCmd:			ldx		#promptLine						;	X = String entered

					pshs	y								;	save x before change
					ldy		,y								;	load content of Y with command string to check
					lbsr	CompareString					;	compare
					beq		FoundCmd				
					puls	y								;	reload X with last table address
					
					leay	4,y								;	not found, inc to next command to check
					ldd		,y								;	load D with the content at Y
					cmpd	#$0000							;	is the end of table (No address)?
					bne		FindCmd							;	No, loop again
					
					ldx		#STRSorry						;	end of table, unknow command
					lbsr	WriteString
					
					bra	Mainloop                            ;	go main loop 
					
FoundCmd:			puls	y								;	reload X with last table address
                    leay    2,y
                    ldy     ,y
					jmp     ,y								

;	----------------------------------------------------------------------------------------------------
;	Command execution
;	----------------------------------------------------------------------------------------------------

;	----------------------------------------------------------------------------------------------------
;	HELP Command
mnHelp:				ldx		#STRHelp
					lbsr	WriteString
                	lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	VER Command
mnVersion:			ldx		#STRVersion
					lbsr	WriteString
					
					lda		Major
					lbsr	WriteHexByte
					
                	lda		#'.'						;	symbol for data to display
					lbsr	PutChar						;	display
					
					lda		Minor
					lbsr	WriteHexByte
					
					ldx		#STRNewLine
                	lbsr	WriteString					
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
mnMemSize:			ldx		#STRMemSize
                	lbsr	WriteString

					ldd		RamSize									
					lbsr	WriteHexByte

					tfr		b,a
					lbsr	WriteHexByte

					ldx		#STRNewLine
                	lbsr	WriteString					
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	LIST Command
mnList:				lda		MagicCartHigh				;	Check if a cartidge is inserted		
					cmpa	#'A'
					bne		_mnListFailed				;	no
					
					lda		MagicCartLow
					cmpa	#'P'
					bne		_mnListFailed				;	no
					
					ldy		#AutoCartEntry				;	Y = $8002				
_mnListLoop:		leax	CA_Name,y					;	display the name
					lbsr	WriteString	
					
					lda		#$09						;	tabulation
					lbsr	PutChar
					lda		#'$'						;	Hexa symbol
					lbsr	PutChar
										
					ldd		CA_Run,y
					lbsr	WriteHexByte
					
					tfr		b,a
					lbsr	WriteHexByte
					
					ldx		#STRNewLine
					lbsr	WriteString	
					
					ldd		CA_Next,y
					tfr		d,y
					
					cmpy	#$0000
					beq		_mnListEnd
					bra		_mnListLoop
					
_mnListEnd:			lbra	Mainloop
					
_mnListFailed:		ldx		#STRListFailed
					lbsr	WriteString	
                	lbra	Mainloop
					
;	----------------------------------------------------------------------------------------------------
;	RUN Command
mnRun:				lbsr	SkipSpace					;	skip space from current X									
					lbsr	ReadHexFromString			;	read hexa address pointed by X and store it to D
					tfr		d,y							;	store D in X

                    jsr     0,y                    
                    lbra	Mainloop
					
					;	----------------------------------------------------------------------------------------------------
;	PEEK Command
mnRead:				lbsr	SkipSpace					;	skip space from current X									
					lbsr	ReadHexFromString			;	read hexa value pointed by X and store it to D
					tfr		d,x							;	store D in X
					
					lda		#'$'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		,x							;	load A with the content at the X address
					lbsr	WriteHexByte				;	display A
					
                                            
					lda		#' '						;	separator
					lbsr	PutChar						;	display					
                        
					lda		#'b'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		,x							;	load A with the content at the X address
					lbsr	WriteBinByte				;	display A
							
					ldx		#STRNewLine
                	lbsr	WriteString					
					lbra	Mainloop

;	----------------------------------------------------------------------------------------------------
;	POKE Command
mnWrite:			lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value to poke pointed by X and store it to D
					;stb		save_regB					;	only LSB in B will be used
					pshs	b
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnWrite2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnWrite2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,x							;	store D in X
					puls	b
					stb		0,x
					
					ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop
					
;	----------------------------------------------------------------------------------------------------
;	DUMP Command
mnDump:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value = count and store it to D
					stb		save_count					;	only LSB in B will be used
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnDump2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnDump2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,y							;	store D (adress start) in Y										
					
_mnDump3:			ldb		save_count					;	reload the count
					cmpb	#0
					beq		_mnDumpDone
					
					decb								;	decrement count in B
					stb		save_count					;	save count
						
					lda		#'$'						;	symbol for data to display
					lbsr	PutChar						;	display
					
					tfr		y,d
					lbsr	WriteHexByte				;	display upper D = A
					
					tfr		b,a
					lbsr	WriteHexByte				;	display lower D = B

					lda		#':'						;	symbol separator
					lbsr	PutChar						;	display
					
					lda		#'$'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		,y							;	load A with the content at the X address
					lbsr	WriteHexByte				;	display A
					
                                            
					lda		#' '						;	separator
					lbsr	PutChar						;	display					
                        
					lda		#'b'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		,y							;	load A with the content at the X address
					lbsr	WriteBinByte				;	display A
							
					ldx		#STRNewLine
                	lbsr	WriteString					
					
					leay	1,y							;	next value
					bra		_mnDump3
					
_mnDumpDone:		ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop					
					
;	----------------------------------------------------------------------------------------------------
;	COPY Command
mnCopy:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value = count and store it to D
					stb		save_count					;	only LSB in B will be used
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnCopy2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnCopy2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,y							;	store D (adress source) in Y										
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnCopy3
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnCopy3:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,x							;	store D (adress destination) in X	
					
                    ldb		save_count					;	reload the count
_mnCopy4:			cmpb	#0
					beq		_mnCopyDone
					
					decb								;	decrement count in B
						
                    lda     ,y
                    sta     ,x
                    
					leay	1,y							;	next value Y = Y +1
					leax	1,x
					bra		_mnCopy4
					
_mnCopyDone:		ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop					

;	----------------------------------------------------------------------------------------------------
;	ORI Command
mnOri:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read mask to set pointed by X and store it to D
					;stb		save_regB					;	only LSB in B will be used										
					pshs	b
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnOri2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop

_mnOri2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,x							;	store D in X
					puls	b
					orb		,x
					stb		,x
					
                	ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop

;	----------------------------------------------------------------------------------------------------
;	ANDI Command
mnAndi:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read mask to set pointed by X and store it to D
					;stb		save_regB					;	only LSB in B will be used
					pshs	b
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnAndi2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop

_mnAndi2:			lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					
					tfr		d,x							;	store D in X
					puls	b
					andb	,x
					stb		,x
					
                	ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop
					
;	----------------------------------------------------------------------------------------------------
;	SW1 Command
mnSw1:              swi
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	SW2 Command
mnSw2:              swi2
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	SW3 Command
mnSw3:              swi3
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	BSET Command
mnBset:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value as bit number to set pointed by X and store it to D
					
					cmpd	#8
					bpl     _mnBset1
					stb		save_regB					;	only LSB in B will be used as bit number
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnBset2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnBset1:			ldx		#STRHow						;	bit number incorrect
					lbsr	WriteString					
                	lbra	Mainloop			

_mnBset2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					tfr		d,x							;	store D in X
					
					lda		save_regB					;	A = bit number
					ldb		#$01						;	B = mask
_mnBset3:			cmpa	#0
					beq		_mnBset4
					lslb	
					deca
					bra		_mnBset3
					
_mnBset4:          	orb		,x							;	B= B OR (x) 
					stb		,x							;	(x) = B

					ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop

					lbra	Mainloop

;	----------------------------------------------------------------------------------------------------
;	BCLR Command
mnBclr:				lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value as bit number to set pointed by X and store it to D
					
					cmpd	#8
					bpl		_mnBclr1
					
					stb		save_regB					;	only LSB in B will be used as bit number
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnBclr2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnBclr1:			ldx		#STRHow						;	bit number incorrect
					lbsr	WriteString					
                	lbra	Mainloop	
					
_mnBclr2:			lbsr	SkipSpace					;	skip space from current X	
					lbsr	ReadHexFromString			;	read hexa adr value pointed by X and store it to D
					tfr		d,x							;	store D in X
					
					lda		save_regB					;	A = bit number
					ldb		#$FE						;	B = mask
_mnBclr3:			cmpa	#0
					beq		_mnBclr4
					rolb	
					deca
					bra		_mnBclr3
					
_mnBclr4:          	andb	,x							;	B = B AND (x) 
					stb		,x							;	(x) = B

					ldx		#STRDone
					lbsr	WriteString
					lbra	Mainloop

					lbra	Mainloop

;	----------------------------------------------------------------------------------------------------
;	PIA DATA REGISTER Command
mnPiadr:			lbsr	SkipSpace					;	skip space from current X	
					lda		,x+							;	check the port
					cmpa	#'A'						;	is port A requested ?
					beq		mnPiadr1				
							
					cmpa	#'B'
					bne		mnPiadr6
						
					ldy		#PiaCRB
					sty		Pia_CR						;	contains the correct CR according to port A or B
					ldy		#PiaDDRB
					sty		Pia_DDR						;	contains the correct DDR according to port A or B
					
					bra		mnPiadr2
					
mnPiadr1:			ldy		#PiaCRA
					sty		Pia_CR						;	contains the correct CR according to port A or B
					ldy		#PiaDDRA
					sty		Pia_DDR						;	contains the correct DDR according to port A or B
					
mnPiadr2:			lda		,x+							;	check the separator
					cmpa	#','
					bra     mnPiadr3
                    
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
mnPiadr3:			lda		,x+							;	check the separator
					cmpa	#'I'
					beq		mnPiadr4

					ldb		#PIA_OUTUTS					;	PINs will be in Output
					bra		mnPiadr5
					
mnPiadr4:			ldb		#PIA_INPUTS					;	PINs will be in Input

					
mnPiadr5:			lda		#$FB						;	clear bit DDR to access to DDR register
					anda	[Pia_CR]
					sta		[Pia_CR]
					
					stb		[Pia_DDR]					;	set Direction register, b contains the good value
					
					
                    lda		#$04						;	Set the DDR bit to enable next access to Data Register
					ora		[Pia_CR]
					sta		[Pia_CR]
					
					ldx		#STRDone
					lbsr	WriteString
                    lbra	Mainloop
					
mnPiadr6:			leax	-1,x
					ldy		#OPTCtrx
					lbsr	CompareString				
					beq		mnPiadr7					;	equal to "CTRX" ?

					ldx		#STRWhat
					lbsr	WriteString
                    lbra	Mainloop

mnPiadr7:			;	Centronics port configuration
					
					;	to do !
					
					ldx		#STRCentronics
					lbsr	WriteString
                    lbra	Mainloop	
;	----------------------------------------------------------------------------------------------------
;	PIA RD Command
mnPiard:			lbsr	SkipSpace					;	skip space from current X	
					lda		,x+							;	check the port
					cmpa	#'A'						;	is port A requested ?
					beq		mnPiard1				

					cmpa	#'B'
					bne		mnPiard3
					
					ldy		#PiaORB
					bra		mnPiard2
					
mnPiard1:			ldy		#PiaORA

mnPiard2:			lda		#'$'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		0,y							;	load A with the content of PIA DDRx
					lbsr	WriteHexByte				;	display A
					
                                            
					lda		#' '						;	separator
					lbsr	PutChar						;	display					
                        
					lda		#'b'						;	symbol for data to display
					lbsr	PutChar						;	display
					lda		0,y							;	reload A with the content of PIA DDRx
					lbsr	WriteBinByte				;	display A
							
					ldx		#STRNewLine
                	lbsr	WriteString
					
					lbra	Mainloop
					
mnPiard3:			ldx		#STRWhat
					lbsr	WriteString
                    lbra	Mainloop					
;	----------------------------------------------------------------------------------------------------
;	PIA WR Command
mnPiawr:			lbsr	SkipSpace					;	skip space from current X				
					lbsr	ReadHexFromString			;	read hexa value to write pointed by X and store it to D
					;stb	save_regB					;	only LSB in B will be used
					
					lda		,x+							;	check the separator
					cmpa	#','
					beq		_mnPiawr2
					
					ldx		#STRSyntErr					;	failed
					lbsr	WriteString					
                	lbra	Mainloop
					
_mnPiawr2:			lbsr	SkipSpace					;	skip space from current X	
					lda		,x+							;	get the correct PIA port A or B to write
					cmpa	#'A'
					beq		_mnPiawr3
				
					cmpa	#'B'
					bne		_mnPiawr5
					
					ldy		#PiaORB
					bra		_mnPiawr4
					
_mnPiawr3:			ldy		#PiaORA

_mnPiawr4:			stb		0,y							;	B already contains the value to write
					
					ldx		#STRDone
					lbsr	WriteString
                    lbra	Mainloop
					
_mnPiawr5:			ldx		#STRWhat
					lbsr	WriteString
                    lbra	Mainloop					
;	----------------------------------------------------------------------------------------------------
;	MEMTEST Command
mnMemTest:			ldx		#STRMemTest
					lbsr	WriteString
					lbsr	MemTest
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	MEMTEST Command
mnClear:			ldx		#STRClear
					lbsr	WriteString
					lbra	Mainloop
;	----------------------------------------------------------------------------------------------------
;	BASIC Command
mnBasic:			ldx		#STRBasic
					lbsr	WriteString
					bra		BASIC									
;	----------------------------------------------------------------------------------------------------
;	----------------------------------------------------------------------------------------------------
;	tinyBasic code

BASIC:				JMP	SETUP
;WARMS				LDS	STKTOP
;	JSR	INTEEE
;	BRA	WMS05
SETUP				;LDS	#RAMEND-52
					lds		RamTop						;	instead use the calculated value from Monitor
					leas	-52,s
SET03				STS		STKTOP
;	JSR	INTEEE
CLEAR				LDD		#RAMBEG
					STD		USRBAS
					STD		USRTOP
CLR02				STD		STKLIM
WMS05				JSR		CRLF
					LDX		#VSTR
					JSR		PUTSTR
CMDB						LDS	STKTOP
					CLR		MODE
					JSR		CRLF
					LDX		USRBAS
					STX		CURSOR
CMDE						LDX	#0000
					STX		LINENB
					TST		MODE
					BNE		CMD01
					LDA		#':'
					JSR		PUTCHR
CMD01				JSR		GETLIN
					JSR		TSTNBR
					BCC		CMD02
					BVS		CMD05
					JSR		SKIPSP
					CMPA	#EOL
					BEQ		CMDE
					JSR		MSLINE
					BRA		CMDB
CMD02				PSHS	X
					LDX		USRTOP
					CMPX		STKLIM
					PULS		X
					BEQ		CMD03
					JMP		ERRORR
CMD03				ADDD		#0
					BEQ		CMD05
CMD04				PSHS		D
					SUBD		#9999
					PULS		D
					BHI		CMD05
					BSR		EDITOR
					BRA		CMDE
CMD05				JMP		ERRORS
VSTR				FCC		"\033ETINY V1.38 MC6809 1977-1984"
					FCB		EOL
;*****************************
;*****************************
EDITOR				PSHS		D
					JSR		SKIPSP
					STX		SCRTCH
					LDA		0,S
					LDX		CURSOR
					CMPX		USRTOP
					BEQ		ED00
					CMPD		0,X
					BCC		ED01
ED00				LDX		USRBAS
ED01				JSR		FNDLIN
					STX		CURSOR
					BCS		ED04
					STX		SAVESP
					LEAX		2,X
ED02				LDA		,X+
					CMPA		#EOL
					BNE		ED02
ED03				CMPX		USRTOP
					BEQ		ED35
					LDA		,X+
					STX		CHAR
					LDX		SAVESP
					STA		,X+
					STX		SAVESP
					LDX		CHAR
					BRA		ED03
ED35				LDX		SAVESP
					STX		USRTOP
					STX		STKLIM
ED04				LDX		SCRTCH
					LDB		#-1
ED05				INCB
					LDA		,X+
					CMPA		#EOL
					BNE		ED05
					TSTB	
					BNE		ED55
					LEAS		2,S
					RTS
ED55				LEAX		-1,X
					ADDB		#4
ED06				LEAX		-1,X
					DECB	
					LDA		0,X
					CMPA		#SPACE
					BEQ		ED06
					LDA		#EOL
					STA		1,X
					CLRA	
					LDX		USRTOP
					STX		CHAR
					ADDD		USRTOP
					STD		USRTOP
					STD		STKLIM
					JSR		TSTSTK
					BCC		ED07
					STX		USRTOP
					STX		STKLIM
					JMP		ERRORF
ED07				LDX		USRTOP
ED08				STX		SAVESP
					LDX		CHAR
					CMPX		CURSOR
					BEQ		ED09
					LDA		,-X
					STX		CHAR
					LDX		SAVESP
					STA		,-X
					BRA		ED08
ED09						PULS	D
					LDX		CURSOR
					STD		,X++
					STX		CHAR
ED10						LDX	SCRTCH
					LDA		,X+
					STX		SCRTCH
					LDX		CHAR
					STA		,X+
					STX		CHAR
					CMPA		#EOL
					BNE		ED10
					RTS
;*****************************
;*****************************
PUTS01				JSR		PUTCHR
					LEAX		1,X
PUTSTR				LDA		0,X
					CMPA		#EOL
					BNE		PUTS01
					RTS
;*****************************
;*****************************
CRLF				LDX		#CRLFST
					BSR		PUTSTR
					CLR		ZONE
					RTS
					
CRLFST				FCB		CR,LF,DEL,FILL,FILL,FILL,EOL
;*****************************
;*****************************
ERRORF				BSR		ER01
					FCC		"SORRY"
					FCB		EOL
ERRORS				BSR		ER01
					FCC		"WHAT ?"
					FCB		EOL
ERRORR				BSR		ER01
					FCC		"HOW ?"
					FCB		EOL
BREAK				BSR		ER01
					FCC		"BREAK"
					FCB		EOL
END					BSR		ER01
					FCC		"STOP"
					FCB		EOL
ER01				BSR		CRLF
					LDA		#BELL
					JSR		PUTCHR
					LDD		LINENB
					JSR		PRNT4
					LDA		#SPACE
					JSR		PUTCHR
					PULS		X
					BSR		PUTSTR
					BSR		CRLF
					JMP		CMDB
;*****************************
;*****************************
GL00				BSR		CRLF
GETLIN				LDX		#BUFFER
GL03				JSR		GETCHR
					CMPA		#SPACE
					BCS		GL05
					CMPA		#$7F
					BEQ		GL03
					CMPX		#BUFFER+BSIZE-1
					BNE		GL04
					LDA		#BELL
					BRA		GL02
GL04				STA		,X+
GL02				JSR		PUTCHR
					BRA		GL03
GL05				CMPA		#BS
					BEQ		GL07
					CMPA		#CAN
					BEQ		GL00
					CMPA		#LF
					BEQ		GL09
					CMPA		#CR
					BNE		GL03
					TST		MODE
					BEQ		GL06
					JSR		PUTCHR
					BRA		GL08
GL06				PSHS		X
					JSR		CRLF
					PULS	X
GL08				LDA		#EOL
					STA		0,X
					LDX		#BUFFER
					RTS
GL07				CMPX		#BUFFER
					BEQ		GL03
					LEAX		-1,X
					LDA		#BS
					JSR		PUTCHR
					LDA		#SPACE
					JSR		PUTCHR
					LDA		#BS
					BRA		GL02
GL09				ORCC		#$01
					ROR		MODE
					BRA		GL02
;*****************************
;*****************************
REM00				LEAX	1,X
REM					BSR		SKIPSP
					CMPA		#EOL
					BNE		REM00
ENDSMT				JSR		TSTEOL
ENDS02				LDA		LINENB
					ORA		LINENB+1
					BEQ		REM09
REM05				CMPX		USRTOP
					BNE		NXTLIN
					JMP		ERRORR
NXTLIN				LDD		,X++
					STD		LINENB
MSLINE				JSR		TSTBRK
					BSR		IFAN
					BCS		IMPLET
					PSHS	D
REM09				RTS
IMPLET				JMP		LET
;*****************************
;*****************************
IFAN				BSR		SKIPSP
					STX		CURSOR
					LDX		#VERBT
FAN00				LDA		,X+
					CMPA		#EOL
					BNE		FAN04
					LDX		CURSOR
					ORCC	#$01
					RTS
FAN04				STX		CHAR
					LDX		CURSOR
					STX		SCRTCH
FAN05				LDX		SCRTCH
					CMPA	0,X
					BNE		FAN07
					LEAX	1,X
					STX		SCRTCH
					LDX		CHAR
					LDA		,X+
					STX		CHAR
					CMPA	#EOL
					BNE		FAN05
					LDD		0,X
					LDX		SCRTCH
					ANDCC	#$FE
					RTS
FAN07				LDX		CHAR
FAN08				LDA		,X+
					CMPA	#EOL
					BNE		FAN08
					LEAX	2,X
					BRA		FAN00
;*****************************
;*****************************
NXTNSP				LEAX	1,X
SKIPSP				LDA		0,X
					CMPA	#SPACE
					BEQ		NXTNSP
					RTS
;*****************************
;*****************************
TSTHEX				BSR		TSTDIG
					BCC		TST05
					CMPA	#'A'
					BCS		TST03
					CMPA	#'F'
					BHI		TST03
					SUBA	#'A'-10
					ANDCC	#$FE
					RTS
;*****************************
;*****************************
TSTLTR				CMPA	#'A'
					BCS		TST03
					CMPA	#'Z'
					BLS		TST05
TST03				ORCC	#$01
					RTS
;*****************************
;*****************************
TSTDIG				CMPA	#'0'
					BCS		TST03
					CMPA	#'9'
					BHI		TST03
					SUBA	#'0'
TST05				ANDCC	#$FE
					RTS
;*****************************
;*****************************
TSTVAR				BSR		SKIPSP
					BSR		TSTLTR
					BCS		TSTV03
					TFR		A,B
					LDA		1,X
					BSR		TSTLTR
					BCC		TST03
					LEAX	1,X
					SUBB	#'A'
					ASLB
					CLRA
					ADDD	STKTOP
TSTV02				ANDCC	#$FE
TSTV03				RTS
;*****************************
;*****************************
USER				JSR		ARGONE
					PSHS	D
					JSR		SKIPSP
					CMPA	#','
					BEQ		USER03
					CMPA	#')'
					ORCC	#$01
					BEQ		USER05
USER02				JMP		ERRORS
USER03				LEAX	1,X
					JSR		EXPR
					PSHS	A
					JSR		SKIPSP
					CMPA	#')'
					PULS	A
					BNE		USER02
					ANDCC	#$FE
USER05				LEAX	1,X
					STX		CURSOR
					JSR		[,S++]
					LDX		CURSOR
					ANDCC	#$FE
					RTS
;*****************************
;*****************************
TSTSNB				JSR		SKIPSP
					CMPA	#'-'
					BNE		TSTNBR
					LEAX	1,X
					BSR		TSTNBR
					BCS		TSN02
					NEGA
					NEGB
					SBCA	#0
					ANDCC	#$FC
TSN02				RTS
;*****************************
;*****************************
TSTNBR				JSR		SKIPSP
					JSR		TSTDIG
					BCC		TSTN02
					CMPA	#'$'
					ORCC	#$01
					BNE		TSTN09
TSTN20				LEAX	1,X
					CLR		,-S
					CLR		,-S
TSTN23				LDA		0,X
					JSR		TSTHEX
					BCS		TSTN07
					LEAX	1,X
					PSHS	X
					PSHS	A
					LDD		3,S
					BITA	#$F0
					BNE		TSTN11
					ASLB
					ROLA
					ASLB
					ROLA
					ASLB
					ROLA
					ASLB
					ROLA
					ADDB	,S+
					STD		2,S
					PULS	X
					BRA		TSTN23
TSTN02				LEAX	1,X
					PSHS	A
					CLR		,-S
TSTN03				LDA		0,X
					JSR		TSTDIG
					BCS		TSTN07
					LEAX	1,X
					PSHS	X
					PSHS	A
					LDD		3,S
					ASLB
					ROLA
					BVS		TSTN11
					ASLB	
					ROLA	
					BVS		TSTN11
					ADDD	3,S
					BVS		TSTN11
					ASLB	
					ROLA	
					BVS		TSTN11
					ADDB	0,S
					ADCA	#0
					BVS		TSTN11
					STD		3,S
					LEAS	1,S
					PULS	X
					BRA		TSTN03
TSTN07				PULS	D
					ANDCC	#$FE
TSTN09				ANDCC	#$FD
					RTS
TSTN11				LDX		1,S
					LEAS	5,S
					ORCC	#$03
					RTS
;*****************************
;*****************************
TSTSTK				STS		SAVESP
					LDD		SAVESP
					SUBD	#STKCUS
					SUBD	STKLIM
					RTS
;*****************************
;*****************************
PEEK				JSR		PAREXP
					PSHS	D
					PSHS	X
					LDB		[2,S]
					PULS	X
					LEAS	2,S
					CLRA
					RTS
;*****************************
;*****************************
POKE				JSR		PAREXP
					PSHS	D
					JSR		SKIPSP
					CMPA	#'='
					BEQ		POKE05
					JMP		ERRORS
POKE05				LEAX	1,X
					JSR		EXPR
					JSR		TSTEOL
					PSHS	X
					STB		[2,S]
					PULS	X
					LEAS	2,S
					JMP		ENDS02
;*****************************
;*****************************
TSTFUN				JSR		SKIPSP
					STX		CURSOR
					LDX		#FUNT
					JSR		FAN00
					BCS		TSTF05
					PSHS	D
TSTF05				RTS
;*****************************
;*****************************
FUNT				FCC		"USR"
					FCB		EOL
					FDB		USER
					FCC		"PEEK"
					FCB		EOL
					FDB		PEEK
					FCC		"MEM"
					FCB		EOL
					FDB		TSTSTK
					FCB		EOL
;*****************************
;*****************************
FLINE				LDX		USRBAS
FNDLIN				CMPX	USRTOP
					BNE		FND03
					ORCC	#$03
					RTS
FND03				CMPD	0,X
					BNE		FND05
					ANDCC	#$FC
					RTS
FND05				BCC		FND07
					ORCC	#$01
					ANDCC	#$FD
					RTS
FND07				PSHS	A
					LDA		#EOL
					LEAX	1,X
FND09				LEAX	1,X
					CMPA	0,X
					BNE		FND09
					PULS	A
					LEAX	1,X
					BRA		FNDLIN
;*****************************
;*****************************
RELEXP				BSR		EXPR
					PSHS	D
					CLRB
					JSR		SKIPSP
					CMPA	#'='
					BEQ		REL06
					CMPA	#'<'
					BNE		REL03
					LEAX	1,X
					INCB
					JSR		SKIPSP
					CMPA	#'>'
					BNE		REL05
					LEAX	1,X
					ADDB	#4
					BRA		REL07
REL03				CMPA	#'>'
					BNE		EXPR06
					LEAX	1,X
					ADDB	#4
					JSR		SKIPSP
REL05				CMPA	#'='
					BNE		REL07
REL06				LEAX	1,X
					ADDB	#2
REL07				PSHS	B
					BSR		EXPR
					PSHS	X
					SUBD	3,S
					TFR		CC,A
					LSRA
					TFR		A,B
					ASLA
					ASLA
					PSHS	B
					ADDA	,S+
					ANDA	#$06
					BNE		REL08
					INCA
REL08				CLRB
					ANDA	2,S
					BEQ		REL09
					COMB
REL09				CLRA
					PULS	X
					LEAS	3,S
					RTS
;*****************************
;*****************************
EXPR				CLR		,-S
					CLR		,-S
					JSR		SKIPSP
					CMPA	#'-'
					BEQ		EXPR05
					CMPA	#'+'
					BNE		EXPR03
EXPR02				LEAX	1,X
EXPR03				BSR		TERM
EXPR04				ADDD	0,S
					STD	0,S
					JSR		SKIPSP
					CMPA	#'+'
					BEQ		EXPR02
					CMPA	#'-'
					BNE		EXPR06
EXPR05				LEAX	1,X
					BSR		TERM
					NEGA
					NEGB
					SBCA	#0
					BRA		EXPR04
EXPR06				PULS	D
					RTS
;*****************************
;*****************************
TERM				JSR		FACT
					PSHS	D
TERM03				JSR		SKIPSP
					CMPA	#'*'
					BEQ		TERM07
					CMPA	#'/'
					BEQ		TERM05
					PULS	D
					RTS
TERM05				LEAX	1,X
					BSR		FACT
					PSHS	X
					LEAX	2,S
					PSHS	D
					EORA	0,X
					JSR		ABSX
					LEAX	0,S
					JSR		ABSX
					PSHS	A
					LDA		#17
					PSHS	A
					CLRA
					CLRB
DIV05				SUBD	2,S
					BCC		DIV07
					ADDD	2,S
					ANDCC	#$FE
					BRA		DIV09
DIV07				ORCC	#$01
DIV09				ROL		7,S
					ROL		6,S
					ROLB
					ROLA
					DEC		0,S
					BNE		DIV05
					LDA		1,S
					LEAS	4,S
					TSTA
					BPL		TERM06
					LEAX	2,S
					BSR		NEGX
TERM06				PULS	X
					BRA		TERM03
TERM07				LEAX	1,X
					BSR		FACT
MULT				PSHS	B
					LDB		2,S
					MUL
					LDA		1,S
					STB		1,S
					LDB		0,S
					MUL
					LDA		2,S
					STB		2,S
					PULS	B
					MUL
					ADDA	0,S
					ADDA	1,S
					STD		0,S
					BRA		TERM03
;*****************************
;*****************************
FACT				JSR		TSTVAR
					BCS		FACT03
					PSHS		X
					TFR		D,X
					LDD		0,X
					PULS	X
FACT02				RTS
FACT03				JSR		TSTNBR
					BCC		FACT02
					JSR		TSTFUN
					BCC		FACT02
PAREXP				BSR		ARGONE
					PSHS	A
					JSR		SKIPSP
					CMPA	#')'
					PULS	A
					BNE		FACT05
					LEAX	1,X
					RTS
FACT05				JMP		ERRORS
;*****************************
;*****************************
ARGONE				JSR		TSTSTK
					BCC		FACT04
					JMP		ERRORF
FACT04				JSR		SKIPSP
					CMPA	#'('
					BNE		FACT05
					LEAX	1,X
					JMP		EXPR
;*****************************
;*****************************
ABSX				TST		0,X
					BPL		NEG05
NEGX				NEG		0,X
					NEG		1,X
					BCC		NEG05
					DEC		0,X
NEG05				RTS
;*****************************
;*****************************
TSTEOL				PSHS	A
					JSR		SKIPSP
					CMPA	#EOL
					BEQ		TEOL03
					JMP		ERRORS
TEOL03				LEAX	1,X
					PULS	A
					RTS
;*****************************
;*****************************
LET					JSR		TSTVAR
					BCC		LET03
					JMP		ERRORS
LET03				PSHS	D
					JSR		SKIPSP
					CMPA	#'='
					BEQ		LET05
					JMP		ERRORS
LET05				LEAX	1,X
					JSR		EXPR
					BSR		TSTEOL
					STX		CURSOR
					PULS	X
					STD		0,X
					LDX		CURSOR
					JMP		ENDS02
;*****************************
;*****************************
IF					JSR		RELEXP
					TSTB	
					BEQ		IF03
					JMP		MSLINE
IF03				JMP		REM
;*****************************
;*****************************
GOTO				JSR		EXPR
					BSR		TSTEOL
					JSR		FLINE
					BCS		GOSB04
					JMP		NXTLIN
;*****************************
;*****************************
GOSUB				JSR		EXPR
					BSR		TSTEOL
					STX		CURSOR
					JSR		FLINE
					BCC		GOSB03
GOSB04				JMP		ERRORR
GOSB03				JSR		TSTSTK
					BCC		GOSB05
					JMP		ERRORF
GOSB05				LDD		CURSOR
					PSHS	D
					LDD	LINENB
					PSHS	D
					JSR	NXTLIN
					PULS	D
					STD	LINENB
					PULS	X
					JMP	ENDS02
;*****************************
;*****************************
RETURN	EQU	TSTEOL
;*****************************
;*****************************
PRINT				JSR	SKIPSP
PR01				CMPA	#','
					BEQ	PR05
					CMPA	#';'
					BEQ	PR07
					CMPA	#EOL
					BEQ	PR04
					CMPA	#'"'
					BNE	PR02
					LEAX	1,X
					BSR	PRNTQS
					BRA	PR03
PR02				JSR	EXPR
					PSHS	X
					BSR	PRNTN
					PULS	X
PR03				JSR	SKIPSP
					CMPA	#','
					BEQ	PR05
					CMPA	#';'
					BEQ	PR07
					CMPA	#EOL
					BEQ	PR04
					JMP	ERRORS
PR04				PSHS	X
					JSR	CRLF
					PULS	X
					BRA	PR08
PR05				LDB	#$7
PR06				LDA	#SPACE
					JSR	PUTCHR
					BITB	ZONE
					BNE	PR06
PR07				LEAX	1,X
					JSR	SKIPSP
					CMPA	#EOL
					BNE	PR01
PR08				LEAX	1,X
					JMP	ENDS02
;
;
PRQ01				JSR	PUTCHR
PRNTQS				LDA	,X+
					CMPA	#EOL
					BNE	PRQ03
					JMP	ERRORS
PRQ03				CMPA	#'"'
					BNE	PRQ01
					RTS
;
PRNTN				TSTA
					BPL	PRN03
					NEGA
					NEGB
					SBCA	#0
					PSHS	A
					LDA	#'-'
					JSR	PUTCHR
					PULS	A
PRN03				LDX	#PRNPT-2
PRN05				LEAX	2,X
					CMPD	0,X
					BCC	PRN07
					CMPX	#PRNPTO
					BNE	PRN05
PRN07				CLR	CHAR
PRN09				CMPD	0,X
					BCS	PRN11
					SUBD	0,X
					INC	CHAR
					BRA	PRN09
PRN11				PSHS	A
					LDA	#'0'
					ADDA	CHAR
					JSR	PUTCHR
					PULS	A
					CMPX	#PRNPTO
					BEQ	PRN13
					LEAX	2,X
					BRA	PRN07
PRN13				RTS
PRNPT				FDB	10000
					FDB	1000
					FDB	100
					FDB	10
PRNPTO				FDB	1
;
PRNT4				LDX	#PRNPT+2
					BRA	PRN07
;*****************************
;*****************************
INPUT				JSR	TSTVAR
					BCS	IN11
					PSHS	D
					STX	CURSOR
IN03				LDA	#'?'
					JSR	PUTCHR
					JSR	GETLIN
IN05				JSR	SKIPSP
					CMPA	#EOL
					BEQ	IN03
					JSR	TSTSNB
					BCC	IN07
					LDX	#RMESS
					JSR	PUTSTR
					JSR	CRLF
					BRA	IN03
IN07				STX	SCRTCH
					PULS	X
					STD	0,X
					LDX	CURSOR
					JSR	SKIPSP
					CMPA	#','
					BEQ	IN09
					JMP	ENDSMT
IN09				LEAX	1,X
					JSR	TSTVAR
					BCC	IN13
IN11				JMP	ERRORS
IN13				PSHS	D
					PSHS	X
					LDX	SCRTCH
					JSR	SKIPSP
					CMPA	#','
					BNE	IN05
					LEAX	1,X
					BRA	IN05
RMESS				FCC	"RE-ENTER"
					FCB	EOL
;*****************************
;*****************************
RUN					LDX	STKTOP
					LDA	#52
RUN01				CLR	,X+
					DECA
					BNE	RUN01
					LDX	USRBAS
					JMP	REM05
;*****************************
;*****************************
LIST				JSR	TSTNBR
					BCC	LIST03
					CLRA
					CLRB
					STD	CURSOR
					LDA	#$7F
					BRA	LIST07
LIST03				STD	CURSOR
					JSR	SKIPSP
					CMPA	#','
					BEQ	LIST05
					LDA	CURSOR
					BRA	LIST07
LIST05				LEAX	1,X
					JSR	TSTNBR
					BCC	LIST07
					JMP	ERRORS
LIST07				JSR	TSTEOL
					PSHS	D
					LDD	CURSOR
					STX	CURSOR
					JSR	FLINE
LIST09				CMPX	USRTOP
					BEQ	LIST10
					PULS	D
					CMPD	0,X
					BCS	LIST11
					PSHS	D
					LDD	,X++
					PSHS	X
					JSR	PRNT4
					PULS	X
					LDA	#SPACE
					JSR	PUTCHR
					JSR	PUTSTR
					LEAX	1,X
					PSHS	X
					JSR	CRLF
					PULS	X
					JSR	TSTBRK
					BRA	LIST09
LIST10				LEAS	2,S
					LDA	#ETX
					JSR	PUTCHR
LIST11				LDX	CURSOR
					JMP	ENDS02
;*****************************
;*****************************
VERBT				FCC	"LET"
					FCB	EOL
					FDB	LET
					FCC	"IF"
					FCB	EOL
					FDB	IF
					FCC	"GOTO"
					FCB	EOL
					FDB	GOTO
					FCC	"GOSUB"
					FCB	EOL
					FDB	GOSUB
					FCC	"RETURN"
					FCB	EOL
					FDB	RETURN
					FCC	"POKE"
					FCB	EOL
					FDB	POKE
					FCC	"PRINT"
					FCB	EOL
					FDB	PRINT
					FCC	"INPUT"
					FCB	EOL
					FDB	INPUT
					FCC	"REM"
					FCB	EOL
					FDB	REM
					FCC	"STOP"
					FCB	EOL
					FDB	END
					FCC	"END"
					FCB	EOL
					FDB	END
					FCC	"RUN"
					FCB	EOL
					FDB	RUN
					FCC	"LIST"
					FCB	EOL
					FDB	LIST
					FCC	"NEW"
					FCB	EOL
					FDB	CLEAR
					FCC	"?"
					FCB	EOL
					FDB	PRINT
					FCB	EOL
;*****************************
;*****************************
TSTBRK				JSR	BRKEEE
					BEQ	GETC05
GETCHR				JSR	INEEE
					CMPA	#ETX
					BNE	GETC05
					JMP	BREAK
GETC05				RTS
PUTCHR				INC	ZONE
					JMP	OUTEEE
;*****************************
;*****************************
INEEE				BSR	BRKEEE
					BEQ	INEEE
					LDA	RECEV
					ANDA	#$7F
					RTS
OUTEEE				PSHS	A
OUT01				LDA	TRCS
					BITA	#TDRE
					BEQ	OUT01
					PULS	A
					STA	TRANS
					RTS
BRKEEE				PSHS	A
BRK03				LDA	TRCS
					BITA	#ORFE
					BEQ	BRK05
					LDA	RECEV
					BRA	BRK03
BRK05				BITA	#RDRF
					PULS	A
					RTS
;	----------------------------------------------------------------------------------------------------
;	----------------------------------------------------------------------------------------------------
;	Write a string on the ACIA/Terminal Console
;	X = address of the string to write

WriteString			pshs	a,x,cc
WSloop:				lda		,x+
					beq		WS_done
					lbsr	PutChar
					bra		WSloop
					
WS_done:			puls	a,x,cc
					rts

;	----------------------------------------------------------------------------------------------------
; Read a string from the ACIA/Terminal Console
; arguments:	X = pointer to string buffer
;				B = maximum character count in B
; returns:		string copied to buffer
; destroys:		A,B

ReadString:			pshs	x					;	save buffer origin

					decb						;	leave room for null char.
					abx							;	save buffer end
					pshs	x
					ldx		RDSTRBUFSTART,s		;	restore buffer origin
					
rl_getchar:			lbsr	GetCharUntil
					cmpa	#NLCHAR				;	return could be CR or LF
					beq		rl_linedone
					
					cmpa	#CRCHAR
					beq		rl_linedone
		
					cmpa	#BACKSPACECHAR		;	handle delete or backspace
					beq		rl_deletechar
		
					cmpa	#DELETECHAR
					beq		rl_deletechar
					
					; lbsr	VALIDATE_ALL		;	validate character
					; bvs		rl_getchar
					
rl_storechar:		cmpx	RDSTRBUFEND,s		;	max amount of characters typed?
					bge		rl_getchar			;	yes, don't store character
					
					lbsr	PutChar				;	echo character
					sta		,x+					;	store char in buffer
					bra		rl_getchar
					
rl_deletechar:		cmpx	RDSTRBUFSTART,s		;	don't delete if at first char
					beq		rl_getchar
		
					lda		#$08
					lbsr	PutChar				;	send delete sequence (\b space \b)
		
					lda		#$20
					lbsr	PutChar
		
					lda		#$08
					lbsr	PutChar
		
					lda		#0					;	overwrite last char with 0
					sta		,-x
					bra		rl_getchar
					
rl_linedone:		lda		#0					;	null-terminate the string
					sta		,x+
					
					leas	2,s					;	throw away end address
					puls	x					;	restore X
					
					rts

;	----------------------------------------------------------------------------------------------------
;	register: X = string where to skip space
;	output: X = next character not equal to SPACE

SkipSpace:			lda		,x
					cmpa	#SPACE
					bne		_SkipSpace
					leax	1,x	
					bra		SkipSpace
					
_SkipSpace:			rts
					
;	----------------------------------------------------------------------------------------------------
;	compare the strings
;	register: X = prompt line string
;	register: Y = reference string
;	CCR.Z = 1 if equal else 0
;	output:	x point to the next character to compare after the recognized sub-string reference
;
;	ex:	X = "READ FFFE"		Y = "READ"

CompareString:		pshs	a,y

_CompareString:		lda		,y+						;	get a character from reference string
					cmpa	#0						;	compare to EOS
					beq		_CMPStringdone			;	YES, end of string
					
					cmpa	,x+						;	compare this ref character with the entered
					bne		_CMPStringfailed		;	different
										
					bra		_CompareString			;	continue
					
_CMPStringfailed:	puls	a,y
					andcc	#$FB					;	clear bit Z					
					rts
					
_CMPStringdone:		puls	a,y
					orcc	#$04					;	set bit Z			
					rts			

;	----------------------------------------------------------------------------------------------------
;	compare the strings
;	register: X = string where to find inside the second
;	register: Y = second string
;	CCR.Z = 1 if equal else 0

StartWithString:	pshs	a,y

_StartWithString:	lda		,x+
					cmpa	,y+
					bne		_StartWithfailed
					
					cmpa	#0                      ;   end if null termintated
					beq		_StartWithdone
                    
                    cmpa	#' '                    ;   end if space
					beq		_StartWithdone
                    
					bra		_StartWithString
				
_StartWithfailed:	puls	a,y
					andcc	#$FB					;	clear bit Z					
					rts
					
_StartWithdone:		puls	a,y
					orcc	#$04					;	set bit Z			
					rts			
					
;	----------------------------------------------------------------------------------------------------
;	Write a byte in hexadecimal on the ACIA/Terminal Console
;	register: A = byte to display
			
WriteHexByte		pshs	cc
					rora
					rora
					rora
					rora
					bsr		PutHexChar
					rora
					rora
					rora
					rora
					rora
					bsr		PutHexChar
					puls	cc
					rts

;	----------------------------------------------------------------------------------------------------
;	Write a byte in hexadecimal on the ACIA/Terminal Console
;	register: A = byte to display

WriteBinByte:		pshs	b,cc
					ldb		#$80
					
_WriteBinByte1:		stb		save_regB
                    pshs    a
					anda	save_regB
					beq		_WriteBinByte2			;	bit = 0
					
					lda		#'1'
					bsr		PutChar
					puls	a
					bra		_WriteBinByte3
					
_WriteBinByte2:     lda		#'0'
					bsr		PutChar
					puls	a

_WriteBinByte3:		lsrb							;	A >> 1		    
					beq		_WriteBinByte			;	A = 0 ?
					bra		_WriteBinByte1
					
_WriteBinByte:		puls	b,cc
					rts
					
;	----------------------------------------------------------------------------------------------------
;	Convert the LSB content of register A to ASCI representation and call PutChar to display it
PutHexChar			pshs	a,cc
					anda	#$0F
					adda	#'0'
					cmpa	#'9'
					ble		_PutHexChar1
					
					adda	#7
_PutHexChar1		bsr		PutChar
					puls	a,cc
					rts

;	----------------------------------------------------------------------------------------------------
; send to the UART the content of register A
PutChar				pshs	a
_PutChar1			lda		Uart
					bita	#$02
					beq		_PutChar1
					puls	a
					sta		UartTDR
					rts

;	----------------------------------------------------------------------------------------------------
; Wait and get from the Uart a new char in register A
GetCharUntil:		lda		Uart
					bita	#$01
					beq		GetCharUntil
					
                    lda		UartRDR                 ;   read the char
                    
                    cmpa    #'a'                    ;   is the char >= 'a' ?
                    bge     _GetCharUntil1          ;   yes
                    bra     GetCharUntilEnd
                        
_GetCharUntil1:     cmpa    #'z'                    ;   is the char <= 'z'
                    ble     _GetCharUntil2          ;   yes
                    bra     GetCharUntilEnd
                    
_GetCharUntil2:     suba    #32                     ;   usbstract 32 to have uppercase
                    
GetCharUntilEnd:	rts

;	----------------------------------------------------------------------------------------------------
; Try to get from the Uart a new char in register A 
;	CCR.Z = 1 if new char

GetChar:			lda		Uart				
					bita	#$01
					beq		GetCharFailed
										
					lda		Uart+1
					orcc	#$04					;	set bit Z	
					rts
					
GetCharFailed:		andcc	#$FB					;	clear bit Z	
					rts

;	----------------------------------------------------------------------------------------------------
;;; read hex digits from the string in X into a 16-bit integer
;;; stops after the first invalid character
;;; arguments:	string pointer in X
;;; returns:	value in D
;;; destroys:	X advanced
ReadHexFromString:	ldd		#$0000
					pshs	d			;	temporary result is on stack
readhexdigit:		ldb		,x+			;	get a character
					cmpb	#'0'		;	is it a decimal digit?
					blo		nothex
					cmpb	#'9'
					bhi		testaf
					subb	#'0'		;	it's a decimal digit
					bra		addhexdigit	;	we're good
testaf:				cmpb	#'A'		;	is it between A and F?
					blo		nothex
					cmpb	#'F'
					bhi		testaflower
					subb	#55
					bra		addhexdigit
testaflower:		cmpb	#'a'
					blo		nothex
					cmpb	#'f'
					bhi		nothex
					subb	#87
addhexdigit:		lsl		1,s		;	multiply temporary by 16
					rol		,s
					lsl		1,s
					rol		,s
					lsl		1,s
					rol		,s
					lsl		1,s
					rol		,s
					orb		1,s			;	or digit into lower nibble
					stb		1,s
					bra		readhexdigit
nothex:				leax	-1,x		;	back up x
					puls	d			;	pop result into D
					andcc	#$FD		;	clear V
					rts

;	----------------------------------------------------------------------------------------------------
;	Memory test


MemTest:			pshs	a,x
					ldx		RamTop
					
MMloop1:			cmpx	#$0000
					beq		MMSuccess
					
					lda  	0,x
					coma                			
					sta  	0,x
					cmpa 	0,x            				
					bne  	MMError        				
										       			
					com  	0,x            				
					leax 	-1,x     
					bra  	MMloop1

MMSuccess:  		ldx		#STRDone
					lbsr	WriteString
					puls	a,x
					rts
					
MMError:  			ldx		#STRFailed
					lbsr	WriteString					
					puls	a,x
					rts
					
;	----------------------------------------------------------------------------------------------------
;	SWI Software Interrupt: Display registers on Console

Vector_swi:			ldx		#system_sw1
					lbsr	WriteString
					

                    ;ldx		#str_cc
					;lbsr	WriteString
					;lda		,s
					;anda	#$7f
					;lbsr	WriteHexByte
			
					;ldx		#str_a
					;lbsr	WriteString
					
					;lda		1,s
					;lbsr	WriteHexByte

					;ldx		#str_b
					;lbsr	WriteString
					
					;lda		2,s
					;lbsr	WriteHexByte

					;ldx		#str_dp
					;lbsr	WriteString
					
					;lda		3,s
					;lbsr	WriteHexByte

					;ldx		#str_x
					;lbsr	WriteString
					
					;lda		4,s					;	MSB byte
					;lbsr	WriteHexByte
					;lda		5,s					;	LSB byte
					;lbsr	WriteHexByte

					;ldx		#str_y
					;lbsr	WriteString
					
					;lda		6,s
					;lbsr	WriteHexByte
					;lda		7,s
					;lbsr	WriteHexByte

					;ldx		#STRNewLine
					;lbsr	WriteString

					rti

;	----------------------------------------------------------------------------------------------------
;	Interrupt handler
Vector_irq:			
					ldx		#system_irq
					lbsr	WriteString
					
					rti
;	----------------------------------------------------------------------------------------------------
;	Interrupt handler
Vector_firq:		
					ldx		#system_firq
					lbsr	WriteString
					
					rti
;	----------------------------------------------------------------------------------------------------
;	Interrupt handler
Vector_nmi:
					ldx		#system_nmi
					lbsr	WriteString
					
					rti
;	----------------------------------------------------------------------------------------------------
;	Interrupt handler
Vector_swi2:		
					ldx		#system_sw2
					lbsr	WriteString
					
					rti
;	----------------------------------------------------------------------------------------------------
;	Interrupt handler
Vector_swi3:		
					ldx		#system_sw3
					lbsr	WriteString
					
					rti
;	----------------------------------------------------------------------------------------------------
;	Interrupt handler reserved for Motorola
Vector_reserved:	
					rti

;	----------------------------------------------------------------------------------------------------
;   remember:
;   \015 = $0D  return
;   \012 = $0A  newline

STRSystemStart		fcc	"\033ERedBoard 6809 Monitor by Favard Laurent 2003/2013\015\012\0"
STRPromptCLI		fcc	"CLI>\0"
STRNewLine			fcc	"\015\012\0"
STRClear            fcc "\033E\0"
STRMemCalculated	fcc	"End of memory: $\0"
STRMemSize			fcc "Size bytes: $\0"
STRSystemReady		fcc	"Ready\015\012\0"
STRVersion			fcc	"Version: \0"
STRAutCartOk		fcc	"Automatic cartridge inserted\015\012\0"
STRAppCartOk		fcc	"Application cartridge inserted\015\012\0"
STRMemTest			fcc "Test running...\015\012\0"
STRList				fcc	"List of applications:\015\012\0"
STRListFailed		fcc	"No applications cartridge\015\012\0"
STRBasic			fcc	"BASIC running\015\012\0"
STRCountApp			fcc	"Count: \0"
;	----------------------------------------------------------------------------------------------------
STRSorry            fcc	"Sorry ?\015\012\0"
STRSyntErr       	fcc	"Syntax error\015\012\0"
STRDone				fcc	"Ok\015\012\0"
STRHow				fcc	"How ?\015\012\0"
STRWhat				fcc	"What ?\015\012\0"
STRFailed			fcc	"Failed\015\012\0"
STRCentronics		fcc	"Centronics: not available\015\012\0"
;	----------------------------------------------------------------------------------------------------
system_irq			fcc	"IRQ !015\012\0"
system_firq			fcc	"FIRQ !\015\012\0"
system_nmi			fcc	"NMI !\015\012\0"
system_sw1			fcc	"SW1 !\015\012\0"
system_sw2			fcc	"SW2 !\015\012\0"
system_sw3			fcc	"SW3 !\015\012\0"
;	----------------------------------------------------------------------------------------------------
STRHelp				fcc "\033E"
                    fcc "[HELP/?] : Commands list\015\012"
                    fcc "[CLS]    : CLear Screen\015\012"
					fcc	"[VER]    : VERsion\015\012"
					fcc	"[MEMSIZE]: Memory size\015\012"
					fcc	"[LIST]   : LIST contents of App Cartridge\015\012"
					fcc "[RUN]    : RUN <AE> Run a program\015\012"
					fcc	"[PEEK]   : READ <AE>\015\012"
					fcc	"[POKE]   : WRITE <byte>,<AE>\015\012"
					fcc	"[DUMP]   : DUMP <byte>,<AE>\015\012"
					fcc	"[COPY]   : COPY <byte>,<SAE>,<DAE>\015\012"
					fcc	"[ORI]    : ORI <mask>,<AE>\015\012"
					fcc	"[ANDI]   : ANDI <mask>,<AE>\015\012"
					fcc	"[BSET]   : BSET [0-7],<AE>\015\012"
					fcc	"[BCLR]   : BCLR [0-7],<AE>\015\012"
					fcc	"[SETPIA] : PIA set A/B,[I/O] or CTRX\015\012"
					fcc	"[RDPIA]  : PIA Read A/B\015\012"
					fcc	"[WRPIA]  : PIA Write <byte>,A/B\015\012"
					fcc	"[SW1/2/3]: SW interrupt\015\012"
					fcc	"[MEMTEST]: MEMory TEST\015\012"
                    fcc	"[BASIC]  : TinyBasic\015\012\0"
;	----------------------------------------------------------------------------------------------------

;str_cc				fcc	" CC:\0"
;str_a				fcc	"  A:\0"
;str_b				fcc	"  B:\0"
;str_dp				fcc	" DP:\0"
;str_x				fcc	"  X:\0"
;str_y				fcc	"  Y:\0"
;	----------------------------------------------------------------------------------------------------
CMDHelp				fcc "?\0"
CMDHelp2			fcc "HELP\0"
CMDVersion			fcc "VER\0"
CMDMemSize			fcc	"MEMSIZE\0"
CMDClear			fcc "CLS\0"
CMDList				fcc "LIST\0"
CMDRun				fcc "RUN\0"
CMDRead				fcc "PEEK\0"
CMDWrite			fcc "POKE\0"
CMDSw1				fcc "SW1\0"
CMDSw2				fcc "SW2\0"
CMDSw3				fcc "SW3\0"
CMDOri				fcc "ORI\0"
CMDAndi				fcc "ANDI\0"
CMDBset				fcc "BSET\0"
CMDBclr				fcc "BCLR\0"
CMDDump				fcc "DUMP\0"
CMDCopy				fcc "COPY\0"
CMDPIADR			fcc	"SETPIA\0"
CMDPIARD			fcc	"RDPIA\0"
CMDPIAWR			fcc	"WRPIA\0"
CMDMemTest			fcc "MEMTEST\0"
CMDBasic			fcc "BASIC\0"
;	----------------------------------------------------------------------------------------------------
OPTCtrx				fcc	"CTRX\0"		
;	----------------------------------------------------------------------------------------------------

;	Jmp table for CLI commands
DispatchCommands	fdb 	CMDHelp
					fdb		mnHelp
					fdb 	CMDHelp2
					fdb		mnHelp
					fdb 	CMDVersion
					fdb		mnVersion
					fdb		CMDMemSize
					fdb		mnMemSize
					fdb 	CMDClear
					fdb		mnClear
					fdb		CMDList
					fdb		mnList
					fdb		CMDRun
					fdb		mnRun
					fdb 	CMDRead
					fdb		mnRead
					fdb 	CMDWrite
					fdb		mnWrite
					fdb 	CMDSw1
					fdb		mnSw1
					fdb 	CMDSw2
					fdb		mnSw2
					fdb 	CMDSw3
					fdb		mnSw3
					fdb 	CMDOri
					fdb		mnOri
					fdb 	CMDAndi
					fdb		mnAndi
					fdb 	CMDBset
					fdb		mnBset
					fdb 	CMDBclr
					fdb		mnBclr
					fdb 	CMDDump
					fdb		mnDump
					fdb 	CMDCopy
					fdb		mnCopy
					fdb		CMDPIADR
					fdb		mnPiadr
					fdb		CMDPIARD
					fdb		mnPiard
					fdb		CMDPIAWR
					fdb		mnPiawr
					fdb 	CMDMemTest
					fdb		mnMemTest
					fdb 	CMDBasic
					fdb		mnBasic
					fdb		$0000						;	end of table
                    
;	----------------------------------------------------------------------------------------------------
;	Monitor functions table exported
FunctionsTable		fdb		PutChar
					fdb		PutHexChar
					fdb		GetChar
					fdb		GetCharUntil
					fdb		WriteHexByte
					fdb		WriteBinByte
					fdb		WriteString
					fdb		ReadString
					fdb		ReadHexFromString
					fdb		$0000						;	end of table
                    
;	----------------------------------------------------------------------------------------------------
;   Jmp table to vectors stored in RAM, excepted RESET

JmpSwi3:            jmp    [Swi3Vector]
JmpSwi2:            jmp    [Swi2Vector]
JmpFirq:            jmp    [FirqVector]
JmpIrq:             jmp    [IrqVector]
JmpSwi:             jmp    [SwiVector]
JmpNmi:             jmp    [NmiVector]

;	----------------------------------------------------------------------------------------------------
;	System vector specification
					
					spaceto ROMVectors				; special LFD directive: fill from last PC = * to here 
					org	ROMVectors
Vectors:			
					fdb	Vector_reserved		
					fdb	JmpSwi3
					fdb	JmpSwi2
					fdb	JmpIrq
					fdb	JmpIrq
					fdb	JmpSwi
					fdb	JmpNmi
					fdb	RomStart            

					end

;	----------------------------------------------------------------------------------------------------
;
;	Global Memory Map (RedBoard 6809)
;
;	+---------------+
;	|               | $FFFF 
;	| Boot          |		8 Kb
;	| ROM           | $E000
;	+---------------+ 
;	|               | $DFFF
;	|  IO devices   |		4 kb
;	|...............|
;	|  PIA 6821     | $D004 - $D007 (4 registers)
;	|...............|
;	|  ACIA 6850    | $D000 - $D001 (2 registers)
;	+---------------+ 
;	|               | $CFFF
;	|               |		4 kb
;	|               | $C000
;	+---------------+ 
;	|               | $BFFF
;	|               |
;	|               |		16 kB
;	|               |
;	|               | $8000
;	+---------------+
;	| Ram Monitor   | $7FFF
;	|...............|
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	|               |
;	| User          |		32 Kb
;	| RAM           |
;	|               |
;	|...............|
;	| Ram Monitor   |
;	+---------------+ $0000 
;
;
;
;
;
