//
//
//
//  EK6809Processor.m
//
//  Ported by Laurent on 27/07/2012, based on the great job "USim, R.P.Bellis"
//  Copyright 2012 Laurent68k. All rights reserved.
//
//	In memory of Steve Jobs, February 24, 1955 - October 5, 2011.
//
//	FIX:	self->cc.bit.v bit was wrong in cmp8 and cmp16


#import "EK6809Processor.h"

//----------------------------------------------------------------------------
//	Interface for hidden methods
@interface EK6809Processor (private)

-(void)			execute;

-(UInt16) 		readWord16:(UInt16) address;
-(void) 		writeWord16:(UInt16) address data:(UInt16) val;

-(UInt16*)		refreg:(UInt8)a;

-(UInt8*)		byterefreg:(int)a;
-(UInt16*)		wordrefreg:(int)a;

-(UInt8)		fetch_operand;
-(UInt16)		fetch_word_operand;
-(UInt16)		fetch_effective_address;

-(UInt16)		do_effective_address:(UInt8)a;
-(void)			do_predecrement:(UInt8)a;
-(void)			do_postincrement:(UInt8)a;

-(void)			abx;
-(void)			adca;
-(void)			adcb;
-(void)			adda;
-(void)			addb;
-(void)			addd;
-(void)			anda;
-(void)			andb;
-(void)			andcc;
-(void)			asra;
-(void)			asrb;
-(void)			asr;
-(void)			bcc;
-(void)			lbcc;
-(void)			bcs;
-(void)			lbcs;
-(void)			beq;
-(void)			lbeq;
-(void)			bge;
-(void)			lbge;
-(void)			bgt;
-(void)			lbgt;
-(void)			bhi;
-(void)			lbhi;
-(void)			bita;
-(void)			bitb;
-(void)			ble;
-(void)			lble;
-(void)			bls;
-(void)			lbls;
-(void)			blt;
-(void)			lblt;
-(void)			bmi;
-(void)			lbmi;
-(void)			bne;
-(void)			lbne;
-(void)			bpl;
-(void)			lbpl;
-(void)			bra;
-(void)			lbra;
-(void)			brn;
-(void)			lbrn;
-(void)			bsr;
-(void)			lbsr;
-(void)			bvc;
-(void)			lbvc;
-(void)			bvs;
-(void)			lbvs;
-(void)			clra;
-(void)			clrb;
-(void)			clr;
-(void)			cmpa;
-(void)			cmpb;
-(void)			cmpd;
-(void)			cmpx;
-(void)			cmpy;
-(void)			cmpu;
-(void)			cmps;
-(void)			coma;
-(void)			comb;
-(void)			com;
-(void)			cwai;
-(void)			daa;
-(void)			deca;
-(void)			decb;
-(void)			dec;
-(void)			eora;
-(void)			eorb;
-(void)			exg;
-(void)			inca;
-(void)			incb;
-(void)			inc;
-(void)			jmp;
-(void)			jsr;
-(void)			lda;
-(void)			ldb;
-(void)			ldd;
-(void)			ldx;
-(void)			ldy;
-(void)			lds;
-(void)			ldu;
-(void)			leax;
-(void)			leay;
-(void)			leas;
-(void)			leau;
-(void)			lsla;
-(void)			lslb;
-(void)			lsl;
-(void)			lsra;
-(void)			lsrb;
-(void)			lsr;
-(void)			mul;
-(void)			nega;
-(void)			negb;
-(void)			neg;
-(void)			nop;
-(void)			ora;
-(void)			orb;
-(void)			orcc;
-(void)			pshs;
-(void)			pshu;
-(void)			puls;
-(void)			pulu;
-(void)			rola;
-(void)			rolb;
-(void)			rol;
-(void)			rora;
-(void)			rorb;
-(void)			ror;
-(void)			rti;
-(void)			rts;
-(void)			sbca;
-(void)			sbcb;
-(void)			sex;
-(void)			sta;
-(void)			stb;
-(void)			std;
-(void)			stx;
-(void)			sty;
-(void)			sts;
-(void)			stu;
-(void)			suba;
-(void)			subb;
-(void)			subd;
-(void)			swi;
-(void)			swi2;
-(void)			swi3;
-(void)			sync;
-(void)			tfr;
-(void)			tsta;
-(void)			tstb;
-(void)			tst;

-(void)			do_branch:(int)a;
-(void)			do_longBranch:(int)a;

-(void)			help_adc:(UInt8*)a operand:(UInt8)operand;
-(void)			help_add:(UInt8*)a operand:(UInt8)operand;
-(void)			help_and:(UInt8*)a operand:(UInt8)operand;
-(void)			help_asr:(UInt8*)a;
-(void)			help_bit:(UInt8)a;
-(void)			help_clr:(UInt8*)a;
-(void)			help_cmp8:(UInt8)a operand:(UInt8)operand;
-(void)			help_cmp16:(UInt16)a;
-(void)			help_com:(UInt8*)a;
-(void)			help_dec:(UInt8*)a;
-(void)			help_eor:(UInt8*)a;
-(void)			help_inc:(UInt8*)a;
-(void)			help_ld8:(UInt8*)a;
-(void)			help_ld16:(UInt16*)a;
-(void)			help_lsr:(UInt8*)a;
-(void)			help_lsl:(UInt8*)a;
-(void)			help_neg:(UInt8*)a;
-(void)			help_or:(UInt8*)a;
-(void)         help_psh:(UInt8) w :(UInt16*) stackPtr :(UInt16*) reg;
-(void) 		help_pul:(UInt8) w :(UInt16*) stackPtr :(UInt16*) reg;
-(void)			help_ror:(UInt8*)a;
-(void)			help_rol:(UInt8*)a;
-(void)			help_sbc:(UInt8*)a;
-(void)			help_st8:(UInt8)a;
-(void)			help_sub8:(UInt8*)a;
-(void)			help_tst:(UInt8)a;

-(void)         pushStackS8:(UInt8)data;
-(void)         pushStackS16:(UInt16)data;

@end

//----------------------------------------------------------------------------
//	Pivate implémentation of EK6809Processor by category
@implementation EK6809Processor (private)

-(UInt16) readWord16:(UInt16) address {
    
	UInt16		tmp;
    
	tmp = [self->delegate read:address++];
	tmp <<= 8;
	tmp &= 0xFF00;
	tmp |= [self->delegate read:address];
    
	return tmp;
}
//----------------------------------------------------------------------------
-(void) writeWord16:(UInt16) address data:(UInt16) data {
    
	[self->delegate write:address++ data:(data >> 8)];
	[self->delegate write:address data:data];
}
//----------------------------------------------------------------------------
-(UInt8) fetch {
    
	UInt8		val = [self->delegate read:self->pc];
	self->pc += 1;
    
	return val;
}
//----------------------------------------------------------------------------
-(UInt16) fetch_word {
    
	UInt16		val = [self readWord16:self->pc];
	self->pc += 2;
    
	return val;
}
//----------------------------------------------------------------------------
// Bit extend operations
-(UInt16) extend5:(UInt8) reg {
    
	if (reg & 0x10) {
		return (UInt16)reg | 0xFFE0;
	}
    else {
		return (UInt16)reg;
	}
}
//----------------------------------------------------------------------------
-(UInt16) extend8:(UInt8) reg {
    
	if (reg & 0x80) {
		return (UInt16)reg | 0xFF00;
	} else {
		return (UInt16)reg;
	}
}
//----------------------------------------------------------------------------
-(UInt16*) refreg:(UInt8) post {
    
	post &= 0x60;
	post >>= 5;
    
	if (post == 0) {
		return &self->x;
	} else if (post == 1) {
		return &self->y;
	} else if (post == 2) {
		return &self->u;
	} else {
		return &self->s;
	}
}
//----------------------------------------------------------------------------
-(UInt8*) byterefreg:(int) regCode {
    
	if (regCode == 0x08) {
		return &self->acc.byte.a;
	} else if (regCode == 0x09) {
		return &self->acc.byte.b;
	} else if (regCode == 0x0a) {
		return &self->cc.all;
	} else {
		return &self->dp;
	}
}
//----------------------------------------------------------------------------
-(UInt16*) wordrefreg:(int) regCode {
    
	if (regCode == 0x00) {
		return &self->acc.d;
	} else if (regCode == 0x01) {
		return &self->x;
	} else if (regCode == 0x02) {
		return &self->y;
	} else if (regCode == 0x03) {
		return &self->u;
	} else if (regCode == 0x04) {
		return &self->s;
	} else {
		return &self->pc;
	}
}
//----------------------------------------------------------------------------
-(UInt8) fetch_operand {
    
	UInt8		ret = 0;
	UInt16		addr;
    
	if (mode == immediate) {
		ret = [self fetch];
	}
	else if (mode == relative) {
		ret = [self fetch];
	}
	else if (mode == extended) {
		addr = [self fetch_word];
		ret = [self->delegate read:addr];
	}
	else if (mode == direct) {
		addr = ((UInt16)self->dp << 8) | [self fetch];
		ret = [self->delegate read:addr];
	}
	else if (mode == indexed) {
		UInt8		post = [self fetch];
		[self do_predecrement:post];
		addr = [self do_effective_address:post ];
		ret = [self->delegate read:addr];
        [self do_postincrement:post];
	}
	else {
		//invalid("addressing mode");
	}
    
	return ret;
}
//----------------------------------------------------------------------------
-(UInt16) fetch_word_operand {
    
	UInt16		addr, ret = 0;
    
	if (mode == immediate) {
		ret = [self fetch_word];
	}
	else if (mode == relative) {
		ret = [self fetch_word];
	}
	else if (mode == extended) {
		addr = [self fetch_word];
		ret = [self readWord16:addr ];
	}
	else if (mode == direct) {
		addr = (UInt16)self->dp << 8 | [self fetch];
		ret = [self readWord16:addr];
	}
	else if (mode == indexed) {
		UInt8	post = [self fetch];
		[self do_predecrement:post ];
		addr = [self do_effective_address:post];
        [self do_postincrement:post];
        ret = [self readWord16:addr];
	}
	else {
		//invalid("addressing mode");
	}
    
	return ret;
}
//----------------------------------------------------------------------------
-(UInt16) fetch_effective_address {
    
	UInt16		addr = 0;
    
	if (mode == extended) {
		addr = [self fetch_word];
	}
	else if (mode == direct) {
		addr = (UInt16)self->dp << 8 | [self fetch];
	}
	else if (mode == indexed) {
		UInt8		post = [self fetch];
		[self do_predecrement:post ];
		addr = [self do_effective_address:post ];
		[self do_postincrement:post ];
	}
	else {
		//invalid("addressing mode");
	}
    
	return addr;
}
//----------------------------------------------------------------------------
-(UInt16) do_effective_address:(UInt8) post {
    
	UInt16		addr = 0;
    
	if ((post & 0x80) == 0x00) {
		addr = *[self refreg:post] + [self extend5:(post & 0x1f)];
	} else {
		switch (post & 0x1f) {
			case 0x00: case 0x02:
				addr = *[self refreg:post];
				break;
			case 0x01: case 0x03: case 0x11: case 0x13:
				addr = *[self refreg:post];
				break;
			case 0x04: case 0x14:
				addr = *[self refreg:post];
				break;
			case 0x05: case 0x15:
				addr = self->acc.byte.b + *[self refreg:post];
				break;
			case 0x06: case 0x16:
				addr = self->acc.byte.a + *[self refreg:post];
				break;
			case 0x08: case 0x18:
				addr = *[self refreg:post] + [self extend8:[self fetch ]];
				break;
			case 0x09: case 0x19:
				addr = *[self refreg:post] + [self fetch_word];
				break;
			case 0x0b: case 0x1b:
				addr = self->acc.d + *[self refreg:post];
				break;
			case 0x0c: case 0x1c:
                addr = self->pc + [self extend8:[self fetch]];
				break;
			case 0x0d: case 0x1d:
				addr = self->pc + [self fetch_word];
				break;
			case 0x1f:
				addr = [self fetch_word];
				break;
			default:
				//invalid("indirect addressing postbyte");
				break;
		}
        
		/* Do extra indirection */
		if (post & 0x10) {
			addr = [self readWord16:addr];
		}
	}
    
	return addr;
}
//----------------------------------------------------------------------------
-(void) do_postincrement:(UInt8) post {
    
	switch (post & 0x9f) {
		case 0x80:
			*[self refreg:post] += 1;
			break;
		case 0x90:
			//invalid("postincrement");
			break;
		case 0x81: case 0x91:
			*[self refreg:post] += 2;
			break;
	}
}
//----------------------------------------------------------------------------
-(void) do_predecrement:(UInt8) post {
    
	switch (post & 0x9f) {
		case 0x82:
			*[self refreg:post] -= 1;
			break;
		case 0x92:
			//invalid("predecrement");
			break;
		case 0x83: case 0x93:
			*[self refreg:post] -= 2;
			break;
	}
}

//----------------------------------------------------------------------------
// 	Instructions 6809 implementation
//----------------------------------------------------------------------------

-(void) abx {
    
	self->x += self->acc.byte.b;
	self->instruction = [NSString stringWithFormat:@"abx" ];
}
//----------------------------------------------------------------------------
-(void) help_adc:(UInt8*) reg operand:(UInt8)operand {
    
	//UInt8	m = [self fetch_operand];
    
	{
		UInt8	t = (*reg & 0x0f) + (operand & 0x0f) + self->cc.bit.c;
		self->cc.bit.h = btst(t, 4);		// Half carry
	}
    
	/*{
		UInt8	t = (*reg & 0x7f) + (operand & 0x7f) + self->cc.bit.c;
		//self->cc.bit.v = btst(t, 7);		// Bit 7 carry in
	}*/
    
	{
		UInt16	t = *reg + operand + self->cc.bit.c;

		self->cc.bit.v = (((*reg ^ operand ^ t ^ ( t >> 1 )) & 0x80 ));	//	new way overflow

		self->cc.bit.c = btst16(t, 8);		// Bit 7 carry out
		*reg = t & 0xff;
	}
    
	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) adca {
    
	UInt8	operand = [self fetch_operand];
	[self help_adc:&self->acc.byte.a operand:operand];
	
	self->instruction = [NSString stringWithFormat:@"adca #$%02X", operand ];
}
//----------------------------------------------------------------------------
-(void) adcb {
    
	UInt8	operand = [self fetch_operand];
	[self help_adc:&self->acc.byte.b operand:operand];

	self->instruction = [NSString stringWithFormat:@"adcb #$%02X", operand ];
}
//----------------------------------------------------------------------------
-(void) help_add:(UInt8*) reg operand:(UInt8)operand {
    
	//UInt8	m = [self fetch_operand];
    
	{
		UInt8	t = (*reg & 0x0f) + (operand & 0x0f);
		self->cc.bit.h = btst(t, 4);		// Half carry
	}
    
	/*{
		UInt8	t = (*reg & 0x7f) + (operand & 0x7f);
		//self->cc.bit.v = btst(t, 7);		// Bit 7 carry in
	}*/
    
	{
		UInt16	t = *reg + operand;

		self->cc.bit.v = (((*reg ^ operand ^ t ^ ( t >> 1 )) & 0x80 ));	//	new way overflow

		self->cc.bit.c = btst16(t, 8);		// Bit 7 carry out
		*reg = t & 0xff;
	}
    
	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) adda {

    UInt8	m = [self fetch_operand];
	[self help_add:(&self->acc.byte.a) operand:m];

	self->instruction = [NSString stringWithFormat:@"adda #$%02X", m ];
}
//----------------------------------------------------------------------------
-(void) addb {

	UInt8	m = [self fetch_operand];    
	[self help_add:(&self->acc.byte.b) operand:m];

	self->instruction = [NSString stringWithFormat:@"addb #$%02X", m ];
}
//----------------------------------------------------------------------------
-(void) addd {
    
	UInt16	m = [self fetch_word_operand];
    	
	/*{
		UInt16	t = (self->acc.d & 0x7fff) + (m & 0x7fff);
		self->cc.bit.v = btst16(t, 15);
	}*/
    
	{
		UInt32	t = (UInt32)self->acc.d + m;
		
		self->cc.bit.v = (((acc.d ^ m ^ t ^ ( t >> 1 )) & 0x8000 ));
		
		self->cc.bit.c = btst16(t, 16);
		self->acc.d = (UInt16)(t & 0xffff);
	}
    
	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.n = btst16(self->acc.d, 15);
	self->cc.bit.z = !acc.d;
    
    self->instruction = [NSString stringWithFormat:@"addd #$%04X", m ];

}
//----------------------------------------------------------------------------
-(void) help_and:(UInt8*) reg operand:(UInt8)m{
    
	*reg = *reg & m;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
	self->cc.bit.v = 0;
}
//----------------------------------------------------------------------------
-(void) anda {
    
	UInt8 m = [self fetch_operand];
	[self help_and:(&self->acc.byte.a) operand:m];
	
	self->instruction = [NSString stringWithFormat:@"anda #$%02X", m ];
}
//----------------------------------------------------------------------------
-(void) andb {
    
    UInt8 m = [self fetch_operand];
	[self help_and:(&self->acc.byte.b) operand:m];
	
	self->instruction = [NSString stringWithFormat:@"andb #$%02X", m ];
}
//----------------------------------------------------------------------------
-(void) andcc {
    
	UInt8 operand = [self fetch];
	self->cc.all &= operand;
	
	self->instruction = [NSString stringWithFormat:@"andcc #$%02X", operand ];
}
//----------------------------------------------------------------------------
-(void) help_asr:(UInt8*) reg {
    
	self->cc.bit.c = btst(*reg, 0);
	*reg >>= 1;							/* Shift UInt16 right */
	if ((self->cc.bit.n = btst(*reg, 6)) != 0) {
		bset(reg, 7);
	}
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) asra {
    
	[self help_asr:(&acc.byte.a)];
	
	self->instruction = [NSString stringWithFormat:@"asra"];
}
//----------------------------------------------------------------------------
-(void) asrb {
    
	[self help_asr:(&self->acc.byte.b)];
	
	self->instruction = [NSString stringWithFormat:@"asrb"];
}
//----------------------------------------------------------------------------
-(void) asr {
    
	UInt16	addr = [self fetch_effective_address];
	UInt8	data = [self->delegate read:addr];
    
	[self help_asr:(&data)];
	[self->delegate write:addr data:data];
	
	self->instruction = [NSString stringWithFormat:@"asr"];
}
//----------------------------------------------------------------------------
-(void) bcc {
    
	//	Branch if Carry Clear
	[self do_branch:(!self->cc.bit.c)];
	
	self->instruction = [NSString stringWithFormat:@"bcc"];
}
//----------------------------------------------------------------------------
-(void) lbcc {
    
	[self do_longBranch:(!self->cc.bit.c)];
	
	self->instruction = [NSString stringWithFormat:@"lbcc"];
}
//----------------------------------------------------------------------------
-(void) bcs {
    
	[self do_branch:(self->cc.bit.c)];
}
//----------------------------------------------------------------------------
-(void) lbcs {
    
	[self do_longBranch:(self->cc.bit.c)];
	
	self->instruction = [NSString stringWithFormat:@"bcs"];
}
//----------------------------------------------------------------------------
-(void) beq {
    
	[self do_branch:self->cc.bit.z];
	self->instruction = [NSString stringWithFormat:@"beq" ];
}
//----------------------------------------------------------------------------
-(void) lbeq {
    
	[self do_longBranch:self->cc.bit.z];

	self->instruction = [NSString stringWithFormat:@"lbeq" ];
}
//----------------------------------------------------------------------------
-(void) bge {
    
	[self do_branch: !   (self->cc.bit.n ^ self->cc.bit.v)];
	
	self->instruction = [NSString stringWithFormat:@"bge"];
}
//----------------------------------------------------------------------------
-(void) lbge {
    
	[self do_longBranch:!(self->cc.bit.n ^ self->cc.bit.v)];
	
	self->instruction = [NSString stringWithFormat:@"lbge"];
}
//----------------------------------------------------------------------------
-(void) bgt {
    
	[self do_branch:!(self->cc.bit.z & (self->cc.bit.n ^ self->cc.bit.v))];
	
	self->instruction = [NSString stringWithFormat:@"bgt"];
}
//----------------------------------------------------------------------------
-(void) lbgt {
    
	[self do_longBranch:!(self->cc.bit.z & (self->cc.bit.n ^ self->cc.bit.v))];
	
	self->instruction = [NSString stringWithFormat:@"lbgt"];
}
//----------------------------------------------------------------------------
-(void) bhi {
    
	[self do_branch:!(self->cc.bit.c | self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"bhi" ];
}
//----------------------------------------------------------------------------
-(void) lbhi {
    
	[self do_longBranch:!(self->cc.bit.c | self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"lbhi" ];
}
//----------------------------------------------------------------------------
-(void) bita
{
	[self help_bit:self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"bita" ];
}
//----------------------------------------------------------------------------
-(void) bitb
{
    [self help_bit:self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"bitb" ];
}
//----------------------------------------------------------------------------
-(void) help_bit:(UInt8) source
{
	UInt8 t = source & [self fetch_operand];
	self->cc.bit.n = btst(t, 7);
	self->cc.bit.v = 0;
	self->cc.bit.z = !t;
}
//----------------------------------------------------------------------------
-(void) ble
{
	[self do_branch:(self->cc.bit.z | (self->cc.bit.n ^ self->cc.bit.v))];
	
	self->instruction = [NSString stringWithFormat:@"ble" ];
}
//----------------------------------------------------------------------------
-(void) lble
{
	[self do_longBranch:(self->cc.bit.z | (self->cc.bit.n ^ self->cc.bit.v))];
	
	self->instruction = [NSString stringWithFormat:@"lble" ];
}
//----------------------------------------------------------------------------
-(void) bls
{
	[self do_branch:(self->cc.bit.c | self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"lbs" ];
}
//----------------------------------------------------------------------------
-(void) lbls
{
	[self do_longBranch:(self->cc.bit.c | self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"lbls" ];
}
//----------------------------------------------------------------------------
-(void) blt
{
	[self do_branch:(self->cc.bit.n ^ self->cc.bit.v)];
	
	self->instruction = [NSString stringWithFormat:@"blt" ];
}
//----------------------------------------------------------------------------
-(void) lblt
{
	[self do_longBranch:(self->cc.bit.n ^ self->cc.bit.v)];
	
	self->instruction = [NSString stringWithFormat:@"lblt" ];
}
//----------------------------------------------------------------------------
-(void) bmi
{
	[self do_branch:(self->cc.bit.n)];
	
	self->instruction = [NSString stringWithFormat:@"bmi" ];
}
//----------------------------------------------------------------------------
-(void) lbmi
{
	[self do_longBranch:(self->cc.bit.n)];
	
	self->instruction = [NSString stringWithFormat:@"lbmi" ];
}
//----------------------------------------------------------------------------
-(void) bne
{
	[self do_branch:(!self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"bne" ];
}
//----------------------------------------------------------------------------
-(void) lbne
{
	[self do_longBranch:(!self->cc.bit.z)];
	
	self->instruction = [NSString stringWithFormat:@"lbne" ];
}
//----------------------------------------------------------------------------
-(void) bpl
{
	[self do_branch:(!self->cc.bit.n)];
	
	self->instruction = [NSString stringWithFormat:@"bpl" ];
}
//----------------------------------------------------------------------------
-(void) lbpl
{
	[self do_longBranch:(!self->cc.bit.n)];
	
	self->instruction = [NSString stringWithFormat:@"lbpl" ];
}
//----------------------------------------------------------------------------
-(void) bra
{
	[self do_branch:1];
	self->instruction = [NSString stringWithFormat:@"bra at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) lbra
{
	[self do_longBranch:1];
	
	self->instruction = [NSString stringWithFormat:@"lbra at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) brn
{
	[self do_branch:0];
	
	self->instruction = [NSString stringWithFormat:@"brn" ];
}
//----------------------------------------------------------------------------
-(void) lbrn
{
	[self do_longBranch:0];
	
	self->instruction = [NSString stringWithFormat:@"lbrn" ];
}
//----------------------------------------------------------------------------
-(void) bsr
{
	UInt8	offset = [self fetch];
	[self->delegate write:(--s) data:(UInt8)self->pc];
	[self->delegate write:(--s) data:(UInt8)(self->pc >> 8)];
	self->pc += [self extend8:(offset)];
	
	self->instruction = [NSString stringWithFormat:@"bsr at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) lbsr
{
	UInt16	offset = [self fetch_word];
	[self->delegate write:(--self->s) data:(UInt8)self->pc];
	[self->delegate write:(--self->s) data:(UInt8)(self->pc >> 8)];
	self->pc += offset;
	
	self->instruction = [NSString stringWithFormat:@"lbsr at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) bvc
{
	[self do_branch:!self->cc.bit.v];
	
	self->instruction = [NSString stringWithFormat:@"bvc" ];
}
//----------------------------------------------------------------------------
-(void) lbvc
{
	[self do_longBranch:!self->cc.bit.v];
	
	self->instruction = [NSString stringWithFormat:@"lbvc" ];
}
//----------------------------------------------------------------------------
-(void) bvs
{
	[self do_branch:self->cc.bit.v];
	
	self->instruction = [NSString stringWithFormat:@"bvs" ];
}
//----------------------------------------------------------------------------
-(void) lbvs
{
	[self do_longBranch:self->cc.bit.v];
	
	self->instruction = [NSString stringWithFormat:@"lbvs" ];
}
//----------------------------------------------------------------------------
-(void) clra
{
	[self help_clr:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"clra" ];
}
//----------------------------------------------------------------------------
-(void) clrb
{
	[self help_clr:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"clrb" ];
}
//----------------------------------------------------------------------------
-(void) clr
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_clr:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"clr at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_clr:(UInt8*) reg {
    
	self->cc.all &= 0xf0;
	self->cc.all |= 0x04;
	*reg = 0;
}
//----------------------------------------------------------------------------
-(void) cmpa
{
    UInt8	operand = [self fetch_operand];
	[self help_cmp8:self->acc.byte.a operand:operand];
	
	self->instruction = [NSString stringWithFormat:@"cmpa" ];
}
//----------------------------------------------------------------------------
-(void) cmpb
{
    UInt8	operand = [self fetch_operand];
	[self help_cmp8:self->acc.byte.b operand:operand];
	
	self->instruction = [NSString stringWithFormat:@"cmpb" ];
}
//----------------------------------------------------------------------------
-(void) help_cmp8:(UInt8) reg operand:(UInt8)operand {
    
    //reg = 0x0F + '0';
    //operand = '9';
	
	UInt8 m = (~operand) + 1;
    
	/* autre solution
     {
		UInt16	t = reg + m;
		
		self->cc.bit.v = (((reg ^ operand ^ t ^ ( t >> 1 )) &0x80 ));
		
        bool otherC = btst(t, 8);
        
		self->cc.bit.c = btst16(t, 8);
		reg = t & 0xff;
	}*/
    {
		UInt8	t = (reg & 0x7f) + (m & 0x7f);
		cc.bit.v = btst(t, 7);
	}
    
	{
		UInt16	t = reg + m;
		cc.bit.c = btst16(t, 8);
		reg = t & 0xff;
	}

    
	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.c = !self->cc.bit.c;
	self->cc.bit.n = btst(reg, 7);
	self->cc.bit.z = !reg;
    
    //bool ble = (self->cc.bit.z | (self->cc.bit.n ^ self->cc.bit.v));
}
//----------------------------------------------------------------------------
-(void) cmpd
{
	[self help_cmp16:acc.d];
	
	self->instruction = [NSString stringWithFormat:@"cmpd" ];
}
//----------------------------------------------------------------------------
-(void) cmpx
{
	[self help_cmp16:self->x];
	
	self->instruction = [NSString stringWithFormat:@"cmpx X=0x%04X", self->x ];
}
//----------------------------------------------------------------------------
-(void) cmpy
{
	[self help_cmp16:self->y];
	
	self->instruction = [NSString stringWithFormat:@"cmpy" ];
}
//----------------------------------------------------------------------------
-(void) cmpu
{
	[self help_cmp16:self->u];
	
	self->instruction = [NSString stringWithFormat:@"cmpu" ];
}
//----------------------------------------------------------------------------
-(void) cmps
{
	[self help_cmp16:self->s];
	
	self->instruction = [NSString stringWithFormat:@"cmps" ];
}
//----------------------------------------------------------------------------
-(void) help_cmp16:(UInt16) reg {
    
	UInt16	operand = [self fetch_word_operand];
	UInt16 m = (~operand) + 1;
    
	/*
     {
		UInt32	t = (UInt32)reg + m;
		
		self->cc.bit.v = (((reg ^ operand ^ t ^( t >> 1 )) & 0x8000 ));
		
		self->cc.bit.c = btst32(t, 16);
		reg = (UInt16)(t & 0xffff);
	}*/
    
    {
		UInt16	t = (reg & 0x7fff) + (m & 0x7fff);
		cc.bit.v = btst(t, 15);
	}
    
	{
		UInt32	t = (UInt32)reg + m;
		cc.bit.c = btst32(t, 16);
		reg = (UInt16)(t & 0xffff);
	}

	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.c = !self->cc.bit.c;
	self->cc.bit.n = btst16(reg, 15);
	self->cc.bit.z = !reg;
    
    //  for test only: bool equation for each branch
    //bool bls = (self->cc.bit.c | self->cc.bit.z);
}
//----------------------------------------------------------------------------
-(void) coma
{
	[self help_com:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"coma" ];
}
//----------------------------------------------------------------------------
-(void) cwai {
    
	self->instruction = [NSString stringWithFormat:@"cwai" ];
}
//----------------------------------------------------------------------------
-(void) comb
{
	[self help_com:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"comb" ];
}
//----------------------------------------------------------------------------
-(void) com
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_com:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"com at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_com:(UInt8*) reg {
    
	*reg = ~*reg;
	self->cc.bit.c = 1;
	self->cc.bit.v = 0;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) daa
{
	UInt8	c = 0;
	UInt8	lsn = (self->acc.byte.a & 0x0f);
	UInt8	msn = (self->acc.byte.a & 0xf0) >> 4;
    
	if (self->cc.bit.h || (lsn > 9)) {
		c |= 0x06;
	}
    
	if (self->cc.bit.c ||
	    (msn > 9) ||
	    ((msn > 8) && (lsn > 9))) {
		c |= 0x60;
	}
    
	{
		UInt16	t = (UInt16)self->acc.byte.a + c;
		self->cc.bit.c = btst16(t, 8);
		self->acc.byte.a = (UInt8)t;
	}
    
	self->cc.bit.n = btst(self->acc.byte.a, 7);
	self->cc.bit.z = !self->acc.byte.a;
}
//----------------------------------------------------------------------------
-(void) deca
{
	[self help_dec:(&self->acc.byte.a)];

	self->instruction = [NSString stringWithFormat:@"deca" ];
}
//----------------------------------------------------------------------------
-(void) decb
{
	[self help_dec:(&self->acc.byte.b)];

	self->instruction = [NSString stringWithFormat:@"decb" ];
}
//----------------------------------------------------------------------------
-(void) dec
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_dec:&m];
	[self->delegate write:addr data:m];

	self->instruction = [NSString stringWithFormat:@"dec at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_dec:(UInt8*) reg {
    
	self->cc.bit.v = (*reg == 0x80);
	*reg = *reg - 1;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) eora
{
	[self help_eor:(&self->acc.byte.a)];

	self->instruction = [NSString stringWithFormat:@"eora" ];
}
//----------------------------------------------------------------------------
-(void) eorb
{
	[self help_eor:(&self->acc.byte.b)];

	self->instruction = [NSString stringWithFormat:@"eorb" ];
}
//----------------------------------------------------------------------------
-(void) help_eor:(UInt8*) reg {
    
	*reg = *reg ^ [self fetch_operand];
	cc.bit.v = 0;
	cc.bit.n = btst(*reg, 7);
	cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) swap8:(UInt8*) r1 :(UInt8*) r2 {
    
	UInt8	t;
	t = *r1; *r1 = *r2; *r2 = t;
}
//----------------------------------------------------------------------------
-(void) swap16:(UInt16*) r1 :(UInt16 *) r2 {
    
	UInt16	t;
	t = *r1; *r1 = *r2; *r2 = t;
}
//----------------------------------------------------------------------------
-(void) exg
{

	self->instruction = [NSString stringWithFormat:@"exg" ];

	int	r1, r2;
	UInt8	w = [self fetch];
	r1 = (w & 0xf0) >> 4;
	r2 = (w & 0x0f) >> 0;
	if (r1 <= 5) {
		if (r2 > 5) {
			//invalid("exchange reg");
			return;
		}
		[self swap16:[self wordrefreg:r2] :[self wordrefreg:r1]];
	}
    else if (r1 >= 8 && r2 <= 11) {
		if (r2 < 8 || r2 > 11) {
			//invalid("exchange reg");
			return;
		}
		[self swap8:[self byterefreg:r2] :[self byterefreg:r1]];
	}
    else  {
		//invalid("exchange reg");
		return;
	}
}
//----------------------------------------------------------------------------
-(void) inca
{
	[self help_inc:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"inca" ];

}
//----------------------------------------------------------------------------
-(void) incb
{
	[self help_inc:&self->acc.byte.b ];
	
	self->instruction = [NSString stringWithFormat:@"incb" ];

}
//----------------------------------------------------------------------------
-(void) inc
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_inc:&m];
	[self->delegate write:addr data:m];
	
		self->instruction = [NSString stringWithFormat:@"inc at PC=$%04X", addr ];

}
//----------------------------------------------------------------------------
-(void) help_inc:(UInt8*) reg
{
	cc.bit.v = (*reg == 0x7f);
	*reg = *reg + 1;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) jmp
{
	self->pc = [self fetch_effective_address];
	
	self->instruction = [NSString stringWithFormat:@"jmp at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) jsr
{
	UInt16	addr = [self fetch_effective_address];
	[self->delegate write:(--s) data:self->pc];
	[self->delegate write:(--s) data:self->pc >> 8];
	self->pc = addr;
	
	self->instruction = [NSString stringWithFormat:@"jsr at PC=$%04X", self->pc ];
}
//----------------------------------------------------------------------------
-(void) lda {	

	[self help_ld8:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"lda a<=$%02X", self->acc.byte.a];
}
//----------------------------------------------------------------------------
-(void) ldb {	

	[self help_ld8:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"ldb a<=$%02X", self->acc.byte.b];
}
//----------------------------------------------------------------------------
-(void) help_ld8:(UInt8*) reg {	

	*reg = [self fetch_operand];
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.v = 0;
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) ldd
{
	[self help_ld16:&self->acc.d];
	
	self->instruction = [NSString stringWithFormat:@"ldd #$%04X", self->acc.d ];
}
//----------------------------------------------------------------------------
-(void) ldx
{
	[self help_ld16:&self->x];
	
	self->instruction = [NSString stringWithFormat:@"ldx #$%04X", self->x ];	
}
//----------------------------------------------------------------------------
-(void) ldy
{
	[self help_ld16:&self->y];
	self->instruction = [NSString stringWithFormat:@"ldy #$%04X", self->y ];
}
//----------------------------------------------------------------------------
-(void) lds
{
	[self help_ld16:&self->s];
	self->instruction = [NSString stringWithFormat:@"lds #$%04X", self->s];
}
//----------------------------------------------------------------------------
-(void) ldu
{
	[self help_ld16:&self->u];
	self->instruction = [NSString stringWithFormat:@"ldu #$%04X", self->u];
}
//----------------------------------------------------------------------------
-(void) help_ld16:(UInt16*) reg
{
	*reg = [self fetch_word_operand];
	cc.bit.n = btst16(*reg, 15);
	cc.bit.v = 0;
	cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) leax
{
	self->x = [self fetch_effective_address];
	cc.bit.z = !self->x;
	
	self->instruction = [NSString stringWithFormat:@"leax address=$%04X", self->x ];
}
//----------------------------------------------------------------------------
-(void) leay
{
	self->y = [self fetch_effective_address];
	cc.bit.z = !self->y;
	
	self->instruction = [NSString stringWithFormat:@"leay address=$%04X", self->y ];
}
//----------------------------------------------------------------------------
-(void) leas
{
	self->s = [self fetch_effective_address];
	
	self->instruction = [NSString stringWithFormat:@"leas address=$%04X", self->s ];
}
//----------------------------------------------------------------------------
-(void) leau
{
	self->u = [self fetch_effective_address];
	
	self->instruction = [NSString stringWithFormat:@"leau address=$%04X", self->u ];
}
//----------------------------------------------------------------------------
-(void) lsla
{
	[self help_lsl:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"lsla" ];
}
//----------------------------------------------------------------------------
-(void) lslb
{
	[self help_lsl:&self->acc.byte.b];

		self->instruction = [NSString stringWithFormat:@"lslb" ];
}
//----------------------------------------------------------------------------
-(void) lsl
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_lsl:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"lsl at $%04X", addr ];

}
//----------------------------------------------------------------------------
-(void) help_lsl:(UInt8*) reg
{
	cc.bit.c = btst(*reg, 7);
	cc.bit.v = btst(*reg, 7) ^ btst(*reg, 6);
	*reg <<= 1;
	cc.bit.n = btst(*reg, 7);
	cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) lsra
{
	[self help_lsr:&self->acc.byte.a];
	
		self->instruction = [NSString stringWithFormat:@"lsra" ];

}
//----------------------------------------------------------------------------
-(void) lsrb
{
	[self help_lsr:&self->acc.byte.b];
	
		self->instruction = [NSString stringWithFormat:@"lsrb" ];

}
//----------------------------------------------------------------------------
-(void) lsr
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
    [self help_lsr:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"lsr at %04X", addr ];

}
//----------------------------------------------------------------------------
-(void) help_lsr:(UInt8*) reg
{
	self->cc.bit.c = btst(*reg, 0);
	*reg >>= 1;	/* Shift UInt16 right */
	self->cc.bit.n = 0;
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) mul
{
	self->acc.d = self->acc.byte.a * self->acc.byte.b;
	self->cc.bit.c = btst(self->acc.byte.b, 7);
	self->cc.bit.z = !self->acc.d;
	
	self->instruction = [NSString stringWithFormat:@"mul" ];
}
//----------------------------------------------------------------------------
-(void) nega
{
	[self help_neg:&self->acc.byte.a];

	self->instruction = [NSString stringWithFormat:@"nega" ];
}
//----------------------------------------------------------------------------
-(void) negb
{
	[self help_neg:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"negb" ];
}
//----------------------------------------------------------------------------
-(void) neg
{
	UInt16 	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
    [self help_neg:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"neg at $%04X", addr ];

}
//----------------------------------------------------------------------------
-(void) help_neg:(UInt8*) reg
{
	cc.bit.v = (*reg == 0x80);
	{
		UInt16	t = (UInt16)((~*reg) & 0xff) + 1;
		cc.bit.c = btst16(t, 8);
		*reg = t & 0xff;
	}
    
	cc.bit.n = btst(*reg, 7);
	cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) nop
{
	self->instruction = [NSString stringWithFormat:@"nop" ];
}
//----------------------------------------------------------------------------
-(void) ora
{
	[self help_or:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"ora" ];
}
//----------------------------------------------------------------------------
-(void) orb
{
	[self help_or:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"orb" ];

}
//----------------------------------------------------------------------------
-(void) help_or:(UInt8*) reg
{
	*reg = *reg | [self fetch_operand];
	self->cc.bit.v = 0;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) orcc
{
	UInt8	operand = [self fetch_operand];
	self->cc.all |= operand;
	
	self->instruction = [NSString stringWithFormat:@"orcc #$%X", operand ];
}
//----------------------------------------------------------------------------
-(void) pshs
{
	[self help_psh:[self fetch] :&self->s :&self->u];
	self->instruction = [NSString stringWithFormat:@"pshs (...)" ];
}
//----------------------------------------------------------------------------
-(void) pshu
{
	[self help_psh:[self fetch] :&self->u :&self->s];

	self->instruction = [NSString stringWithFormat:@"pshu (...)" ];
}
//----------------------------------------------------------------------------
-(void) help_psh:(UInt8) w :(UInt16*) stackPtr :(UInt16*) reg
{
	if (btst(w, 7)) {
		[self->delegate write:--(*stackPtr) data:(UInt8)self->pc];
		[self->delegate write:--(*stackPtr) data:(UInt8)(self->pc >> 8)];
	}
	if (btst(w, 6)) {
		[self->delegate write:--(*stackPtr) data:(UInt8)*reg];
        [self->delegate write:--(*stackPtr) data:(UInt8)(*reg >> 8)];
	}
	if (btst(w, 5)) {
		[self->delegate write:--(*stackPtr) data:(UInt8)self->y];
        [self->delegate write:--(*stackPtr) data:(UInt8)(self->y >> 8)];
	}
	if (btst(w, 4)) {
		[self->delegate write:--(*stackPtr) data:(UInt8)self->x];
        [self->delegate write:--(*stackPtr) data:(UInt8)(self->x >> 8)];
	}
    if (btst(w, 3)) [self->delegate write:--(*stackPtr) data:(UInt8)self->dp];
    if (btst(w, 2)) [self->delegate write:--(*stackPtr) data:(UInt8)self->acc.byte.b];
    if (btst(w, 1)) [self->delegate write:--(*stackPtr) data:(UInt8)self->acc.byte.a];
    if (btst(w, 0)) [self->delegate write:--(*stackPtr) data:(UInt8)self->cc.all];
}
//----------------------------------------------------------------------------
-(void) puls
{
	UInt8	w = [self fetch];
    [self help_pul:w :&self->s :&self->u];
	self->instruction = [NSString stringWithFormat:@"puls" ];
}
//----------------------------------------------------------------------------
-(void) pulu
{
	UInt8	w = [self fetch];
    [self help_pul:w :&self->u :&self->s];
	
	self->instruction = [NSString stringWithFormat:@"pulu" ];
}
//----------------------------------------------------------------------------
-(void) help_pul:(UInt8) w :(UInt16*) stackPtr :(UInt16*) reg
{
	if (btst(w, 0)) self->cc.all = [self->delegate read:(*stackPtr)++];
	if (btst(w, 1)) self->acc.byte.a = [self->delegate read:(*stackPtr)++];
	if (btst(w, 2)) self->acc.byte.b = [self->delegate read:(*stackPtr)++];
	if (btst(w, 3)) self->dp = [self->delegate read:(*stackPtr)++];
	
	if (btst(w, 4)) {
		self->x = [self readWord16:(*stackPtr)];
		*stackPtr += 2;
	}
	if (btst(w, 5)) {
		self->y = [self readWord16:(*stackPtr)];
		*stackPtr += 2;
	}
	if (btst(w, 6)) {
		*reg = [self readWord16:(*stackPtr)];
		*stackPtr += 2;
	}
	if (btst(w, 7)) {
		self->pc = [self readWord16:(*stackPtr)];
		*stackPtr += 2;
	}
}
//----------------------------------------------------------------------------
-(void) rola {
    
	[self help_rol:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"rola" ];
}
//----------------------------------------------------------------------------
-(void) rolb {
    
	[self help_rol:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"rolb" ];
}
//----------------------------------------------------------------------------
-(void) rol {
    
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_rol:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"rol at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_rol:(UInt8*) reg {
    
	int	oc = cc.bit.c;
	cc.bit.v = btst(*reg, 7) ^ btst(*reg, 6);
	cc.bit.c = btst(*reg, 7);
	*reg = *reg << 1;
	if (oc) bset(reg, 0);
	cc.bit.n = btst(*reg, 7);
	cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) rora {
    
	[self help_ror:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"rora" ];
}
//----------------------------------------------------------------------------
-(void) rorb
{
	[self help_ror:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"rorb" ];
}
//----------------------------------------------------------------------------
-(void) ror
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m = [self->delegate read:addr];
	[self help_ror:&m];
	[self->delegate write:addr data:m];
	
	self->instruction = [NSString stringWithFormat:@"ror at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_ror:(UInt8*) reg
{
	int	oc = cc.bit.c;
	self->cc.bit.c = btst(*reg, 0);
	*reg = *reg >> 1;
	if (oc) {
		bset(reg, 7);
	}
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !x;
}
//----------------------------------------------------------------------------
-(void) rti
{
	[self help_pul:0x01 :&self->s :&self->u];
	if (self->cc.bit.e) {
		[self help_pul:0xfe :&self->s :&self->u];
	}
	self->instruction = [NSString stringWithFormat:@"rti" ];
}
//----------------------------------------------------------------------------
-(void) rts
{
	self->pc = [self readWord16:(self->s)];
	self->s += 2;
	
	self->instruction = [NSString stringWithFormat:@"rts" ];
}
//----------------------------------------------------------------------------
-(void) sbca
{
	[self help_sbc:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"sbca" ];
}
//----------------------------------------------------------------------------
-(void) sbcb
{
	[self help_sbc:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"sbcb" ];
}
//----------------------------------------------------------------------------
-(void) help_sbc:(UInt8 *) reg
{
	UInt8	operand = [self fetch_operand];
	UInt8 m = (~operand) + 1 - self->cc.bit.c;
    
	/*{
		UInt8	t = (*reg & 0x7f) + (m & 0x7f);
		self->cc.bit.v = btst(t, 7);
		
	}*/
    
	{
		UInt16	t = *reg + m;
		
		self->cc.bit.v = (((*reg ^ operand ^ t ^ ( t >> 1 )) & 0x80 ));
		
		self->cc.bit.c = btst16(t, 8);
		*reg = t & 0xff;
	}
    
	self->cc.bit.v ^= self->cc.bit.c;
	self->cc.bit.c = !cc.bit.c;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) sex
{
	self->cc.bit.n = btst(self->acc.byte.b, 7);
	self->cc.bit.z = !self->acc.byte.b;
	self->acc.byte.a = self->cc.bit.n ? 255 : 0;
	
	self->instruction = [NSString stringWithFormat:@"sex" ];
}
//----------------------------------------------------------------------------
-(void) sta
{
	[self help_st8:self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"sta" ];
}
//----------------------------------------------------------------------------
-(void) stb
{
	[self help_st8:self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"stb" ];
}
//----------------------------------------------------------------------------
-(void) help_st8:(UInt8) reg
{
	UInt16	addr = [self fetch_effective_address];
	[self->delegate write:addr data:reg];
	self->cc.bit.v = 0;
	self->cc.bit.n = btst(reg, 7);
	self->cc.bit.z = !reg;
}
//----------------------------------------------------------------------------
-(void) std
{
	[self help_st:self->acc.d];
	
	self->instruction = [NSString stringWithFormat:@"stdx" ];
}
//----------------------------------------------------------------------------
-(void) stx
{
	[self help_st:self->x];
	
	self->instruction = [NSString stringWithFormat:@"stx" ];
}
//----------------------------------------------------------------------------
-(void) sty
{
	[self help_st:self->y];
	
	self->instruction = [NSString stringWithFormat:@"sty" ];
}
//----------------------------------------------------------------------------
-(void) sts
{
    [self help_st:self->s];
	
	self->instruction = [NSString stringWithFormat:@"sts" ];
}
//----------------------------------------------------------------------------
-(void) stu
{
	[self help_st:self->u];
	
	self->instruction = [NSString stringWithFormat:@"stu" ];
}
//----------------------------------------------------------------------------
-(void) help_st:(UInt16) reg
{
	UInt16	addr = [self fetch_effective_address];
	[self writeWord16:addr data:reg];
	self->cc.bit.v = 0;
	self->cc.bit.n = btst16(reg, 15);
	self->cc.bit.z = !reg;
}
//----------------------------------------------------------------------------
-(void) suba
{
	[self help_sub8:&self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"suba" ];
}
//----------------------------------------------------------------------------
-(void) subb
{
	[self help_sub8:&self->acc.byte.b];
	
	self->instruction = [NSString stringWithFormat:@"subb" ];
}
//----------------------------------------------------------------------------
-(void) help_sub8:(UInt8*) reg
{
	UInt8	op = [self fetch_operand];
	UInt8 m = (~op) + 1;
    
	/*{
		UInt8	t = (*reg & 0x7f) + (m & 0x7f);
		self->cc.bit.v = btst(t, 7);
	}*/
    
	{
		UInt16	t = *reg + m;
		
		self->cc.bit.v = (((*reg ^ op ^ t ^ ( t >> 1 )) & 0x80 ));	//	new way overflow
		
		self->cc.bit.c = btst16(t, 8);
		*reg = t & 0xff;
	}
    
	self->cc.bit.v ^= cc.bit.c;
	self->cc.bit.c = !cc.bit.c;
	self->cc.bit.n = btst(*reg, 7);
	self->cc.bit.z = !*reg;
}
//----------------------------------------------------------------------------
-(void) subd
{
	UInt16	operand = [self fetch_word_operand];
	UInt16 m = (~operand) + 1;
    
	/*{
		UInt16	t = (acc.d & 0x7fff) + (m & 0x7fff);
		self->cc.bit.v = btst16(t, 15);
	}*/
    
	{
		UInt32	t = (UInt32)self->acc.d + m;
		
		self->cc.bit.v = (((acc.d ^ operand ^ t ^ ( t >> 1 )) & 0x8000 ));
		
		self->cc.bit.c = btst16(t, 16);
		self->acc.d = (UInt16)(t & 0xffff);
	}
    
	self->cc.bit.v ^= cc.bit.c;
	self->cc.bit.c = !cc.bit.c;
	self->cc.bit.n = btst16(self->acc.d, 15);
	self->cc.bit.z = !self->acc.d;
	
	self->instruction = [NSString stringWithFormat:@"subd" ];
}
//----------------------------------------------------------------------------
-(void) swi
{
	self->cc.bit.e = 1;
	[self help_psh:0xFF :&self->s :&self->u ];
	self->cc.bit.f = cc.bit.i = 1;
	self->pc = [self readWord16:VECTOR_SWI];
	
	self->instruction = [NSString stringWithFormat:@"swi" ];
}
//----------------------------------------------------------------------------
-(void) swi2
{
	self->cc.bit.e = 1;
	[self help_psh:0xFF  :&self->s :&self->u];
    self->pc = [self readWord16:VECTOR_SWI2];
	
	self->instruction = [NSString stringWithFormat:@"swi2" ];
}
//----------------------------------------------------------------------------
-(void) swi3
{
	self->cc.bit.e = 1;
	[self help_psh:0xFF :&(self->s) :&self->u];
    self->pc = [self readWord16:VECTOR_SWI3];
	
	self->instruction = [NSString stringWithFormat:@"swi3" ];
}
//----------------------------------------------------------------------------
-(void) sync {
    
	self->instruction = [NSString stringWithFormat:@"sync" ];
}
//----------------------------------------------------------------------------
-(void) tfr
{
	int	r1, r2;
	UInt8	w = [self fetch];
	r1 = (w & 0xf0) >> 4;
	r2 = (w & 0x0f) >> 0;
	if (r1 <= 5) {
		if (r2 > 5) {
			//invalid("transfer reg");
			return;
		}
		*[self wordrefreg:r2] = *[self wordrefreg:r1 ];
	} else if (r1 >= 8 && r2 <= 11) {
		if (r2 < 8 || r2 > 11) {
			//invalid("transfer reg");
			return;
		}
		*[self byterefreg:r2] = *[self byterefreg:r1];
	} else  {
		//invalid("transfer reg");
		return;
	}
	
	self->instruction = [NSString stringWithFormat:@"tfr" ];
}
//----------------------------------------------------------------------------
-(void) tsta
{
	[self help_tst:self->acc.byte.a];
	
	self->instruction = [NSString stringWithFormat:@"tsta" ];
}
//----------------------------------------------------------------------------
-(void) tstb
{
	[self help_tst:self->acc.byte.b];

	self->instruction = [NSString stringWithFormat:@"tstb" ];
}
//----------------------------------------------------------------------------
-(void) tst
{
	UInt16	addr = [self fetch_effective_address];
	UInt8	m =[self->delegate read:addr];
	[self help_tst:m];
	
	self->instruction = [NSString stringWithFormat:@"tst at $%04X", addr ];
}
//----------------------------------------------------------------------------
-(void) help_tst:(UInt8) reg
{
	self->cc.bit.v = 0;
	self->cc.bit.n = btst(reg, 7);
	self->cc.bit.z = !reg;
}
//----------------------------------------------------------------------------
-(void) do_branch:(int )condition
{

	UInt16 offset = [self extend8:[self fetch_operand]];
	if (condition ) {
		self->pc += offset;
	}
}
//----------------------------------------------------------------------------
-(void) do_longBranch:(int) condition
{
	UInt16 offset = [self fetch_word_operand];
	if (condition ) {
		self->pc += offset;
	}
}
//----------------------------------------------------------------------------
-(void) pushStackS8:(UInt8)data {
	
	[self->delegate write:--self->s data:data];
}
//----------------------------------------------------------------------------
-(void) pushStackS16:(UInt16)data {
	
	[self->delegate write:--self->s data:(UInt8)data];
    [self->delegate write:--self->s data:(UInt8)(data >> 8)];
}
//---------------------------------------------------------------------------
-(void) execute {
    
	self->ir = [self fetch];
    
	/* Select addressing mode */
	switch (self->ir & 0xf0) {
		case 0x00: case 0x90: case 0xd0:
			mode = direct; break;
		case 0x20:
			mode = relative; break;
		case 0x30: case 0x40: case 0x50:
			if (self->ir < 0x34) {
				mode = indexed;
			} else if (self->ir < 0x38) {
				mode = immediate;
			} else {
				mode = inherent;
			}
			break;
		case 0x60: case 0xa0: case 0xe0:
			mode = indexed; break;
		case 0x70: case 0xb0: case 0xf0:
			mode = extended; break;
		case 0x80: case 0xc0:
			if (self->ir == 0x8d) {
				mode = relative;
			} else {
				mode = immediate;
			}
			break;
		case 0x10:
			switch (self->ir & 0x0f) {
				case 0x02: case 0x03: case 0x09:
				case 0x0d: case 0x0e: case 0x0f:
					mode = inherent; break;
				case 0x06: case 0x07:
					mode = relative; break;
				case 0x0a: case 0x0c:
					mode = immediate; break;
				case 0x00: case 0x01:
					self->ir <<= 8;
					self->ir |= [self fetch];
					switch (self->ir & 0xf0) {
						case 0x20:
							mode = relative; break;
						case 0x30:
							mode = inherent; break;
						case 0x80: case 0xc0:
							mode = immediate; break;
						case 0x90: case 0xd0:
							mode = direct; break;
						case 0xa0: case 0xe0:
							mode = indexed; break;
						case 0xb0: case 0xf0:
							mode = extended; break;
					}
					break;
			}
			break;
	}
    
	/* Select instruction */
	switch (self->ir) {
		case 0x3a:
			[self abx]; break;
		case 0x89: case 0x99: case 0xa9: case 0xb9:
			[self adca]; break;
		case 0xc9: case 0xd9: case 0xe9: case 0xf9:
			[self adcb]; break;
		case 0x8b: case 0x9b: case 0xab: case 0xbb:
			[self adda]; break;
		case 0xcb: case 0xdb: case 0xeb: case 0xfb:
			[self addb]; break;
		case 0xc3: case 0xd3: case 0xe3: case 0xf3:
			[self addd]; break;
		case 0x84: case 0x94: case 0xa4: case 0xb4:
			[self anda]; break;
		case 0xc4: case 0xd4: case 0xe4: case 0xf4:
			[self andb]; break;
		case 0x1c:
			[self andcc]; break;
		case 0x47:
			[self asra]; break;
		case 0x57:
			[self asrb]; break;
		case 0x07: case 0x67: case 0x77:
			[self asr]; break;
		case 0x24:
			[self bcc]; break;
		case 0x25:
			[self bcs]; break;
		case 0x27:
			[self beq]; break;
		case 0x2c:
			[self bge]; break;
		case 0x2e:
			[self bgt]; break;
		case 0x22:
			[self bhi]; break;
		case 0x85: case 0x95: case 0xa5: case 0xb5:
			[self bita]; break;
		case 0xc5: case 0xd5: case 0xe5: case 0xf5:
			[self bitb]; break;
		case 0x2f:
			[self ble]; break;
		case 0x23:
			[self bls]; break;
		case 0x2d:
			[self blt]; break;
		case 0x2b:
			[self bmi]; break;
		case 0x26:
			[self bne]; break;
		case 0x2a:
			[self bpl]; break;
		case 0x20:
			[self bra]; break;
		case 0x16:
			[self lbra]; break;
		case 0x21:
			[self brn]; break;
		case 0x8d:
			[self bsr]; break;
		case 0x17:
			[self lbsr]; break;
		case 0x28:
			[self bvc]; break;
		case 0x29:
			[self bvs]; break;
		case 0x4f:
			[self clra]; break;
		case 0x5f:
			[self clrb]; break;
		case 0x0f: case 0x6f: case 0x7f:
			[self clr]; break;
		case 0x81: case 0x91: case 0xa1: case 0xb1:
			[self cmpa]; break;
		case 0xc1: case 0xd1: case 0xe1: case 0xf1:
			[self cmpb]; break;
		case 0x1083: case 0x1093: case 0x10a3: case 0x10b3:
			[self cmpd]; break;
		case 0x118c: case 0x119c: case 0x11ac: case 0x11bc:
			[self cmps]; break;
		case 0x8c: case 0x9c: case 0xac: case 0xbc:
			[self cmpx]; break;
		case 0x1183: case 0x1193: case 0x11a3: case 0x11b3:
			[self cmpu]; break;
		case 0x108c: case 0x109c: case 0x10ac: case 0x10bc:
			[self cmpy]; break;
		case 0x43:
			[self coma]; break;
		case 0x53:
			[self comb]; break;
		case 0x03: case 0x63: case 0x73:
			[self com]; break;
		case 0x19:
			[self daa]; break;
		case 0x4a:
			[self deca]; break;
		case 0x5a:
			[self decb]; break;
		case 0x0a: case 0x6a: case 0x7a:
			[self dec]; break;
		case 0x88: case 0x98: case 0xa8: case 0xb8:
			[self eora]; break;
		case 0xc8: case 0xd8: case 0xe8: case 0xf8:
			[self eorb]; break;
		case 0x1e:
			[self exg]; break;
		case 0x4c:
			[self inca]; break;
		case 0x5c:
			[self incb]; break;
		case 0x0c: case 0x6c: case 0x7c:
			[self inc]; break;
		case 0x0e: case 0x6e: case 0x7e:
			[self jmp]; break;
		case 0x9d: case 0xad: case 0xbd:
			[self jsr]; break;
		case 0x86: case 0x96: case 0xa6: case 0xb6:
			[self lda]; break;
		case 0xc6: case 0xd6: case 0xe6: case 0xf6:
			[self ldb]; break;
		case 0xcc: case 0xdc: case 0xec: case 0xfc:
			[self ldd]; break;
		case 0x10ce: case 0x10de: case 0x10ee: case 0x10fe:
			[self lds]; break;
		case 0xce: case 0xde: case 0xee: case 0xfe:
			[self ldu]; break;
		case 0x8e: case 0x9e: case 0xae: case 0xbe:
			[self ldx]; break;
		case 0x108e: case 0x109e: case 0x10ae: case 0x10be:
			[self ldy]; break;
		case 0x32:
			[self leas]; break;
		case 0x33:
			[self leau]; break;
		case 0x30:
			[self leax]; break;
		case 0x31:
			[self leay]; break;
		case 0x48:
			[self lsla]; break;
		case 0x58:
			[self lslb]; break;
		case 0x08: case 0x68: case 0x78:
			[self lsl]; break;
		case 0x44:
			[self lsra]; break;
		case 0x54:
			[self lsrb]; break;
		case 0x04: case 0x64: case 0x74:
			[self lsr]; break;
		case 0x3d:
			[self mul]; break;
		case 0x40:
			[self nega]; break;
		case 0x50:
			[self negb]; break;
		case 0x00: case 0x60: case 0x70:
			[self neg]; break;
		case 0x12:
			[self nop]; break;
		case 0x8a: case 0x9a: case 0xaa: case 0xba:
			[self ora]; break;
		case 0xca: case 0xda: case 0xea: case 0xfa:
			[self orb]; break;
		case 0x1a:
			[self orcc]; break;
		case 0x34:
			[self pshs]; break;
		case 0x36:
			[self pshu]; break;
		case 0x35:
			[self puls]; break;
		case 0x37:
			[self pulu]; break;
		case 0x49:
			[self rola]; break;
		case 0x59:
			[self rolb]; break;
		case 0x09: case 0x69: case 0x79:
			[self rol]; break;
		case 0x46:
			[self rora]; break;
		case 0x56:
			[self rorb]; break;
		case 0x06: case 0x66: case 0x76:
			[self ror]; break;
		case 0x3b:
			[self rti]; break;
		case 0x39:
			[self rts]; break;
		case 0x82: case 0x92: case 0xa2: case 0xb2:
			[self sbca]; break;
		case 0xc2: case 0xd2: case 0xe2: case 0xf2:
			[self sbcb]; break;
		case 0x1d:
			[self sex]; break;
		case 0x97: case 0xa7: case 0xb7:
			[self sta]; break;
		case 0xd7: case 0xe7: case 0xf7:
			[self stb]; break;
		case 0xdd: case 0xed: case 0xfd:
			[self std]; break;
		case 0x10df: case 0x10ef: case 0x10ff:
			[self sts]; break;
		case 0xdf: case 0xef: case 0xff:
			[self stu]; break;
		case 0x9f: case 0xaf: case 0xbf:
			[self stx]; break;
		case 0x109f: case 0x10af: case 0x10bf:
			[self sty]; break;
		case 0x80: case 0x90: case 0xa0: case 0xb0:
			[self suba]; break;
		case 0xc0: case 0xd0: case 0xe0: case 0xf0:
			[self subb]; break;
		case 0x83: case 0x93: case 0xa3: case 0xb3:
			[self subd]; break;
		case 0x3f:
			[self swi]; break;
		case 0x103f:
			[self swi2]; break;
		case 0x113f:
			[self swi3]; break;
		case 0x1f:
			[self tfr]; break;
		case 0x4d:
			[self tsta]; break;
		case 0x5d:
            [self tstb]; break;
		case 0x0d: case 0x6d: case 0x7d:
			[self tst]; break;
		case 0x1024:
			[self lbcc]; break;
		case 0x1025:
			[self lbcs]; break;
		case 0x1027:
			[self lbeq]; break;
		case 0x102c:
			[self lbge]; break;
		case 0x102e:
			[self lbgt]; break;
		case 0x1022:
			[self lbhi]; break;
		case 0x102f:
			[self lble]; break;
		case 0x1023:
			[self lbls]; break;
		case 0x102d:
			[self lblt]; break;
		case 0x102b:
			[self lbmi]; break;
		case 0x1026:
			[self lbne]; break;
		case 0x102a:
			[self lbpl]; break;
		case 0x1021:
			[self lbrn]; break;
		case 0x1028:
			[self lbvc]; break;
		case 0x1029:
			[self lbvs]; break;
		default:
		
			self->instruction = [NSString stringWithFormat:@"UNKNOW INST: %04X", self->ir];
            break;			
	}
}

@end


//---------------------------------------------------------------------------
//	Public implementation of EK6809Processor
@implementation EK6809Processor

@synthesize		ir;
@synthesize		pc;
@synthesize		x;
@synthesize		y;
@synthesize		s;
@synthesize		u;

@synthesize		dp;
@synthesize		acc;
@synthesize		cc;

@synthesize		instruction;

//---------------------------------------------------------------------------
- (id) initWithDelegate:(id)theDelegate {  
  
    if (self = [super initWithDelegate:theDelegate]) {
    		
	}           
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------
// 	Core Processor Virtual Methods
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
-(void) displayRegisters {
    
	[self->delegate performSelector:@selector(displayCPU:) withObject:self];
}
//----------------------------------------------------------------------------
-(void) reset {

	self->pc = [self readWord16:VECTOR_RESET];
	self->dp = 0x00;									/* Direct page register = 0x00 */
	self->cc.all = 0x00;								/* Clear all flags */
	self->cc.bit.i = IRQ_DISABLED;						/* IRQ disabled */
	self->cc.bit.f = FIRQ_DISABLED;						/* FIRQ disabled */
	
	self->flagIRQRaised = false;
	self->flagFIRQRaised = false;
	self->flagNMIRaised = false;
    
    self->instruction = [NSString stringWithFormat:@""];

}
//----------------------------------------------------------------------------
-(void) run {


}
//----------------------------------------------------------------------------
-(void) runStep {
    
	//	Before to execute the current next instruction, we check if there is any interrupts
	if( self->flagNMIRaised ) {
	
		self->flagNMIRaised = false;
		
		//	Save required register before to enter in the interrupt code
		[self pushStackS16: self->pc];
        [self pushStackS16: self->u];
        [self pushStackS16: self->y];
        [self pushStackS16: self->x];
        [self pushStackS8: self->dp];
        [self pushStackS8: self->acc.byte.b];
        [self pushStackS8: self->acc.byte.a];
        
		self->cc.bit.e = 1;				 								// Set bit 'Entire' indicating machine state on stack 
        [self pushStackS8: self->cc.all];
        
		//	Mask interrupts during service routine
		self->cc.bit.i = IRQ_DISABLED;				
		self->cc.bit.f = FIRQ_DISABLED;				
		
		self->pc = [self readWord16:VECTOR_NMI];
	}
	else if( self->flagFIRQRaised && self->cc.bit.f == 0) {
	
		self->flagFIRQRaised = false;
		
		[self pushStackS16: self->pc];
        self->cc.bit.e = 0; 											// Clear bit indicating machine state on stack 
        [self pushStackS8: self->cc.all];
           
        self->cc.bit.i = IRQ_DISABLED;
		self->cc.bit.f = FIRQ_DISABLED;									//	Mask interrupts during service routine 
                        		
		self->pc = [self readWord16:VECTOR_FIRQ];
	}
	if( self->flagIRQRaised && self->cc.bit.i == 0) {
	
		self->flagIRQRaised = false;

		[self pushStackS16: self->pc];
        [self pushStackS16: self->u];
        [self pushStackS16: self->y];
        [self pushStackS16: self->x];
        [self pushStackS8: self->dp];
        [self pushStackS8: self->acc.byte.b];
        [self pushStackS8: self->acc.byte.a];
        
		self->cc.bit.e = 1; 											//	Set bit indicating machine state on stack
        [self pushStackS8: self->cc.all];
		
        self->cc.bit.f = FIRQ_DISABLED; 								//	Mask interrupts during service routine

		self->pc = [self readWord16:VECTOR_IRQ];
	}
	else {
	}
	
	//	Run the next instruction	
    [self execute];
}
//----------------------------------------------------------------------------
-(void) sendIRQs:(EKInterrupts *)collected {

	if(collected != nil ) {
	
		if( [collected isSignaled:@"IRQ"] ) {
		
			NSLog(@"6809: IRQ raised");
			self->flagIRQRaised = true;
		}
		else if( [collected isSignaled:@"NMI"] ) {
					
			NSLog(@"6809: NMI raised");
			self->flagNMIRaised = true;
		}
		else if( [collected isSignaled:@"FIRQ"] ) {
		
			NSLog(@"6809: FIRQ raised");
			self->flagFIRQRaised = true;
		}
		else {
			NSLog(@"6809: Unknow interrupt line raised");
		}
	}
}

@end

/*

----------------------------------------------------------------
|                                                              |
|                                                              |
|                           Motorola                           |
|                                                              |
|              666      88888      000      99999              |
|             6        8     8    0   0    9     9             |
|            6         8     8   0   0 0   9     9             |
|            666666     88888    0  0  0    999999             |
|            6     6   8     8   0 0   0         9             |
|            6     6   8     8    0   0         9              |
|             66666     88888      000      9999               |
|                                                              |
|         6809 MICROPROCESSOR Instruction Set Summary          |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                    _________    _________                    |
|                  _|         \__/         |_  ____            |
|             Vss |_|1                   40|_| Halt <--        |
|             ___  _|                      |_                  |
|         --> NMI |_|2                   39|_| XTAL <--        |
|             ___  _|                      |_                  |
|         --> IRQ |_|3                   38|_| EXTAL <--       |
|            ____  _|                      |_  _____           |
|        --> FIRQ |_|4                   37|_| Reset <--       |
|                  _|                      |_                  |
|          <-- BS |_|5                   36|_| MRDY <--        |
|                  _|                      |_                  |
|          <-- BA |_|6                   35|_| Q -->           |
|                  _|                      |_                  |
|             Vcc |_|7                   34|_| E -->           |
|                  _|                      |_  ___ ____        |
|          <-- A0 |_|8                   33|_| DMA/BREQ <--    |
|                  _|                      |_    _             |
|          <-- A1 |_|9                   32|_| R/W -->         |
|                  _|                      |_                  |
|          <-- A2 |_|10       6809       31|_| D0 <-->         |
|                  _|                      |_                  |
|          <-- A3 |_|11                  30|_| D1 <-->         |
|                  _|                      |_                  |
|          <-- A4 |_|12                  29|_| D2 <-->         |
|                  _|                      |_                  |
|          <-- A5 |_|13                  28|_| D3 <-->         |
|                  _|                      |_                  |
|          <-- A6 |_|14                  27|_| D4 <-->         |
|                  _|                      |_                  |
|          <-- A7 |_|15                  26|_| D5 <-->         |
|                  _|                      |_                  |
|          <-- A8 |_|16                  25|_| D6 <-->         |
|                  _|                      |_                  |
|          <-- A9 |_|17                  24|_| D7 <-->         |
|                  _|                      |_                  |
|         <-- A10 |_|18                  23|_| A15 -->         |
|                  _|                      |_                  |
|         <-- A11 |_|19                  22|_| A14 -->         |
|                  _|                      |_                  |
|         <-- A12 |_|20                  21|_| A13 -->         |
|                   |______________________|                   |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|Written by     Jonathan Bowen                                 |
|               Programming Research Group                     |
|               Oxford University Computing Laboratory         |
|               8-11 Keble Road                                |
|               Oxford OX1 3QD                                 |
|               England                                        |
|                                                              |
|               Tel +44-865-273840                             |
|                                                              |
|Created        August 1981                                    |
|Updated        April 1985                                     |
|Issue          1.5                Copyright (C) J.P.Bowen 1985|
----------------------------------------------------------------
----------------------------------------------------------------
|Mnemon.|Op|IHNZVC|IEXD#R|~|Description           |Notes       |
|-------+--+------+------+-+----------------------+------------|
|ABX    |3A|------|X     |3|Add to Index Register |X=X+B       |
|ADCa  s|B9|-*****| XXXXX|5|Add with Carry        |a=a+s+C     |
|ADDa  s|BB|-*****| XXXXX|5|Add                   |a=a+s       |
|ADDD  s|F3|-*****| XXX*X|7|Add to Double acc.    |D=D+s       |
|ANDa  s|B4|--**0-| XXXXX|5|Logical AND           |a=a&s       |
|ANDCC s|1C|?????1|    X |3|Logical AND with CCR  |CC=CC&s     |
|ASL   d|78|--****| XXX X|7|Arithmetic Shift Left |d=d*2       |
|ASLa   |48|--****|X     |2|Arithmetic Shift Left |a=a*2       |
|ASR   d|77|--****| XXX X|7|Arithmetic Shift Right|d=d/2       |
|ASRa   |47|--****|X     |2|Arithmetic Shift Right|a=a/2       |
|BCC   m|24|------|     x|3|Branch if Carry Clear |If C=0      |
|BCS   m|25|------|     x|3|Branch if Carry Set   |If C=1      |
|BEQ   m|27|------|     x|3|Branch if Equal       |If Z=1      |
|BGE   m|2C|------|     x|3|Branch if Great/Equal |If NxV=0    |
|BGT   m|2E|------|     x|3|Branch if Greater Than|If Zv{NxV}=0|
|BHI   m|22|------|     x|3|Branch if Higher      |If CvZ=0    |
|BHS   m|24|------|     x|3|Branch if Higher/Same |If C=0      |
|BITa  s|B5|--**0-| XXXXX|5|Bit Test accumulator  |a&s         |
|BLE   m|2F|------|     x|3|Branch if Less/Equal  |If Zv{NxV}=1|
|BLO   m|25|------|     x|3|Branch if Lower       |If C=1      |
|BLS   m|23|------|     x|3|Branch if Lower/Same  |If CvZ=1    |
|BLT   m|2D|------|     x|3|Branch if Less Than   |If NxV=1    |
|BMI   m|2B|------|     x|3|Branch if Minus       |If N=1      |
|BNE   m|26|------|     x|3|Branch if Not Equal   |If Z=0      |
|BPL   m|2A|------|     x|3|Branch if Plus        |If N=0      |
|BRA   m|20|------|     x|3|Branch Always         |PC=m        |
|BRN   m|21|------|     x|3|Branch Never          |NOP         |
|BSR   m|8D|------|     x|7|Branch to Subroutine  |-[S]=PC,BRA |
|BVC   m|28|------|     x|3|Branch if Overflow Clr|If V=0      |
|BVS   m|29|------|     x|3|Branch if Overflow Set|If V=1      |
|CLR   d|7F|--0100| XXX X|7|Clear                 |d=0         |
|CLRa   |4F|--0100|X     |2|Clear accumulator     |a=0         |
|CMPa  s|B1|--****| XXXXX|5|Compare               |a-s         |
|CMPD  s|B3|--****| XXX*X|8|Compare Double acc.   |D-s    (10H)|
|CMPS  s|BC|--****| XXX*X|8|Compare Stack pointer |S-s    (11H)|
|CMPU  s|B3|--****| XXX*X|8|Compare User stack ptr|U-s    (11H)|
|CMPi  s|BC|--****| XXX*X|7|Compare               |i-s (Y ~s=8)|
|COM   d|73|--**01| XXX X|2|Complement            |d=~d        |
|COMa   |43|--**01|X     |7|Complement accumulator|a=~a        |
|CWAI  n|3C|E?????|    X |K|AND CCR, Wait for int.|CC=CC&n,E=1,|
|DAA    |19|--****|X     |2|Decimal Adjust Acc.   |A=BCD format|
|DEC   d|7A|--***-| XXX X|7|Decrement             |d=d-1       |
|DECa   |4A|--***-|X     |2|Decrement accumulator |a=a-1       |
|EORa  s|B8|--**0-| XXXXX|5|Logical Exclusive OR  |a=axs       |
|EXG r,r|1E|------|X     |8|Exchange (r1 size=r2) |r1<->r2     |
|INC   d|7C|--***-| XXX X|7|Increment             |d=d+1       |
|INCa   |4C|--***-|X     |2|Increment accumulator |a=a+1       |
|JMP   s|7E|------| XXX X|4|Jump                  |PC=EAs      |
|JSR   s|BD|------| XXX X|8|Jump to Subroutine    |-[S]=PC,JMP |
|LBcc nn|10|------|     x|5|Long cond. Branch(~=6)|If cc LBRA  |
|LBRA nn|16|------|     x|5|Long Branch Always    |PC=nn       |
|LBSR nn|17|------|     x|9|Long Branch Subroutine|-[S]=PC,LBRA|
|LDa   s|B6|--**0-| XXXXX|5|Load accumulator      |a=s         |
|LDD   s|FC|--**0-| XXX*X|6|Load Double acc.      |D=s         |
|LDS   s|FE|--**0-| XXX*X|7|Load Stack pointer    |S=s    (10H)|
|LDU   s|FE|--**0-| XXX*X|6|Load User stack ptr   |U=s         |
|LDi   s|BE|--**0-| XXX*X|6|Load index register   |i=s (Y ~s=7)|
|LEAp  s|3X|---i--| xX  X|4|Load Effective Address|p=EAs(X=0-3)|
|LSL   d|78|--0***| XXX X|7|Logical Shift Left    |d={C,d,0}<- |
|LSLa   |48|--0***|X     |2|Logical Shift Left    |a={C,a,0}<- |
|LSR   d|74|--0***| XXX X|7|Logical Shift Right   |d=->{C,d,0} |
|LSRa   |44|--0***|X     |2|Logical Shift Right   |d=->{C,d,0} |
|MUL    |3D|---*-*|X     |B|Multiply              |D=A*B       |
|NEG   d|70|-?****| XXX X|7|Negate                |d=-d        |
|NEGa   |40|-?****|X     |2|Negate accumulator    |a=-a        |
|NOP    |12|------|X     |2|No Operation          |            |
|ORa   s|BA|--**0-| XXXXX|5|Logical inclusive OR  |a=avs       |
|ORCC  n|1A|??????|    X |3|Inclusive OR CCR      |CC=CCvn     |
|PSHS  r|34|------|X     |2|Push reg(s) (not S)   |-[S]={r,...}|
|PSHU  r|36|------|X     |2|Push reg(s) (not U)   |-[U]={r,...}|
|PULS  r|35|??????|X     |2|Pull reg(s) (not S)   |{r,...}=[S]+|
|PULU  r|37|??????|X     |2|Pull reg(s) (not U)   |{r,...}=[U]+|
|ROL   d|79|--****| XXX X|7|Rotate Left           |d={C,d}<-   |
|ROLa   |49|--****|X     |2|Rotate Left acc.      |a={C,a}<-   |
|ROR   d|76|--****| XXX X|7|Rotate Right          |d=->{C,d}   |
|RORa   |46|--****|X     |2|Rotate Right acc.     |a=->{C,a}   |
----------------------------------------------------------------
----------------------------------------------------------------
|Mnemon.|Op|IHNZVC|IEXD#R|~|Description           |Notes       |
|-------+--+------+------+-+----------------------+------------|
|RTI    |3B|-*****|X     |6|Return from Interrupt |{regs}=[S]+ |
|RTS    |39|------|X     |5|Return from Subroutine|PC=[S]+     |
|SBCa  s|B2|--****| XXXXX|5|Subtract with Carry   |a=a-s-C     |
|SEX    |1D|--**--|X     |2|Sign Extend           |D=B         |
|STa   d|B7|--**0-| XXX X|5|Store accumultor      |d=a         |
|STD   d|FD|--**0-| XXX X|6|Store Double acc.     |D=a         |
|STS   d|FF|--**0-| XXX X|7|Store Stack pointer   |S=a    (10H)|
|STU   d|FF|--**0-| XXX X|6|Store User stack ptr  |U=a         |
|STi   d|BF|--**0-| XXX X|6|Store index register  |i=a (Y ~s=7)|
|SUBa  s|B0|--****| XXXXX|5|Subtract              |a=a-s       |
|SUBD  s|B3|--****| XXX*X|7|Subtract Double acc.  |D=D-s       |
|SWI    |3F|1-----|X     |J|Software Interrupt 1  |-[S]={regs} |
|SWI2   |3F|E-----|X     |K|Software Interrupt 2  |SWI    (10H)|
|SWI3   |3F|E-----|X     |K|Software Interrupt 3  |SWI    (11H)|
|SYNC   |13|------|X     |2|Sync. to interrupt    |  (min ~s=2)|
|TFR r,r|1F|------|X     |6|Transfer (r1 size<=r2)|r2=r1       |
|TST   s|7D|--**0-| XXX X|7|Test                  |s           |
|TSTa   |4D|--**0-|X     |2|Test accumulator      |a           |
|----------+------+------+-+-----------------------------------|
| CCR      |-*01? |      | |Unaffect/affected/reset/set/unknown|
| E        |E     |      | |Entire flag (Bit 7, if set RTI~s=F)|
| F  I     |I     |      | |FIRQ/IRQ interrupt mask (Bit 6/4)  |
| H        | H    |      | |Half carry (Bit 5)                 |
| N        |  N   |      | |Negative (Bit 3)                   |
| Z        |   Z  |      | |Zero (Bit 2)                       |
| V        |    V |      | |Overflow (Bit 1)                   |
| C        |     C|      | |Carry/borrow (Bit 0)               |
|-----------------+------+-------------------------------------|
| a               |I     | |Inherent (a=A,Op=4XH, a=B,Op=5XH)  |
| nn,E            | E    | |Extended (Op=E, ~s=e)              |
| [nn]            | x    | |Extended indirect                  |
| xx,p!           |  X   | |Indexed (Op=E-10H, ~s=e-1)         |
| [xx,p!]         |  X   | |Indexed indirect (p!=p++,--p only) |
| n,D             |   D  | |Direct (Op=E-20H, ~s=e-1)          |
| #n              |    # | |Immediate (8-bit, Op=E-30H, ~s=e-3)|
| #nn             |    * | |Immediate (16-bit)                 |
| m               |     x| |Relative (PC=PC+2+offset)          |
| [m]             |     R| |Relative indirect (ditto)          |
|--------------------------+-----------------------------------|
|DIRECT                    |Direct addressing mode             |
|EXTEND                    |Extended addressing mode           |
|FCB      n                |Form Constant Byte                 |
|FCC      'string'         |Form Constant Characters           |
|FDB      nn               |Form Double Byte                   |
|RMB      nn               |Reserve Memory Bytes               |
|--------------------------+-----------------------------------|
| A  B                     |Accumulators (8-bit)               |
| CC                       |Condition Code register (8-bit)    |
| D                        |A and B (16-bit, A high, B low)    |
| DP                       |Direct Page register (8-bit)       |
| PC                       |Program Counter (16-bit)           |
| S  U                     |System/User stack pointer(16-bit)  |
| X  Y                     |Index registers (16-bit)           |
|--------------------------+-----------------------------------|
| a                        |Acc A or B (a=A,Op=BXH, a=B,Op=FXH)|
| d  s  EA                 |Destination/source/effective addr. |
| i  p  r                  |Regs X,Y/regs X,Y,S,U/any register |
| m                        |Relative address (-126 to +129)    |
| n  nn                    |8/16-bit expression(0 to 255/65535)|
| xx  p!                   |A,B,D,nn/p+,-p,p++,--p (indexed)   |
| +  -  *  /               |Add/subtract/multiply/divide       |
| &  ~  v  x               |AND/NOT/inclusive OR/exclusive OR  |
| <-  ->  <->              |Rotate left/rotate right/exchange  |
| [ ]  [ ]+  -[ ]          |Indirect address/increment/decr.   |
| { }                      |Combination of operands            |
| {regs}                   |If E {PC,U/S,Y,X,DP,B,A,CC}/{PC,CC}|
| (10H)  (11H)             |Hex opcode to precede main opcode  |
|--------------------------+-----------------------------------|
| FFF0H to FFF1H           |Reserved by Motorola               |
| FFF2H to FFF3H           |SWI3 instruction interrupt vector  |
| FFF4H to FFF5H           |SWI2 instruction interrupt vector  |
| FFF6H to FFF7H           |Fast hardware int. vector (FIRQ)   |
| FFF8H to FFF9H           |Hardware interrupt vector (IRQ)    |
| FFFAH to FFFBH           |SWI instruction interrupt vector   |
| FFFCH to FFFDH           |Non-maskable interrupt vector (NMI)|
| FFFEH to FFFFH           |Reset vector                       |
----------------------------------------------------------------
 
 L'adressage inhérent
	Le code opératoire contient toute l'information nécessaire à l'exécution de l'instruction.
	Ex: ABX, ASLA, RORA, etc.

L'adressage immédiat
	Le code opératoire est directement suivi par un opérande de 1 ou 2 octets. 
	Ex: CMPA #$2B06 --> Comparaison de A avec la valeur hexa 2B06;
	ADDB #%1001100 --> Addition de la valeur binaire 1001100 à B.
	
L'adressage direct
	Il permet en collaboration avec le registre DP de charger un accumulateur avec le contenu de n'importe quelle adresse mémoire.
	Ex: Avec DP = 00
	LDA < $00 charge A avec le contenu de l'adresse $0000;
	CMPX < $35 compare X avec le contenu des adresses $0035 et $0036.
	
L'adressage étendu
	Il permet d'atteindre toute la mémoire mais avec un opérande à 2 octets. 
	Ex: LDA $5100 --> charge A avec le contenu de l'adresse $5100.
	
L'adressage étendu indirect
	C'est le contenu de l'adresse citée comme opérande qui va indiquer l'adresse mémoire. 
	Ex: On a à l'adresse $0100 de la mémoire la valeur $35 et l'adresse $0101 contient la valeur $B7.
	LDA [$1000] ---> CHARGE A avec le contenu de l'adresse $35B7.
	
L'adressage relatif court
	Il permet d'atteindre toute la mémoire par un déplacement de +127 ou -128 octets. 
	Ex: A l'adresse $00FE on a l'instruction BRA $0110 Branchement à l'adresse $0110.
	($0110(de BRA $0110) - $0100 (de PC) = $0010 cette valeur est ajoutée au compteur programme lors de l'exécution)
	
L'adressage relatif long
	Même principe que l'adressage relatif court mais permet d'atteindre toute la mémoire par un déplacement de +32767 à -32768. 
	Ex: LBEQ $2000 --> Branche le déroulement à l'adresse $2000 si le bit Z de CC est positionné.
	
L'adressage indexé
	On utilise un registre d'index de 16 bits qui spécifie une base à laquelle on ajoute un déplacement signé de 5, 8 ou 16 bits.

L'adressage indexé indirect
	Le registre d'index contient l'adresse effective de l'octet à manipuler.
 
 */