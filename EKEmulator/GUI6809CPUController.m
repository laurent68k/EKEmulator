//
//  GUI6809CPUController.m
//
//  Created by Laurent on 22/11/2012
//	Updated on: 
//
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#include <stdlib.h>

#import "EK6809Processor.h"
#import "GUI6809CPUController.h"

@implementation GUI6809CPUController

//---------------------------------------------------------------------------
-(id) initWithNotification:(NSString *)theNotification{
	
	self = [super init];
	if( self != nil ) {
		
		self->notificationName = theNotification;
	}
	
	return self;
}
//---------------------------------------------------------------------------
-(void) dealloc {
			
    [super dealloc];
}
//---------------------------------------------------------------------------
- (void)awakeFromNib {
	
	[[self window] setTitle: @"CPU 6809"];
	
	//	Register for item change
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayCPU:) name:self->notificationName object:nil];
}
//---------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)note {
	
}

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

-(void) displayCPU:(NSNotification*)notification {

  	NSObject	*objet = (NSObject *)[[notification userInfo] objectForKey: @"EK6809Processor" ];
	
	if( [objet isKindOfClass:[EK6809Processor class]] ) {
	
		EK6809Processor *proc6809 = (EK6809Processor *)objet;
		
		self->tfCC.stringValue = @"";
		for(int mask = 0x80; mask > 0; mask = mask >> 1) {
		
			self->tfCC.stringValue = [NSString stringWithFormat:@"%@%@", self->tfCC.stringValue, ((proc6809.cc.all & mask) > 0 ? @"1" : @"0") ];
		}
		
		self->tfDP.stringValue = [NSString stringWithFormat:@"DP:0x%02X", proc6809.dp];
		self->tfA.stringValue = [NSString stringWithFormat:@"A:0x%02X", proc6809.acc.byte.a];
		self->tfB.stringValue = [NSString stringWithFormat:@"B:0x%02X", proc6809.acc.byte.b];
		self->tfD.stringValue = [NSString stringWithFormat:@"D:0x%04X", proc6809.acc.d];
		self->tfX.stringValue = [NSString stringWithFormat:@"X:0x%04X", proc6809.x];
		self->tfY.stringValue = [NSString stringWithFormat:@"Y:0x%04X", proc6809.y];
		self->tfS.stringValue = [NSString stringWithFormat:@"S:0x%04X", proc6809.s];
		self->tfU.stringValue = [NSString stringWithFormat:@"U:0x%04X", proc6809.u];

		self->tfPC.stringValue = [NSString stringWithFormat:@"PC:0x%04X", proc6809.pc];
		self->tfIR.stringValue = [NSString stringWithFormat:@"IR:0x%02X", proc6809.ir];
		self->tfINSTR.stringValue = [NSString stringWithFormat:@"%@", proc6809.instruction];
	}
}

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

- (void) showUI {
	
    // load the nib
    if (NULL == [self window]) {
	
        [NSBundle loadNibNamed: @"CPU6809" owner: self];
    }
	
    [self showWindow:self];
}
//---------------------------------------------------------------------------

@end
