

;		DotFlag+Texture V1.0
;  Coded by Duke of Prestige on the 28.2.'93


	section	DotFlag2,code_c

;---------------------------------------------------------- INIT DEMO

START:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6		; CustomRegBase to a6
	move	#$4000,$9a(a6)		; Forbid Interrupts
	move	#$0020,$96(a6)		; Forbid Sprites
	bsr.w	initCoords
	bsr.w	initTexture
.lp:	tst.b	$006(a6)		; wait for y0 für einen
	bne.s	.lp			; flackerfreien Übergang
	move.l	#CopperList,$84(a6)	; Copperliste2 laden und
	move	#$123,$8a(a6)		; über Copjmp2 aktivieren

;---------------------------------------------------------- WAITVBEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	4(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

;------------------------------------------------------ DOUBLE BUFFERING

DBuff:
;	move	#$f0,$dff180
	lea	FrontScreen(pc),a0
	lea	Planes+2(pc),a1
	movem.l	(a0),d0-d2
	movem.l	d0-d1,4(a0)
	move.l	d2,(a0)
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	swap	d2
	add.l	#7000,d2
	move	d2,12(a1)
	swap	d2
	move	d2,8(a1)

	bsr.w	DotFlag
;	move	#$f00,$dff180

;---------------------------------------------------------- MAIN ROUTINE

	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.s	WaitVBeam

;---------------------------------------------------------- EXIT DEMO

Exit:	lea	$dff000,a6
	move	#$8020,$96(a6)		; allow  Sprites
	move	#$c00,$9a(a6)		; permit Interrupts
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;---------------------------------------------------------- DOTFLAG

DotFlag:
.cls:	btst	#14,$02(a6)
	bne.b	.cls
	move.l	#$1000000,$40(a6)
	clr.l	$64(a6)
	move.l	DelScreen,$54(a6)
	move	#[348*64]+[320/16],$58(a6)

.DotDance:
	lea	Coords(pc),a0
	lea	XSinTab(pc),a1
	lea	XTabOffset(pc),a2
	lea	YSinTab(pc),a5
	move.l	HiddenScreen,a3
	movem	(a2),d4-d5		; Get Offsets
	addq	#2,d4
	addq	#2,d5
	and	#127,d4
	and	#127,d5			; Kill overflow
	movem	d4-d5,(a2)		; Store new Coords

	moveq	#20-1,d6
.ylp:	movem.l	d4-d5,-(a7)
	moveq	#50-1,d7
.lp:	move.l	a3,a4			; Store Screenadr

	movem	(a0),d0-d1		; get fix coords
	addq	#8,a0
.x:	add	(a1,d4.w),d0		; get x-shift
.y:	add	(a5,d5.w),d1		; get y-shift
	move.b	d0,d2
	lsr	#3,d0	
	add	d1,d0
	not.b	d2			; Soft-Shift-Wert holen
	bset	d2,(a4,d0.w)
.nxtdot:addq	#2,d4
	addq	#2,d5
	dbf	d7,.lp
	movem.l	(a7)+,d4-d5
	addq	#4,d4
	addq	#4,d5
	and	#127,d4
	and	#127,d5			; Kill overflow
	dbf	d6,.ylp
	rts	

XTabOffset:	dc.w	0
YTabOffset:	dc.w	32

;---------------------------------------------------------- InitCoords

initCoords:
	lea	Coords(pc),a0
	moveq	#20-1,d6
	moveq	#0,d1
.ylp:	moveq	#50-1,d7
	moveq	#02,d0
.xlp:	movem	d0-d1,(a0)
	addq	#6,d0
	addq	#8,a0
	dbf	d7,.xlp
	add	#320,d1
	dbf	d6,.ylp

ModifyYTab:			; YTab in Zeilen umrechnen
	lea	XSinTab(pc),a0
	lea	YSinTab(pc),a1
	moveq	#128-1,d7
.mulu40:
	move	(a0)+,d0
	move	d0,d1
	lsl	#5,d1
	lsl	#3,d0
	add	d1,d0
	move	d0,(a1)+
	dbf	d7,.mulu40

	rts

initTexture:
	moveq	#0,d0
	move	#7000,d1
	lea	Coords+2(pc),a0
	lea	TextureTab(pc),a1
	move	#1000-1,d7
.lp:	move.b	(a1)+,d0
	tst.b	d0
	beq.b	.notset
	add	d1,(a0)
.notset:
	addq	#8,a0
	dbf	d7,.lp
	rts

;---------------------------------------------------------- COPPERLIST

CopperList:
	dc.w	$106,0,$1fc,0		; AGA- Fick
	dc.w	$180,0,$182,$00a,$184,$aaa,$186,$fff
	dc.w	$8e,$5181,$90,$00c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,0,$108,0,$10a,0
	dc.w	$100,$2200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$ffe1,$fffe,$100,$00
	dc.l	$fffffffe

;---------------------------------------------------------- POINTER

FrontScreen:	dc.l	Screen1
DelScreen:	dc.l	Screen2
HiddenScreen:	dc.l	Screen3

;---------------------------------------------------------- Tabellen

XSinTab:
	dc.w	0,0,0,0,1,1,2,2,3,4,4,5,6,7,8,9,10,10,11,12
	dc.w	13,14,15,16,16,17,18,18,19,19,20,20,20,20,20
	dc.w	20,20,19,19,18,18,17,16,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,4,3,2,2,1,1,0,0,0
	dc.w	0,0,0,0,1,1,2,2,3,4,4,5,6,7,8,9,10,10,11,12
	dc.w	13,14,15,16,16,17,18,18,19,19,20,20,20,20,20
	dc.w	20,20,19,19,18,18,17,16,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,4,3,2,2,1,1,0,0,0

YSinTab:ds.w	128

TextureTab:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,0,1,1,1,1,1,0,0,0,1,1,1,1,1
	dc.b	1,1,1,1,1,0,0,1,1,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,1,1
	dc.b	1,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,1
	dc.b	1,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0
	dc.b	1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0
	dc.b	1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,1,1,1
	dc.b	1,1,1,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,0,1,1,1,1,1,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,1,0,0,1,1,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1
	dc.b	1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1
	dc.b	1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 
;-------------------------------------------------------- BitplaneStorage

Coords:		ds.l	2*50*20
Screen1:	ds.b	2*7000		;320*175/8
Screen2:	ds.b	2*7000
Screen3:	ds.b	2*7000


