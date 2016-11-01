//
//  EKCircuit.m
//
//  Created by Laurent on 14/11/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKTextFieldTerminal.h"

@implementation EKTextViewTerminal

#define		BACKSPACE		0x08
#define     DELCHAR         0x7F
#define		LF				0x0A
#define		VT				0x0B
#define		CR				0x0D
#define		BEL				0x07
#define		ESC				0x1B

#define 	MT_CLS   		'E'			//	clear screen, cursor move home 
#define 	MT_INVVIDEO   	'p'			//	Setting cursor, background, text, video inverse and more color stuff. 
#define 	MT_NORMVIDEO	'q'			//	Setting cursor, background, text, video inverse and more color stuff
	

//---------------------------------------------------------------------------
//	force to have in setDelegate the new protocol supported
-(void) setDelegate:(id<EKTextViewTerminalProtocol>)theDelegate {

	self->previousChar = 0x00;
	
	[self setBackgroundColor:[NSColor brownColor]];
	[self setFont: [NSFont fontWithName:@"Andale Mono" size:12] ];
    [self setString:@""];
	
	[super setDelegate:theDelegate];
}
//---------------------------------------------------------------------------
- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------


-(void) doCommandVT52:(char) code {

	switch(code) {
	
		case	MT_CLS:
			[self setString: @""];
			break;
			
		case	MT_INVVIDEO:
			break;
			
		case	MT_NORMVIDEO:
			break;
            
		default:
			// VT escape code not implemented, ignore			
			break;
	}
}
//---------------------------------------------------------------------------
-(void) acceptChar:(char)newChar {
		
    switch (newChar) {
							
        case	ESC:
			//	catch escape \033 sequence
			break;
			
		case	BEL:
			NSBeep();
			break;

		case BACKSPACE:
        case DELCHAR: {
                NSUInteger length = [self.string length];
                if( length > 0 ) {
                    [self setString:[NSString stringWithFormat:@"%@", [self.string substringToIndex:length - 1 ]] ];
                }
            }
			break;

        default:
		
			if( self->previousChar == ESC ) {
			
				[self doCommandVT52: newChar];
			}
			else {
				[self setString:[NSString stringWithFormat:@"%@%c", self.string, newChar] ];
			}
            break;
    }	
	self->previousChar	= newChar;
}

//---------------------------------------------------------------------------
-(void) keyDown:(NSEvent *)theEvent {

	NSString	*chars = [theEvent characters];
	
	const char *cString = [chars UTF8String];   //[[chars uppercaseString] UTF8String];
	
	if( self.delegate != nil ) {
	
		//	sould be not necessary if the delegate has been forced to be id<EKTextViewTerminalProtocol>
		if( [self.delegate conformsToProtocol:@protocol(EKTextViewTerminalProtocol)] ) {
		
			[((id<EKTextViewTerminalProtocol>)self.delegate) charAvailable: cString[ [chars length] - 1 ] ];
		}
	}

	//[super keyDown:theEvent];
}
//---------------------------------------------------------------------------
- (void)interpretKeyEvents:(NSArray *)eventArray {

	[super interpretKeyEvents:eventArray];
}
//---------------------------------------------------------------------------

@end
