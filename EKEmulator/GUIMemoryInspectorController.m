//
//  GUIMemoryInspectorController.m
//
//  Created by Laurent on 23/10/2012
//	Updated on: 
//
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#include <stdlib.h>


#import "GUIMemoryInspectorController.h"

@implementation GUIMemoryInspectorController

//---------------------------------------------------------------------------
-(id) initWithContent:(UInt8 *) theContent {
	
	self = [super init];
	if( self != nil ) {
		
		self->memory = theContent;
	}
	
	return self;
}
//---------------------------------------------------------------------------
-(void) dealloc {
			
    [super dealloc];
}
//---------------------------------------------------------------------------
- (void)awakeFromNib {
	
	[[self window] setTitle: @"Memory Inspector"];
	self->tvDisplay.string = @"";
}
//---------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)note {
	
}

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

#define	SPACE	0x20
#define	DEL		0x7F

-(char) getPrintableChar:(char)theChar {

	return ( (theChar >= SPACE && theChar < DEL ) ? theChar : '.');
}
//---------------------------------------------------------------------------
-(void) display:(UInt32) addressStart {
    
    self->tvDisplay.string = @"";
    
    
	for(UInt32 address = addressStart; address <= addressStart + 0x0160; address += 16 ) {
        
		self->tvDisplay.string = [NSString stringWithFormat:@"%@\n$%04X: %02X %02X %02X %02X %02X %02X %02X %02X\t%02X %02X %02X %02X %02X %02X %02X %02X  %c%c%c%c%c%c%c%c %c%c%c%c%c%c%c%c",
                                  self->tvDisplay.string,
                                  address,
                                  self->memory[address + 0],
                                  self->memory[address + 1],
                                  self->memory[address + 2],
                                  self->memory[address + 3],
                                  self->memory[address + 4],
                                  self->memory[address + 5],
                                  self->memory[address + 6],
                                  self->memory[address + 7],
                                  self->memory[address + 8],
                                  self->memory[address + 9],
                                  self->memory[address + 10],
                                  self->memory[address + 11],
                                  self->memory[address + 12],
                                  self->memory[address + 13],
                                  self->memory[address + 14],
                                  self->memory[address + 15],
                                  
                                  [self getPrintableChar: self->memory[address + 0] ],
                                  [self getPrintableChar: self->memory[address + 1] ],
                                  [self getPrintableChar: self->memory[address + 2] ],
                                  [self getPrintableChar: self->memory[address + 3] ],
                                  [self getPrintableChar: self->memory[address + 4] ],
                                  [self getPrintableChar: self->memory[address + 5] ],
                                  [self getPrintableChar: self->memory[address + 6] ],
                                  [self getPrintableChar: self->memory[address + 7] ],
                                  [self getPrintableChar: self->memory[address + 8] ],
                                  [self getPrintableChar: self->memory[address + 9] ],
                                  [self getPrintableChar: self->memory[address + 10] ],
                                  [self getPrintableChar: self->memory[address + 11] ],
                                  [self getPrintableChar: self->memory[address + 12] ],
                                  [self getPrintableChar: self->memory[address + 13] ],
                                  [self getPrintableChar: self->memory[address + 14] ],
                                  [self getPrintableChar: self->memory[address + 15] ] ];
	}
    
	//NSRunInformationalAlertPanel(APP_WINDOW__TITLE, @"The volume name must not be greater than 8", @"OK", NULL, NULL);		
}
//---------------------------------------------------------------------------
-(IBAction) changeAddress:(id)sender {
    
    NSStepper *stepper = (NSStepper *)sender;
    self->tfAdrStart.stringValue = [NSString stringWithFormat:@"%04X", stepper.intValue];

    [self display:stepper.intValue];
}
//---------------------------------------------------------------------------
-(IBAction) goButton:(id)sender {
    
    unsigned int addressStart = 0;
    sscanf([self->tfAdrStart.stringValue cStringUsingEncoding:NSASCIIStringEncoding], "%X", &addressStart );

    [self display:addressStart];
}

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

- (void) showUI {
	
    // load the nib
    if (NULL == [self window]) {
	
        [NSBundle loadNibNamed: @"MemoryInspector" owner: self];
    }
	
    [self showWindow:self];
}
//---------------------------------------------------------------------------

@end

/*
 
 $7F60: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 0F
 $7F70: 0F 0F 0F 0F 0F 0F 0F 0F	0F 0F 0F 0F 00 00 00 00
 $7F80: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7F90: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7FA0: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7FB0: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7FC0: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7FD0: 00 00 00 00 00 00 00 00	00 00 00 00 00 00 00 00
 $7FE0: 00 00 00 00 00 00 00 00	00 46 0C C1 14 F0 EF C3
 $7FF0: 1E C1 0A F0 AB CD 56 C1	24 7F 7E 7F 6F C0 A6 00
 
 */
