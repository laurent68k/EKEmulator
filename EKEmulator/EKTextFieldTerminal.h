//
//  EKCircuit.h
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>

//  declare a protocol for the delegate
@protocol EKTextViewTerminalProtocol <NSTextViewDelegate>

    @required

	//	Indicate that a new char has been hit by keyboard
	-(void) charAvailable:(const char)newChar;
	
@end

@interface EKTextViewTerminal : NSTextView {

	@protected
	
		char	previousChar;
		
}

-(void)				acceptChar:(char)newChar;

@end
