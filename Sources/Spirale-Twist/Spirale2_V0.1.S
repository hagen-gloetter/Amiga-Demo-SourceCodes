


	section	code,code_p		; code to chipmem
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
	move.l	#copperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
	bsr	Inits

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


;------------------------------------------------------------------------------
;----------------------  VERTICAL BLANK ROUTINE  ------------------------------
;------------------------------------------------------------------------------


VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

DoSpirale:
	lea	CopperSpirale+6,a0
	lea	Sintab(pc),a5
	lea	Sintab16(pc),a4
	lea	PictureTab,a1

	move	SinCounter1(pc),d0		; readsin1
	move	SinCounter2(pc),d1		; readsin2
	addq	#2,d0
	addq	#2,d1
	and	#511,d0
	and	#511,d1
	move	d0,SinCounter1
	move	d1,SinCounter2
	move	#240-1,d7
	moveq	#0,d2
	
.lp	move	(a5,d0.w),d2
	add	(a5,d1.w),d2
	lsl	#4,d2
	lea	(a1,d2.w),a2
	move.l	(a2),a3
	move	(a2)+,04(a0)
	move	(a2)+,00(a0)
	move	(a2)+,12(a0)
	move	(a2)+,08(a0)
	move	(a2)+,20(a0)
	move	(a2)+,16(a0)
	lea	28(a0),a0
	addq	#2,d0
	addq	#4,d1
	and	#511,d0
	and	#511,d1
	dbf	d7,.lp

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte



;--------------------------------------------------------------------------
;---------------------------- INITS----------------------------------------
;--------------------------------------------------------------------------

Inits:

ShowTextBitplane:
	move.l	#Bitplane,d0
	lea	Copperplanes+2,a0
	move	d0,4(a0)
	swap	d0	
	move	d0,(a0)

InitPictureColors
	lea	Picture+30720,a0
	lea	coppercolors,a1
	move	#$0180,d0
	moveq	#8-1,d7			; color	0-7
.lp1	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.lp1
	move	fontcolor(pc),d1
	moveq	#8-1,d7			; color 7-f
.lp2	move	d0,(a1)+
	move	d1,(a1)+
	addq	#2,d0
	dbf	d7,.lp2

;---------------------------------------------------------- INIT COPPERLIST

initCopperlist
	lea	CopperSpirale,a0
	move.l	#$30e1fffe,d0
	move.l	#$00e00000,d1
	move.l	#$00e20000,d2
	move.l	#$00e40000,d3
	move.l	#$00e60000,d4
	move.l	#$00e80000,d5
	move.l	#$00ea0000,d6
	move	#0000240-1,d7
.lp:	movem.l	d0-d6,(a0)
	lea	28(a0),a0
	add.l	#$01000000,d0
	dbf	d7,.lp

MakeFastPictureTab:
	lea	Picture+000,a0
	lea	Picture+080,a1
	lea	Picture+160,a2
	lea	PictureTab,a3
	moveq	#00000,d3	; Füllangwort
	moveq	#128-1,d7
	move.l	#00240,d6
.lp	move.l	a0,d0
	move.l	a1,d1
	move.l	a2,d2
	swap	d0
	swap	d1
	swap	d2
	movem.l	d0-d3,(a3)
	add.l	d6,a0
	add.l	d6,a1
	add.l	d6,a2
	lea	16(a3),a3
	dbf	d7,.lp

GenerateSinTab:
	lea	Sintab(pc),a0
	lea	Sintab16(pc),a1
	moveq	#4,d1
	move	#256-1,d7
.lp	move	(a0)+,d0
	lsl	d1,d0
	move	d0,(a1)+
	dbf	d7,.lp
	rts

;---------------------------------------------------------- Pointer

FontColor	dc.w	$f00
SinCounter1	dc.w	0
SinCounter2	dc.w	0


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


		incdir	`Duke_Sources_6:spirale2/`
		incdir	ram:

SinTab:		include	`sintab.s`		; 256 Werte 0-63
SinTab16:	ds.w	256
;---------------------------------------------------------- Copperlist

		section	Chipdata,data_c


copperlist:	dc.w	$106,0,$1fc,0
		dc.w	$180,0,$182,$555
		dc.w	$8e,$3181,$90,$21c1,$92,$3c,$94,$d4
		dc.w	$102,0,$104,$0,$108,0,$10a,0
		dc.w	$100,$c200
CopperPlanes:	dc.w	$ec,0,$ee,0
CopperColors:	ds.w	16
CopperSpirale:	ds.w	240*14
		dc.l	$fffffffe


Picture:	incbin	`spirale640x128x3.int`

;---------------------------------------------------------- BitplaneSpace

		section	Tabelle,bss_p

PictureTab:	ds.l	4*128		; vorberechnete Langwörter

		section	Bitplane,bss_c

Bitplane:	ds.b	20480		; TextBitplane

