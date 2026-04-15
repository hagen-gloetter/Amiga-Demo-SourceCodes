
; 32x32x5 Brush Zoomer by Duke of Haze on the 5.1.94

; FUCK!	ca. 4 Std tipperei, sucherei und fummelei um einen Fehler im Converter
;	zu finden, bis ich merkte, daß DPaint Scheiße gebaut hat ! ARRRGGG !

	section	code,code_p		; code to public
x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0			; clear d0
	jsr	-552(a6)		; old open library
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
	move	#$0083c0,$96(a6)	; dmacon data
	move.l	#Copperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

;---------------------------------------------------------- INITS

Converter:	; Converts a Brush 32x32x5 (+cols) to Coppercolors
	lea	Brush(pc),a0	; Plane 1
	lea	1*128(a0),a1	; Plane 2
	lea	2*128(a0),a2	; Plane 3
	lea	3*128(a0),a3	; Plane 4
	lea	4*128(a0),a4	; Plane 5
	lea	5*128(a0),a5	; Colortab
	lea	CopBrush,a6
	moveq	#0,d1
	moveq	#0,d3
.lp3	moveq	#128-1,d7	; Spalte	(Höhe in Pixeln)
.lp2	moveq	#8-1,d0		; Byte
.lp	moveq	#0,d2
.noPl0	btst	d0,(a0,d1.w)
	beq.b	.noPl1
	addq	#1,d2
.noPl1	btst	d0,(a1,d1.w)
	beq.b	.noPl2
	addq	#2,d2
.noPl2	btst	d0,(a2,d1.w)
	beq.b	.noPl3
	addq	#4,d2
.noPl3	btst	d0,(a3,d1.w)
	beq.b	.noPl4
	addq	#8,d2
.noPl4	btst	d0,(a4,d1.w)
	beq.b	.noPl5
	add	#16,d2
.noPl5	add	d2,d2
	move	(a5,d2.w),(a6)+
	dbf	d0,.lp
	addq	#1,d1
	dbf	d7,.lp2
makeCop:
	lea	CopSpace,a0
	lea	CopBrush,a1
	move.l	#$3007fffe,d0		; Wait
	move.l	#$01005200,d1		; Bplcon0=5pl
	moveq	#32-1,d6		; höhe in px
.olp	move.l	d0,(a0)+		; insert wait
	move.l	d1,(a0)+		; insertbplcon
	moveq	#31-1,d7		; 31 col loop
	move	#$182,d2		; color1
.lp	move	d2,(a0)+		; $18x to cop
	move	(a1)+,(a0)+		; color to cop
	addq	#2,d2			; color1=color1+1
	dbf	d7,.lp
	add.l	#$01000000,d0		; one line down
	move	(a1)+,d2		; overjump every 32th pixel
	dbf	d6,.olp
	move.l	d0,(a0)+		; final wait
	move.l	#$01000000,(a0)+	; clear bplcon0

showPic:lea	planes+2,a0
	move.l	#Zoompic,d0
	move	#5-1,d7
.lp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq	#8,a0
	add.l	#5120,d0
	dbf	d7,.lp
.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6
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
	move	#7000,d7
.lp	dbf	d7,.lp
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)
	btst	#2,$dff016		; Wait for right mouse button
	beq	nop
	beq	yzoom

xzoom:	lea	planes+2,a0
	lea	xsintab(pc),a1
	move.l	#Zoompic,d0
	move	zoomcounter(pc),d1
	addq	#2,d1
	and	#511,d1
	move	d1,zoomcounter
	move	(a1,d1.w),d1
	move	d1,d4			; store
	move	d1,d2
	lsl	#3,d1
	lsl	#5,d2
	add	d2,d1
	add.l	d1,d0
	move	#5-1,d7
.lp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq	#8,a0
	add.l	#5120,d0
	dbf	d7,.lp
center:	move	#150,d3			; middle
	sub	d4,d3			; center
yzoom:	lea	copspace,a0
	lea	ysintab(pc),a1
	move	zoomcounter(pc),d1
	move	(a1,d1.w),d0		; akt. kommastellenwert
	move	d0,d1
	and	#$f,d1			; kommastelle isolieren
	move	#32-1,d7
	clr	zeroflag
.lp 	and	#$1f,d1			; kommastelle+overflow isolieren
	add	d0,d1
	move	d1,d2
	lsr	#4,d2
	add	d2,d3			; y-wait modifizieren
	cmp	#$ff,d3
	ble	.gogo
	tst	zeroflag
	bne.b	.gogo
	move	#1,zeroflag
	move.l	#$ffe1fffe,-128(a0)
.gogo	move.b	d3,(a0)
	move.l	#$01005200,4(a0)
	lea	132(a0),a0
	dbf	d7,.lp	
.end	move.b	d3,(a0)			; final wait to clr the screen

nop:
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

zeroflag	dc.w	0

;---------------------------------------------------------- SYSTEM-POINTER

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

zoomcounter	dc.w	0


;---------------------------------------------------------- INCLUDES

		incdir	dh1:code/Sources/

XSinTab:	include	`brushzoom/xsintab1.s`
YSinTab:	include	`brushzoom/ysintab1.s`
Brush:		incbin	`brushzoom/Y&Y32x32x5.raw`

;	auto	is\0\360\256\64\64\w40\yy	; geerate x sin		OK!

;---------------------------------------------------------- Copperlist

		section	data,data_c

Copperlist:	dc.w	$106,0,$1fc,0
		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$140,0,$150,0,$160,0,$170,0
		dc.w	$148,0,$158,0,$168,0,$178,0
		dc.w	$180,0
		dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
		dc.w	$102,0,$104,$0,$108,-40,$10a,-40
Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
CopSpace:	ds.w	66*32+4		; (ffe1fffe,01000000)
copend		dc.l	$fffffffe

ZoomPic:	incbin	`brushzoom/Zoompic.raw`

;---------------------------------------------------------- BitplaneSpacen

		section	Bitplanes,bss_c

CopBrush:	ds.w	32*32
