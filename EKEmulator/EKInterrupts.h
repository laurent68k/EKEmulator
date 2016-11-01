//
//  EKInterrupts.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"

@interface EKInterrupts : NSObject {

	@protected
	
		NSMutableArray	*irqs;
}

-(id)				init;
-(void) 			clearIRQs;
-(bool)				isSignaled:(NSString *)interrupt;
-(void)				signal:(NSString *)interrupt;

@end
