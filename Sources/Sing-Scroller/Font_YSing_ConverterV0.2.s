;	RawSingPic to Tab Converter by Duke of Haze

;---------------------------------------------------------- 

; OutPut:	D0	= Gesamtanzahl der Punkte aus denen das Bild besteht
;	A0	= StartAdresse der zu savenden Binärdaten
;	A1	=   EndAdresse der zu savenden Binärdaten
;	A2	= Länge der Tabelle in Bytes

;---------------------------------------------------------- Variablen

write	=	0	; 0=Show Picture
			; 1=Write to Disk (SaveEndAdr=Tabelle+A2)
Hoehe	=	48	; Hoehe  des Logos in Pixeln
Breite	=	48	; Breite des Logos in Pixeln
maxYPoints	=	6	; Maximale Anzahl der Punkte in einer Spalte

;---------------------------------------------------------- fixe Variable

bBreite	=	Breite/8
xoffset	=	(320-Breite)/2	; zentrier-offset um Pic zu mitteln

;---------------------------------------------------------- Init Converter


	section	Converter,code_c	; code to chipmem
x:

;-------------------------------------------------- Converter from Pic to Tab.

	clr	dots
	lea	SingFont,a3
	lea	Tabelle,a4
	moveq	#26-1,d5
SingPicToTab:	move.l	a3,a0
	move.l	a4,a1
	move.l	a0,a2
	
;---------------------------------------------------------------- zeilenloop
.xloop	move	#bBreite-1,d6
;------------------------------------------------------------ byteloop
.byteloop	moveq	#7,d2
;------------------------------------------------------ spaltenloop 
.columnloop	move	#Hoehe-1,d7
	moveq	#0,d0
	moveq	#0,d1
.yloop	move.b	(a0),d0
	btst	d2,d0
	beq.b	.noentry
	move	d1,(a1)+
	add	#1,dots
.noentry	add.l	#bBreite,a0	; pic y=y+1
	addq	#1,d1		; ycounter
	dbf	d7,.yloop
;------------------------------------------------------ spaltenloop 
	move	#$0000,(a1)+	; endkennung 
	subq	#1,d2
	move.l	a2,a0
	bpl.b	.columnloop	
;------------------------------------------------------------  byteloop
.nextbyte	addq.l	#1,a2
	move.l	a2,a0
	dbf	d6,.byteloop

	add.l	#48*48/8,a3
	add.l	#Breite*6,a4
	dbf	d5,SingPicToTab
	move.l	a1,RealTabEnd


;---------------------------------------------------------------- zeilenloop

	move	dots,d0
	lea	Tabelle,a0
	move.l	RealTabEnd,a1
	move.l	a1,a2
	sub.l	a0,a2
	rts


;---------------------------------------------------------- Pointer

dots	dc.w	0
RealTabEnd	dc.l	0

;---------------------------------------------------------- Orginal Sing Bild

	incdir	Codes:SingScroller/
SingFont:	incbin	ShebertFont.lin.b

;---------------------------------------------------------- Auto-Sequence

	printt
	printt
	printt
	printt	`SingPic to Tab Converter V2.0`
	printt
	printt
	if	write=1
	auto	j\wb\Tabelle\tabend\
	endif
	
;---------------------------------------------------------- DataSpace

Tabelle:	ds.w	Breite*(6+2)*27	; +2=EndKennung +26 Chars
Tabend:

