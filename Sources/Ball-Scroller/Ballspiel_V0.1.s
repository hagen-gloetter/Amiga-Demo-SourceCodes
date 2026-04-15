
; BALL-COPPER-SCROLLER by DUKE

; Ich hoff nur, daß der Effect so kewl wird, wie ich ihn mir vorstell,
; sonst war der ganze Streß umsonst...

	section	code,code_p		; code to public
x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0			; clear d0
	jsr	-552(a6)		; open library
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
	move.l	#Copperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

.bplini	move.l	#BallPic,d0
	lea	BallPlanes+2,a1
	moveq	#5-1,d7
.lp	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq	#8,a1
	swap	d0
	add.l	#20,d0
	dbf	d7,.lp

initBall:
	lea	BallScroll,a0
	lea	Sintab(pc),a1
	move.l	#$58e1fffe,d0
	moveq	#0,d2
	moveq	#32-1,d7
.lp	move.l	d0,(a0)+
	moveq	#31-1,d6
	move	#$182,d1
.lp2	move	d1,(a0)+
	move	d2,(a0)+
;	sub	#$10,d2
	addq	#2,d1
	dbf	d6,.lp2
	moveq	#0,d3
	move	(a1)+,d3
	rol	#8,d3
	swap	d3
	add.l	d3,d0
	dbf	d7,.lp


;----------------------------------------------------------- CONVERTER

Converter:	; Converts a Font 8x8x3 (480*8*3+cols) to Coppercolors
	lea	Font(pc),a5
	lea	0*480(a5),a0
	lea	1*480(a5),a1
	lea	2*480(a5),a2
	lea	3*480(a5),a3
	lea	CopFont,a4
	moveq	#0,d1
	moveq	#0,d3
	moveq	#60-1,d6	; Zeile
.lp3	moveq	#8-1,d7		; Spalte
.lp2	moveq	#8-1,d0		; Byte
.lp	moveq	#0,d2
	btst	d0,(a0,d1.w)
	beq.b	.no1
	addq	#1,d2
.no1	btst	d0,(a1,d1.w)
	beq.b	.no2
	addq	#2,d2
.no2	btst	d0,(a2,d1.w)
	beq.b	.no3
	addq	#4,d2
.no3	add	d2,d2
	move	(a3,d2.w),(a4)+
	dbf	d0,.lp
	add	#60,d1
	dbf	d7,.lp2
	addq	#1,d3
	move	d3,d1
	dbf	d6,.lp3

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
;------------------------------------------------------- VERTICAL BLANK ROUTINE
;------------------------------------------------------------------------------

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)


;-------------------------------------------------------- BALL_SCROLLER

BallScroller:
	move	sc_counter(pc),d0
	add	#1,d0
	and	#3,d0
	bne.b	.moveHiddenScroller

.getnewChar
	move.l	ScrollPointer(pc),a5
	moveq	#0,d0
	move.b	(a5)+,d0
	bne.b	.nop
	lea	Scrolltext(pc),a5
	move.b	(a5)+,d0
.nop:	move.l	a5,ScrollPointer
	sub	#32,d0			; -base
	lsl	#7,d0			; *128
.copyCharToHiddenScroller:
	lea	CopFont,a0
	lea	(a0,d0.w),a0
	lea	HiddenScroller+64,a1
	moveq	#8-1,d7
.ylp	moveq	#8-1,d6
.xlp	move	(a0)+,(a1)+
	dbf	d6,.xlp
	lea	64(a1),a1
	dbf	d7,.ylp

.moveHiddenScroller
	move	d0,sc_counter
	lea	HiddenScroller,a1
	lea	4(a1),a0
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#-1,$44(a6)
	move	#2,$64(a6)
	move	#2,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#8*64+39,$58(a6)

.copyHiddenScrollerToCopperlist
	lea	hiddenscroller,a0
	lea	ballscroll+6+10*128,a1
	moveq	#31-1,d7
.wblt2:	btst	#14,$02(a6)
	bne.b	.wblt2
	move	#78,$64(a6)
	move	#126,$66(a6)
	move.l	#$09f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	movem.l	a0-a1,$50(a6)
	move	#[8*64]+1,$58(a6)
	addq.l	#2,a0
	addq.l	#4,a1
	dbf	d7,.wblt2


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- SYS-POINTER

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

;---------------------------------------------------------- DEMO-POINTER

SinTab:		dc.w	1,1,2,3,4,5,6,7		; 32 Werte
		dc.w	8,9,9,10,10,11,11,11
		dc.w	11,11,11,11,10,10,9,9
		dc.w	8,7,6,5,4,3,2,1

		incdir  dh1:code/sources/
Font:		incbin	`BallScroller/testfont8x8x3.raw`


sc_counter	dc.w	0			; Breitenzähler

ScrollPointer	dc.l	ScrollText

ScrollText:
	dc.b	`HAZE       `
	dc.b	`OF       `
	dc.b	`MOTION                    `
	dc.b	0



;---------------------------------------------------------- COPPERLIST

		section	copperlist,data_c

Copperlist:	dc.w	$106,0,$1fc,0
		dc.w	$180,$532,$182,$555
BallCop		dc.w	$5907,$fffe
		dc.w	$8e,$5981,$90,$f8c1,$92,$5c,$94,$a4
		dc.w	$102,0,$104,$10,$108,80,$10a,80
		dc.w	$100,$5200
BallPlanes:	dc.w	$e0,0,$e2,0,$e4,0,$e6,0,$e8,0
		dc.w	$ea,0,$ec,0,$ee,0,$f0,0,$f2,0
BallScroll:	ds.w	32*64
		dc.l	$fffffffe

;---------------------------------------------------------- BITPLANE


BallPic:	incbin	`ballscroller/ball160x160x5.int`

;---------------------------------------------------------- SPACE FOR DATAS


		section	bss,bss_c

HiddenScroller:	ds.w	40*8
CopFont:	ds.b	480*8*2		; convertierte 8x8x3 Font
