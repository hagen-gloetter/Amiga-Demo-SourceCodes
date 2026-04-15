
; INTRO 1 by Duke of Haze done for Motion on the 29.11.93 

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
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#Copperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083e0,$96(a6)	; dmacon data + sprdma
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
.bplini	move.l	#LogoScreen,d0
	lea	Planes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq	#8,a1
	move.l	#TextScreen,d0
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	swap	d0
	add	#80,d0
	addq	#8,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
.initcop:
	lea	coptab,a0
	move.l	#$10e1fffe,d0
	move.l	#$1107fffe,d1
	move.l	#$01800888,d2
	move.l	#$01820888,d3
	move.l	#$01000000,d4
	move	#310-1,d7
.lp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.l	d4,d0
	add.l	d4,d1
	dbf	d7,.lp

initSpr	move.l	#Spr1,d0
	lea	Sprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp

;---------------------------------------------------------- GET VECTORBASE

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	moveq	#$0,d7
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,pr_Vectorbasept	; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- START VBI

initVBI	move.l	pr_Vectorbasept,a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)	; Start VBI
	bsr.w	pr_init

.noexit	cmp	#1,outflag		; no exit till screen is faded in
	bne.b	.noexit
	
;---------------------------------------------------------- MOUSE WAIT

mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:
	move.w	#-1,pr_musicfadedirection
	move.w	#-1,outflag
.wait	cmp.w	#-2,outflag
	bne.s	.wait
.lp	tst.w	pr_musicfadect		; Now fading out...
	bne.s	.lp
	bsr.w	pr_end
	lea	$dff000,a6
	move.l	pr_Vectorbasept(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
.exit	move	#$7fff,$9a(a6)		; disable interrupts
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
	moveq	#0,d0
	rts


;------------------------------------------------------------------------------

;------------------------------------------------------- VERTICAL BLANK ROUTINE

;------------------------------------------------------------------------------


VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	tst	outflag
	bmi.w	Fadeout
	bne.w	vbimain			; jump to vbi mainroutine

;---------------------------------------------------------- FADE DEMO IN

FadeIn:	move	fadecounter(pc),d0	; fade mtn logo in
	beq.w	.movesprin
.fadein	lea	coltab(pc),a0
	lea	coptab+014,a1
	lsl	#4,d0
	lea	(a1,d0.w),a1
	moveq	#64-1,d7
.lp	move	(a0)+,(a1)
	add	#16,a1
	dbf	d7,.lp
	sub	#1,fadecounter
	bra.w	vbiEnd
.MoveSprIn
	move	sprpos(pc),d0
	cmp	#380,d0
	beq.b	sprdone
	addq	#8,d0			; sprite speed
	move	d0,sprpos
	bsr.w	MoveSpr
	bra.w	vbiEnd
sprdone	move	#1,outflag
	bra.w	vbiEnd

;---------------------------------------------------------- FADE DEMO OUT

Fadeout:
	cmp	#-2,outflag
	beq.b	.picweg
.sprweg	move	sprpos(pc),d0
	cmp	#60,d0			; end pos
	beq.b	.sprout
	subq	#8,d0			; sprite speed
	move	d0,sprpos
	bsr.w	MoveSpr
	bra.w	vbiEnd
.sprout	move	#-2,outflag
	bra.w	vbiEnd
.picweg	cmp	#302,fadecounter	; max pos
	bge.w	vbiEnd
	move	fadecounter(pc),d0
	lea	coltab2(pc),a0
	lea	coptab+010,a1
	lsl	#4,d0
	lea	(a1,d0.w),a1
	moveq	#8-1,d7
.lp	move	(a0),(a1)
	move	(a0)+,4(a1)
	add	#16,a1
	dbf	d7,.lp
	add	#2,fadecounter
	bra.w	vbiEnd

;---------------------------------------------------------- INTRO-MAIN-ROUTINE

vbiMain:



vbiEnd:	bsr.w	pr_music
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- MOVE SPRITE MACRO

MoveSpr	lea	Spr1,a0
	moveq	#5-1,d7
	move	#285,d1
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3
	move.b	d1,(a0)
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3
.noE8:	add.w	#12,d1
	move.b	d1,2(a0)
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3
.noL8:	lsr.w	#1,d0
	bcc.b	.noH0
	bset	#0,d3
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	add	#16,d4
	move	d4,d0
	move	d5,d1
	lea	56(a0),a0
	dbf	d7,.spr
	rts

;---------------------------------------------------------- SOUND POINTER

includefadingroutine		=	1
packedsongformat		=	1
fadingsteps			=	8	; 1-8

;---------------------------------------------------------- DEMO-POINTER

fadecounter	dc.w	246		; fix !	fadepos-logo
sprpos		dc.w	60		; fix ! movepos-spr
outflag		dc.w	0		; demoposition

;---------------------------------------------------------- SYS-POINTER

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
oldVBI		dc.l	0
gfxname		dc.b	'graphics.library',0,0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d7
		rte				; back to user state code

;---------------------------------------------------------- COLOUR TABLES

Coltab:		dc.w	$000,$100,$200,$300,$400,$500,$600,$700 ; FadeInTab
		dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
		dc.w	$f10,$f20,$f30,$f40,$f50,$f60,$f60,$f70
		dc.w	$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0 ;
		dc.w	$ff2,$ff3,$ff4,$ff5,$ff6,$ff6,$ff7,$ff8
		dc.w	$ff9,$ffa,$ffb,$ffc,$ffc,$ffd,$ffe,$fff
		dc.w	$eee,$ddd,$ccc,$bbb,$bbb,$aaa,$aaa,$aaa
		dc.w	$aaa,$aaa,$aaa,$aaa,$aaa,$aaa,$aaa,$aaa
Coltab2:	dc.w	$888,$888,$888,$888,$99b,$88b,$77c,$55d

;---------------------------------------------------------- INCLUDES

		incdir	`Duke_Sources_6:`
		include	`makros/prorunner.s`
Font:		include	`intro1/8x8Romanhex.s`
;Font:		include `8x8Fantasy.hex`

;---------------------------------------------------------- CHIPDATA

		section	ChipDatas,data_c

;---------------------------------------------------------- Copperlist

Copperlist:	dc.w	$106,$0,$1fc,$0
Sprite:		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$140,0,$150,0,$160,0,$170,0
		dc.w	$148,0,$158,0,$168,0,$178,0
		dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$000
		dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$000
		dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$000
		dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$000
screen_defs	dc.w	$8e,$3181,$90,$30c1,$92,$3c,$94,$d4
		dc.w	$102,0,$104,$10,$108,0,$10a,0
		dc.w	$100,$b200
		dc.w	$184,$fff,$186,$fff,$188,$fff
		dc.w	$18a,$fff,$18c,$fff,$18e,$fff
Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
;		dc.w	$ec,0,$ee,0
coptab:		ds.w	8*310
		dc.l	$fffffffe

;---------------------------------------------------------- MODULE

Module:		incbin	"mod.chip2.p" 

;---------------------------------------------------------- LOGO-SCREEN

		include	`makros/haze80x12x2.spr`
LogoScreen:	ds.b	43*80
		incbin	`intro1/MTN640x170x1.raw`
		ds.b	43*80

;---------------------------------------------------------- TEXT-SCEENS

		section	TextScreen,bss_c

TextScreen:	ds.b	20480

