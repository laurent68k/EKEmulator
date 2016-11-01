//
//  EK6530.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EK6850.h"

@implementation EK6850

@synthesize		regRDR;
@synthesize		regTRD;
@synthesize		flagRDRFull;

//---------------------------------------------------------------------------
-(id) initWithDelegate:(UInt16)aBaseAddress delegate:(id)theDelegate irq:(NSString *)theIRQ {
  
	self = [super initWithSize:aBaseAddress size:2];
    if( self != nil ) {
    		
		self->delegate = theDelegate;
		self->irq = theIRQ;
		
		[self->irq retain];
		
		self->flagRDRFull = false;
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

	[self->irq release];
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

//---------------------------------------------------------------------------
-(UInt8) read:(UInt16) address {

	UInt8	value = 0xFF;
	
	if( address - self->baseAddress < self->size ) {
	
		//	assume that RS is mapped to A0
		//	register + 1: Receive Data register
		if( address & 0x0001 ) {
		
			bclr(&self->regSR, BIT_RDRF);		// Clear RDRF
			bclr(&self->regSR, BIT_IRQ);		// Clear IRQ
            
            value = self->regRDR;
            //self->regRDR = 0;                   // fixme pas tres propre
		}
		//	register + 0: Status register
		else {
		
			value = self->regSR;
		}
	}
	return value;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	if( address - self->baseAddress < self->size ) {
	
		//	register + 1: Transmit Data register
		if( address & 0x0001 ) {
		
			bclr(&self->regSR, BIT_IRQ);			// Clear IRQ
			bset(&self->regSR, BIT_TDRE);			// Set TDRE to 1 = register isn't empty
		
			self->regTRD = data;
			[self->delegate TransmitData6850:self];
			
		}
		//	register + 0: Ctrl register
		else {
		
			self->regCR = data;

			// Check for master reset
			if (btst(self->regCR, BIT_CD1) && btst(self->regCR, BIT_CD0)) {
			
				[self reset];
			}
		}

		return true;
	}
	return false;
}
//---------------------------------------------------------------------------
/*
	Execute one execution cycle for this device, eg: Try to get a new character
	and try to send a character if any.
 */
-(void)	runStep {

	[self->delegate ReceiveData6850: self];
	if( self->flagRDRFull ) {
		
		// Check for IRQ
		if (btst(self->regCR, BIT_RIE)) {			// If interrupt enable
			bset(&self->regSR, BIT_IRQ);			// Set IRQ
		}

		bset(&self->regSR, BIT_RDRF);				// Set RDRF
	}
}
//---------------------------------------------------------------------------
-(void)	reset {

	self->regSR = 0;
	self->regCR = 0;
	
	bset(&self->regSR, BIT_TDRE);	// Set bit TDRE = data register empty
}
//---------------------------------------------------------------------------
-(bool)	isIRQRaised {

	return btst(self->regSR, BIT_IRQ);
}
//---------------------------------------------------------------------------
-(NSString *) getKindIRQ {

	return self->irq;
}
//---------------------------------------------------------------------------

@end

/*

STATUS REGISTER

7	6	5		4	3	2		1		0
IRQ	PE	OVRN	FE!	CTS	!DCD	TDRE	RDRF

IRQ –Interrupt request
set whenever the ACIA wishes to interrupt CPU:
	–Received data register full (SR bit 0 set)
	–Transmitter data register empty (SR bit 1 set)
!DCD bit set (SR bit 2)

PE –Parity error
set when the parity bit received does not match the parity bit generated locally for the received data

OVRN –Receiver Overrun•set when data is received by the ACIA and not read by the CPU when new data is received over
	-writing old data
	it indicates that data has been lost
	
FE –Framing error
set when received data is incorrectly framed by the start and stop bits

!CTS –Clear to send•directly indicates the status of the ACIA’s

!CTS input

!DCD –Data Carrier Detect•set when the ACIA’s!DCD input is high
	reset when the CPU reads both the status register and the data register or when ACIA is master reset
	
TDRE -Transmitter data register empty
set when the transmitter data register is empty, indicating that data has been sent
	reset when transmitter data register is full or when !CTS is high, indicating that the peripheral is not ready
	
	RDRF –Receiver data register full•set when the receiver data register is full, indicating that data has been received
	reset when the data has been read from the data register
	

 */
 