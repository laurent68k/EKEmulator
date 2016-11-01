//
//  EKCircuit.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKCircuit.h"

@implementation EKCircuit

@synthesize size;
@synthesize baseAddress;

//---------------------------------------------------------------------------
-(id) initWithSize:(UInt16)aBaseAddress size:(UInt16) aSize {
  
	self = [super init];
    if( self != nil ) {
    
		self->baseAddress = aBaseAddress;
		self->size = aSize;
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

//  8 bit operations
bool btst(UInt8 x, UInt8 n) {

	return (x & (1 << n)) ? true : false;
}

void bset(UInt8 *x, UInt8 n) {

	*x |= (1 << n);
}

void bclr(UInt8 *x, UInt8 n) {

	*x &= ~(1 << n);
}
// 16 bit operations
bool btst16(UInt16 x, int n)
{
	return (x & (1 << n)) ? true : false;
}

void bset16(UInt16 * x, int n)
{
	*x |= (1 << n);
}

void bclr16(UInt16 * x, int n)
{
	*x &= ~(1 << n);
}

// 32 bit operations
bool btst32(UInt32 x, int n)
{
	return (x & (1L << n)) ? true : false;
}

void bset32(UInt32* x, int n)
{
	*x |= (1L << n);
}

void bclr32(UInt32* x, int n)
{
	*x &= ~(1L << n);
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(UInt8) read:(UInt16) address {

	return	0xFF;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	return	false;
}
//---------------------------------------------------------------------------
-(void)	reset {

}
//---------------------------------------------------------------------------
-(void)	runStep {

}
//---------------------------------------------------------------------------
-(bool)	isIRQRaised {

	return false;
}
//---------------------------------------------------------------------------
-(NSString *) getKindIRQ {

	return nil;
}
//---------------------------------------------------------------------------


@end
