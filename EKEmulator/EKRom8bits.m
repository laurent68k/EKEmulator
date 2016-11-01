//
//  EKRom8bits.m
//
//  Created by Laurent on 28/08/2012.
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.


#import "EKRom8bits.h"

@implementation EKRom8bits


//---------------------------------------------------------------------------
-(id) initWithSizeAndContent:(UInt16)aBaseAddress size:(UInt16) aSize content:(NSString *)filename{
  
	self = [super initWithSize:aBaseAddress size:aSize];
    if( self != nil ) {
    		
		self->romContent = NULL;
		[self loadROMWithImage:filename];
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

	FREENULL(self->romContent);
    [super dealloc];
}

//----------------------------------------------------------------------------
// 	
//----------------------------------------------------------------------------

-(void) loadROMWithImage:(NSString *)filename {

	NSString* fileRoot = [[NSBundle mainBundle] pathForResource: filename ofType:@"bin"];
	
	NSFileHandle *fileROM = [NSFileHandle fileHandleForReadingAtPath:fileRoot];	
	NSData *datas = [fileROM readDataToEndOfFile];

	//	allocate the ROM content
	self->romContent = malloc( [datas length]);
	[datas getBytes:self->romContent];

	[fileROM closeFile];
}
//---------------------------------------------------------------------------
-(UInt8) read:(UInt16) address {

	UInt8	value = 0xFF;
	
	if( address - self->baseAddress < self->size ) {
		value = self->romContent[address - self->baseAddress ];
	}
	return value;
}
//---------------------------------------------------------------------------
-(bool) write:(UInt16) address data:(UInt8) data {

	return	false;
}
//---------------------------------------------------------------------------

@end
