

;	RawSingPic to Tab Converter by Duke of Haze

; Zu beachten:	- es dürfen NIE mehr als 6 Pixel in einer Spalte sein !
;		- die Breite muß durch 8 teilbar sein !
;		- bla. bla.

;---------------------------------------------------------- Variablen

Hoehe	=	170	; Hoehe  des Logos in Pixeln
Breite	=	320	; Breite des Logos in Pixeln

;---------------------------------------------------------- fixe Variable

bBreite	=	Breite/8
xoffset	=	(320-Breite)/2	; zentrier-offset um Pic zu mitteln

;---------------------------------------------------------- Init Converter

	section	code,code_c		; code to chipmem
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
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

	bsr	SingPicToTab
	bsr	setdots

;------------------------------------------------------ WAIT FOR VERTICAL BEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam
;	move	#$f00,$dff180		; Rasterzeitmessung Beginn (rot)

;------------------------------------------------------ DOUBLE BUFFERING

DBuff:	lea	FrontScreen(pc),a0
	lea	Planes+2(pc),a1
	movem.l	(a0),d0-d1
;	exg	d0,d1
	movem.l	d0-d1,(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- MAIN ROUTINE

;	move	#$f00,$dff180		; Rasterzeitmessung Ende (grün)
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	WaitVBeam

;---------------------------------------------------------- EXIT TO SYSTEM

	lea	$dff000,a6
	move	#$7fff,$9a(a6)		; disable interrupts
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


;---------------------------------------------------------- SETDOTS 

setdots:
	moveq	#0,d0
	moveq	#0,d2
	lea	Tabelle,a0
	lea	Bitplane,a1
	move	#Breite*6-1,d7
.lp	move	(a0)+,d0
	beq.b	.nop
	move.b	d0,d2
	lsr	#3,d0
	not.b	d2
	bset	d2,(a1,d0.w)
.nop	dbf	d7,.lp
	rts


;-------------------------------------------------- Converter from Pic to Tab.

SingPicToTab:
	lea	SingLogo,a0
	lea	Tabelle,a1
	move.l	a0,a3
	move.l	a1,a2
	moveq	#xoffset,d3		; <- zentrier-offset ->
	moveq	#0,d4

	moveq	#bBreite-1,d6	; logo breite in bytes
.xlp	moveq	#0,d0
	moveq	#8,d2

;- byteweise das y suchraster verschieben   -

.blp	move	#Hoehe-1,d7	; yloop im byte
	move	#320,d1

;- Logo in ySpalte auf gesetzte bits testen -

.ylp	move.b	(a0),d0		; loop der y-pos
	btst	d2,d0
	beq.b	.eine0
	move	d3,d4
	add	d1,d4
	move	d4,(a1)+
.eine0:	add	#320,d1
	add	#bBreite,a0
	dbf	d7,.ylp
	addq	#1,d3
;----------------------------
	add	#12,a2
	move.l	a3,a0
	move.l	a2,a1
	subq	#1,d2
	cmp	#0,d2
	bne.b	.blp
	subq	#1,d3
;----------------------------
	addq	#1,a3
	dbf	d6,.xlp
	rts

;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
FrontScreen	dc.l	Bitplane
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- Copperlist

cop:	dc.w	$180,0,$182,$bbb
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- Orginal Sing Bild

SingLogo:	incbin	`duke_sources_5:intro1/singmtn320x74x1.raw`

Tabelle:	ds.w	6*Breite
Tabend:

;---------------------------------------------------------- BitplaneSpace

Bitplane:	ds.b	10240
