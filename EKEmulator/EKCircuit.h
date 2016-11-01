//
//  EKCircuit.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"

@interface EKCircuit : NSObject {

	@protected
	
		UInt16		size;
		UInt16		baseAddress;
		
}

@property(nonatomic,readonly)	UInt16		size;
@property(nonatomic,readonly)	UInt16	baseAddress;

//	Methods in C style
bool                btst(UInt8 x, UInt8 n);
void                bset(UInt8 *x, UInt8 n);
void                bclr(UInt8 *x, UInt8 n);

bool 				btst16(UInt16 x, int n);
bool 				btst32(UInt32 x, int n);

//  Methods Objec-C

-(id)				initWithSize:(UInt16)aBaseAddress size:(UInt16) aSize;

-(UInt8) 			read:(UInt16) address;
-(bool)		 		write:(UInt16) address data:(UInt8) data;

-(void) 			reset;
-(void)				runStep;
-(bool)				isIRQRaised;
-(NSString *)		getKindIRQ;

@end
