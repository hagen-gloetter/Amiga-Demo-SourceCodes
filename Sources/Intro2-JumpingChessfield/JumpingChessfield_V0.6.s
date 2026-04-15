
;			 Jumping Chessfield
;		   by Duke of Haze on the 30.11.93


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

.getVBR	move.l	4.w,a6
	moveq	#0,d0
	and.b	#$f,$129(a6)		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
.68000	move.l	d0,VectorBase		; save it
	lea	$dff000,a6

;---------------------------------------------------------- INITS

	bsr.w	initBitPlane
	bsr.w	InitRastCop

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

;------------------------------------------------------------ MAIN ROUTINE
;------------------------------------------------------------ DO RASTERS

Raster:	lea	VRaster(pc),a0
	move.l	RPos(pc),a5
	move	(a5),d0
	bne.b	.ok
	lea	VHRastTab(pc),a5
	move	(a5),d0
.ok:	addq	#2,a5
	move.l	a5,Rpos
	move	d0,d1
	lsl	#5,d0
	lsl	#3,d1
	add	d1,d0
	lea	(a0,d0.w),a0
.dorst:	lea	Bitplane2+40,a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	clr.l	$64(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[1*64]+[320/16],$58(a6)
CopRst:	lea	RstCop+128*12(pc),a0
	move.l	Rpos2(pc),a5
	move	(a5),d5
	bne.b	.go
	lea	VHRastTab(pc),a5
	move	(a5),d5
.go:	addq	#2,a5
	move.l	a5,Rpos2
	move.l	a0,a1
	move	#$0aaa,d0
	move	#$0000,d1
	move	d0,d3
	move	d1,d2
	moveq	#1,d6
.up:	move	d5,d7
.lp:	move	d0,06(a0)
	move	d1,10(a0)
	move	d2,06(a1)
	move	d3,10(a1)
	add	#12,a0
	sub	#12,a1
	addq	#1,d6
	cmp	#128,d6
	beq.b	.end
	dbf	d7,.lp
	exg	d0,d1
	exg	d2,d3
	bra.b	.up
.end:
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;---------------------------------------------------------- INITBITPLANE

InitBitPlane:
	lea	BitPlane1(pc),a0
	lea	Bitplane2(pc),a1
	lea	Planes(pc),a2
	move	#$e0,d1
	moveq	#2-1,d7
.lp:	move.l	a0,d0
	swap	d0
	move	d1,(a2)+
	move	d0,(a2)+
	addq	#2,d1
	move	d1,(a2)+
	move	a0,(a2)+
	addq	#6,d1
	add	#10240,a0
	dbf	d7,.lp
	moveq	#2-1,d7
	move	#$e2,d1
.dpf:	move.l	a1,d0
	swap	d0
	addq	#2,d1
	move	d1,(a2)+
	move	d0,(a2)+
	addq	#2,d1
	move	d1,(a2)+
	move	a1,(a2)+
	addq	#4,d1
	add	#40,a1
	dbf	d7,.dpf
	rts

;---------------------------------------------------------- INITCOPRASTER

InitRastCop:
	lea	RstCop(pc),a2
	move.l	#$30e1fffe,d0
	move.l	#$01920000,d1
	move.l	#$01960000,d2
	move	#256-1,d7
.lp:	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	add.l	#$01000000,d0
	dbf	d7,.lp
	lea	Bitplane2(pc),a0	; OK OK !  Es is' böswillig, aber was
	lea	Bitplane2(pc),a1	; solls, daß Ergebnis zählt doch oda ?
.wblt:	btst	#14,$02(a6)		; Plane1 füllen.....
	bne.b	.wblt
	move.l	#-1,$dff044
	move.l	#0,$64(a6)
	move.l	#$90f0000,$40(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move	#[1*64]+[320/16],$58(a6)
	rts

;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a0801		; movec vbr,d0
		rte				; back to user state code

;---------------------------------------------------------- POINTER

Rpos:		dc.l	VHRastTab
Rpos2:		dc.l	VHRastTab

;---------------------------------------------------------- COPPERLIST 

Cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$104,$64,$108,0,$10a,-40
	dc.w	$100,$5600
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.w	$f0,0,$f2,0
RstCop:	ds.l	3*256
	dc.l	$fffffffe

;---------------------------------------------------------- Includes
		incdir	`duke_sources_6:intro2/`
VRaster:	incbin	`raster320x184x1.raw`

;---------------------------------------------------------- JumpTab

VHRasttab:;	values = 200
	dc.w	83,86,88,91,93,96,98,101,103,106,108,111,113,116,118,120
	dc.w	123,125,127,129,131,133,135,137,139,141,143,145,146,148,149,151
	dc.w	152,154,155,156,157,158,159,160,161,162,162,163,164,164,164,165
	dc.w	165,165,165,165,165,165,164,164,164,163,162,162,161,160,159,158
	dc.w	157,156,155,154,152,151,149,148,146,145,143,141,139,137,135,133
	dc.w	131,129,127,125,123,120,118,116,113,111,108,106,103,101,98,96
	dc.w	93,91,88,86,83,80,78,75,73,70,68,65,63,60,58,55
	dc.w	53,50,48,46,43,41,39,37,35,33,31,29,27,25,23,21
	dc.w	20,18,17,15,14,12,11,10,9,8,7,6,5,4,4,3,2,2,2,1,1,1,1,1
	dc.w	1,1,2,2,2,3,4,4,5,6,7,8,9,10,11,12,14,15,17,18,20,21,23,25
	dc.w	27,29,31,33,35,37,39,41,43,46,48,50,53,55,58,60
	dc.w	63,65,68,70,73,75,78,80
	dc.l	0

;---------------------------------------------------------- BitPlaneSpace

BitPlane1:	ds.b	2*10240
BitPlane2:	ds.b	2*40
