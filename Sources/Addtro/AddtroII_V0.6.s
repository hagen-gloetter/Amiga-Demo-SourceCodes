
	printt	10
	printt	` Addtro for Deep Space Nine - Coded by DUKE of HAZE `


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
	cmp	#8,d0
	beq.w	TypeText
	cmp	#9,d0
	beq.w	WaitSomeFrames2
	cmp	#10,d0
	beq.w	ShowTyper
	cmp	#11,d0
	beq.w	ShowScroller

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
	swap	d0
	move	d0,4(a0)
	add.l	#160,d0
	swap	d0
	move	d0,16(a0)
	swap	d0
	move	d0,20(a0)
	add.l	#40960-160,d0
	addq	#8,a0
	dbf	d7,.plp2
.ds9colors:
	lea	DS9Colors,a0
	lea	DS9ColTab,a1
	move	#$0180,d0
	moveq	#16-1,d7
.clp	move	d0,(a0)+
	move	(a1)+,(a0)+
	addq	#2,d0
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
	move	(a0),d0
	beq.b	.end
	sub	d1,d0	
	move	d0,(a0)
	add	d1,d1
	add	#16,a0
	add	#4,16*80(a0)
	sub	#4,16*140(a0)
	bra.w	VbiEnd
.end	move	#8,demoflag
	bra.w	VbiEnd

;---------------------------------------------------------- Type Box Info
TypeText:
	move.l	TxtPtr(pc),a0
	lea	ds9screen+40964+80,a4
	move.l	a4,a1
	lea	Font,a2
.type	moveq	#0,d0
	move.b	(a0)+,d0
	beq.b	.end
	cmp	#1,d0			; return
	bne.b	.print
	lea	1280(a4),a4
	lea	(a4),a1
	move.b	(a0)+,d0
	beq.b	.end
.print	sub	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,000(a1)		; copy 1. line
	move.b	(a3)+,160(a1)		; copy 2. line
	move.b	(a3)+,320(a1)		; copy 3. line
	move.b	(a3)+,480(a1)		; copy 4. line
	move.b	(a3)+,640(a1)		; copy 5. line
	move.b	(a3)+,800(a1)		; copy 6. line
	move.b	(a3)+,960(a1)		; copy 7. line
	move.b	(a3)+,1120(a1)		; copy 8. line
	addq	#1,a1			; x = x+1
	bra.b	.type
.end	move	#9,demoflag
	clr	wait
	bra.w	vbiend

;---------------------------------------------------------- Wait 2
WaitSomeFrames2:
	move	wait,d0
	cmp	#100,d0
	cmp	#20,d0		; extend
	beq.b	.end
	addq	#1,d0
	move	d0,wait
	bra.w	VbiEnd
.end	move	#10,demoflag
	clr	wait
	bra.w	vbiend

;---------------------------------------------------------- Show Text
ShowTyper:
	lea	DS9Copper+10,a0
	moveq	#2,d1
	move	(a0),d0
	beq.b	.end
	sub	d1,d0	
	move	d0,(a0)
	add	d1,d1
	bra.w	VbiEnd
.end	move	#11,demoflag
	bra.w	VbiEnd

ShowScroller:
	move	scrollwait,d0
	and.b	#3,d0
	bne.b	.scroll
.type	move.l	ScrollPointer,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.b	.go
	lea	Scrolltext,a0
	move.b	(a0)+,d0
.go	move.l	a0,ScrollPointer
	lea	Font,a2
	lea	(a2,d0.w),a3
	lea	Ds9Screen+160*466+160,a1
.print	sub	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,0*160(a1)		; copy 1. line
	move.b	(a3)+,1*160(a1)		; copy 2. line
	move.b	(a3)+,2*160(a1)		; copy 3. line
	move.b	(a3)+,3*160(a1)		; copy 4. line
	move.b	(a3)+,4*160(a1)		; copy 5. line
	move.b	(a3)+,5*160(a1)		; copy 6. line
	move.b	(a3)+,6*160(a1)		; copy 7. line
	move.b	(a3)+,7*160(a1)		; copy 8. line

.scroll	lea	Ds9Screen+160*466+80,a1
	lea	2(a1),a0
	wblt
	move	#78,$64(a6)
	move	#78,$66(a6)
	move.l	#$e9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[8*64]+[656/16],$58(a6)
	add	#1,scrollwait
	bra.w	VbiEnd


;---------------------------------------------------------- Demo Pointer

DemoFlag	dc.w	0	; 0=moveSpr 1=showlogo 2=logoout
sprx		dc.w	50	; LaserSprte xcoord
wait		dc.w	0
TxtPtr		dc.l	Typertext
ScrollPointer	dc.l	ScrollText
Scrollwait	dc.w	0

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


TyperText:	; 0=End 1=Return
 dc.b 1
 dc.b `+-------------------------------------------------------------------+`,1
 dc.b `|         ALWAYS REMEBER:  MOTION MAKES THE WORLD GO ROUND          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| FASTWAY            WHQ | RD: +49-714-129-0036 DST      | ANDY     |`,1
; dc.b `|                        | #2: +49-714-129-0036 DST      |          |`,1
; dc.b `|                        | #3: +49-714-129-0036 DST      |          |`,1
; dc.b `|                        | #4: +49-714-129-0036 DST      |          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| GATEWAY TO HELL    GHQ | #1: +49-712-147-8470 DST      | DRAGON   |`,1
 dc.b `|                        | #2: +49-712-144-696  DST      |          |`,1
 dc.b `|                        | #3: +49-712-194-1590 ISDN     |          |`,1
 dc.b `|                        | #4: +49-712-194-1591 ISDN     |          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| DEEP SPACE NINE    GHQ | #1: +49-715-290-2518 V32.bis  | SISKO    |`,1
 dc.b `|                        | #2: +49-715-290-2508 DST <-RD |          |`,1
; dc.b `|                        | #3: +49-715-290-2507 DST      |          |`,1
 dc.b `|                        | #4: +49-715-293-8240 ISDN<-RD |          |`,1
; dc.b `|                        | #5: +49-715-293-8241 ISDN     |          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| BLIND DATE         GHQ | #1: +49-714-151-252  HST      | PSYCHO   |`,1
 dc.b `|                        | #2: +49-714-151-759  V32.bis  |          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| RESTRICTED AREA    GHQ | #1: +49-816-566-642  DST      | JMS      |`,1
 dc.b `|                        | #2: +49-816-566-738  V32.bis  |          |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| PARANOID ILLUSION USHQ | #1:  +1-203-859-0335 DST      | BUZZ     |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b `| BONEHEADS         USHQ | #1:  +1-909-356-0787 DST      | BONEHEAD |`,1
 dc.b `+------------------------+-------------------------------+----------+`,1
 dc.b 0,0,0,0
 even

ScrollText:
	dc.b	`HAZE - Crazy Fools, without any rules              `
	dc.b	` HAZE - There is always a nop, that can be inserted `
	dc.b	`        HAZE - To boldly go, where no sane has gone before `
	dc.b	`        Question: What does "Bones" McCoy say befor he `
	dc.b	`performes brain surgery on a blonde ?               `
	dc.b	`                                              `
	dc.b	` Answer: Space. The final frontier......      `
	dc.b	`                                              `
	dc.b	` This nice Addtro was coded by Duke.  `
	dc.b	` The GFX were done by Fnord.    `
	dc.b	` The Sound was composed by  .... na wie soll ich sagen ? `
	dc.b	` ... Ich hoff halt, dass mir Mad Hatter einen ChipTune `
	dc.b	`bastelt ....             See ya soon, or somewhere in time `
	dc.b	`     Duke of Haze/Motion                                 `
	dc.b	0
	even
			; 0    1    2    3    4    5    6    7
DS9ColTab:	dc.w	$123,$555,$778,$778,$aaa,$999,$778,$778
		dc.w	$eee,$eee,$eed,$eee,$eee,$bbc,$eed,$eed
			; 8    9    10   11   12   13   14   15

; 1\/,4/\,5* =Pic  2,3,6,7\/,8,9,12,13/\,10,11,14,15*

		Section	chipdata,data_c

;---------------------------------------------------------- Includes

Font:		include	addtro/Font2.8x8.hex
BarPic:		incbin	addtro/barcode80x10x1.raw
DS9Pic:		incbin	addtro/DS9Pic352x93x1.raw
		include	makros/haze80x12x2.spr

LaserSprite:	dc.w	$0000,$0000,$c000,$0000
		dc.w	$c000,$0000,$0000,$0000

;---------------------------------------------------------- Copperlist

CopperList:	dc.w	$106,0,$1fc,0
CopperLaser:	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$1a0,0,$1a2,$a00,$1a4,$a00,$1a6,$a00
BarCols		dc.w	$180,$123,$182,0
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
		dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$333
		dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$333
		dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$333
		dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$333
		dc.w	$8e,$3081,$90,$29c1
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
