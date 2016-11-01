//
//  EK6530.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "EKCircuit.h"

@protocol EK6850Protocol <NSObject>

@required

	-(void) ReceiveData6850:(id)acia6850;
	-(void) TransmitData6850:(id)acia6850;
	
@end

#define	BIT_IRQ		7
#define	BIT_TDRE	1
#define	BIT_RDRF	0

#define BIT_RIE		7
#define	BIT_CD1 	1
#define	BIT_CD0		0

@interface EK6850 : EKCircuit {

	@protected
			
		id <EK6850Protocol>	delegate;
		
        NSString                *irq;
    
		//	RIE TC1 TC0 WS2 WS1 WS0 CD1 CD0
		//	where: 	RIE: Receiver interrupt enable
		//			TC : Transmitter control
		//			WS : Word select
		//			CD : Counter divisionRSR
		UInt8					regCR;
		
		//	IRQ	PE OVRN FE !CTS !DCD TDRE RDRF
		UInt8					regSR;
    
        UInt8                   regRDR;             //  Receive data register
        UInt8                   regTRD;             //  Transmit data register
		
		bool					flagRDRFull;		//	Indicate that the ReceiveData6850 success
}       

@property(readwrite) UInt8	regRDR;
@property(readwrite) UInt8	regTRD;
@property(readwrite) bool 	flagRDRFull;

-(id)				initWithDelegate:(UInt16)aBaseAddress delegate:(id)theDelegate irq:(NSString *)theIRQ;

-(UInt8) 			read:(UInt16) address;
-(bool)		 		write:(UInt16) address data:(UInt8) data;

@end
