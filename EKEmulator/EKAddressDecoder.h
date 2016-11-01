//
//  EKCircuit.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "EKCircuit.h"
#import "EKInterrupts.h"

#define	SZMEMORY			0x10000			//	from 0x0000 to 0xFFFF

@interface EKAddressDecoder : EKCircuit {

	@protected
	
        NSMutableArray  *arrayOfCircuits;
		EKCircuit*		memoryMap[SZMEMORY];
		EKInterrupts*	collectedInterrupts;
		
}

-(id)				init;
-(void) 			addCircuit:(EKCircuit *) circuit;

-(UInt8) 			read:(UInt16) address;
-(bool)		 		write:(UInt16) address data:(UInt8) data;

-(void) 			reset;
-(void)				runStep;

-(EKInterrupts *) 	collectIRQs;

@end
