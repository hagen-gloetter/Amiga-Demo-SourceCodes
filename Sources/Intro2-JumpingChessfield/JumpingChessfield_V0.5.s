;
;	Rasterdance by Duke of PRESTIGE written on the 21.11.'92
;	========================================================

;	By now it's a hack of 1½h and I hope there 'll be
;	enough time to improve this little Routine ...
;


	section RasterDance,Code_C

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initBitPlane
	bsr.w	InitRastCop
	bsr.w	DKESpr
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2
	bsr.b	initVBI			; Call Init to mount the VBI
mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.b	mloop
	bsr.b	removeVBI		; Call Out to remove the IRQ
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;---------------------------------------------------------- VBI

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	bsr.w	Raster
	move	#$0020,$9c(a6)		; Restore IRQ Base
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- VBI-INIT

initVBI:
	lea	$dff000,a6
	move	$1c(a6),intena		; interrupt installieren
	move.l	$6c.w,oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c.w
	move	#%1100000000100000,$9a(a6)
;	move	#$0020,$96(a6)
	rts

;---------------------------------------------------------- VBI-REMOVE

removeVBI:
	lea	$dff000,a5
	move	#$7fff,$9a(a5)
	move.l	oldVBI(pc),$6c.w
	move	intena(pc),d0
	or	#$8000,d0
	move	d0,$9a(a5)
;	lea	gfxname(pc),a1		; only when using CopList1
;	moveq	#0,d0
;	move.l	4.w,a6
;	jsr	-552(a6)
;	move.l	d0,a4
;	move.l	38(a4),$80(a5)
;	move	#0,$88(a5)
	move	#$8020,$96(a5)
	move	#$c00,$9a(a5)
	rts

;---------------------------------------------------------- INITBITPLANE

InitBitPlane:
	lea	BitPlane1,a0
	lea	Bitplane2,a1
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
	lea	RstCop,a2
	move.l	#$30e1fffe,d0
	move.l	#$01920000,d1
	move.l	#$01960000,d2
	move	#256-1,d7
.lp:	move.l	d0,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	add.l	#$01000000,d0
	dbf	d7,.lp
	lea	Bitplane2,a0	; OK OK !  Es is' böswillig, aber was
	lea	Bitplane2,a1	; solls, daß Ergebnis zählt doch oda ?..
.wblt:	btst	#14,$02(a6)	; Plane1 füllen.....
	bne.b	.wblt
	move.l	#-1,$dff044
	clr.l	$64(a6)
	move.l	#$90f0000,$40(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move	#[1*64]+[320/16],$58(a6)
	rts

;------------------------------------------------------------ INIT © SPR

DKESpr:	lea	DSpr(pc),a0
	lea	SprDat(pc),a1
	move	#417,d0
	move	#280,d1
	bsr.b	.CalcCW
	add	#28,a0
	add	#8,a1
	move	#433,d0
	move	#280,d1
.CalcCW:move.l	a0,d4
	swap	d4
	move	d4,2(a1)
	move	a0,6(a1)
	moveq	#0,d3
	moveq	#6,d2
	move.b	d1,(a0)
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3
.noE8:	add.w	d2,d1
	move.b	d1,2(a0)
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3
.noL8:	lsr.w	#1,d0
	bcc.b	.noH0
	bset	#0,d3
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	rts	

DSpr:	dc.w	$0000,$0000
	dc.w	$b1d2,$ca40,$0052,$0000
	dc.w	$7052,$4a00,$0252,$0000
	dc.w	$13de,$1850,$0000,$0000
	dc.w	$0000,$0000
	dc.w	$971a,$04a6,$9400,$0000
	dc.w	$f714,$102c,$9400,$0000
	dc.w	$9710,$04b0,$0000,$0000

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
	add	d0,a0
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
.end:	rts

;---------------------------------------------------------- POINTER

Rpos:		dc.l	VHRastTab
Rpos2:		dc.l	VHRastTab
intena:		dc.w	0
oldVBI:		dc.l	0
gfxname:	dc.b	'graphics.library',0
 even

;---------------------------------------------------------- COPPERLIST 

Cop:	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$104,$64,$108,0,$10a,-40
	dc.w	$100,$4600
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
Planes:	ds.l	2*4
RstCop:	ds.l	3*256
	dc.l	$fffffffe

VRaster:	incbin	`data5:raw/raster320x184`
BitPlane1:	ds.b	2*10240
BitPlane2:	ds.b	2*40

VHRasttab:;	values = 200
        dc.w      83,86,88,91,93,96,98,101
        dc.w      103,106,108,111,113,116,118,120
        dc.w      123,125,127,129,131,133,135,137
        dc.w      139,141,143,145,146,148,149,151
        dc.w      152,154,155,156,157,158,159,160
        dc.w      161,162,162,163,164,164,164,165
        dc.w      165,165,165,165,165,165,164,164
        dc.w      164,163,162,162,161,160,159,158
        dc.w      157,156,155,154,152,151,149,148
        dc.w      146,145,143,141,139,137,135,133
        dc.w      131,129,127,125,123,120,118,116
        dc.w      113,111,108,106,103,101,98,96
        dc.w      93,91,88,86,83,80,78,75
        dc.w      73,70,68,65,63,60,58,55
        dc.w      53,50,48,46,43,41,39,37
        dc.w      35,33,31,29,27,25,23,21
        dc.w      20,18,17,15,14,12,11,10
        dc.w      9,8,7,6,5,4,4,3
        dc.w      2,2,2,1,1,1,1,1
        dc.w      1,1,2,2,2,3,4,4
        dc.w      5,6,7,8,9,10,11,12
        dc.w      14,15,17,18,20,21,23,25
        dc.w      27,29,31,33,35,37,39,41
        dc.w      43,46,48,50,53,55,58,60
        dc.w      63,65,68,70,73,75,78,80
	dc.l	0
