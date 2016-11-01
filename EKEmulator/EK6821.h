//
//  EK6821.h
//
//  Created by Laurent on 21/09/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "EKCircuit.h"

@protocol EK6821Protocol <NSObject>
			 
@required

	-(bool) ReadPIA6821A:(id) data;
	-(bool) ReadPIA6821B:(id) data;
	-(void) WritePIA6821A:(id) data;
	-(void) WritePIA6821B:(id) data;
	
@end


#define		BIT_ASINPUT		0
#define		BIT_ASOUTPUT	1

#define		BIT_DDR_ACCESS	0x04

@interface EK6821 : EKCircuit {

	@protected
			
		id <EK6821Protocol>	delegate;
		
        NSString                *irq;

		UInt8					regSR;
    
        UInt8                   regCRA;
        UInt8                   regDDRA;             
        UInt8                   regORA;             
		
        UInt8                   regCRB;             
        UInt8                   regDDRB;             
        UInt8                   regORB;      

		UInt8					portA;
		UInt8					portB;
}       

@property(readonly) UInt8	regORA;
@property(readonly) UInt8	regORB;
@property(readwrite) UInt8	portA;
@property(readwrite) UInt8	portB;

-(id)				initWithDelegate:(UInt16)aBaseAddress delegate:(id)theDelegate irq:(NSString *)theIRQ;

-(UInt8) 			read:(UInt16) address;
-(bool)		 		write:(UInt16) address data:(UInt8) data;

@end
