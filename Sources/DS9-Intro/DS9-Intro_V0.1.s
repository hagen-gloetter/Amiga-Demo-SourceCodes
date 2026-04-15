 printt	`         +--------------------------------------------------------+`
 printt	`         |  Deep Space Nine Intro - Coded by Duke of Haze/Motion  |`
 printt	`         +--------------------------------------------------------+`

	section	code,code_c		; code to chipmem
x:	move.l	a7,stack		; save stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
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
	move.l	#CopperList1,$80(a6)	; copper1 start address
	move.l	#CopperList2,$84(a6)	; copper1 start address

	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

	bsr.w	InitDS9Pic

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
	move.l	stack(pc),a7
	moveq	#0,d0
	rts



InitDS9Pic:		;.force_the_f...ing_Bitch_Pic_to_Screen
	move.l	#Picture,d0
	lea	BitPlanes1+2,a0
	bsr.b	.init
	bsr.b	.cols
	move.l	#Picture+82,d0
	lea	BitPlanes2+2,a0
.init	moveq	#4-1,d7
.ilp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#42640,d0
	addq.l	#8,a0
	dbf	d7,.ilp
	rts

.cols:	move.l	d0,a0
	lea	Colors1,a1
	lea	Colors2,a2
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a1)+
	move	d0,(a2)+
	move	(a0),(a1)+
	move	(a0)+,(a2)+
	addq	#2,d0
	dbf	d7,.clp

.FlipFlop:
	lea	CopJump1+2,a1
	lea	CopJump1+2,a2
	move.l	#CopperList1,d1
	move.l	#CopperList2,d2
	move	d1,4(a2)
	move	d2,4(a1)
	swap	d1
	swap	d2
	move	d1,(a2)
	move	d2,(a1)
	rts
	
;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Pointer


stack		dc.l	0
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


;---------------------------------------------------------- COPPERLIST -1-

CopperList1:	dc.w	$106,0,$1fc,0
		dc.w	$8e,$247d,$90,$28c5,$92,$38,$94,$d8
		dc.w	$102,$44,$104,$10,$108,80,$10a,80
		dc.w	$100,$c204
BitPlanes1:	dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
Colors1:	ds.w	32
CopJump1:	dc.w	$84,0,$86,0,$8a,$1234		
		dc.l	$fffffffe

;---------------------------------------------------------- COPPERLIST -2-

CopperList2:	dc.w	$106,0,$1fc,0
		dc.w	$8e,$247d,$90,$28c5,$92,$38,$94,$d8
		dc.w	$102,$44,$104,$10,$108,80,$10a,80
		dc.w	$100,$c204
BitPlanes2:	dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
Colors2:	ds.w	32
		dc.w	$ffe1,$fffe,$2a07,$fffe
CopJump2:	dc.w	$80,0,$82,0,$88,$1234		
		dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

		incdir	Dh1:code/sources/DS9-Intro/
Picture:	incbin	DS9.656x520x4.raw
