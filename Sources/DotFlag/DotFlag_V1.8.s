
;		DotFlag V1.8
;  Coded by Duke of Prestige on the 28.2.'93
;
; ( Mehr geht bei dem Code echt nicht mehr.. reached the top limit )

	section	DotFlagV1.8,code_c

;---------------------------------------------------------- INIT DEMO

START:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6		; CustomRegBase to a6
	move	#$4000,$9a(a6)		; Forbid Interrupts
	move	#$0020,$96(a6)		; Forbid Sprites
	bsr.w	initCoords
	bsr.w	initXYSinTab
.lp:	tst.b	$006(a6)		; wait for y0 für einen
	bne.s	.lp			; flackerfreien Übergang
	move.l	#CopperList,$84(a6)	; Copperliste2 laden und
	move	#$123,$8a(a6)		; über Copjmp2 aktivieren

.cls:	btst	#14,$02(a6)
	bne.b	.cls
	move.l	#$1000000,$40(a6)
	clr.l	$64(a6)

;---------------------------------------------------------- WAITVBEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	4(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

;------------------------------------------------------ DOUBLE BUFFERING

DBuff:
;	move	#$f0,$180(a6)
	lea	FrontScreen(pc),a0
	lea	Planes+2(pc),a1
	movem.l	(a0),a3/d1-d2
	exg	a3,d1
	exg	d1,d2
	movem.l	a3/d1-d2,(a0)
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	swap	d2

;---------------------------------------------------------- DOTFLAG

DotFlag:
.cls:	btst	#14,$02(a6)
	bne.b	.cls
	move.l	d1,$54(a6)
	move	#[256*64]+[320/16],$58(a6)
;	move	#$ff0,$180(a6)

DotDance:
	lea	Coords(pc),a0
	lea	XYSinTab(pc),a1
	lea	XYTabOffset(pc),a2
	move.b	(a2),d4
	addq	#2,d4
	and.b	#127,d4
	move.b	d4,(a2)			; Store new Coords
	moveq	#40-1,d6
.ylp:	moveq	#50-1,d7
	lea	(a1,d4.w),a1
.lp:	move	(a0)+,d0
.x:	add	(a1)+,d0		; get x-shift
	move.b	d0,d2
	lsr	#3,d0
	not.b	d2			; Soft-Shift-Wert holen
	bset	d2,(a3,d0.w)
	dbf	d7,.lp
	lea	XYSinTab(pc),a1
	addq	#4,d4
	and.b	#127,d4
	dbf	d6,.ylp

;	move	#$f00,$180(a6)
	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.w	WaitVBeam

;---------------------------------------------------------- EXIT DEMO

Exit:	lea	$dff000,a6
	move	#$8020,$96(a6)		; allow  Sprites
	move	#$c00,$9a(a6)		; permit Interrupts
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;---------------------------------------------------------- InitCoords

initCoords:
	lea	Coords(pc),a0
	moveq	#40-1,d6
	moveq	#0,d1
.ylp:	moveq	#50-1,d7
	moveq	#02,d0
.xlp:	move	d1,d2
	add	d0,d2
	move	d2,(a0)+
	addq	#6,d0
	dbf	d7,.xlp
	add	#1280,d1
	dbf	d6,.ylp
	rts

;---------------------------------------------------------- INITXYSINTAB

initXYSinTab:
	lea	XCosTab(pc),a0
	lea	XSinTab(pc),a1
	lea	XYSinTab(pc),a2
	moveq	#128-1,d7
.lp:	move	(a0)+,d0
	move	(a1)+,d1
	mulu	#320,d1
	add	d1,d0
	move	d0,(a2)+
	dbf	d7,.lp
	rts

;---------------------------------------------------------- COPPERLIST

CopperList:
	dc.w	$180,0,$182,$fff
	dc.w	$8e,$5081,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,0,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.l	$fffffffe

;---------------------------------------------------------- POINTER

FrontScreen:	dc.l	Screen1
DelScreen:	dc.l	Screen2
HiddenScreen:	dc.l	Screen3

;---------------------------------------------------------- Tabellen

XCosTab:dc.w	0,0,0,0,1,1,2,2,3,4,4,5,6,7,8,9,10,10,11,12
XSinTab:dc.w	13,14,15,16,16,17,18,18,19,19,20,20,20,20,20
	dc.w	20,20,19,19,18,18,17,16,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,4,3,2,2,1,1,0,0,0
	dc.w	0,0,0,0,1,1,2,2,3,4,4,5,6,7,8,9,10,10,11,12
	dc.w	13,14,15,16,16,17,18,18,19,19,20,20,20,20,20
	dc.w	20,20,19,19,18,18,17,16,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,4,3,2,2,1,1,0,0,0
	dc.w	0,0,0,0,1,1,2,2,3,4,4,5,6,7,8,9,10,10,11,12
	dc.w	13,14,15,16,16,17,18,18,19,19,20,20,20,20,20
	dc.w	20,20,19,19,18,18,17,16,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,4,3,2,2,1,1,0,0,0

;-------------------------------------------------------- TabellenStorage

Coords:		ds.l	2*50*40
XYTabOffset:	dc.w	0
XYSinTab:	ds.w	128

;-------------------------------------------------------- BitplaneStorage

Screen1:	ds.b	10240
Screen2:	ds.b	10240
Screen3:	ds.b	10240


