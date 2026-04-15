
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
	bsr.w	InitCopRast
	bsr.w	InitLogo

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
	move	RPos1(pc),d0
	lea	VHRastTab(pc),a5
	addq	#2,d0
	and	#511,d0
	move	d0,Rpos1
	move	(a5,d0.w),d0
	move	d0,d1
	lsl	#5,d0
	lsl	#3,d1
	add	d1,d0
	lea	(a0,d0.w),a0
.dorst:	move.l	PlayField2(pc),a1
	lea	40(a1),a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#0,$64(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[1*64]+[320/16],$58(a6)	; x
CopRst:	lea	RstCop+128*12(pc),a0
	move	Rpos2(pc),d0
	addq	#2,d0
	and	#511,d0
	move	d0,Rpos2
	move	(a5,d0.w),d5	; loop länge
	move.l	a0,a1
	move	#$0ccc,d0	; $192
	move	#$0666,d1	; $196
	move	d0,d3
	move	d1,d2
	moveq	#5,d6
.up	move	d5,d7
.lp:	move	d0,06(a0)
	move	d1,10(a0)
	move	d2,06(a1)
	move	d3,10(a1)
	add	#12,a0		; /\
	sub	#12,a1		; \/
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
	move.l	Playfield1(pc),d0
	move.l	Playfield2(pc),d1
	lea	Planes+2(pc),a0
	moveq	#3-1,d7		; init PF1
.pf1:	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#10240,d0
	addq	#8,a0
	dbf	d7,.pf1
	moveq	#2-1,d7		; init PF2
.pf2:	move	d1,4(a0)
	swap	d1
	move	d1,(a0)
	swap	d1
	add.l	#40,d1
	addq	#8,a0
	dbf	d7,.pf2
	rts

;---------------------------------------------------------- INITCOPRASTER

InitCopRast:
	lea	RstCop(pc),a2
	move.l	#$30e1fffe,d0
	move.l	#$01920000,d1		; PF2 color 01
	move.l	#$01960000,d2		; PF2 color 03
	move.l	#$01000000,d3
	move	#256-1,d7
.lp:	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	add.l	d3,d0
	dbf	d7,.lp
	move.l	PlayField2(pc),a0
.wblt:	btst	#14,$02(a6)		; Plane1 füllen.....
	bne.b	.wblt
	move.l	#$ffffffff,$44(a6)
	move.l	#$00000000,$64(a6)
	move.l	#$090f0000,$40(a6)
	move.l	a0,$50(a6)		; OK OK !  Es is' böswillig, aber was
	move.l	a0,$54(a6)		; solls, daß Ergebnis zählt doch oda ?
	move	#[1*64]+[320/16],$58(a6)
	rts

InitLogo:
	lea	Logo(pc),a0
	move.l	PlayField1(pc),a1
.wbltr:	btst	#14,$02(a6)
	bne.b	.wbltr
	move.l	#$9f00000,$40(a6)
	move.l	#$fffffff,$44(a6)
	move.l	#$0000000,$64(a6)
	moveq	#3-1,d7
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	movem.l	a0-a1,$50(a6)
	move	#[80*64]+[320/16],$58(a6)
	lea	03200(a0),a0
	lea	10240(a1),a1
	dbf	d7,.wblt
	lea	LgCols(pc),a1
	move	#$180,d0
	moveq	#8-1,d7
.clp:	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp
	rts


;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
oldVBI		dc.l	0
VectorBase	dc.l	0
Rpos1:		dc.w	0	
Rpos2:		dc.w	0	
PlayField1	dc.l	Bitplane1
PlayField2	dc.l	Bitplane2
gfxname		dc.b	'graphics.library',0,0
vbr_exception	dc.l	$4e7a0801		; movec vbr,d0
		rte				; back to user state code


;---------------------------------------------------------- COPPERLIST 

Cop:	dc.w	$106,0,$1fc,0		; AGA-Fix
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$104,$0,$108,0,$10a,-40
	dc.w	$100,$5600
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
Planes:	dc.w	$e0,0,$e2,0	; \
	dc.w	$e8,0,$ea,0	;  )> PF1
	dc.w	$f0,0,$f2,0	; /
	dc.w	$e4,0,$e6,0	; \ > PF2
	dc.w	$ec,0,$ee,0	; /
LgCols:	ds.w	2*8
RstCop:	ds.l	3*256
	dc.l	$fffffffe

;---------------------------------------------------------- Includes
		incdir	`duke_sources_6:intro2/`
Logo		incbin	`Motion320x80x3.raw`
VRaster:	incbin	`Raster320x160x1.raw`

;---------------------------------------------------------- JumpTab

VHRasttab:	include	`jumptab.s`	; Tab from 0 to 160  256 values

;---------------------------------------------------------- BitPlaneSpace

	section	Bitplanes,bss_c
	
BitPlane1:	ds.b	3*10240		; sequenziell !!
BitPlane2:	ds.b	2*40
