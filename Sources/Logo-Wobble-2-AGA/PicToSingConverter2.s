
;	RawSingPic to Tab Converter by Duke of Haze

; Zu beachten:	- es dürfen NIE mehr als maxpoints Pixel in einer Spalte sein
;		- die Breite muß durch 8 teilbar sein
;		- der Buffer beim saven wird automatisch berechnet 
;		- hires wird zwar falsch dargestellt, aber richtig convertiert
;		- Bild wird wenn es schmaler als 320 ist in die Mitte zentriert
;		- es werden keine nullen gespeichert
;		- Daten werden mit Endkennung versehen (-1.l) 

;---------------------------------------------------------- 

; OutPut:	D0	= Gesamtanzahl der Punkte aus denen das Bild besteht
;		A0	= StartAdresse der zu savenden Binärdaten
;		A1	=   EndAdresse der zu savenden Binärdaten
;		A2	= Länge der Tabelle

;---------------------------------------------------------- Variablen

write		=	0	; 0=Show Picture
				; 1=Write to Disk (SaveEndAdr=Tabelle+A2)
Hoehe		=	64	; Hoehe  des Logos in Pixeln
Breite		=	256	; Breite des Logos in Pixeln
maxpoints 	=	4	; maximal pixel per y-line

;---------------------------------------------------------- fixe Variable

bBreite	=	Breite/8
xoffset	=	(320-Breite)/2	; zentrier-offset um Pic zu mitteln



;---------------------------------------------------------- Init Converter


	section	Converter,code_c	; code to chipmem

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
	bsr	fill
	move	#$1200,con+2

;---------------------------------------------------------- SHOW PICTURE

	move.l	#Bitplane,d0
	lea	Planes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- MAIN ROUTINE

;	move	#$f00,$dff180		; Rasterzeitmessung Ende (grün)
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	mloop

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
	lea	tabelle,a0	
	move.l	dataend,a1
	move.l	a1,a2
	sub.l	a0,a2
	move.l	a2,tabsize
	move	dots,d0
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
	move	d2,$dff180	; Show that I'm workin'
	cmp.l	a1,a2
	beq.w	.noentry	; wenn y-columne gesamt 0 ist kein eintrag
	add.l	#maxpoints*2,a2	; in die tabelle ansonsten x»x+1
.noentry
	move.l	a3,a0
	move.l	a2,a1
	subq	#1,d2
	cmp	#-1,d2		; oder 0
	bne.b	.blp
	subq	#1,d3
;----------------------------
	addq	#1,a3
	dbf	d6,.xlp
	move.l	#-1,(a2)+
	move.l	a2,dataend
	rts


;---------------------------------------------------------- SETDOTS 

setdots:
	move	#0,dots
	moveq	#0,d0
	moveq	#0,d2
	lea	Tabelle,a0
	lea	Bitplane,a1
	move	#Breite*MaxPoints,d7
	subq	#1,d7
.lp	move	(a0)+,d0
	bmi.b	.end
	beq.b	.nop
	add	#1,dots
	move.b	d0,d2
	lsr	#3,d0
	not.b	d2
	bset	d2,(a1,d0.w)
.nop	move	d0,$dff180
	dbf	d7,.lp
.end	rts

;---------------------------------------------------------- FILL PICTURE

Fill:	rts
	lea	Bitplane,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#3-1,d7
.lp	move.l	a0,a1
	move	#Hoehe-1,d6
.lp2	movem.l	(a1),d0-d1
	eor.l	d0,d2
	eor.l	d1,d3
	movem.l	d2-d3,(a1)
	add.l	#40,a1
	dbf	d6,.lp2
	addq.l	#8,a0
	dbf	d7,.lp
	rts


;---------------------------------------------------------- Pointer

tabsize		dc.l	0
dots		dc.w	0
datastart	dc.l	Tabelle
dataend		dc.l	0

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- Copperlist

cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$bbb
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
con:	dc.w	$100,$0
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe


;---------------------------------------------------------- Orginal Sing Bild

		incdir	dh1:Code/Sources/LogoWobble2/
SingLogo:	incbin	MTN_Logo_256x64x1.raw


;---------------------------------------------------------- Auto-Sequence

	printt
	printt
	printt
	printt	`SingPic to Tab Converter V2.0`
	printt
	printt	`Total amount of Dots in Picture`
	printv	dots
	printt
	if	write=1
	auto	j\wb\Tabelle\tabelle+
	endif
	
;---------------------------------------------------------- DataSpace

Tabelle:	ds.w	MaxPoints*Breite+2	; +2 = EndKennung
Tabend:

;---------------------------------------------------------- BitplaneSpace

Bitplane:	ds.b	10240
