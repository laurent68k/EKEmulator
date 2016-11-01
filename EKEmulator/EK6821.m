//
//  EK6821.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EK6821.h"

@implementation EK6821

@synthesize		regORA;
@synthesize		regORB;
@synthesize		portA;
@synthesize		portB;

//---------------------------------------------------------------------------
-(id) initWithDelegate:(UInt16)aBaseAddress delegate:(id)theDelegate irq:(NSString *)theIRQ {
  
	self = [super initWithSize:aBaseAddress size:4];
    if( self != nil ) {
    		
		self->delegate = theDelegate;
		self->irq = theIRQ;
		
		[self->irq retain];
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

-(void) setOutputBits:(UInt8 *)registre direction:(UInt8)direction data:(UInt8) data {

    UInt8 bitNumber = 1;
    
    for(int index = 1; index <= 8; index++ ) {
        
        UInt8 complement = ~bitNumber;
        if( (direction & bitNumber) >= BIT_ASOUTPUT ) {
            
            *registre = ((data & bitNumber) >= 1 ) ? bitNumber | *registre : complement & *registre;
        }
        bitNumber <<= 1;
    }
}
//----------------------------------------------------------------------------
-(void) setInputBits:(UInt8 *)registre direction:(UInt8)direction data:(UInt8) data {

    UInt8 bitNumber = 1;
    
    for(int index = 1; index <= 8; index++ ) {
        
        UInt8 complement = ~bitNumber;
        if( (direction & bitNumber) == BIT_ASINPUT ) {
            
            *registre = ((data & bitNumber) >= 1 ) ? bitNumber | *registre : complement & *registre;
        }
        bitNumber <<= 1;
    }
}
//----------------------------------------------------------------------------
-(UInt8) read:(UInt16) address {

	UInt8	value = 0xFF;
	
	if( address - self->baseAddress < self->size ) {
	
		//	register + 3: CRB
		if( (address & 0x0003) == 0x0003 ) {
		
			value = self->regCRB;
		}
		//	register + 2: DDRB or ORB
		else if ( (address & 0x0002) == 0x0002 ) {
		
			//	if DDR access = 1 => ORB
			if( self->regCRB & BIT_DDR_ACCESS ) {

				[self->delegate ReadPIA6821B: self];
				[self setInputBits:&self->regORB direction:self->regDDRB data:self->portB];
				
				value = self->regORB;
			}
			//	DDRB
			else {
			
				value= self->regDDRB;
			}
		}
		//	register + 1: CRA
		else if( address & 0x0001 ) {
		
			value = self->regCRA;
		}
		//	register + 0: DDRA or ORA
		else {
		
			//	if DDR access = 1 => ORA
			if( self->regCRA & BIT_DDR_ACCESS ) {
			
				[self->delegate ReadPIA6821A: self];
				[self setInputBits:&self->regORA direction:self->regDDRA data:self->portA];

				value = self->regORA;
			}
			//	DDRA
			else {
			
				value = self->regDDRA;
			}
		}

		return value;
	}
	return value;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	if( address - self->baseAddress < self->size ) {
	
		//	register + 3: CRB
		if( (address & 0x0003) == 0x0003 ) {
		
			self->regCRB = data;
		}
		//	register + 2: DDRB or PRB
		else if ( (address & 0x0002) == 0x0002 ) {
		
			//	if DDR access = 1 => ORB
			if( self->regCRB & BIT_DDR_ACCESS ) {

				[self setOutputBits:&self->regORB direction:self->regDDRB data:data];
				[self->delegate WritePIA6821B:self];
			}
			//	DDRB
			else {

				self->regDDRB = data;
			}
		}
		//	register + 1: CRA
		else if( address & 0x0001 ) {
		
			self->regCRA = data;
		}
		//	register + 0: DDRA or PRA
		else {
		
			//	if DDR access = 1 => ORA
			if( self->regCRA & BIT_DDR_ACCESS ) {

				[self setOutputBits:&self->regORA direction:self->regDDRA data:data];
				[self->delegate WritePIA6821A:self];
			}
			//	DDRA
			else {
			
				self->regDDRA = data;
			}
		}

		return true;
	}
	return false;
}
//---------------------------------------------------------------------------
-(void)	runStep {

	//  Nothing to do for a 6821 at any execution cycle
}
//---------------------------------------------------------------------------
-(void)	reset {

	self->regCRA = 0x00;
	self->regCRB = 0x00;
	self->regDDRA = 0x00;		//	all pins are input
	self->regDDRB = 0x00;		//	all pins are input
	
}
//---------------------------------------------------------------------------
-(bool)	isIRQRaised {

	return false;
}
//---------------------------------------------------------------------------
-(NSString *) getKindIRQ {

	return self->irq;
}
//---------------------------------------------------------------------------

@end

/*

	

 */
 