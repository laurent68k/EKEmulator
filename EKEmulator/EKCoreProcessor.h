//
//  EKCoreProcessor.h
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "EKCircuit.h"
#import "EKInterrupts.h"

@protocol EKCoreProcessorProtocol <NSObject>

	@required

	-(UInt8)    read:(UInt16) address;
	-(void)     write:(UInt16) address data:(UInt8) data;
	-(void)     displayCPU:(id)coreProcessor;
	
@end


@interface EKCoreProcessor : EKCircuit {

	@protected

		id <EKCoreProcessorProtocol>	delegate;
}


-(id)				initWithDelegate:(id)theDelegate;

-(void)				reset;
-(void)				run;
-(void)				runStep;
-(void)				sendIRQs:(EKInterrupts *)interrupts;
-(void)				displayRegisters;

@end
