;TOSAAAAAOMEAAAAALKLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPOFJB
;               T            T              T       T

; Name       : Action Playfield Test
; Authors    : Hagen Glötter & Mirko Tochtermann
; Date       : 04.11.1994
; Description: Test aller Vordergrund Funktionen wie zB Gegener Sprite usw
;
; 	Clear screen test version

PF2_Breite	=	384/8	; 48
PF2_Hoehe	=	320


	incdir	codes:makros/
	include	-My_Makros.s
	incdir	game:

	section	code,code_c		; code to chipmem
x:	KillSystem

	ml	#copperlist,$80(a6)	; copper1 start address
	bsr	ActionInits

	StartVBI

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

	RemoveVBI
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	mw	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	GegnerPrint

	mw	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Init Sprites

ActionInits:

initBitplane:	ml	#Screen1+1440,d0
	lea	PF2_planes+2(pc),a1
	mq	#4-1,d7
.bpllp	mw	d0,4(a1)
	swap	d0
	mw	d0,(a1)
	swap	d0
	add	PF2_Breite,d0
	addq	#8,a1
	dbf	d7,.bpllp
	rts


;-------------------------------------------------------- MAIN ROUTINE

GegnerPrint:

;	move.l	Hiddenscreen,a7
;	add.l	#4*13822,a7
;	move	#987-1,d7
;.lp	movem.l	d0-d6/a0-a6,-(a7)
;	dbf	d7,.lp


	lea	Hiddenscreen,a0
	lea	1440(a0),a0
	wblt
	move	#4,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	a0,$54(a6)
	move	#[256*64]+[352/16],$58(a6)


	ml	a7,stack
	lea	Fill(pc),a7
	movem.l	(a7)+,d0-d7/a0-a6
	move.l	Hiddenscreen,a7
	add.l	#4*13822,a7
	rept	614
	movem.l	d0-d7/a0-a6,-(a7)
	endr

	ml	stack,a7


	rts

stack		dc.l	0

;-------------------------------------------------------- GegnerTabellen

		; x,y,frame,treffer,speedx,speedy,tabx,taby

GegnerTabellen:		dc.l	GegnerTab1,GegnerTab2

GegnerTab1		ds.w	32*11
GegnerTab2		ds.w	32*11

;-------------------------------------------------------- SchußTabellen

		; x,y,frame,power,speedx,speedy

GegnerSchüsse:		dc.l	Bulltab1,Bulltab2

Bulltab1		ds.w	128*8
Bulltab2		ds.w	128*8

;-------------------------------------------------------- Pointer

		pop
VorderGrund:		dc.l	Screen1	; } Action PFs
HiddenScreen		dc.l	Screen2	;/ 


Fill		dcb.l	16,0

		pop
stackptr		dc.l	0
syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase		dc.l	0
vbr_exception		dc.l	$4e7a7801		; mwc vbr,d0
		rte		; back to user state code


;---------------------------------------------------------- Copperlist


Copperlist:		dc.w	$106,$20,$1fc,%0001100
		dc.w	$180,0,$182,$555
		dc.w	$8e,$2171,$90,$41d1,$92,$30,$94,$d8
		dc.w	$102,0
		dc.w	$102,0,$104,$10,$108,3*48+4,$10a,3*48+4
		dc.w	$100,$4200

ArgonSpriteCop		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0

GegnerSpriteCop		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0

	
PF2_Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
PF2_Colors		ds.w	2*16
		dc.l	$fffffffe


;---------------------------------------------------------- BitplaneSpace

		pop
ArgonSprite1:		dc.l	0,0,0,0	; ControlWort
		ds.l	32*4
		ds.l	4*1	; SprEnd

		pop
ArgonSprite2:		dc.l	0,0,0,0	; ControlWort
		ds.l	32*4
		ds.l	4*1	; SprEnd

		pop
Screen1:		ds.b	4*PF2_Breite*PF2_Hoehe

		pop
Screen2:		ds.b	4*PF2_Breite*PF2_Hoehe

