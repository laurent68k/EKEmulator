//
//  EK6502Processor.h
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "EKCoreProcessor.h"

@interface EK6502Processor : EKCoreProcessor {

	@protected

		// egisters that we assume all CPUs have
		//UInt16			ir;
		//UInt16			pc;
}

//@property(nonatomic,retain,readwrite)	NSString *name;

-(id)				initWithDelegate:(id)theDelegate;

-(void)				reset;
-(void)				run;
-(void)				runStep;

@end
