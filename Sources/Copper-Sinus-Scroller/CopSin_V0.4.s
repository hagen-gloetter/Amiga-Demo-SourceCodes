
; Progy : Copper-Sinus-Scroller
; Autor : Hagen Glötter & Mirko Tochtermann
; Datum : 3.11.93
;
; DIE neue Version 1.2 ist jetzt auch VBI-getaktet erhältlich und ist
; damit viel Benutzerfreunlicher als alle andern ! Wählen Sie DIESE(L)
; Version auch für ihr Intro !!

	section	demo,code_p		; code to publicmem
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
	move.l	#cop1,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0087e0,$96(a6)	; dmacon data + bltpri + sprdma
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
.initpl	move.l	#TextScreen,d0		; init Bitplanes
	lea	Pln1+2,a0
	lea	Pln2+2,a1
	moveq	#3-1,d7
.plp	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
	swap	d0
	add.l	#80,d0
	addq	#8,a0
	addq	#8,a1
	dbf	d7,.plp
.initcl lea	Font+3*480,a0		; init Colors
	lea	cols1+2,a1
	lea	cols2+2,a2
	moveq	#8-1,d7
.clp	move	(a0),(a1)
	move	(a0)+,(a2)
	addq	#4,a1
	addq	#4,a2
	dbf	d7,.clp
initSpr	move.l	#Spr1,d0		; Sprite hinnageln
	lea	Sprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp
showspr	lea	Spr1,a0
	moveq	#5-1,d7
	move	#380,d0
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

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d0,pr_Vectorbasept
.68000	lea	$dff000,a6

;---------------------------------------------------------- INIT COPPER-LISTS

initCopSin:
	lea	CopSin1,a0
	lea	CopSin2,a1
	move.l	#$102ffffe,d0
	move.l	#$01800000,d2
	move	#320-1,d7
.lp2	move.l	d0,(a0)+
	move.l	d0,(a1)+
	moveq	#48-1,d6
.lp	move.l	d2,(a0)+
	move.l	d2,(a1)+
	dbf	d6,.lp
	add.l	#$01000000,d0
	add.l	#$01000000,d1
	dbf	d7,.lp2

;----------------------------------------------------------- CONVERTER

Converter:	; Converts a Font 8x8x3 (480*8*3) to Coppercolors
	lea	Font(pc),a5
	lea	0*480(a5),a0
	lea	1*480(a5),a1
	lea	2*480(a5),a2
	lea	3*480(a5),a3
	lea	CopFont,a4
	moveq	#0,d1
	moveq	#0,d3
	moveq	#60-1,d6	; Zeile
.lp3	moveq	#8-1,d7		; Spalte
.lp2	moveq	#8-1,d0		; Byte
.lp	moveq	#0,d2
	btst	d0,(a0,d1.w)
	beq.b	.no1
	addq	#1,d2
.no1	btst	d0,(a1,d1.w)
	beq.b	.no2
	addq	#2,d2
.no2	btst	d0,(a2,d1.w)
	beq.b	.no3
	addq	#4,d2
.no3	add	d2,d2
	move	(a3,d2.w),(a4)+
	dbf	d0,.lp
	add	#60,d1
	dbf	d7,.lp2
	addq	#1,d3
	move	d3,d1
	dbf	d6,.lp3

initVBI	move.l	pr_VectorBasept,a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)
	bsr.w	pr_init

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:
	bsr.w	pr_end
	lea	$dff000,a6
	move.l	pr_vectorbasept,a0
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
;	move	#$0f0,$dff180		; Rasterzeitmessung Anfang (rot)

;------------------------------------------------------ COPPER DOUBLE BUFFERING

DBuff:	lea	HotCop(pc),a0
	movem.l	(a0),d0-d2/a4
	exg	d0,d2			; cop1=cop2
	exg	d1,a4			; copsin1=copsin2
	movem.l	d0-d2/a4,(a0)
	move.l	d0,$80(a6)
	move.w	#$1234,$88(a6)

;--------------------------------------------------------- MOVE HIDDEN SCROLLER

CopScroll:				; Scroller bewegen
	lea	Scroller+1100,a1
	lea	2(a1),a0
	moveq	#4,d0			; Modulo A, D
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	d0,$64(a6)
	move	d0,$66(a6)
	move.l	#$09f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	movem.l	a0-a1,$50(a6)
	move	#[64*64]+48,$58(a6)	; 47+Hidden

;---------------------------------------------------------- PRINT ONE COLUMN

PrintSpareLetter:
	move	Spalte(pc),d0
	move	counter(pc),d7
	bne	.noNewLetter
.newLetter
	move.l	TextPointer(pc),a5
	moveq	#0,d0
	move.b	(a5)+,d0
	bne.b	.go
	lea	Scrolltext(pc),a5
	move.b	(a5)+,d0
.go:	move.l	a5,TextPointer
	sub	#32,d0
	lsl	#7,d0
	move	#8,Counter		; Breite des Letters
	move	d0,Spalte
.noNewLetter
	lea	Scroller+1194,a0
	lea	CopFont,a1
	moveq	#8-1,d6
.lp2	moveq	#8-1,d7
.lp	move	(a1,d0.w),(a0)
	add	#100,a0
	dbf	d7,.lp
	add	#16,d0
	dbf	d6,.lp2
	add	#2,Spalte
	sub	#1,counter

;---------------------------------------------------- COPY COP-LETTER TO SCREEN

CopyToScreen:
	lea	Scroller+4,a0
	move.l	a4,a1			; CopSin1+6,a1
	move.l	a1,a3
	moveq	#0,d0
.sin	lea	Sintab(pc),a2
	move	SinPtr(pc),d0
	addq	#8,d0			; Sin 1
	and	#1023,d0
	move	d0,SinPtr
	move.l	(a2,d0),d1
	add.l	d1,a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#98,$64(a6)
	move	#194,$66(a6)
	move.l	#$9f00000,$40(a6)
	moveq	#48-1,d7
.loop:	btst	#14,$02(a6)
	bne.b	.loop
	movem.l	a0-a1,$50(a6)
	move	#[86*64]+1,$58(a6)	; übergröße um scroller zu löschen
	addq	#2,a0
	addq	#4,a3
	move.l	a3,a1
	addq	#4,d0			; Sin 2
	and	#1023,d0
	add.l	(a2,d0.w),a1
	dbf	d7,.loop

	bsr.w	pr_music
	lea	$dff000,a6
;	move	#$0f0,$180(a6)		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;----------------------------------------------------------- MUSIC-POINTER

includefadingroutine		=	0
packedsongformat		=	1
fadingsteps			=	8	; 1-8

;----------------------------------------------------------- DEMO-POINTER

counter		dc.w	0
spalte		dc.w	0
sinptr		dc.w	0
textpointer	dc.l	scrolltext
hotcop		dc.l	cop1,copsin1+6,cop2,copsin2+6

;----------------------------------------------------------- SYS-POINTER

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
oldVBI		dc.l	0
gfxname		dc.b	'graphics.library',0,0
vbr_exception	dc.l	$4e7a0801		; movec vbr,d0
		rte				; back to user state code

;----------------------------------------------------------- SCROLLTEXT

Scrolltext:
	dc.b	`HAZE OF MOTION   `
	dc.b	`STRONG AND BRAVE !   `
	dc.b	`WARRIORS TO THE GRAVE !      `
	dc.b	0
	even

;----------------------------------------------------------- INCLUDES

SinTab:		include	`copsin/sintab.s`
Font:		incbin	`copsin/testfont8x8x3.raw`
		include	`makros/prorunner.s`


;----------------------------------------------------------- MODUL-DATEN

	section	data,data_c		; data to chipmem

		incdir	`duke_sources_6:`
Module:		incbin	"mod.chip1.p"
		include	`makros/haze80x12x2.spr`


;---------------------------------------------------------- COPPERLIST -1-

Cop1:	dc.w	$106,0,$1fc,0
Sprite:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0
	dc.w	$140,0,$150,0,$160,0,$170,0
	dc.w	$148,0,$158,0,$168,0,$178,0
	dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$444
	dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$444
	dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$444
	dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$444
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,$10,$104,$0,$108,0,$10a,0
Cols1:	dc.w	$180,0,$182,0,$184,0,$186,0
	dc.w	$188,0,$18a,0,$18c,0,$18e,0
Pln1:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$100,$3200
CopSin1	ds.b	320*196
	dc.l	$fffffffe

;---------------------------------------------------------- COPPERLIST -2-

Cop2:	dc.w	$106,0,$1fc,0
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,$10,$104,$0,$108,0,$10a,0
Cols2:	dc.w	$180,0,$182,0,$184,0,$186,0
	dc.w	$188,0,$18a,0,$18c,0,$18e,0
Pln2:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$100,$3200
CopSin2	ds.b	320*196
	dc.l	$fffffffe

;---------------------------------------------------------- LEERSPEICHER

	section	Bitplanes,bss_c		; bss to chipmem
	
Scroller:	ds.w	50*86		; HiddenScroll (Screenbreite*Höhe*Pixel
CopFont:	ds.b	480*8*2		; convertierte 8x8x3 Font
TextScreen:	ds.b	10240*3		; Bitplanes 1-3

