//
//  EKRom8bits.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKRam8bits.h"

@implementation EKRam8bits

@synthesize	ramContent;

//---------------------------------------------------------------------------
-(id) initWithSize:(UInt16)aBaseAddress size:(UInt16) aSize {
  
	self = [super initWithSize:aBaseAddress size:aSize];
    if( self != nil ) {
    		
		self->ramContent = malloc( aSize );
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

	FREENULL(self->ramContent);
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

//---------------------------------------------------------------------------
-(UInt8) read:(UInt16) address {

	UInt8	value = 0xFF;
	
	if( address - self->baseAddress < self->size ) {
	
		value = self->ramContent[address - self->baseAddress ];
	}
	return value;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	if( address - self->baseAddress < self->size ) {
	
		self->ramContent[address - self->baseAddress ] = data;
		return true;
	}
	return false;
}
//---------------------------------------------------------------------------

@end
