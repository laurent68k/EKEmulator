//
//  Computer6809-1.h
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "EKCoreProcessor.h"
#import "EKAddressDecoder.h"
#import "EKRam8bits.h"
#import "EK6850.h"
#import "EK6821.h"

@interface Computer6809 : NSObject <EKCoreProcessorProtocol,EK6850Protocol>{

	@protected

        id                  delegate;
		EKCoreProcessor		*microProcessor;
		EKAddressDecoder	*addressDecoder;
        EKRam8bits 			*ramCircuit;
		
		UInt16				breakPointAddress;
		bool				breakPointActive;
		
		bool				systemHalt;
}

@property(readwrite) bool	systemHalt;

-(id)               initWithDelegate:(id)theDelegate;
-(void)				threadExecuteComputer;

-(void)				resetComputer;
-(void)				runComputer;
-(void)				runStep;
-(void)				haltComputer;

-(UInt8*)			ramContent;

-(void)				setBreakPoint:(UInt16) addressToStop;
-(void)				cancelBreakPoint;

@end
