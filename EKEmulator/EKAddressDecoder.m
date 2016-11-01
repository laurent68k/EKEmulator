//
//  EKCircuit.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKAddressDecoder.h"

@implementation EKAddressDecoder

//---------------------------------------------------------------------------
-(id) init {
  
	self = [super initWithSize:0 size:0];			//	Address decoder doesn't have any registers and base address
    if( self != nil ) {
    
        arrayOfCircuits = [[NSMutableArray alloc] init];
		for( UInt32 index = 0; index < SZMEMORY; index++ ) {
	
			self->memoryMap[index] = nil;
		}
		self->collectedInterrupts = [[EKInterrupts alloc] init];
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {
	
    [self->collectedInterrupts release];
    [arrayOfCircuits removeAllObjects];
    [arrayOfCircuits release];
    
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(void) addCircuit:(EKCircuit *) circuit {

    //  add the new device to the devices list for the release terminate
    [arrayOfCircuits addObject:circuit];
    
    for( UInt16 index = 0; index < circuit.size; index++ ) {
	
		self->memoryMap[circuit.baseAddress + index] = circuit;
        //NSLog(@"$%04X", circuit.baseAddress + index);
    }
}
//---------------------------------------------------------------------------
-(UInt8) read:(UInt16) address {

	EKCircuit *circuit = self->memoryMap[ address ];
	if( circuit != nil ) {
	
		return [circuit read:address];
	}
	return 0xFF;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	EKCircuit *circuit = self->memoryMap[ address ];
	if( circuit != nil ) {

		return [circuit write:address data:data];
	}
	return false;	
}
//---------------------------------------------------------------------------
/*
	Run for each devices a execution cycle
 */
-(void) runStep {

	for(int index = 0; index < arrayOfCircuits.count; index++) {
        
        EKCircuit   *circuit = (EKCircuit *)[arrayOfCircuits objectAtIndex:index];
        [circuit runStep];
    }
}
//---------------------------------------------------------------------------
/*
	Perform a reset on all devices
 */
-(void) reset {

	for(int index = 0; index < arrayOfCircuits.count; index++) {
        
        EKCircuit   *circuit = (EKCircuit *)[arrayOfCircuits objectAtIndex:index];
        [circuit reset];
    }
}
//---------------------------------------------------------------------------
-(EKInterrupts *) collectIRQs {
	
	bool irqRaised = false;
    EKInterrupts*   collected = nil;
    
    [self->collectedInterrupts clearIRQs];
	for(int index = 0; index < arrayOfCircuits.count && !irqRaised; index++) {
        
        EKCircuit   *circuit = (EKCircuit *)[arrayOfCircuits objectAtIndex:index];
        irqRaised = [circuit isIRQRaised];
		
        if( irqRaised) {
            
            [self->collectedInterrupts signal:[circuit getKindIRQ]];
            collected = self->collectedInterrupts;
        }
    }
	
	return collected;
}
//---------------------------------------------------------------------------

@end
