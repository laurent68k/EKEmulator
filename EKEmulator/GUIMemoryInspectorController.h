//
//  GUIMemoryInspectorController.h
//
//  Created by Laurent on 23/10/2012
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>

@interface GUIMemoryInspectorController : NSWindowController {

	@protected

	IBOutlet NSTextView			*tvDisplay;
    IBOutlet NSTextField        *tfAdrStart;

	UInt8						*memory;
}

-(id)				initWithContent:(UInt8 *) theContent;
-(void) 			showUI;

-(IBAction) 		goButton:(id)sender;
-(IBAction) 		changeAddress:(id)sender;

@end
