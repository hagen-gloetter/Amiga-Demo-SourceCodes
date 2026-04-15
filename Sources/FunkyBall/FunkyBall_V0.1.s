;TOSAAAAAKMBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPPFDP
;               T        T              T       T



	incdir	codes:

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

	bsr	initBall
	
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

;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Inits

initBall
	lea	CopBall,a0
	move.l	#$6007fffe,d0
	move.l	#$01060000,d1
	move.l	#$01062000,d3

	move	#64-1,d7		; y
.olp	move.l	d0,(a0)+		; wt
	move.l	d1,(a0)+		; 106
	move.l	#$01820000,d2
	move	#31-1,d6
.ilp	move.l	d2,(a0)+		; cols
	not	d2
	add.l	#$00020000,d2
	dbf	d6,.ilp
	move.l	d3,(a0)+		; 106 2
	move.l	#$01800000,d2
	move	#32-1,d6
.ilp2	move.l	d2,(a0)+		; cols
	not	d2
	add.l	#$00020000,d2
	dbf	d6,.ilp2
	add.l	#$02000000,d0
	dbf	d7,.olp

.bplini	move.l	#FunkyBall+100*40*6,d0
	lea	BitPlanes+2(pc),a1
	moveq	#6-1,d7
.blp	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq.l	#8,a1
	swap	d0
	add.l	#40,d0
	dbf	d7,.blp
	rts




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

Modulo	=	-40

	cnop	0,8
cop:	dc.w	$106,0,$1fc,0,$100,0
	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$200,$108,Modulo,$10a,Modulo
	dc.w	$5e01,$fffe
	dc.w	$100,$6200
BitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.w	$f0,0,$f2,0
	dc.w	$f4,0,$f6,0
CopBall	ds.l	64*66	; wt con3 31col con3 32col
	dc.w	$e001,$fffe,$100,$200
copend	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
FunkyBall	inciff	FunkyBall/Ball320x125x6.iff

Picture	inciff	FunkyBall/TestPic128x128x5.iff
