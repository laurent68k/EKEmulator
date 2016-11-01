//
//  EKCoreProcessor.m
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKCoreProcessor.h"
#import "EKInterrupts.h"

@implementation EKCoreProcessor


//---------------------------------------------------------------------------
- (id) initWithDelegate:(id)theDelegate {  
  
    if (self = [super init]) {
    
		self->delegate = theDelegate;
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------
// 	Core Processor
//----------------------------------------------------------------------------

-(void) reset {

}
//----------------------------------------------------------------------------
-(void) run {

}
//----------------------------------------------------------------------------
-(void) runStep {

}
//----------------------------------------------------------------------------
-(void) sendIRQs:(EKInterrupts *)interrupts {


}
//----------------------------------------------------------------------------
-(void) displayRegisters {
    
}
//----------------------------------------------------------------------------


@end
