;TOSAAAABFGBAAAABIKNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPNBPC
;               T        T              T       T

; Name       : Action Playfield Test
; Authors    : Hagen Glötter & Mirko Tochtermann
; Date       : 04.11.1994
; Description: Test aller Vordergrund Funktionen wie zB Gegener Sprite usw
;
; 

PF2_Breite	=	384/8	; 48
PF2_Hoehe	=	320


	incdir	codes:makros/
	include	-My_Makros.s
	incdir	game:

	section	code,code_c		; code to chipmem
x:	ml	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	ml	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	mq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	ml	d0,a1		; use base-pointer
	ml	$26(a1),syscop1	; store systemcopper1 start adr
	ml	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	mw	$002(a6),dmacon	; store sys dmacon
	mw	$010(a6),adkcon	; store sys adkcon
	mw	$01c(a6),intena	; store sys intena
	mw	#$007fff,$9a(a6)	; clear interrupt enable
	mw	#$007fff,$96(a6)	; clear dma channels
	ml	#copperlist,$80(a6)		; copper1 start address
	mw	#$001234,$88(a6)	; copjump 1
	mw	#$0083e0,$96(a6)	; dmacon data
	mw	#$007fff,$9c(a6)	; clear irq request
	mw	#$004000,$9a(a6)	; interrupt disable

	bsr	ActionInits

.bplini	ml	#Screen1,d0
	lea	PF2_planes+2(pc),a1
	mq	#4-1,d7
.bpllp	mw	d0,4(a1)
	swap	d0
	mw	d0,(a1)
	swap	d0
	add	PF2_Breite,d0
	addq	#8,a1
	dbf	d7,.bpllp

.sprcolors	lea	PF2_Colors,a0
	lea	Predatoranim+512*32,a1
	mw	#$1a0,d0
	mq	#16-1,d7
.clp	mw	d0,(a0)+
	mw	(a1)+,(a0)+
	addq	#2,d0
	dbf	d7,.clp
	


.getVBR	ml	4.w,a6
	mq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	ml	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

initVBI	ml	VectorBase(pc),a0
	ml	$6c(a0),oldVBI		; get sys VBI+VBR-Offset
	mw	#$7fff,$9a(a6)
	ml	#VBI,$6c(a0)		; kick own VBI in
	mw	#%1100000000100000,$9a(a6)	; start it

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

remwVBI:	lea	$dff000,a6
	ml	VectorBase(pc),a0
	mw	#$7fff,$9a(a6)
	ml	oldVBI(pc),$6c(a0)
exit:	mw	#$7fff,$9a(a6)		; disable interrupts
	mw	#$7fff,$96(a6)		; disable dmacon
	ml	syscop1(pc),$80(a6)	; restore sys copper1
	ml	syscop2(pc),$84(a6)	; restore sys copper2
	mw	dmacon(pc),d0		; restore sys dmacon
	or.w	#$8000,d0
	mw	adkcon(pc),d1		; restore sys adkcon
	or.w	#$8000,d1
	mw	intena(pc),d2		; restore interenable
	or.w	#$c000,d2
	mw	d0,$96(a6)
	mw	d1,$9e(a6)
	mw	#$7fff,$9c(a6)
	mw	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	ml	stackptr(pc),a7
	mq	#0,d0
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	cnop	0,8
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	mw	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	DialHard
	bsr	mwArgonSprite
	bsr	ClearScreen

;	mw	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Init Sprites

ActionInits:

.initArgonSprites:
	ml	#ArgonSprite1,d0		; init AtSpr1
	lea	ArgonSpriteCop+2,a0
	mw	d0,4(a0)
	swap	d0
	mw	d0,(a0)
	addq.l	#8,a0
	ml	#ArgonSprite2,d0		; init AtSpr2
	mw	d0,4(a0)
	swap	d0
	mw	d0,(a0)


.CopyToSpr	lea	Predatoranim,a0
	lea	ArgonSprite1+16,a1
	wblt
	ml	#-1,$44(a6)
	mw	#0,$64(a6)
	mw	#12,$66(a6)
	ml	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	mw	#[32*64]+[32/16],$58(a6)
	add	#128,a0
	addq	#8,a1
	wblt
	movem.l	a0-a1,$50(a6)
	mw	#[32*64]+[32/16],$58(a6)
	add	#128,a0
	lea	ArgonSprite2+16,a1
	wblt
	movem.l	a0-a1,$50(a6)
	mw	#[32*64]+[32/16],$58(a6)
	add	#128,a0
	addq	#8,a1
	wblt
	movem.l	a0-a1,$50(a6)
	mw	#[32*64]+[32/16],$58(a6)
	rts




;-------------------------------------------------------- MAIN ROUTINE

DialHard:

JoyStick:	mw	ArgonX,d4
	mw	ArgonY,d5
	mw.w	$c(a6),d0
	btst	#1,d0		; RIGHT
	bne.s	rechts
	btst	#9,d0		; LEFT
	bne.s	links

UpDown	mw.w	$c(a6),d0
	mw.w	d0,d1
	lsr.w	d1
	eor.w	d1,d0
	btst	#0,d0		; BACK
	bne.s	zurueck
	btst	#8,d0		; FORW
	bne.s	vor
	btst	#7,$bfe001	; TGR
	beq.b	feuer
	rts

rechts	cmp	#352-32+112,d4
	bge	.nop	
	add	SpriteSpeed,d4
.nop	bra.b	upDown

links	cmp	#0+112,d4
	ble	.nop	
	sub	SpriteSpeed,d4
.nop	bra.b	upDown

vor	cmp	#38,d5
	blo	.nop	
	sub	SpriteSpeed,d5
.nop	rts

zurueck	cmp	#280,d5
	bge	.nop	
	add	SpriteSpeed,d5
.nop	rts

feuer	rts

SpriteSpeed:	dc.w	4

;------------------------------------------------------ Sprite im SelectScreen

mwArgonSprite:
	lea	Argonsprite1,a0
	mw	d4,ArgonX		; X-coord
	mw	d5,ArgonY		; Y-coord
	mw	ArgonX,d0		; X-coord
	mw	ArgonY,d1		; Y-coord
.spr	mw	d0,d4
	mw	d1,d5
	mq	#0,d3	  	; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	mb	d1,(a0)		; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3		; E8
.noE8:	add	#33,d1		; Spr Höhe
	mb	d1,8(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3		; L8
.noL8:	lsr.w	#1,d0		; H1-H8
	bcc.b	.noH0
	bset	#0,d3		; L8
.noH0:	mb	d0,1(a0)
	bset	#7,d3	
	mb	d3,9(a0)
	lea	ArgonSprite2,a1
	ml	(a0)+,(a1)+		;copy cw
	ml	(a0)+,(a1)+
	ml	(a0)+,(a1)+
	ml	(a0)+,(a1)+

	rts



ClearScreen:	
	ml	Hiddenscreen,a4
	addq	#4,a4		; +rand
	wblt
	mw	#0,$66(a6)
	mw	#$0100,$40(a6)
	ml	a4,$54(a6)
	mw	#[112*64]+[352/16],$58(a6)
	lea	Fill,a5
	movem.l	(a5),d0-d6/a0-a3		; 44 breite
	add.l	#52*304-4,a4
	mw	#224,d7
.clearlp	movem.l	d0-d6/a0-a3,-(a4)
	subq	#8,a4
	dbf	d7,.clearlp
	rts

;---------------------------------------------------------- Pointer

ArgonX	dc.w	112+160
ArgonY	dc.w	280

	cnop	0,8
VorderGrund:	dc.l	Screen1	; } Action PFs
HiddenScreen	dc.l	Screen2	;/ 


Fill	dcb.l	11,0

	cnop	0,8
stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; mwc vbr,d0
		rte		; back to user state code


PredatorAnim	incbin	raw/PredatorAnim.raw

;---------------------------------------------------------- Copperlist


Copperlist:	dc.w	$106,$20,$1fc,%0001100
	dc.w	$180,0,$182,$555
	dc.w	$8e,$2171,$90,$41d1,$92,$30,$94,$d8
	dc.w	$102,0
	dc.w	$102,0,$104,$10,$108,3*48+4,$10a,3*48+4
	dc.w	$100,$4200

ArgonSpriteCop	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0

GegnerSpriteCop	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0

	
PF2_Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
PF2_Colors	ds.w	2*16
	dc.l	$fffffffe


;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
ArgonSprite1:	dc.l	0,0,0,0	; ControlWort
	ds.l	32*4
	ds.l	4*1	; SprEnd

	cnop	0,8
ArgonSprite2:	dc.l	0,0,0,0	; ControlWort
	ds.l	32*4
	ds.l	4*1	; SprEnd

	cnop	0,8
Screen1:	ds.b	4*PF2_Breite*PF2_Hoehe

	cnop	0,8
Screen2:	ds.b	4*PF2_Breite*PF2_Hoehe
	cnop	0,8
