//
//  EKInterrupts.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKInterrupts.h"

@implementation EKInterrupts

//---------------------------------------------------------------------------
-(id) init {
  
	self = [super init];
    if( self != nil ) {
	
		self->irqs = [[NSMutableArray alloc] init];
    
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

	[self->irqs removeAllObjects];
	[self->irqs release];
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(void) clearIRQs {

	[self->irqs removeAllObjects];
}
//----------------------------------------------------------------------------
-(bool) isSignaled:(NSString *)interruptName {

	bool	ret = false;
	for(int index = 0; index < self->irqs.count; index++) {
        
        NSString   *irqName = (NSString *)[self->irqs objectAtIndex:index];
		if( [irqName isEqualToString:interruptName] ) {
		
			ret	= true;
			break;
		}
    }
	return ret;
}
//----------------------------------------------------------------------------
-(void) signal:(NSString *)interruptName {

	[self->irqs addObject:interruptName];
}
//----------------------------------------------------------------------------

@end
