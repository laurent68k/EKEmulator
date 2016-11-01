//
//  Computer6809-1.m
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKRom8bits.h"
#import "EKRam8bits.h"
#import "EK6809Processor.h"

#import "Computer6809.h"

@implementation Computer6809

@synthesize	systemHalt;

//---------------------------------------------------------------------------
//  Memory map in accordance to Laurent SBC 6809 "RedBoard"
#define RAMSTART    0x0000
#define RAMSIZE     0x8000      //  32Kb
#define ACIA        0xD000		//	only 2 registers
#define PIA         0xD004		//	only 4 registers 
#define ROMSTART    0xE000
#define ROMSIZE     0x2000      //  8 Kb
//---------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {  
  
    if (self = [super init]) {
    
        self->delegate = theDelegate;
        
        self->addressDecoder = [[EKAddressDecoder alloc] init];
        
        
        self->ramCircuit = [[EKRam8bits alloc] initWithSize:RAMSTART size:RAMSIZE];
        [self->addressDecoder addCircuit: self->ramCircuit];
        
        [self->addressDecoder addCircuit: [[[EK6850 alloc] 		initWithDelegate:ACIA delegate:self irq:@"IRQ"] autorelease]];
        [self->addressDecoder addCircuit: [[[EK6821 alloc] 		initWithDelegate:PIA delegate:self irq:@"IRQ"] autorelease]];

        [self->addressDecoder addCircuit: [[[EKRom8bits alloc] 	initWithSizeAndContent:ROMSTART size:ROMSIZE content:@"EK6809Monitor"] autorelease]];
        
        [self->addressDecoder addCircuit: [[[EKRom8bits alloc] 	initWithSizeAndContent:0x8000 size:16384 content:@"EKApp0001"] autorelease]];
        //[self->addressDecoder addCircuit: [[[EKRom8bits alloc] 	initWithSizeAndContent:0x8000 size:16384 content:@"ExBasRom"] autorelease]];
        
        self->microProcessor = [[EK6809Processor alloc] initWithDelegate: self];

		//	execution thread
		self->systemHalt = false;
    }
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

	[self->ramCircuit release];
	[self->addressDecoder release];
	[self->microProcessor release];
	
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	Protocol <EKCoreProcessorProtocol> implementation
//----------------------------------------------------------------------------

-(UInt8) read:(UInt16) address {
	
	return [self->addressDecoder read:address];
}
//---------------------------------------------------------------------------
-(void) write:(UInt16) address data:(UInt8) data {

	[self->addressDecoder write:address data:data];
}
//---------------------------------------------------------------------------
-(void) displayCPU:(id)coreProcessor {

    if( [self->delegate respondsToSelector:@selector(displayCPU:)] ) {
		
        [self->delegate performSelectorOnMainThread:@selector(displayCPU:) withObject:coreProcessor waitUntilDone:YES];
    }
}

//----------------------------------------------------------------------------
// 	Protocol <EK6850Protocol> implementation
//----------------------------------------------------------------------------

-(void) ReceiveData6850:(id)acia6850 {
	
	if( [self->delegate respondsToSelector:@selector(ReceiveData6850:)] ) {
			
		[self->delegate performSelectorOnMainThread:@selector(ReceiveData6850:) withObject:acia6850 waitUntilDone:YES];
	}
}
//---------------------------------------------------------------------------
-(void) TransmitData6850:(id)acia6850 {

	if( [self->delegate respondsToSelector:@selector(TransmitData6850:)] ) {
	
		[self->delegate performSelectorOnMainThread:@selector(TransmitData6850:) withObject:acia6850 waitUntilDone:NO];
	}
}

//----------------------------------------------------------------------------
// 	Protocol <EK6821Protocol> implementation
//----------------------------------------------------------------------------

-(void) ReadPIA6821A:(id)pia6821 {

	if( [self->delegate respondsToSelector:@selector(ReadPIA6821A:)] ) {
	
		[self->delegate performSelectorOnMainThread:@selector(ReadPIA6821A:) withObject:pia6821 waitUntilDone:NO];
	}
}
//----------------------------------------------------------------------------
-(void) ReadPIA6821B:(id)pia6821 {

	if( [self->delegate respondsToSelector:@selector(ReadPIA6821B:)] ) {
	
		[self->delegate performSelectorOnMainThread:@selector(ReadPIA6821B:) withObject:pia6821 waitUntilDone:YES];
	}
}
//----------------------------------------------------------------------------
-(void) WritePIA6821A:(id)pia6821 {

	if( [self->delegate respondsToSelector:@selector(WritePIA6821A:)] ) {
	
		[self->delegate performSelectorOnMainThread:@selector(WritePIA6821A:) withObject:pia6821 waitUntilDone:YES];
	}		
}
//----------------------------------------------------------------------------
-(void) WritePIA6821B:(id)pia6821 {

	if( [self->delegate respondsToSelector:@selector(WritePIA6821B:)] ) {
	
		[self->delegate performSelectorOnMainThread:@selector(WritePIA6821B:) withObject:pia6821 waitUntilDone:NO];
	}		
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(void)	executeCycle {

	[self->microProcessor runStep];
	[self->addressDecoder runStep];
	
	EKInterrupts *collected = [self->addressDecoder collectIRQs];
	if( collected != nil ) {
		[self->microProcessor sendIRQs:collected];
	}
}
//---------------------------------------------------------------------------
-(void)	threadExecuteComputer {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    bool execute = true;
    do {
		[self executeCycle];
		[self->microProcessor displayRegisters];
        
        [NSThread sleepForTimeInterval:(NSTimeInterval)0.0001];
		
		@synchronized( self ) {
		
			if( self->breakPointActive && self->breakPointAddress == ((EK6809Processor *)self->microProcessor).pc ) {
			
				self->systemHalt = true;
				NSLog(@"Processor halted on breakpoint: PC=0x%04X", ((EK6809Processor *)self->microProcessor).pc);
			}
			
			execute = !self->systemHalt;
		}		      
    } while( execute );
    
	[pool release];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(void)	resetComputer {
		
	@synchronized( self ) {
	
		self->systemHalt = true;
		
		[self->microProcessor reset];
		[self->addressDecoder reset];
		[self->microProcessor displayRegisters];
	}
}
//---------------------------------------------------------------------------
-(void)	runComputer {

	self->systemHalt = false;
	[NSThread detachNewThreadSelector:@selector(threadExecuteComputer) toTarget:self withObject:nil];
}
//---------------------------------------------------------------------------
-(void)	runStep {

    self->systemHalt = true;
    [NSThread detachNewThreadSelector:@selector(threadExecuteComputer) toTarget:self withObject:nil];
}
//---------------------------------------------------------------------------
-(void)	haltComputer {

	@synchronized( self ) {
	
		self->systemHalt = true;
	}
}
//---------------------------------------------------------------------------
-(UInt8 *) ramContent {

	return self->ramCircuit.ramContent;
}
//---------------------------------------------------------------------------
-(void) setBreakPoint:(UInt16) addressToStop {

	@synchronized( self ) {
		self->breakPointAddress = addressToStop;
		self->breakPointActive = true;
	}
}
//---------------------------------------------------------------------------
-(void) cancelBreakPoint {

	@synchronized( self ) {
		self->breakPointActive = false;
	}
}
//---------------------------------------------------------------------------

@end

/*
 
 Memory map:    

 0000-7FFF 32K RAM
 8000-8FFF FREE SPACE  (4K)
 9000-8FFF FREE SPACE  (4K)
 A000-AFFF I/O Area    (4K) CS$A000: - SERIAL INTERFACE ACIA 6850
 B000-8FFF FREE SPACE  (4K) CS$B000
 C000-CFFF FREE SPACE  (4K) CS$C000
 D000-DFFF FREE SPACE  (4K) CS$D000
 E000-FFFF ROM Monitor (8K)

*/