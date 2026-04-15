

; Addtro for Deep Space Nine 


wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

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
	move	#$7fff,$9a(a6)		; clear interrupt enable
	move	#$7fff,$96(a6)		; clear dma channels
	move.l	#Copperlist,$80(a6)	; copper1 start address
	move	#$1234,$88(a6)		; copjump 1
	move	#$83e0,$96(a6)		; dmacon data
	move	#$7fff,$9c(a6)		; clear irq request
	move	#$4000,$9a(a6)		; interrupt disable
	move	#$0000,demoflag		; clear democounter
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
	
skript:	move	demoflag,d0		;demo skript
	beq.b	MoveLaserSprite
	cmp	#1,d0
	beq.w	ShowLogo
	cmp	#2,d0
	beq.w	ChangeScreen
	cmp	#3,d0
	beq.w	WaitSomeFrames
	cmp	#4,d0
	beq.w	MoveMTN
	cmp	#5,d0
	beq.w	SwitchScreen
	cmp	#6,d0
	beq.w	ShowHaze
	cmp	#7,d0
	beq.w	ShowDS9

VbiEnd:	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Move Laser Sprite
MoveLaserSprite:
	lea	LaserSprite,a0
	move	sprx,d0			; X-coord
	cmp	#500,d0
	bne.b	.go
	move	#1,demoflag
.go	add	#2,sprx
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
	sub	d0,80(a0)
	sub	d0,96(a0)
	sub	d0,112(a0)
	sub	d0,128(a0)
	sub	d0,144(a0)
	sub	d0,160(a0)
	bra.w	VbiEnd
.end	move	#2,demoflag
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
	move	#3,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- Wait some Frames
WaitSomeFrames:
	move	wait,d0
	cmp	#100,d0
	cmp	#20,d0			; extend
	beq.b	.end
	addq	#1,d0
	move	d0,wait
	bra.w	VbiEnd
.end	move	#4,demoflag
	clr	wait
MakeDS9Copperlist:
	lea	DS9Copper,a0
	move	#256-1,d7
	move.l	#$30e1fffe,d0
	move.l	#$01080050,d1
	move.l	#$010a0050,d2
	move.l	#$01020000,d3
.lp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.l	#$01000000,d0
	dbf	d7,.lp
	lea	DS9Planes+2,a0
	move.l	#DS9Screen,d0	
	moveq	#2-1,d7
.plp2	swap	d0
	move	d0,(a0)
	move	d0,16(a0)
	swap	d0
	move	d0,4(a0)
	move	d0,20(a0)
	add.l	#40960,d0
	addq	#8,a0
	dbf	d7,.plp2
.ds9colors:
	lea	DS9Colors,a0
	move	#$0180,d0
	move	#$0112,d1	; Background
	moveq	#16-1,d7
.clp	move	d0,(a0)+
	move	d1,(a0)+
	addq	#2,d0
	move	#$fff,d1
	dbf	d7,.clp
	
.copyDS9toScreen
	lea	DS9Pic,a0
	lea	DS9Screen+80+18+40*160,a1
	bsr.b	.copy
	lea	DS9Pic+31*44,a0
	lea	DS9Screen+80+18+100*160,a1
	bsr.b	.copy
	lea	DS9Pic+62*44,a0
	lea	DS9Screen+80+18+160*160,a1
	bsr.b	.copy
	bra.w	VbiEnd
.copy	wblt
	move	#0,$64(a6)
	move	#116,$66(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[31*64]+[352/16],$58(a6)
	rts

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
.end	move	#5,demoflag
	clr	wait
	bra.w	VbiEnd

;---------------------------------------------------------- Switch Screen
SwitchScreen:
	move.l	#DS9Copperlist,$80(a6)
	move	#$001234,$88(a6)
	move.l	#Spr1,d0
	lea	HazeSprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp
	move	#6,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- Show Haze
ShowHaze:
	move	#$c200,DS9Con+2
	move	sprx,d0			; X-coord
	cmp	#376,d0
	bge.b	.go
	move	#7,demoflag
.go	subq	#4,sprx
	lea	Spr1,a0
	moveq	#5-1,d7
	move	#280,d1			; Y-coord
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3			; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	move.b	d1,(a0)			; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	add.w	#12,d1			; Spr Höhe
	move.b	d1,2(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	add	#16,d4
	move	d4,d0
	move	d5,d1
	lea	56(a0),a0
	dbf	d7,.spr
	bra.w	VbiEnd

;---------------------------------------------------------- Show DS9
ShowDS9:
	lea	DS9Copper+6,a0
	moveq	#2,d1
	moveq	#2,d2
	move	(a0),d0
	cmp	#160,d0
	beq.b	.end
	add	d1,d0
	move	d0,(a0)
	add	d1,d2
	lea	16(a0),a0
	move	#200,d7
.elp	sub	d1,(a0)
	add	d1,16(a0)
	lea	32(a0),a0
	dbf	d7,.elp
	bra.w	VbiEnd
.end	move	#8,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- Demo Pointer

DemoFlag	dc.w	0	; 0=moveSpr 1=showlogo 2=logoout
sprx:		dc.w	50	; LaserSprte xcoord
wait		dc.w	0

;---------------------------------------------------------- System Pointer

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



		Section	chipdata,data_c

;---------------------------------------------------------- Includes

BarPic:		incbin	addtro/barcode80x10x1.raw
DS9Pic:		incbin	addtro/DS9Pic352x93x1.raw
		include	makros/haze80x12x2.spr

LaserSprite:	dc.w	$0000,$0000,$c000,$0000
		dc.w	$c000,$0000,$0000,$0000

;---------------------------------------------------------- Copperlist

CopperList:	dc.w	$106,0,$1fc,0
CopperLaser:	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$1a0,0,$1a2,$a00,$1a4,$a00,$1a6,$a00
BarCols		dc.w	$180,$112,$182,0
		dc.w	$8e,$8881,$90,$d8c1
		dc.w	$92,$38,$94,$d0
		dc.w	$102,0,$104,$10
		dc.w	$108,-40
		dc.w	$100,$0000
BarCop		ds.w	10*8+4
		dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

DS9Copperlist:	dc.w	$106,0,$1fc,0
HazeSprite:	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$000
		dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$000
		dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$000
		dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$000
		dc.w	$8e,$3081,$90,$30c1
		dc.w	$92,$3c,$94,$d4,$102,0,$104,$10
DS9Planes:	dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
DS9Colors	ds.w	16*2
		dc.w	$3007,$fffe
DS9Con:		dc.w	$100,$00
DS9Copper	ds.w	256*8
		dc.l	$fffffffe

		Section	bss,bss_c

BarPlane:	ds.b	10*40

DS9Screen:	ds.b	160*256*2

