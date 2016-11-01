//
//  GUI6809CPUController.h
//
//  Created by Laurent on 22/11/2012
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>

@interface GUI6809CPUController : NSWindowController {

	@protected

			IBOutlet NSTextField		*tfCC;
			IBOutlet NSTextField		*tfDP;
			IBOutlet NSTextField		*tfA;
			IBOutlet NSTextField		*tfB;
			IBOutlet NSTextField		*tfD;
			IBOutlet NSTextField		*tfX;
			IBOutlet NSTextField		*tfY;
			IBOutlet NSTextField		*tfS;
			IBOutlet NSTextField		*tfU;
	
			IBOutlet NSTextField		*tfPC;
			IBOutlet NSTextField		*tfIR;
			IBOutlet NSTextField		*tfINSTR;

			NSString					*notificationName;
}

-(id)				initWithNotification:(NSString *)notification;
-(void) 			showUI;


@end
