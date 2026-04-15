


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
	move.l	#BarCopperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

BarInit:
	lea	Barpic,a0		; copy to bpl
	lea	Barplane+16,a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#$0000001e,$64(a6)
	move.l	#-1,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[10*64]+[80/16],$58(a6)
	
	lea	BarCop,a0		; create barcoplst
	move.l	#BarPlane,d0
	move.l	#$82e1fffe,d1
	move	#$00e0,d2
	move	#$00e2,d3
	move.l	#$01001200,d4
	moveq	#10-1,d7
.lp	move.l	d1,(a0)+
	move	d2,(a0)+
	swap	d0
	move	d0,(a0)+
	swap	d0
	move	d3,(a0)+
	move	d0,(a0)+
	move.l	d4,(a0)+
	add.l	#40,d0
	add.l	#$01000000,d1
	dbf	d7,.lp
	move.l	d1,(a0)+
	clr	d4
	move.l	d4,(a0)+

	lea	Barcop+6*16,a0		; stretch code
	move	#$5000,d0
	add	d0,(a0)
	add	d0,16(a0)
	add	d0,32(a0)
	add	d0,48(a0)
	add	d0,64(a0)


	move	#$aaa,BarCols+6		; start display

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

;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Pointer

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

;---------------------------------------------------------- Copperlist

BarCopperList:	dc.w	$106,0,$1fc,0
BarCols		dc.w	$180,0,$182,0
		dc.w	$8e,$8881,$90,$d8c1,$92,$38,$94,$d0
		dc.w	$102,0,$104,$10,$108,-40
		dc.w	$100,$00
BarCop:		ds.w	10*8+4
		dc.l	$fffffffe
		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0

DS9Copperlist:
		dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

BarPic:		incbin	df1:addtro/barcode80x10x1.raw
BarPlane:	ds.b	10*40
