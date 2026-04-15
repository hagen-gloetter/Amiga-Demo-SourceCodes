;               T        T              T       T

;*****************************************************************************

;	ZOOOOOM-SCROOOLLLLEERR by Duke of MoTioN

;*****************************************************************************


; Optimized Version + User controlled zoomstart&end + D-Buffering
; 

	incdir	codes:

MaxZoom	=	39	; min 0<->39 max

;---------------------------------------------------------- Makros

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

pop	macro
	cnop	0,8
	endm

;---------------------------------------------------------- Start of Code

	section	code,code_p		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1		; use base-pointer
	move.l	$26(a1),syscop1	; store systemcopper1 start adr
	move.l	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon	; store sys dmacon
	move	$010(a6),adkcon	; store sys adkcon
	move	$01c(a6),intena	; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

;*****************************************************************************
;------------------------------------------------------------------ DEMO-INITS

	bsr.w	PrintSlogan		; vor turn Font |-)
	bsr.w	MakeZoomTab
	bsr.w	TurnFont
	bsr.w	initBitPlanes

	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1

;-------------------------------------------------------------------- VBR-INIT

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000010000,$9a(a6)	; COPPER-IRQ !
	jsr	tp_init
	move	#0,tp_volume

;*****************************************************************************
;------------------------------------------------------------------ MOUSE WAIT

.exit	move	exit,d0
	beq	.exit
	clr	exit

mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop
	addq	#1,demoflag

.exit	move	exit,d0
	beq	.exit

;*****************************************************************************
;-------------------------------------------------------------- EXIT TO SYSTEM

removeVBI:	lea	$dff000,a6
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
.exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	jsr	tp_end
	lea	$dff000,a6
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

;*****************************************************************************
;------------------------------------------------------- VERTICAL BLANK ROUTNE
;*****************************************************************************

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$700,$dff180		; Rasterzeitmessung Anfang (rot)

	move	demoflag(pc),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	Skript(PC,d0.w),a0
	jsr	(a0)

	jsr	tp_play
;	move	#$090,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0010,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;*****************************************************************************
;---------------------------------------------------------------------- Skript
;*****************************************************************************

Skript:	dc.l	Setwait
	dc.l	WaitSomeFrames
	dc.l	FadeSloganIn
	dc.l	Setwait
	dc.l	WaitSomeFrames
	dc.l	FadeSloganOut
	dc.l	CopyScrollerColor
	dc.l	FadeIn
	dc.l	AllowExit		; ab hier userabbruch möglich
	dc.l	ZoomScroller			; mainpart
	dc.l	FadeFontOut
	dc.l	FadeOut

;*****************************************************************************



;--------------------------------------------------------------------- Setwait
Setwait	move	#100,wait
	addq	#1,demoflag
	rts

;-------------------------------------------------------------- WaitSomeFrames
WaitSomeFrames	subq	#1,wait
	beq.b	.end
	rts
.end	addq	#1,demoflag
	rts

;------------------------------------------------------------------- AllowExit
AllowExit	addq	#1,exit
	addq	#1,demoflag
	rts

;*****************************************************************************
;------------------------------------------------------------------ DEMO INITS
;*****************************************************************************

	pop
TurnFont:	lea	Font(pc),a0	; ACHTUNG ! isch hoch complex !
	lea	FontEnd(pc),a3	; (dreht ne 8x8x1 Font um 90 Grad)
	lea	Spareletter(pc),a1
	moveq	#0,d3
.copy	lea	0(a0),a2
	moveq	#8-1,d6
	moveq	#0,d1
.turn	moveq	#8-1,d7
	moveq	#0,d2
	moveq	#0,d0
	move.b	(a2)+,d0
.turn90	btst	d7,d0
	beq.b	.next
	bset	d1,(a1,d2)
.next	addq	#1,d2
	dbf	d7,.turn90
	addq	#1,d1
	dbf	d6,.turn
	move.l	(a1),(a0)+	; copy 4 lines
	move.l	4(a1),(a0)+	; copy 4 lines
	move.l	d3,(a1)
	move.l	d3,4(a1)
	cmp.l	a3,a0
	blo.b	.copy
	rts

;*****************************************************************************
;-------------------------------------------------------------- Init Bitplanes
initBitPlanes:	move.l	#Logo,d0
	lea	LogoBitPlanes+2,a0
	moveq	#5-1,d7		; No. of Planes
.initLogo	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40,d0		; interleave
	addq.l	#8,a0
	dbf	d7,.initLogo

;----------------------------------------------------------------- Init Colors
.initLogoColors	lea	Logo+40*57*5,a0
	lea	LogoColors,a1
	move	#$180,d0
	move	#$000,d1
	moveq	#32-1,d7
.clp	move	d0,(a1)+
	move	d1,(a1)+
	addq	#2,d0
	dbf	d7,.clp

;----------------------------------------------------------- Init Zoomerplanes
	move.l	#Z2,d0
	lea	ZoomLine1+6,a0
	moveq	#9-1,d7		; 8 lines+clr line
.initZoom	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40,d0
	add.l	#20,a0
	dbf	d7,.initzoom
	rts

;-------------------------------------------------------------- Create ZoomTab

MakeZoomTab	lea	ZoomTab,a0
	move.l	#$00010000,d0
	move	#MaxZoom*10,d7
.lp	move.l	d0,(a0)+
	add.l	#$00001000,d0
	dbf	d7,.lp
	move	#MaxZoom*10,d7
.lp2	move.l	d0,(a0)+
	sub.l	#$00001000,d0
	dbf	d7,.lp2
	rts

;--------------------------------------------------------------- Print Slogan

PrintSlogan	lea	Z2+10,a1
	lea	Slogen(pc),a0
	lea	Font(pc),a2
.print:	moveq	#0,d0
	move.b	(a0)+,d0
	beq.b	.exit
	sub	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,0*40(a1)	; copy 1. line
	move.b	(a3)+,1*40(a1)	; copy 2. line
	move.b	(a3)+,2*40(a1)	; copy 3. line
	move.b	(a3)+,3*40(a1)	; copy 4. line
	move.b	(a3)+,4*40(a1)	; copy 5. line
	move.b	(a3)+,5*40(a1)	; copy 6. line
	move.b	(a3)+,6*40(a1)	; copy 7. line
	move.b	(a3)+,7*40(a1)	; copy 8. line
	addq.l	#1,a1
	bra.b	.print	
.exit	rts


;*****************************************************************************
;-------------------------------------------------------------- FADE COLORS IN


FadeSloganIn:	lea	SlogenColors(pc),a0
	bra.b	FadeSloganOut\.fade

FadeSloganOut	lea	SlogenColors2(pc),a0

.fade	move	wait(pc),d0
	bne.b	.end
	move	#2,wait
	move	fadecnt(pc),d0
	cmp	#8,d0
	beq.b	.go
	addq	#1,fadecnt
	add	d0,d0
	lea	(a0,d0),a0
	lea	ZoomLine8+18,a1
	move	(a0),(a1)

.1up	lea	ZoomLine1+18,a1
	moveq	#7-1,d7
.flp	move	20(a1),(a1)
	add.l	#20,a1
	dbf	d7,.flp
.end	subq	#1,wait
	rts

.go	addq	#1,demoflag
	clr	fadecnt
	clr	wait
	rts

;---------------------------------------------------------- CopyScrollerColor

CopyScrollerColor
	lea	Z2,a0
	wblt			; Löschen des sichtbaren
	move.l	#-1,$44(a6)		; Scrollers (320*8)
	move	#0,$66(a6)		; auf der Bitplane
	move.l	#$01000000,$40(a6)
	move.l	a0,$54(a6)
	move	#[8*64]+[320/16],$58(a6)

	lea	FontColors(pc),a0
	lea	ZoomLine1+18,a1
	moveq	#8-1,d7
.flp	move	(a0)+,(a1)
	add.l	#20,a1
	dbf	d7,.flp
	addq	#1,demoflag
	rts	

;--------------------------------------------------------------- Fade Logo in

FadeIn	move	wait(pc),d0
	beq.b	.now
	subq	#1,wait
	bra.w	.end
.now	move	#2,wait

	move	tp_volume,d0
	cmp	#$f0,d0
	bge.b	.go
	addq	#4,tp_volume
	bra.b	.fadecl
.go	addq	#1,demoflag
	clr	wait
	move	#$ff,tp_volume	; cheat volume

.fadecl	lea	Logo+40*57*5,a0
	lea	LogoColors+2,a1
	moveq	#32-1,d7
.fadelp	move	(a0)+,d0
	move	d0,d1
	move	d0,d2
	move	(a1),d3
	move	d3,d4
	move	d3,d5
	and	#$f,d0	; b
	and	#$f,d3
	and	#$f0,d1	; g
	and	#$f0,d4
	and	#$f00,d2
	and	#$f00,d5	; r
	cmp	d0,d3
	beq.b	.nob
	addq	#1,d3	; b
.nob	cmp	d1,d4
	beq.b	.nog
	add	#$10,d4	; g
.nog	cmp	d2,d5
	beq.b	.nor
	add	#$100,d5	; r
.nor	or	d5,d4
	or	d4,d3
	move	d3,(a1)
	addq.l	#4,a1
	dbf	d7,.fadelp
.end	rts


;*****************************************************************************
;-------------------------------------------------------------- FADE FONT OUT

FadeFontOut	addq	#1,wait
	cmp	#30,wait
	bne.b	.fadecl
	addq	#1,demoflag

.fadecl	lea	ZoomLine1+18,a1
	moveq	#8-1,d7
.fadelp	move	#Hcol,d0
	move	d0,d1
	move	d0,d2
	move	(a1),d3
	move	d3,d4
	move	d3,d5
	and	#$f,d0	; b
	and	#$f,d3
	and	#$f0,d1	; g
	and	#$f0,d4
	and	#$f00,d2
	and	#$f00,d5	; r
	cmp	d0,d3
	beq.b	.nob
	subq	#1,d3	; b
.nob	cmp	d1,d4
	beq.b	.nog
	sub	#$10,d4	; g
.nog	cmp	d2,d5
	beq.b	.nor
	sub	#$100,d5	; r
.nor	or	d5,d4
	or	d4,d3
	move	d3,(a1)
	add.l	#20,a1
	dbf	d7,.fadelp
.end	bra	Zoomscroller			; scroll must go on

;*****************************************************************************
;------------------------------------------------------------- FADE COLORS OUT

FadeOut:	move	wait,d0
	beq.b	.now
	subq	#1,wait
	bra.b	.end
.now	move	#4,wait

	move	tp_volume,d0
	ble	.go
	subq	#4,tp_volume
	bra.b	.fadecl
.go	addq	#1,exit
	clr	tp_volume

.fadecl	lea	LogoColors+2,a1
	move	#32-1,d7
.fadelp	move	(a1),d0
	move	d0,d1
	move	d0,d2
	and	#$f,d0	; b
	and	#$f0,d1	; g
	and	#$f00,d2	; r
	cmp	#0,d0
	beq.b	.nob
	subq	#1,d0
.nob	cmp	#0,d1
	beq.b	.nog
	sub	#$10,d1
.nog	cmp	#0,d2
	beq.b	.nor
	sub	#$100,d2
.nor	or	d2,d1
	or	d1,d0
	move	d0,(a1)
	addq.l	#4,a1
	dbf	d7,.fadelp
.end	bra	Zoomscroller			; scroll must go on

;*****************************************************************************
;---------------------------------------------------------------- ZOOMSCROLLER
;*****************************************************************************

	pop
ZoomScroller:	lea	Zoomer(pc),a0	; DBuffer ZoomingScroller
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	move.l	(a0),d5	; für cls
	lea	ZoomLine1+6,a0
	moveq	#9-1,d7		; 8 lines+clr line
.initZoom	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40,d0
	add.l	#20,a0
	dbf	d7,.initzoom

ClearZoomingScroller
	wblt			; Löschen des sichtbaren
	move.l	#-1,$44(a6)		; Scrollers (320*8)
	move	#0,$66(a6)		; auf der Bitplane
	move	#$0100,$40(a6)
	move.l	d5,$54(a6)
	move	#[8*64]+[320/16],$58(a6)

Refresh_Hidden_Scroller
	move	TxtCounter(pc),d0	; print new char to hidden
	bne.b	.noChar		; vertical scroll
	move	#8,TxtCounter		; every 8th frame
.print	lea	HiddenScroller+321,a1
	lea	Font(pc),a2
	moveq	#0,d0
	move.l	TxtPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	lea	ScrollText(pc),a0
	move.b	(a0)+,d0
.no0:	cmp	#1,d0
	bne.b	.no1
	move	#MaxZoom*20*4,Zstrt
	move.b	(a0)+,d0

.no1	move.l	a0,TxtPtr
	sub.b	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.l	(a3)+,(a1)+	; copy 1-4 line
	move.l	(a3)+,(a1)+	; copy 4-8 line
.noChar	subq	#1,TxtCounter

.moveHidden	lea	HiddenScroller,a1	; move Hidden Scroller
	lea	2(a1),a0		; 1 Pixel up (vertical)
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move	#$89f0,$40(a6)		; byteshift
	movem.l	a0-a1,$50(a6)
	move	#[164*64]+[16/16],$58(a6)

OnScreen	lea	HiddenScroller,a0	; hidden to screen
	move.l	d5,a1
	lea	ZoomTab(pc),a2
.prepareXZoom	move	zcounter(pc),d5
	move	Zstrt(pc),d0		; Zoomstart
	move	d5,d1
	addq	#8,d5		; ZoomSpeed
	cmp.w	d0,d1
	bne.b	.no0
	moveq	#0,d5
.no0	move	d5,zcounter
	move.l	(a2,d5.w),d5
	move.l	d5,d6
	swap	d5
.zoom	moveq	#7,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#40,d2
	move	#320-1,d7	; xsize
.xloop	move.b	(a0),d4
	rol.b	#1,d4
	move	d3,d1
.line1	btst	#1,d4	;-
	beq.b	.line2
	bset	d0,(a1,d1)
.line2	add	d2,d1
	btst	#2,d4	;-
	beq.b	.line3
	bset	d0,(a1,d1)
.line3	add	d2,d1
	btst	#3,d4	;-
	beq.b	.line4
	bset	d0,(a1,d1)
.line4	add	d2,d1
	btst	#4,d4	;-
	beq.b	.line5
	bset	d0,(a1,d1)
.line5	add	d2,d1
	btst	#5,d4	;-
	beq.b	.line6
	bset	d0,(a1,d1)
.line6	add	d2,d1
	btst	#6,d4	;-
	beq.b	.line7
	bset	d0,(a1,d1)
.line7	add	d2,d1
	btst	#7,d4	;-
	beq.b	.line8
	bset	d0,(a1,d1)
.line8	add	d2,d1
	btst	#0,d4	;-
	beq.b	.xloopEnd
	bset	d0,(a1,d1)
.xloopEnd	subq.b	#1,d0
	bpl.b	.go
	moveq	#7,d0
	addq	#1,d3
.go	subq.b	#1,d5	; kommastellen
	bne.b	.go2
	swap	d5
	add.l	d6,d5
	swap	d5
	addq.l	#1,a0	; eine spalte weiter
.go2	dbf	d7,.xloop	; xzoom finished ?
	move.l	d6,d5	; kommastelle

;*****************************************************************************

yzoom:	lea	ZoomLine5,a0	; for up
	lea	(a0),a1	; for down
	move	#$98,d1	; middle of screen
	move.b	d1,(a0)	; to cop
	move	d1,d2	; store value
	moveq	#4-1,d7
.yloop	clr	d5	; kommastellen
	swap	d5
	add.l	d6,d5
	swap	d5
	add	d5,d1
	sub	d5,d2
	lea	+20(a0),a0	; one up
	lea	-20(a1),a1	; one down
	move.b	d1,(a0)
	move.b	d2,(a1)
	dbf	d7,.yloop
	rts

;---------------------------------------------------------- SCROLL-TEXT

	;	0=end 1=Zoomstart
	pop
ScrollText:	
	dc.b	` can YOU feel the beat of a million hearts around ?`
	dc.b	`                      `

	dc.b	`MOTION ! - CRAZY FOOLS, WITH`,1,`OUT ANY RULES !  `
	dc.b	`               `
	dc.b	`I SEE HOUSES BURNING!      `
	dc.b	`I'M ASHAMED       `
	dc.b	`BEFORE YOU CLOSE YOUR EYES DENYINGLY !      `
	dc.b	`YOU BETTER ASK YOURSELF      `
	dc.b	`DID I CHOOSE SOMETHING I COULD REGRET ?     `
	dc.b	`DID I DO SOMETHING ?     `
	dc.b	`I SHOULD REGRET       `
	dc.b	`IS THIS THE PLACE I USED TO CALL      `
	dc.b	`- FATHERLAND -      `
	dc.b	`IS THIS THE PLACE I USED TO KNOW AS     `
	dc.b	`- FATHERLAND -      `
	dc.b	`THE SILENCE IS ILLUSION      `
	dc.b	`STAY AWAKE      `
	dc.b	`I HEAR CHILDREN CRYING IN FEAR AND PAIN      `
	dc.b	`DO COWARDS ASK THEMSELVES ?     `
	dc.b	`          `
	dc.b	` HAZE -  OMNIA ROMAE VERNALIA SUNT !`
	dc.b	`               `
	dc.b	`  "HE WAS A MAN, TAKE HIM FOR ALL IN ALL.`
	dc.b	` I SHALL NOT LOOK UPON HIS LIKE AGAIN."            `
	dc.b	`                      `
	dc.b	`HAZE - THERE IS ALWAYS A NOP, THAT CAN BE INSERTED ! `
	dc.b	`                       `
	dc.b	`HAZE - TO BOLDLY GO, WHERE NO SANE HAS GONE BEFORE ! `
	dc.b	`                       `
	dc.b	`HAZE - CULTURE KILLED THE NATIVE ! `
	dc.b	`                      `

	dc.b	0
	even

Slogen:	dc.b	`KICK YOUR LOVE INTO ...`
	dc.b	0
	even


;---------------------------------------------------------- INCLUDES

	pop
	incdir	codes:
Font	;include	makros/8x8HexFont.hex
	include	makros/8x8HexFont2.hex
	;include	makros/Font.Moria8.hex
	;include	makros/8x8Fantasy.hex
	;include	zoomscroller/ZoomFont8x8x1.hex
FontEnd

;---------------------------------------------------------------- Zoom Tabelle
	pop
ZoomTab	ds.l	2*MaxZoom*10+2

;---------------------------------------------------------------- DEMO-POINTER

	pop
demoflag	dc.w	0		; democounter
Zcounter	dc.w	0		; pos in zoomtab
exit	dc.w	0		; allowes exit
wait	dc.w	0		; warten auf nix
Zstrt	dc.w	0		; Zoomstarter
SpareLetter	ds.b	8		; font dreh puffer
TxtCounter	dc.w	0		; cnt for new ltr print
Zoomer	dc.l	Z1,Z2		; DBuffer für ZoomingScroller
TxtPtr	dc.l	ScrollText
fadecnt	dc.w	0

;----------------------------------------------------------------- SYS-POINTER

stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801	; movec vbr,d7
	rte			; back to user state code


SlogenColors	dc.w	$555,$666,$777,$888,$999,$aaa,$bbb,$ccc
SlogenColors2	dcb.w	8,Hcol
FontColors	dc.w	$227,$228,$229,$22a,$22b,$22c,$22d,$22e

;----------------------------------------------------------------- PlayRoutine

	incdir	Codes:
	include	makros/tp3.s		; play routine

;----------------------------------------------------------------- Copperliste

HCol	= $333

	section	copperlist,data_c

	pop
cop:	dc.w	$106,0,$1fc,0,$100,$0
	dc.w	$3001,$fffe
	dc.w	$8e,$3181,$90,$33c1
	dc.w	$92,$38,$94,$d0
	dc.w	$102,7,$104,$10
	dc.w	$108,-40,$10a,0
BackCol	dc.w	$180,HCol
 ZoomLine1:	dc.w	$9607,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine2:	dc.w	$9707,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine3:	dc.w	$9807,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine4:	dc.w	$9907,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
ZoomLine5:	dc.w	$9a07,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine6:	dc.w	$9b07,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine7:	dc.w	$9c07,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine8:	dc.w	$9d07,$fffe,$e0,0,$e2,0,$100,$1200,$182,HCol
 ZoomLine9:	dc.w	$9e07,$fffe,$e0,0,$e2,0,$100,$0200,$182,HCol

	dc.w	$ffe1,$fffe
	dc.w	$01c1,$fffe
	dc.w	$102,0,$104,$0,$108,4*40,$10a,4*40
	dc.w	$100,$5200
LogoBitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.w	$f0,0,$f2,0
LogoColors	ds.w	32*2
	dc.w	$9c,$8010	; vbi
	dc.l	$fffffffe

;-------------------------------------------------------------------- ChipData

Song	incbin	tunes/Tekkno.tp3

Logo	incbin	`Zoomscroller/Motion2.320x57x5.int`

;--------------------------------------------------------------- BitplaneSpace

	section	bss,bss_c

	pop
Z1	ds.b	40*9	; ZoomingScroller
	pop		;(xgezoomter 8x8 scroller)
Z2	ds.b	40*9	; ZoomingScroller
			
	pop
HiddenScroller	ds.b	330	; (328) senkrecht !
	even

