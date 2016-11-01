//
//  EK6502Processor.m
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EK6502Processor.h"

@implementation EK6502Processor

//---------------------------------------------------------------------------
- (id) initWithDelegate:(id)theDelegate {  
  
    if (self = [super initWithDelegate:theDelegate]) {
    		
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------
// 	Core Processor Virtual Methods
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



@end
