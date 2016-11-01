//
//  EK6809Processor.h
//
//  Created by Laurent on 27/07/2012.
//  Copyright 2011 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.

#import <Cocoa/Cocoa.h>
#import "EKCoreProcessor.h"

#define	VECTOR_RESET	0xFFFE
#define	VECTOR_NMI		0xFFFC
#define	VECTOR_IRQ		0xFFF8
#define	VECTOR_FIRQ		0xFFF6
#define	VECTOR_SWI		0xFFFA
#define	VECTOR_SWI2		0xFFF4
#define	VECTOR_SWI3		0xFFF2

#define IRQ_DISABLED	1
#define FIRQ_DISABLED	1

typedef enum tagAddressingMode {
				immediate = 0,
				relative = 0,
				inherent,
				extended,
				direct,
				indexed
	} AddressingMode;

typedef union {
    UInt16			d;	// Combined accumulator A and B (16-bit, A high, B low) 
    struct {
        UInt8		b;	// Accumulator b:	Low byte
        UInt8		a;	// Accumulator a:	High byte
    } byte;
} accumulators;

//	order must be c = bit0 => e = bit7
typedef union {
    UInt8			all;	// Condition code register
    struct {
//#ifdef MACH_BITFIELDS_LSB_FIRST
        UInt8		c : 1;	// Carry bit 0
        UInt8		v : 1;	// Overflow
        UInt8		z : 1;	// Zero
        UInt8		n : 1;	// Negative
        UInt8		i : 1;	// IRQ disable
        UInt8		h : 1;	// Half carry
        UInt8		f : 1;	// FIRQ disable
        UInt8		e : 1;	// Entire bit 7
/*#else
        UInt8		e : 1;	// Entire
        UInt8		f : 1;	// FIRQ disable
        UInt8		h : 1;	// Half carry
        UInt8		i : 1;	// IRQ disable
        UInt8		n : 1;	// Negative
        UInt8		z : 1;	// Zero
        UInt8		v : 1;	// Overflow
        UInt8		c : 1;	// Carry
#endif*/
    } bit;
} codecondition;
	
@interface EK6809Processor : EKCoreProcessor {

	@protected

		AddressingMode	mode;
		
		//	6809 public registers
		UInt16			ir;
		UInt16			pc;
		UInt16			u, s;		// Stack pointers
		UInt16			x, y;		// Index registers
		UInt8			dp;			// Direct Page register
		accumulators    acc;

		codecondition   cc;
		
		//	internals registers
		bool			flagIRQRaised;
		bool			flagFIRQRaised;
		bool			flagNMIRaised;
		
		//	helper
		NSString		*instruction;
}

@property(readonly) UInt16	ir;
@property(readonly) UInt16	pc;
@property(readonly) UInt16	x;
@property(readonly) UInt16	y;
@property(readonly) UInt16	s;
@property(readonly) UInt16	u;

@property(readonly) UInt8				dp;
@property(readonly) codecondition		cc;
@property(readonly) accumulators		acc;

@property(nonatomic,readonly) NSString			*instruction;

-(id)				initWithDelegate:(id)theDelegate;

-(void)				reset;
-(void)				run;
-(void)				runStep;
-(void)				sendIRQs:(EKInterrupts *)interrupts;


@end
