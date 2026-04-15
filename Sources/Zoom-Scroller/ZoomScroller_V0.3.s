;               T        T              T       T
;--------------------------------------------------------------------
; ZOOOOOM-SCROOOLLLLEERR by Duke of MoTioN
;
;	sintab y = 1-22
;--------------------------------------------------------------------




	incdir	dh1:code/sources/

;---------------------------------------------------------- Makros

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

;---------------------------------------------------------- Start of Code

	section	code,code_c		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1		; use base-pointer
	move.l	$26(a1),syscop1	; store systemcopper1 start adr
	move.l	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon	; store sys dmacon
	move	$010(a6),adkcon	; store sys adkcon
	move	$01c(a6),intena	; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

;---------------------------------------------------------- VBR-INIT

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- DEMO-INITS

	bsr.w	TurnFont
	bsr.w	initBitPlanes

;---------------------------------------------------------- VBI-INIT

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

removeVBI:	lea	$dff000,a6
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon(pc),d0		; restore sys dmacon
	move	adkcon(pc),d1		; restore sys adkcon
	move	intena(pc),d2		; restore interenable
	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	move.l	stackptr(pc),a7
	moveq	#0,d0
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	ZoomScroller
;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- DEMO INITS

TurnFont:			; ACHTUNG ! isch hoch komplex !
	lea	Font(pc),a0	; (dreht ne 8x8x1 Font um 90 Grad)
	lea	FontEnd(pc),a3
	lea	Spareletter(pc),a1
	moveq	#0,d3
.copy	lea	0(a0),a2
	moveq	#8-1,d6
	moveq	#0,d1
.turn	moveq	#8-1,d7
	moveq	#0,d2
	moveq	#0,d0
	move.b	(a2)+,d0
.turn90	btst	d7,d0
	beq.b	.next
	bset	d1,(a1,d2)
.next	addq	#1,d2
	dbf	d7,.turn90
	addq	#1,d1
	dbf	d6,.turn
	move.l	(a1),(a0)+	; copy 4 lines
	move.l	4(a1),(a0)+	; copy 4 lines
	move.l	d3,(a1)
	move.l	d3,4(a1)
	cmp.l	a3,a0
	blo	.copy
	rts

initBitPlanes:	move.l	#Bitplane,d0
	lea	LogoBitPlanes+2(pc),a0
	moveq	#1-1,d7		; No. of Planes
.initLogo	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40,d0		; intrleave
	addq.l	#8,a0
;	dbf	d7,.initLogo

	move.l	#ZoomingScroller,d0
	lea	ZoomLine1+6(pc),a0
	moveq	#9-1,d7		; 8 lines+clr line
.initZoom	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40,d0
	add.l	#20,a0
;	dbf	d7,.initzoom
	rts

;---------------------------------------------------------- ZOOMSCROLLER

ZoomScroller:
	move	TxtCounter(pc),d0
	bne.b	.move
	move	#8,TxtCounter
.print	lea	HiddenScroller(pc),a1	; print letter to hiddenscroll
	lea	Font(pc),a2
	moveq	#0,d0
	move.l	TxtPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	lea	ScrollText(pc),a0
	move.b	(a0)+,d0
.no0:	move.l	a0,TxtPtr
	sub	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,321(a1)	; copy 1. line
	move.b	(a3)+,322(a1)	; copy 2. line
	move.b	(a3)+,323(a1)	; copy 3. line
	move.b	(a3)+,324(a1)	; copy 4. line
	move.b	(a3)+,325(a1)	; copy 5. line
	move.b	(a3)+,326(a1)	; copy 6. line
	move.b	(a3)+,327(a1)	; copy 7. line
	move.b	(a3)+,328(a1)	; copy 8. line

.move	subq	#1,TxtCounter
	lea	HiddenScroller(pc),a0		; move hidden scroller
	lea	1(a0),a1
	move	#328-1,d7
.lp	move.b	(a1)+,(a0)+
	dbf	d7,.lp

OnScreenTEST	lea	HiddenScroller(pc),a0
	lea	Bitplane+20,a1
	move.b	(a0)+,00*40(a1)	; copy 1. line
	move.b	(a0)+,01*40(a1)	; copy 2. line
	move.b	(a0)+,02*40(a1)	; copy 3. line
	move.b	(a0)+,03*40(a1)	; copy 4. line
	move.b	(a0)+,04*40(a1)	; copy 5. line
	move.b	(a0)+,05*40(a1)	; copy 6. line
	move.b	(a0)+,06*40(a1)	; copy 7. line
	move.b	(a0)+,07*40(a1)	; copy 8. line
	move.b	(a0)+,08*40(a1)	; copy 1. line
	move.b	(a0)+,09*40(a1)	; copy 2. line
	move.b	(a0)+,10*40(a1)	; copy 3. line
	move.b	(a0)+,11*40(a1)	; copy 4. line
	move.b	(a0)+,12*40(a1)	; copy 5. line
	move.b	(a0)+,13*40(a1)	; copy 6. line
	move.b	(a0)+,14*40(a1)	; copy 7. line
	move.b	(a0)+,15*40(a1)	; copy 8. line
TESTEND

OnScreen	
	lea	HiddenScroller,a0
	lea	ZoomingScroller,a1

	moveq	#320/8-1,d7
.byteloop	moveq	#8-1,d0
.line1	btst	d0,(a0,d1)
	beq.b	.line2
	bset	d0,(a1,d1)
.line2	btst	d0,(a0,d1)
	beq.b	.line3
	bset	d0,(a1,d1)
.line3	btst	d0,(a0,d1)
	beq.b	.line4
	bset	d0,(a1,d1)
.line4	btst	d0,(a0,d1)
	beq.b	.line5
	bset	d0,(a1,d1)
.line5	btst	d0,(a0,d1)
	beq.b	.line6
	bset	d0,(a1,d1)
.line6	btst	d0,(a0,d1)
	beq.b	.line7
	bset	d0,(a1,d1)
.line7	btst	d0,(a0,d1)
	beq.b	.line8
	bset	d0,(a1,d1)
.line8	btst	d0,(a0,d1)
	beq.b	.lineEnd
	bset	d0,(a1,d1)

.lineEnd	dbf	d0,.line1
	addq	#1,d1
	dbf	d7,.byteloop


	rts







TxtPtr	dc.l	ScrollText
TxtCounter	dc.w	0		; cnt for new ltr print

ScrollText:	dc.b	`MOTION ! - CRAZY FOOLS, WITHOUT ANY RULES !`
	dc.b	`                 `
	dc.b	0
	even

SpareLetter	ds.b	8		; font dreh puffer

Font	include	zoomscroller/ZoomFont8x8x1.hex
FontEnd

;---------------------------------------------------------- Pointer

		cnop	0,8
stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte		; back to user state code

;---------------------------------------------------------- Copperlist

	cnop	0,8
cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,-40,$10a,-40
	dc.w	$100,$0200
ZoomLine1:	dc.w	$3107,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine2:	dc.w	$3207,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine3:	dc.w	$3307,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine4:	dc.w	$3407,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine5:	dc.w	$3507,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine6:	dc.w	$3607,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine7:	dc.w	$3707,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine8:	dc.w	$3807,$fffe,$e0,0,$e2,0,$100,1200,$182,$070
ZoomLine9:	dc.w	$3907,$fffe,$e0,0,$e2,0,$100,0200,$182,$000

	dc.w	$ffe1,$fffe
	dc.w	$100,$1200
	dc.w	$102,0,$104,$0,$108,0,$10a,0,$182,70
LogoBitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace


Bitplane:	ds.b	40*56	; später durch Logo ersetzen
HiddenScroller	ds.b	328
ZoomingScroller	ds.b	320/8*9	
