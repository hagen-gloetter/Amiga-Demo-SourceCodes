
; Progy :
; Autor : 
; Datum :
; Zweck :

	section	code,code_c		; code to chipmem
x:	movem.l	d0-d7/a0-a6,-(a7)	; store sys registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0			; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1			; use base-pointer
	move.l	$26(a1),syscop1		; store systemcopper1 start addr
	move.l	$32(a1),syscop2		; store systemcopper2 start addr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; custom reg base to a6
	move.w	$002(a6),dmacon		; store sys dmacon
	move.w	$010(a6),adkcon		; store sys adkcon
	move.w	$01c(a6),intena		; store sys intena
	move.w	#$007fff,$9a(a6)	; clear interrupt enable
	move.w	#$007fff,$96(a6)	; clear dma channels
	bsr.w	initBitplanes		; init Bitplanes
.wait:	tst.b	$006(a6)		; wait till y0 for a
	bne.b	.wait			; soft transmission
	move.l	#cop1,$80(a6)		; copper1 start address
	move.l	#cop2,$84(a6)		; copper2 start address
	move.w	#$1234,$88(a6)		; set copjump 1
	move.w	#$0083c0,$96(a6)	; dma kontrol data
	move.w	#$007fff,$9c(a6)	; clear irq request
	move.w	#$004000,$9a(a6)	; interrupt enable

;---------------------------------------------------------- WAIT V-BEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0		; raster beam pos to d0
	and.l	#$00fff00,d0		
	cmp.l	#$0011100,d0
	bne.s	WaitVBeam
;	move	#$f00,$dff180		; Rastertime Start (red)

;------------------------------------------------------ DOUBLE BUFFERING

DBuff:	lea	Copperlist1(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	move.l	d0,$80(a6)

;---------------------------------------------------------- MAIN ROUTINE



;---------------------------------------------------------- WAIT MOUSE

;	move	#$0f0,$dff180		; Rastertime End (green)
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	WaitVBeam

;---------------------------------------------------------- EXIT TO SYSTEM

	lea	$dff000,a6		; customreg base to a6
	move.w	#$7fff,$9a(a6)		; disable interrupts
	move.w	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move.w	dmacon,d0		; restore sys dmacon
	move.w	adkcon,d1		; restore sys adkcon
	move.w	intena,d2		; restore sys intena
	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$c000,d2
	move.w	d0,$96(a6)
	move.w	d1,$9e(a6)
	move.w	#$7fff,$9c(a6)		; enable intreq
	move.w	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore sys registers
	moveq	#0,d0
	rts

;---------------------------------------------------------- INITBITPLANES

initBitplanes:
	lea	Con1+2(pc),a0
	lea	Con2+2(pc),a1
	moveq	#Planes,d0
	ror	#4,d0
	or	#$200,d0		; Set BplCon0
	lea	Planes1(pc),a0		; Position in Copperlist 1 
	lea	Cols1(pc),a1
	move.l	#Screen1,d0		; Adress of Screen1
	move.l	#PlaneSize,d1		; Size of the Bitplane
	bsr.b	.init			; init first Picture
	lea	Planes2(pc),a0		; Position in Copperlist 2
	lea	Cols2(pc),a1
	move.l	#Screen2,d0		; Adress of Screen2
.init:	moveq	#Planes-1,d7
	move	#Colors-1,d6
	move	#$0e0,d2
.plp:	move	d2,0(a0)
	addq	#2,d2
	swap	d0
	move	d0,2(a0)
	move	d2,4(a0)
	addq	#2,d2
	swap	d0
	move	d0,6(a0)
	add.l	d1,d0
	addq	#8,a0
	dbf	d7,.plp
.cols:	move	#$180,d2
	move.l	d0,a0
.clp:	move	d2,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d2
	dbf	d6,.clp
	rts

;---------------------------------------------------------- DEVINITONS

Planes		=	5	 ; <=- Change ONLY this for
Colors		=	2^Planes ;     different values of planes
PlaneSize	=	10240	 ; Bitplanesize= Width/8*Height 

;---------------------------------------------------------- POINTER

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
Copperlist1	dc.l	cop1,cop2
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- COPPERLIST -1-

cop1:	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
Con1	dc.w	$100,0
Planes1	ds.w	Planes*4
Cols1	ds.w	Colors*2
	dc.l	$fffffffe

;---------------------------------------------------------- COPPERLIST -2-

cop2:	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
Con2	dc.w	$100,0
Planes2	ds.w	Planes*4
Cols2	ds.w	Colors*2
	dc.l	$fffffffe

;---------------------------------------------------------- BITPLANESPACE

Screen1:	ds.b	4*PlaneSize
Screen2:	ds.b	4*PlaneSize

