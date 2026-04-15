;               T            T              T       T

; Name       : Action Playfield Test
; Authors    : Hagen Glötter & Mirko Tochtermann
; Date       : 24.12.1994
; Description: Test aller Vordergrund Funktionen wie zB Gegener Sprite usw
;
; 	Begin gegner dance

; DoubleBufferScreen   - Schirme austauschen			100%
; ClearHiddenScreen    - zurück zum Alles-Clearer	 		99 %
; CrashCheck	       - kollisionen nach gegner tab testen	50 %
;	- 


PF2_Breite	=	384/8	; 48
PF2_Hoehe	=	320


	incdir	codes:makros/
	include	-My_Makros.s
	incdir	game:

	section	code,code_p		; code to chipmem
x:	KillSystem

	wblt
	move	#$0000,$42(a6)
	bsr	ActionInits
	ml	#copperlist,$80(a6)	; copper1 start address

	StartVBI

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

	RemoveVBI
	rts





;---------------------------------------------------------- Init Action PF

ActionInits:

.ClearPlanes	moveq	#0,d0
	lea	Screen1,a1		; simple clear
	lea	Screen2,a2		; um sicher zu sein,
	move	#48*320-1,d7		; daß die ds.? area
.clearScreens	move.l	d0,(a1)+		; wirklich leer ist.
	move.l	d0,(a2)+
	dbf	d7,.clearScreens

initBitplane:	ml	#Screen1+6146,d0	; schwarzer bildschirm
	lea	PF2_planes+2,a1
	mq	#4-1,d7
.bpllp	mcop	d0,a1
	add	PF2_Breite,d0
	addq	#8,a1
	dbf	d7,.bpllp

Initialize_Colors:
	lea	GegnerColors,a0
	lea	PF2_Colors,a1
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp


GenerateMulu48Tab:
	lea	Mulu48Tab,a0
	moveq	#0,d0
	move	#288-1,d7
.mlp	move	d0,(a0)+
	add	#48,d0
	dbf	d7,.mlp
	rts



;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	mw	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	DBufferScreen		; screen puufern
	bsr	ClearHiddenScreen	; komplettscreen löschen
	
	move	#$888,$dff180
	bsr	CrashCheck		; Kollisionen testen
	move	#$fff,$dff180
;	bsr	GegnerPrint

;	wblt
	mw	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- MAIN ROUTINE



top	=	6146	; start of screen
end	=	13822	; end   of screen

	pop
DBufferScreen:
	lea	Frontscreen,a0		; DBuffer Screen
	movem.l	(a0),d0-d1
	exg.l	d0,d1		; d0 = darstellen
	movem.l	d0-d1,(a0)		; d1 = löschen & aufbauen

d0_darstellen	add.l	#top,d0		;Show new FrontScreen
	lea	PF2_Planes+2,a0
	moveq	#4-1,d7
.bpllp	mcop	d0,a0
	add	#48,d0
	addq.l	#8,a0
	dbf	d7,.bpllp
	rts

;---------------------------------------------------------- ClearHiddenScreen

	pop
ClearHiddenScreen:		; ca. 60 % blt 40% cpu
	add.l	#6146,d1		; bltclr
.blt_clear	wblt
	move	#4,$66(a6)
	move	#$0100,$40(a6)
	move.l	d1,$54(a6)
	move	#[156*4*64]+22,$58(a6)

.cpu_clear	move.l	a7,stack
	add.l	#4*13824-2-6146,d1
	move.l	d1,a7
	lea	fill,a6
	movem.l	(a6),d0-d6/a0-a5
	sub.l	a6,a6
	move	#342/8-1,d7
.clp	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	movem.l	d0-d6/a0-a6,-(a7)
	dbf	d7,.clp	
	move.l	stack,a7
	lea	$dff000,a6
	rts


;--------------------------------------------------------- Gegner Pos berechnen

	pop
CrashCheck:
	move.l	GegnerTabelleOld,a0
	moveq	#16,d4		; bull size
	moveq	#16-1,d7		; anzahl der gegner
.tstCollision	move	(a0),d0		; get enemy x coord
	bmi.b	.nextEnemy
	move	2(a0),d1		; get enemy y coord
	move	d0,d2
	move	d1,d3
	add	#32,d2		; gegner breite
	add	#32,d3		; gegner höhe

	move.l	SchusstabelleOld,a1
	moveq	#100-1,d6		; Anzahl der Schüsse
.checkBulls	move	(a1),d4		; get bull x coord
	bmi.b	.nextBull
	move	2(a1),d5		; get bull y coord

	cmp	d0,d4		; links  & links 
	blt.b	.nextBull
	
	add	#16,d4
	cmp	d2,d4		; rechts & rechts
	bgt.b	.nextBull


	cmp	d1,d5		; oben  & oben 
	blt.b	.nextBull

	add	#16,d5
	cmp	d3,d5		; unten & unten
	blt.w	.nextBull



.nextBull	add	#2*8,a1
	dbf	d6,.checkBulls

.nextEnemy	lea	11*2(a0),a0
	dbf	d7,.tstCollision
	rts



;---------------------------------------------------------- Gegner darstellen

GegnerPrint:
	move.l	Gegnertabellen,a0



	rts





;************************** Tabellen & Strukturen **************************


;-------------------------------------------------------- ArgonSchußTabellen

		; x,y,frame,power,speedx,speedy

Schusstabelle:		dc.l	OwnShots1
SchusstabelleOld:	dc.l	OwnShots2

OwnShots1		ds.w	120*8
OwnShots2		ds.w	120*8


;-------------------------------------------------------- DronenSchußTabellen

		; x,y,frame,power,speedx,speedy

DroneSchusstabelle	dc.l	DroneTab1
DroneSchusstabelleOld	dc.l	DroneTab2

DroneTab1		ds.w	32*8
DroneTab2		ds.w	32*8

;-------------------------------------------------------- GegnerTabellen

		; x,y,frame,treffer,speedx,speedy,tabx,taby

GegnerTabellen:		dc.l	GegnerTab1
GegnerTabelleOld:	dc.l	GegnerTab2

GegnerTab1	rept	32
		dc.w	45,100,0,0,0,0,0,0,0,0,0	; test
	endr
		ds.w	32*11		; real
GegnerTab2		ds.w	32*11

;-------------------------------------------------------- GegnerSchußTabellen

		; x,y,frame,power,speedx,speedy

GegnerSchuesse:		dc.l	Bulltab1
GegnerSchuesseOld:	dc.l	Bulltab2


Bulltab1		ds.w	128*8
Bulltab2		ds.w	128*8

;-------------------------------------------------------- ScreenPointer

FrontScreen:		dc.l	Screen1 ;\ 
HiddenScreen:		dc.l	Screen2	; } Action PFs

;------------------------------------------------------ MultuplikationsTabellen

Mulu48Tab		ds.w	288

;-------------------------------------------------------- Variablen


stack		dc.l	0
Fill		dcb.l	16,0

		pop


;-------------------------------------------------------- SystemPointer

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
vbr_exception		dc.l	$4e7a7801	; mwc vbr,d0
		rte		; back to user state code

;---------------------------------------------------------- Copperliste

	section	Coppelist,data_c

Copperlist:		dc.w	$106,$20,$1fc,%0001100
		dc.w	$180,888,$182,$555
	dc.w	$8e,$2171,$90,$21d1,$92,$30,$94,$d8
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

		dc.w	$ffe1,$fffe
		dc.w	$2101,$fffe
		dc.w	$100,$1200
		dc.w	$180,$aaa
		dc.l	$fffffffe


GegnerColors		incbin	`raw/Palette_Gegner.raw`
SpriteColors		incbin	`raw/Palette_Sprites.raw`

;---------------------------------------------------------- SpriteMem

		pop
ArgonSprite1:		dc.l	0,0,0,0	; ControlWort
		ds.l	32*4
		ds.l	4*1	; SprEnd

		pop
ArgonSprite2:		dc.l	0,0,0,0	; ControlWort
		ds.l	32*4
		ds.l	4*1	; SprEnd


;------------------------ Bss Area --------------------------------------
;---------------------------------------------------------- BitplaneSpace

	section	ScreenData,bss_c

		pop
Screen1:		ds.b	4*PF2_Breite*PF2_Hoehe

		pop
Screen2:		ds.b	4*PF2_Breite*PF2_Hoehe

