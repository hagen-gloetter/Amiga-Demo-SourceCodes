
	section code,code_c

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initBitPlanes
	move	#$8020,$96(a6)
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2
	bsr.w	PrintText


WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam
;	move	#$0f0,$dff180

	bsr.w	MoveScreens
	move.l	#6000,d7
.up	subq	#1,d7
	bne.b	.up

;	move	#$f00,$dff180
mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.s	WaitVBeam

	lea	$dff000,a6
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts


wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


;---------------------------------------------------------- MOVESCREENS

MoveScreens:
	lea	Screen1(pc),a0
	lea	EPlanes+2(pc),a1
	lea	OffsetScreen1(pc),a2
	movem.l	(a0),d0-d3
	movem	(a2),d4-d7
.pl1:	add	d4,d0		; Offset addieren
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq	#8,a1
.pl2:	add	d5,d1		; Offset addieren
	move	d1,4(a1)
	swap	d1
	move	d1,(a1)
	addq	#8,a1
.pl3:	add	d6,d2		; Offset addieren
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
.pl4:	add	d7,d3		; Offset addieren
	move	d3,4(a1)
	swap	d3
	move	d3,(a1)
	addq	#8,a1
	sub	#22,d4
	bne.b	.noOv1
	move	#1408,d4
.noOv1:	sub	#44,d5
	bhi.b	.noOv2
	move	#1408,d5
.noOv2:	sub	#66,d6
	bhi.b	.noOv3
	move	#1408,d6
.noOv3:	sub	#88,d7
	bhi.b	.end
	move	#1408,d7
.end:	movem	d4-d7,(a2)
	rts

;---------------------------------------------------------- PRINT TEXT

PrintText:
	lea	Font(pc),a2
	lea	Bitplane4+1760,a1
	move.l	TextPointer(pc),a5
.lp	moveq	#0,d0
	move.b	(a5)+,d0
	bne.b	.ok
	beq.b	.end		; !!!!!!!!!!!!
	lea	Text(pc),a5
	move.b	(a5)+,d0
.ok:	sub	#32,d0
	lsl	#5,d0
	lea	(a2,d0.w),a0
	wblt
	move	#0,$64(a6)
	move	#42,$66(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[16/16],$58(a6)
	addq	#2,a1
	bra.b	.lp
.end	rts

;---------------------------------------------------------- INIT ROUTS

initBitPlanes:
	move.l	#ECop,$84(a6)
	move	#$123,$8a(a6)
eff1:	moveq	#40-1,d7
.wlp:	move.l	$04(a6),d0
	and.l	#$000ff00,d0
	cmp.l	#$0001f00,d0
	bne.s	.wlp
	dbf	d7,.wlp
	lea	ecol,a0
	sub	#$111,(a0)
	cmp	#0,(a0)
	bne.b	eff1

eff2:	moveq	#40-1,d7
.wlp:	move.l	$04(a6),d0
	and.l	#$000ff00,d0
	cmp.l	#$0001f00,d0
	bne.s	.wlp
	dbf	d7,.wlp
	lea	ecol,a0
	add	#$111,(a0)
	cmp	#$fff,(a0)
	bne.b	eff2


	move.l	Screen1(pc),d0
	lea	EPlanes+2(pc),a0
	moveq	#5-1,d7
.blp:	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq	#8,a0	
	add.l	#12672,d0
	dbf	d7,.blp
	sub.l	#12628,d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)


.initColors:
	lea	ColTab(pc),a0
	lea	Cols(pc),a1
	move	#$0180,d0
	moveq	#32-1,d7
.clp:	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp

.initBlitter
	wblt
	moveq	#-1,d0
	move.l	d0,$44(a6)
	move.l	#40,$64(a6)
	move.l	#$9f00000,$40(a6)

initBlocks:
	lea	Block2x2(pc),a0
	lea	Bitplane1,a1
	bsr.b	.FillScreen

	lea	Block4x4(pc),a0
	lea	Bitplane3(pc),a1
	bsr.b	.FillScreen

	lea	Block8x8(pc),a0
	lea	Bitplane5,a1
	bsr.b	.FillScreen

	lea	Block16x16(pc),a0
	lea	Bitplane2,a1

.FillScreen:
	moveq	#09-1,d6	
.lp:	moveq	#11-1,d7
.lp2:	wblt
	movem.l	a0-a1,$50(a6)
	move	#[32*64]+[32/16],$58(a6)
	addq	#4,a1
	dbf	d7,.lp2
	add	#1408-44,a1
	dbf	d6,.lp


.init;(c)
	lea	DSpr(pc),a0
	lea	SprDat(pc),a1
	move	#417,d0		; xcoord
	move	#290,d1		; ycoord
	bsr.b	.CalcCW
	add	#28,a0
	add	#8,a1
	move	#433,d0		; xcoord
	move	#290,d1		; ycoord
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
	
;---------------------------------------------------------- Copperliste

cop:
	dc.w	$8e,$3181,$90,$30c1
	dc.w	$92,$30,$94,$d8
	dc.w	$100,$6600,$102,0,$104,$64
	dc.w	$108,0,$10a,0
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
EPlanes:dc.w	$e0,0,$e2,0
	dc.w	$e8,0,$ea,0
	dc.w	$f0,0,$f2,0
	dc.w	$e4,0,$e6,0
	dc.w	$ec,0,$ee,0
	dc.w	$f4,0,$f6,0
cols:	ds.l	32
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
	dc.l	$fffffffe
ECop:	dc.w	$100,0,$180
ecol:	dc.w	$fff
	dc.l	$fffffffe


;---------------------------------------------------------- Pointer

; Odd Planes

Screen1:	dc.l	Bitplane1
Screen3:	dc.l	Bitplane3
Screen5:	dc.l	Bitplane5

; Even Planes

Screen2:	dc.l	Bitplane2
Screen4:	dc.l	Bitplane4
Screen6:	dc.l	Bitplane4+46

OffsetScreen1:	dc.w	1408
OffsetScreen2:	dc.w	1408
OffsetScreen3:	dc.w	1408
OffsetScreen4:	dc.w	1408

TextPointer:	dc.l	Text

Text:	dc.b	`   -=> PRESTIGE <=-    `,0
	even

;---------------------------------------------------------- GFX & FONTS

Block2x2:
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011
	dcb.l	2,%11001100110011001100110011001100
	dcb.l	2,%00110011001100110011001100110011

Block4x4:
	dcb.l	4,%11110000111100001111000011110000
	dcb.l	4,%00001111000011110000111100001111
	dcb.l	4,%11110000111100001111000011110000
	dcb.l	4,%00001111000011110000111100001111
	dcb.l	4,%11110000111100001111000011110000
	dcb.l	4,%00001111000011110000111100001111
	dcb.l	4,%11110000111100001111000011110000
	dcb.l	4,%00001111000011110000111100001111
Block8x8:
	dcb.l	8,%11111111000000001111111100000000
	dcb.l	8,%00000000111111110000000011111111
	dcb.l	8,%11111111000000001111111100000000
	dcb.l	8,%00000000111111110000000011111111
Block16x16:
	dcb.l	16,%00000000000000001111111111111111
	dcb.l	16,%11111111111111111000000000000000

ColTab:	dc.w	$000,$707,$880,$880,$080,$080,$080,$080	; Col 0-8
	dc.w	$000,$700,$777,$777,$ccc,$ccc,$aaa,$aaa ; Col 8-16
	dc.w	$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf	; Col 16-24
	dc.w	$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf,$ccf ; Col 24-32

DSpr:	dc.w	$0000,$0000,$b1d2,$ca40,$0052,$0000
	dc.w	$7052,$4a00,$0252,$0000,$13de,$1850
	dc.w	$0000,$0000,$0000,$0000,$971a,$04a6
	dc.w	$9400,$0000,$f714,$102c,$9400,$0000
	dc.w	$9710,$04b0,$0000,$0000

Font:	include	`Duke_Sources_II:makros/DukeFont.hex`

;---------------------------------------------------------- BitPlaneSpace

BitPlane1:	ds.b	12672	; 320+32/8*288
BitPlane3:	ds.b	12672
BitPlane5:	ds.b	12672

BitPlane2:	ds.b	12672
BitPlane4:	ds.b	12672
BitPlane6:	ds.b	12672

