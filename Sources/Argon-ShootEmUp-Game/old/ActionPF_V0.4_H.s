;TOSAAAABHJOAAAABCMIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPNFJK
;               T            T              T       T

; Name       : Action Playfield Test
; Authors    : Hagen Glötter & Mirko Tochtermann
; Date       : 24.12.1994
; Description: Test aller Vordergrund Funktionen wie zB Gegener Sprite usw
;
; 	Begin gegner dance

; Überlegng:	1. Pufferscreen mit blt löschen
;	2. kollisionen nach neuer g. tab testen
;	3. 



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
	mw	#-1,$2e(a6)
	ml	#copperlist,$80(a6)	; copper1 start address

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
;	mw	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	DoubleBufferAll

;	bsr	GegnerPrint
;	mw	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Init Sprites

ActionInits:

.ClearPlanes	moveq	#0,d0
	lea	Screen1,a1		; simple clear
	lea	Screen2,a2		; um sicher zu sein,
	lea	Screen3,a3
	move	#48*320-1,d7		; daß die ds.? area
.clearScreens	move.l	d0,(a1)+		; wirklich leer ist.
	move.l	d0,(a2)+
	move.l	d0,(a3)+
	dbf	d7,.clearScreens

initBitplane:	ml	#Screen1+6146,d0	; schwarzer bildschirm
	lea	PF2_planes+2,a1
	mq	#4-1,d7
.bpllp	mcop	d0,a1
	add	PF2_Breite,d0
	addq	#8,a1
	dbf	d7,.bpllp


GenerateMulu48Tab:
	lea	Mulu48Tab,a0
	moveq	#0,d0
	move	#288-1,d7
.mlp	move	d0,(a0)+
	add	#48,d0
	dbf	d7,.mlp
	rts

;-------------------------------------------------------- MAIN ROUTINE



top	=	6146	; start of screen
end	=	13822	; end   of screen

DoubleBufferAll:
	lea	Frontscreen,a0		;DBuffer Screen
	movem.l	(a0),d0-d2
	exg.l	d0,d2		; d0 = darstellen
	exg.l	d0,d1		; d1 = aufbauen
	movem.l	d0-d2,(a0)		; d2 = löschen

loeschen	add	#6146,d2
	wblt
	move	#4,$66(a6)
	move	#$0100,$40(a6)
	move.l	d2,$54(a6)
	move	#[0*64]+[352/16],$58(a6)
	

darstellen	add	#6146,d0		;Show new Frontscreen
	lea	PF2_Planes+2,a0
	moveq	#4-1,d7
.bpllp	mcop	d0,a0
	add	PF2_Breite,d0
	addq	#8,a0
	dbf	d7,.bpllp


DBufferGegnerTabellen:
	lea	GegnerTabellen,a0
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)

DBufferSchussTabellen:
	lea	GegnerSchuesse,a0
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)

	rts

;---------------------------------------------------------- Gegner darstellen

GegnerPrint:
	lea	Gegnertabellen,a0

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

GegnerTab1		dc.w	45,100,0,0,0,0,0,0,0,0,0
		ds.w	32*11
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
ClearScreen:		dc.l	Screen3	;/ 

;------------------------------------------------------ MultuplikationsTabellen

Mulu48Tab		ds.w	288

;-------------------------------------------------------- Variablen


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
vbr_exception		dc.l	$4e7a7801		; mwc vbr,d0
		rte		; back to user state code


;---------------------------------------------------------- Copperliste

	section	Coppelist,data_c

Copperlist:

	dc.w	$106,$20,$1fc,%0001100
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

		dc.l	$fffffffe

	dc.w	$1007,$fffe	; wait
	dc.w	$0001,$7ffe		; WaitBlt
	dc.w	$0001,$7ffe		; WaitBlt
;CopCls:	dc.w	$54,0,$56,0		; Bltddat
	dc.w	$40,$0100,$42,$0000	; Bltcon0+1
	dc.w	$66,$4		; Bltdmod
	dc.w	$58,22		; BltSize

	dc.w	$180,$f00



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

;	section	ScreenData,bss_c

		pop
Screen1:		ds.b	4*PF2_Breite*PF2_Hoehe

		pop
Screen2:		ds.b	4*PF2_Breite*PF2_Hoehe

		pop
Screen3:		ds.b	4*PF2_Breite*PF2_Hoehe

