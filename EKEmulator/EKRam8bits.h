//
//  EKRom8bits.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "EKCircuit.h"

@interface EKRam8bits : EKCircuit {

	@protected
			
		UInt8	*ramContent;
		
}

@property(readwrite) UInt8*	ramContent;

-(id)				initWithSize:(UInt16)aBaseAddress size:(UInt16) aSize;

-(UInt8) 			read:(UInt16) address;
-(bool)		 		write:(UInt16) address data:(UInt8) data;

@end
