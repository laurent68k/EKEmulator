//
//  GUIWindowController.m
//  EKEmulator
//
//  Created by Laurent on 02/09/12.
//  Copyright (c) 2012 Laurent. All rights reserved.
//

#import "EK6809Processor.h"
#import "GUIWindowController.h"
#import "GUIMemoryInspectorController.h"
#import "GUI6809CPUController.h"

@interface GUIWindowController ()

@end

@implementation GUIWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
		self->computer = [[Computer6809 alloc] initWithDelegate:self];
		self->character = 0;
    }
    
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {
    
	[self->computer release];
	
    [super dealloc];
}
//---------------------------------------------------------------------------
- (void)awakeFromNib {

    self->bRun.enabled = YES;
	self->bRunStep.enabled = YES;
	self->bReset.enabled = YES;
	self->bHalt.enabled = NO;
        
	self->tfBrkPoint.stringValue = @"";
	[self->tfConsole setDelegate:(id)self];
	
    self->tfPIAA.stringValue = @"";
    self->tfPIAB.stringValue = @"";
    
    [self->computer resetComputer];

}
//---------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)note {
	
	[NSApp terminate: self ];
}
//---------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

-(void) displayCPU:(id)coreProcessor {

    if( [coreProcessor isKindOfClass:[EK6809Processor class]] ) {
	
		EK6809Processor *proc6809 = (EK6809Processor *)coreProcessor;
        
		//	Notification
		//	Send to the Notification center the CPU state machine
		NSDictionary	*userInfo = [NSDictionary dictionaryWithObject:proc6809 forKey: @"EK6809Processor"];	
		NSNotification	*notification = [NSNotification notificationWithName:@"CPU6809" object:self userInfo:userInfo];

		[[NSNotificationCenter defaultCenter] postNotification: notification];
	}
}

//---------------------------------------------------------------------------
//	<EKTextViewTerminalProtocol>
//---------------------------------------------------------------------------

-(void) charAvailable:(const char)newChar {

	self->character = newChar;
}

//---------------------------------------------------------------------------
//	Editor+Keyboard
//---------------------------------------------------------------------------

- (void)controlTextDidChange:(NSNotification *)notification {
	
	NSTextField *ed = [notification object];
	self->character = 0;
	if( [[ed stringValue] length] > 0 ) {
	
        const char *cString = [[[ed stringValue] uppercaseString] UTF8String];
        
		self->character = cString[ [ed.stringValue length] - 1 ];
	}
}
//---------------------------------------------------------------------------
- (IBAction) clear:(id)sender {
    
    self->tfConsole.string = @"";
}

//---------------------------------------------------------------------------
//	Selector for 6850 ACIA
//---------------------------------------------------------------------------

-(void) TransmitData6850:(id)acia6850 {

    if( [acia6850 isKindOfClass:[EK6850 class]] ) {
        
		[self->tfConsole acceptChar:((EK6850 *)acia6850).regTRD];
    }
}
//---------------------------------------------------------------------------
-(void) ReceiveData6850:(id)acia6850 {

    ((EK6850 *)acia6850).flagRDRFull = (self->character != 0);
	if( self->character != 0 && [acia6850 isKindOfClass:[EK6850 class]] ) {
	        
		((EK6850 *)acia6850).regRDR = (UInt8)self->character;
		self->character = 0;
	}
}

//---------------------------------------------------------------------------
//	Selector for 6821 PIA
//---------------------------------------------------------------------------

-(void) ReadPIA6821A:(id) pia6821 {

	if( [pia6821 isKindOfClass:[EK6821 class]] ) {
		
		((EK6821 *)pia6821).portA = 0;
	}
}
//----------------------------------------------------------------------------
-(void) ReadPIA6821B:(id) pia6821 {

	if( [pia6821 isKindOfClass:[EK6821 class]] ) {
		
		((EK6821 *)pia6821).portB = 0;
	}
}
//----------------------------------------------------------------------------
-(void) WritePIA6821A:(id) pia6821 {

	self->tfPIAA.stringValue = [NSString stringWithFormat:@"PIA.A: %X", ((EK6821 *)pia6821).regORA];
}
//----------------------------------------------------------------------------
-(void) WritePIA6821B:(id) pia6821 {

	self->tfPIAB.stringValue = [NSString stringWithFormat:@"PIA.B: %X", ((EK6821 *)pia6821).regORB];
}

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

- (IBAction)runUntil:(id)sender {
    
    [self->computer runComputer];

	self->bRun.enabled = NO;
	self->bRunStep.enabled = NO;
	self->bReset.enabled = NO;
	self->bHalt.enabled = YES;
}
//---------------------------------------------------------------------------
- (IBAction)runStep:(id)sender {
    
    [self->computer runStep];
	
	self->bRun.enabled = YES;
	self->bRunStep.enabled = YES;
	self->bReset.enabled = YES;
	self->bHalt.enabled = NO;
}
//---------------------------------------------------------------------------
- (IBAction)reset:(id)sender {
    
    [self->computer resetComputer];

	self->bRun.enabled = YES;
	self->bRunStep.enabled = YES;
	self->bReset.enabled = YES;
	self->bHalt.enabled = NO;
}
//---------------------------------------------------------------------------
- (IBAction)halt:(id)sender {
    
    [self->computer haltComputer];
	
	self->bRun.enabled = YES;
	self->bRunStep.enabled = YES;
	self->bReset.enabled = YES;
	self->bHalt.enabled = NO;
}
//---------------------------------------------------------------------------
- (IBAction) setBrkPoint:(id)sender {

	if( ! [self->tfBrkPoint.stringValue isEqualToString:@""] ) {
	
		NSLog(@"breakpoint added");
		
		unsigned int addressToStop = 0;
		sscanf([self->tfBrkPoint.stringValue cStringUsingEncoding:NSASCIIStringEncoding], "%X", &addressToStop );
		//if( addressToStop == 0 ) {
		
		//	NSRunInformationalAlertPanel(@"6809", @"Address isn't an hexadecimal value", @"OK", NULL, NULL);
		//}
		
		[self->computer setBreakPoint:(UInt16)addressToStop];
	}
}
//---------------------------------------------------------------------------
- (IBAction) cancelBrkPoint:(id)sender {

	[self->computer cancelBreakPoint];
}
//---------------------------------------------------------------------------
- (IBAction) openMemoryInspector:(id)sender {

	GUIMemoryInspectorController *memoryInspector = [[GUIMemoryInspectorController alloc] initWithContent:[self->computer ramContent]];
	[memoryInspector showUI];
}
//---------------------------------------------------------------------------
- (IBAction) open6809CPUInspector:(id)sender {

	GUI6809CPUController *cpuInspector = [[GUI6809CPUController alloc] initWithNotification:@"CPU6809"];
	[cpuInspector showUI];
}
//---------------------------------------------------------------------------
- (IBAction) NMI:(id)sender {

}
//---------------------------------------------------------------------------
- (IBAction) IRQ:(id)sender {

}
//---------------------------------------------------------------------------
- (IBAction) FIRQ:(id)sender {

}
//---------------------------------------------------------------------------

@end
