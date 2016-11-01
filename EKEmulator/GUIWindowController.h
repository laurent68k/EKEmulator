//
//  GUIWindowController.h
//  EKEmulator
//
//  Created by Laurent on 02/09/12.
//  Copyright (c) 2012 Laurent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Computer6809.h"
#import "EKTextFieldTerminal.h"

@interface GUIWindowController : NSWindowController <EKTextViewTerminalProtocol> {

        @protected
    
            Computer6809    *computer;
			
			IBOutlet NSTextField		*tfPIAA;
			IBOutlet NSTextField		*tfPIAB;

			IBOutlet NSButton			*bReset;
			IBOutlet NSButton			*bRun;
			IBOutlet NSButton			*bRunStep;
			IBOutlet NSButton			*bHalt;
			
			IBOutlet NSButton			*bNMI;
			IBOutlet NSButton			*bIRQ;
			IBOutlet NSButton			*bFIRQ;
			
			char						character;
    
			IBOutlet EKTextViewTerminal *tfConsole;
			
			IBOutlet NSTextField        *tfBrkPoint;

}

- (IBAction)        runUntil:(id)sender;
- (IBAction)		runStep:(id)sender;
- (IBAction)		reset:(id)sender;
- (IBAction)		halt:(id)sender;

- (IBAction) 		setBrkPoint:(id)sender;
- (IBAction) 		cancelBrkPoint:(id)sender;
- (IBAction) 		openMemoryInspector:(id)sender;
- (IBAction)        open6809CPUInspector:(id)sender;
- (IBAction)        clear:(id)sender;

- (void)            charAvailable:(const char)newChar;
- (void)            controlTextDidChange:(NSNotification *)notification;

- (IBAction)		NMI:(id)sender;
- (IBAction)		IRQ:(id)sender;
- (IBAction)		FIRQ:(id)sender;

-(void) 			displayCPU:(id)objet;
-(void) 			TransmitData6850:(id) data;


@end
