


	section	code,code_c		; code to chipmem
x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0			; clear d0
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
.bplini	move.l	#FrontPlane,d0
	lea	Planes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

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


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

DoubleBuffering:
	lea	DBuff,a0
	movem.l	(a0),a1-a2
	exg	a1,a2
	movem.l	a1-a2,(a0)
	lea	Planes+2(pc),a1
	move.l	a2,d0
	move	d0,4(a1)
	swap	d0	
	move	d0,(a1)

	add.l	#48*40+10,a2		; center

Clear:	lea	6400(a2),a4
	movem.l	d0-d6/a0-a6,-(a7)	; store registers
	move.l	a7,store
	lea	Fill,a7
	movem.l	(a7)+,d0-d6/a0-a3/a5-a6
	move.l	a4,a7
	sub.l	a4,a4
	moveq	#114-1,d7
.cls	movem.l	d0-d6/a0-a6,-(a7)	; clear
	dbf	d7,.cls
	move.l	store,a7
	movem.l	(a7)+,d0-d6/a0-a6	; restore registers
CircleChaos:
	lea	circle,a0
	lea	sintab,a5
	move	sincounterx,d0
	move	sincountery,d1
	addq	#2,d0
	add	#2,d1
	and	#511,d0
	and	#511,d1
	move	d0,sincounterx
	move	d1,sincountery


.bltini	btst	#14,$02(a6)
	bne.b	.bltini
	move	#00,$42(a6)		; bltcon1
	move.l	#$ffff0000,$44(a6)	; mask a
	move	#28,$62(a6)		; mod b
	move	#-2,$64(a6)		; mod a
	move	#28,$66(a6)		; mod d


	moveq	#32-1,d7
.lp	move	(a5,d0.w),d2
	move	(a5,d1.w),d3
	move	d2,d4
	and.b	#$f,d4			; softx
	ror	#4,d4
	lsr	#3,d2
	move	d3,d5			; y
	lsl	#5,d5
	lsl	#3,d3
	add	d5,d3
	lea	(a2,d3),a1
	lea	(a1,d2),a1
	lea	(a1),a3
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	or	#$0d3c,d4		; miniterm
	move	d4,$40(a6)
	move.l	a3,$4c(a6)
	movem.l	a0-a1,$4c(a6)
	move	#[80*64]+[96/16],$58(a6)
	add	#16,d0
	add	#16,d1
	and	#511,d0
	and	#511,d1
	dbf	d7,.lp

;-------------------------------------------------------- MAIN ROUTINE

	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Pointer

store		dc.l	0
Fill		ds.l	15
DBuff		dc.l	FrontPlane,HiddenPlane
sincounterx	dc.w	0
sincountery	dc.w	128


syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte				; back to user state code

		incdir	df1:circles/
Circle		incbin	Circle80x80x1.raw
Sintab		include	Sintab.i


;---------------------------------------------------------- Copperlist

cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

FrontPlane:	ds.b	10240
HiddenPlane:	ds.b	10240
