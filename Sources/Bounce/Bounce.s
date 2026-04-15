;TOSAAAAAEJDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPPLGN
;               T        T              T       T



	incdir	codes:


wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


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
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

.bplini	move.l	#Bitplane1,d0
	lea	BitPlanes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

.copinit	lea	Ballpal,a0
	lea	colors,a1
	move	#$180,d0
	moveq	#8-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp

	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1


.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI		; get sys VBI+VBR-Offset
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)		; kick own VBI in
	move	#%1100000000100000,$9a(a6)	; start it

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
	or.w	#$8000,d0
	move	adkcon(pc),d1		; restore sys adkcon
	or.w	#$8000,d1
	move	intena(pc),d2		; restore interenable
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

	cnop	0,8
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	Buffering

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- MAIN ROUTINE

Buffering	lea	Screen,a0
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)

	lea	BitPlanes+2(pc),a1
	moveq	#3-1,d7
.blp	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	swap	d0
	addq	#8,a1
	add	#40,d0
	dbf	d7,.blp	

	move.l	d1,d6
clearScreen	addq.l	#4,d1	
	wblt
	move.l	#-1,$44(a6)
	move	#08,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	d1,$54(a6)
	move	#[3*256*64]+[256/16],$58(a6)
;	wblt

	lea	Ball1Pos,a0
	bsr	BallaBalla
	lea	Ball2Pos,a0

BallaBalla	movem	(a0),d0-d3
	cmp	#0+32,d0
	bgt.b	.xok
	neg	d2
.xok	cmp	#256-32,d0
	blo.b	.x2ok
	neg	d2
.x2ok	cmp	#0+32,d1
	bgt.b	.yok
	neg	d3
.yok	cmp	#256-32,d1
	blo.b	.y2ok
	neg	d3
.y2ok	add	d2,d0
	add	d3,d1
	movem	d0-d3,(a0)
copy	lea	Ball,a0
	move.l	d6,a2
	mulu	#3*40,d1
	add.l	d1,a1
	move	d0,d1
	lsr	#3,d0
	add	d0,a1
	and	#$f,d1
	ror	#4,d1
	or	#$0dfc,d1
	move.l	a0,a1
	wblt
	move.l	#$ffff0000,$44(a6)
	move	#-2,$64(a6)
	move	#34,$66(a6)
	move	d1,$40(a6)
	movem.l	a0-a2,$4c(a6)
	move	#[3*32*64]+[48/16],$58(a6)
	rts



	;	 X   Y  Sp
Ball1Pos	dc.w	080,040,2,4
Ball2Pos	dc.w	100,100,2,3
Ball3Pos	dc.w	140,140,2,1
Ball4Pos	dc.w	180,180,2,2




;---------------------------------------------------------- Pointer


	cnop	0,8
Screen	dc.l	Bitplane1,Bitplane2

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


Ball	inciff	bounce/ball1
BallPal	inciffp	bounce/ball1

;---------------------------------------------------------- Copperlist

	cnop	0,8
cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,2*40,$10a,2*40
	dc.w	$100,$3200
BitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
colors	ds.w	2*8
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
Bitplane1:	ds.b	10240*3
Bitplane2:	ds.b	10240*3
