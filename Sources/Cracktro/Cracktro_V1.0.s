;        T	       T
	incdir	dh1:code/sources/


wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


	section	code,code_c		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
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
	move.l	#copperlist,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083e0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

BarInit:
	lea	Barpic,a0		; copy to bpl
	lea	Barplane+16,a1
	wblt
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
initSpr	move.l	#LaserSprite,d0		; init lasersprite
	lea	CopperLaser+2,a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
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
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon(pc),d0		; restore sys dmacon
	move	adkcon(pc),d1		; restore sys adkcon
	move	intena(pc),d2		; restore interenable
	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	move.l	stackptr(pc),a7
	moveq	#0,d0
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	move.w	demoflag(pc),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.skript(PC,d0.w),a0
	jmp	(a0)

.skript
	dc.l	MoveLaserSprite
	dc.l	ShowLogo
	dc.l	ChangeScreen
	dc.l	WaitSomeFrames
	dc.l	MoveMTN
	dc.l	FadeDown
	dc.l	InitSpirale
	dc.l	Spirale
	
;-------------------------------------------------------- MAIN ROUTINE

VbiEnd:
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Move Laser Sprite

MoveLaserSprite:
	lea	LaserSprite,a0
	move	sprx,d0			; X-coord
	cmp	#500,d0
	ble.w	.go
	addq	#1,demoflag
.go	addq	#2,sprx
	move	#175,d1			; Y-coord
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3			; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	move.b	d1,(a0)			; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	addq	#2,d1			; Spr Höhe
	move.b	d1,2(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	bra.b	VbiEnd

;---------------------------------------------------------- Show Logo
ShowLogo:
	lea	Barcop,a0
	move	(a0),d0
	cmp	#$aae1,d0
	beq.b	.end
.shrink	move	#$0100,d0
	add	d0,(a0)
	add	d0,16(a0)
	add	d0,32(a0)
	add	d0,48(a0)
	add	d0,64(a0)
	add	d0,80(a0)
	sub	d0,96(a0)
	sub	d0,112(a0)
	sub	d0,128(a0)
	sub	d0,144(a0)
	sub	d0,160(a0)
	bra.w	VbiEnd
.end	addq	#1,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- ChangeScreen

ChangeScreen:
	lea	Barcop+6,a0
	move.l	#Barplane,d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	move.l	#$01080000,06(a0)
	move.l	#$01001200,10(a0)
	move.l	#$b4e1fffe,14(a0)
	move.l	#$01000000,18(a0)
	move.l	#$fffffffe,22(a0)
	addq	#1,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- Wait some Frames
WaitSomeFrames:
	move	wait,d0
	cmp	#100,d0
	beq.b	.end
	addq	#1,d0
	move	d0,wait
	bra.w	VbiEnd
.end	addq	#1,demoflag
	clr	wait

;---------------------------------------------------------- Move Motion Out
MoveMTN:
	move	wait,d0
	cmp	#30,d0
	beq.b	.end
	addq	#1,d0
	move	d0,wait
	lea	Barplane,a1
	lea	2(a1),a0
	wblt
	move	#14,$64(a6)
	move	#14,$66(a6)
	move.l	#$89f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[10*64]+[208/16],$58(a6)
	bra.w	VbiEnd
.end	addq	#1,demoflag
	clr	wait
	bra.w	VbiEnd

FadeDown:
	move	wait,d0
	bne.b	.end
	lea	.fade,a0
	move	.fadecnt,d1
	move	(a0,d1.w),d0
	bmi.b	.exit
	move	d0,BarCols+2
	addq	#2,.fadecnt
	addq	#8,wait
	bra.w	VbiEnd
.end	subq	#1,wait
	bra.w	VbiEnd
.exit	addq	#1,demoflag
	clr	wait
	bra.w	VbiEnd
.fade	dc.w	$123,$112,$111,$000,-1	
.fadecnt	dc.w	0


InitSpirale:
ShowTextBitplane:
	move.l	#TextBitplane,d0
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
	move	(a0)+,d1
	and	#$00f,d1
	move	d1,(a1)+
	addq	#2,d0
	dbf	d7,.lp1
	move	fontcolor(pc),d1
	moveq	#8-1,d7			; color 7-f
.lp2	move	d0,(a1)+
	move	d1,(a1)+
	addq	#2,d0
	dbf	d7,.lp2

initCopperlist
	lea	CopperSpirale,a0
	move.l	#$2ae1fffe,d0
	move.l	#$00e00000,d1
	move.l	#$00e20000,d2
	move.l	#$00e40000,d3
	move.l	#$00e60000,d4
	move.l	#$00e80000,d5
	move.l	#$00ea0000,d6
	move	#0000256-1,d7
.lp:	movem.l	d0-d6,(a0)
	lea	28(a0),a0
	add.l	#$01000000,d0
	dbf	d7,.lp
	move.l	#$01000000,a0

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
	move.l	#Copperlist2,$80(a6)
	move	#$1234,$88(a6)
	addq	#1,demoflag
	bra.w	VbiEnd



Spirale:
	lea	CopperSpirale+6,a0
	lea	Sintab(pc),a5
	lea	PictureTab,a1

	move	SinCounter1(pc),d0		; readsin1
	move	SinCounter2(pc),d1		; readsin2
	move	#1023,d3
	addq	#4,d0
	addq	#2,d1
	and	d3,d0
	and	d3,d1
	move	d0,SinCounter1
	move	d1,SinCounter2
	moveq	#0,d2
	move	#256-1,d7

.lp	move	(a5,d0.w),d2
	add	(a5,d1.w),d2
;	and.b	#127,d2
	lsl	#4,d2
	lea	(a1,d2.w),a2
	move	(a2)+,04(a0)
	move	(a2)+,00(a0)
	move	(a2)+,12(a0)
	move	(a2)+,08(a0)
	move	(a2)+,20(a0)
	move	(a2)+,16(a0)
	lea	28(a0),a0
	addq	#2,d0			; sin1
	addq	#6,d1			; sin2
	and	d3,d0
	and	d3,d1
	dbf	d7,.lp


	bra.w	VbiEnd

Fontcolor	dc.w	$ccc

SinTab:		include	`spirale2/sintab2.s`	; 256 Werte 0-63
SinCounter1	dc.w	0
SinCounter2	dc.w	160

;---------------------------------------------------------- Pointer

demoflag		dc.w	0
sprx		dc.w	50	; LaserSprte xcoord
wait		dc.w	0

skript		dc.l	0

stackptr		dc.l	0
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

;---------------------------------------------------------- Includes

Module:		incbin	tunes/pro.ChipTune3

Font:		include	addtro/Font3.8x8.hex
BarPic:		incbin	addtro/barcode80x10x1.raw
		cnop	0,8
		include	makros/haze80x12x2.spr
		cnop	0,8

LaserSprite:	dc.w	$0000,$0000,$c000,$0000
		dc.w	$c000,$0000,$0000,$0000

;---------------------------------------------------------- Copperlist

		cnop	0,8
CopperList:	dc.w	$106,0,$1fc,0
CopperLaser:	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$1a0,0,$1a2,$a00,$1a4,$a00,$1a6,$a00
BarCols		dc.w	$180,$123,$182,0
		dc.w	$8e,$8881,$90,$d8c1
		dc.w	$92,$38,$94,$d0
		dc.w	$102,0,$104,$10
		dc.w	$108,-40
		dc.w	$100,$0000
BarCop		ds.w	10*8+4
		dc.l	$fffffffe


CopperList2:	dc.w	$106,0,$1fc,0
Sprite:		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$140,0,$150,0,$160,0,$170,0
		dc.w	$148,0,$158,0,$168,0,$178,0
		dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$444
		dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$444
		dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$444
		dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$444
		dc.w	$180,$0,$182,$0
		dc.w	$8e,$2b81,$90,$2bc1,$92,$3c,$94,$d4
		dc.w	$102,0,$104,$10,$108,0,$10a,0
		dc.w	$100,$c200
CopperPlanes:	dc.w	$ec,0,$ee,0
CopperColors:	ds.w	32
CopperSpirale:	ds.w	256*14+2
		dc.l	$fffffffe

Picture:		incbin	`spirale2/spirale640x128x3.int`

;---------------------------------------------------------- BitplaneSpace

		section	Tabelle,bss_p

PictureTab:	ds.l	4*128		; vorberechnete Langwörter

		cnop	0,8
BarPlane:	ds.b	10*40
		cnop	0,8

TextBitplane:	ds.b	20480+80	; TextBitplane

