;TOSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

; MultiRasterScroller by Duke of Haze
;
; Rewritten on the 30.11.93  -- Intro is running on every Amiga ! (I hope)
;
; Tja es ist doch möglich PC-relativ zu adressieren und
; doch sections zu benutzen !  (Pointer heißt das Zauberwort)
;
; P.S.: Typewriter ab Bpl4(6) +3200 einschalten (sonst bye bye Logo)
;

	section	MultiScroller,code_c	; code to chipmem
x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	jsr	-408(a6)		; old open library
	move.l	d0,a1			; use base-pointer
	move.l	$26(a1),syscop1		; store systemcopper1 start addr
	move.l	$32(a1),syscop2		; store systemcopper2 start addr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon		; store sys dmacon
	move	$010(a6),adkcon		; store sys adkcon
	move	$01c(a6),intena		; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
.68000	move.l	d0,VectorBase		; save it
	lea	$dff000,a6
	bsr.w	inits			; init Bitplanes+Rasters+Colors
initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:
	lea	$dff000,a6
	move.l	VectorBase,a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon,d0		; restore sys dmacon
	move	adkcon,d1		; restore sys adkcon
	move	intena,d2		; restore interenable
	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	moveq	#0,d0
	rts

;---------------------------------------------------------- Init all Parameters

Inits:
	bsr.w	initlogo
.initBitPlanes:
	move.l	Screen1(pc),d0
	lea	EPlanes+2(pc),a0
	moveq	#6-1,d7
.blp:	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq	#8,a0	
	add.l	#12672,d0
	dbf	d7,.blp
.initColors:
	lea	ColTab(pc),a0
	lea	Cols(pc),a1
	move	#$0180,d0
	moveq	#32-1,d7
.clp:	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp
.initBlitter
	btst	#14,$02(a6)
	bne.b	.initBlitter
	moveq	#-1,d0
	move.l	d0,$44(a6)
	move.l	#40,$64(a6)
	move.l	#$9f00000,$40(a6)
.initBlocks:
	lea	Block2x2(pc),a0
	lea	Bitplane1,a1
	bsr.b	.FillScreen

	lea	Block4x4(pc),a0
	lea	Bitplane3,a1
	bsr.b	.FillScreen

	lea	Block8x8(pc),a0
	lea	Bitplane5,a1
	bsr.b	.FillScreen

	lea	Block16x16(pc),a0
	lea	Bitplane2,a1
.FillScreen:
	moveq	#09-1,d6	
.lp:	moveq	#11-1,d7
.lp2:	btst	#14,$02(a6)
	bne.b	.lp2
	movem.l	a0-a1,$50(a6)
	move	#[32*64]+[32/16],$58(a6)
	addq	#4,a1
	dbf	d7,.lp2
	add	#1408-44,a1
	dbf	d6,.lp
	rts

InitLogo
	lea	Logo(pc),a0
	lea	Bitplane4+2,a1
.wbltr:	btst	#14,$02(a6)
	bne.b	.wbltr
	move.l	#-1,$44(a6)
	move.l	#04,$64(a6)		; 64+66
	move.l	#$9f00000,$40(a6)
	bsr.w	.wblt
	lea	Logo+3200(pc),a0
	lea	Bitplane6+2,a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	movem.l	a0-a1,$50(a6)
	move	#[80*64]+[320/16],$58(a6)
	rts

;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

;---------------------------------------------------------- MOVESCREENS

MoveScreens:
	lea	Screen1(pc),a0
	lea	EPlanes+2(pc),a1
	lea	OffsetScreen1(pc),a2
	movem.l	(a0),d0-d3
	movem	(a2),d4-d7
.pl1:	add	d4,d0		; Offset addieren
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq	#8,a1
.pl2:	add	d5,d1		; Offset addieren
	move	d1,4(a1)
	swap	d1
	move	d1,(a1)
	addq	#8,a1
.pl3:	add	d6,d2		; Offset addieren
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
.pl4:	add	d7,d3		; Offset addieren
	move	d3,4(a1)
	swap	d3
	move	d3,(a1)
	addq	#8,a1
	sub	#22,d4
	bne.b	.noOv1
	move	#1408,d4
.noOv1:	sub	#44,d5
	bhi.b	.noOv2
	move	#1408,d5
.noOv2:	sub	#66,d6
	bhi.b	.noOv3
	move	#1408,d6
.noOv3:	sub	#88,d7
	bhi.b	.end
	move	#1408,d7
.end:	movem	d4-d7,(a2)


	add	#1,shift
	and	#$f,shift
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
oldVBI		dc.l	0
VectorBase	dc.l	0
gfxname		dc.b	'graphics.library',0,0
vbr_exception	dc.l	$4e7a0801		; movec vbr,d0
		rte				; back to user state code

;---------------------------------------------------------- Copperlist

cop:	dc.w	$106,$c00,$1fc,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
	dc.w	$8e,$3082,$90,$2ac1,$92,$30,$94,$d8
	dc.w	$100,$6600,$102
shift	dc.w	0,$104,$64,$108,0
	dc.w	$108,0,$10a,0
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
EPlanes:dc.w	$e0,0,$e2,0
	dc.w	$e8,0,$ea,0
	dc.w	$f0,0,$f2,0
	dc.w	$e4,0,$e6,0
	dc.w	$ec,0,$ee,0
	dc.w	$f4,0,$f6,0
cols:	ds.l	32
	dc.l	$fffffffe

;---------------------------------------------------------- Pointer

; Odd Planes

Screen1:	dc.l	Bitplane1
Screen3:	dc.l	Bitplane3
Screen5:	dc.l	Bitplane5

; Even Planes

Screen2:	dc.l	Bitplane2
Screen4:	dc.l	Bitplane4
Screen6:	dc.l	Bitplane6

OffsetScreen1:	dc.w	1408		; Reihenfolge belassen
OffsetScreen2:	dc.w	1408		; movem (ax),dx
OffsetScreen3:	dc.w	1408
OffsetScreen4:	dc.w	1408

;---------------------------------------------------------- GFX & FONTS

Block2x2:
	rept	16
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	endr
Block4x4:
	rept	8
	dcb.l	4,%11110000111100001111000011110000
	dcb.l	4,%00001111000011110000111100001111
	endr
Block8x8:
	rept	2
	dcb.l	8,%11111111000000001111111100000000
	dcb.l	8,%00000000111111110000000011111111
	endr
Block16x16:
	dcb.l	16,%00000000000000001111111111111111
	dcb.l	16,%11111111111111111000000000000000

ColTab:	dc.w	$000,$707,$880,$880,$080,$080,$080,$080	; Col 0-8   (1)
.logo:	dc.w	$000,$700,$aaa,$aaa,$666,$666,$666,$666 ; Col 8-16  (2)
	dc.w	$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf	; Col 16-24
	dc.w	$ccf,$fcf,$fcf,$ccf,$ccf,$ccf,$ccf,$ccf ; Col 24-32

	incdir	`dh1:code/sources/intro3/`
Logo:	incbin	`Motion320x80x2.raw`

;---------------------------------------------------------- BitplaneSpace

	section	Bitplanes,bss_c

BitPlane1:	ds.b	12672	; 320+32/8*288
BitPlane3:	ds.b	12672
BitPlane5:	ds.b	12672

BitPlane2:	ds.b	12672
BitPlane4:	ds.b	12672
BitPlane6:	ds.b	12672 ; = 76,032 kByte nur für die Bitplanes :-)
