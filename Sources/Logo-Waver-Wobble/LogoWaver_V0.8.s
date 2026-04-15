;  Haze of MoTioN presents a new Demonstration !

; Ab dieser Version wird ueber den CopperIRQ getimet !


Hoehe	=	123
Breite	=	44

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

;---------------------------------------------------------- START OF CODE

	incdir	dh1:code/sources/

	section	code,code_c		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
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

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- DEMO-INITS

	bsr.w	PreCalcWaverTabs


initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000010000,$9a(a6)

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:	lea	$dff000,a6
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
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
	move.l	stackptr(pc),a7
	moveq	#0,d0
	rts

;----------------------------------------------- DEMO-INIT-ROUTINEN

PreCalcWaverTabs:
	lea	SingLogo,a0	; Sing-Tabelle vormultiplizieren
.loop	move	(a0),d0
	bmi.b	.exit		; 0 =Endkennung ges
	beq.b	.go		; -1=Endkennung y
	muls	#Breite,d0		; Screenbreite/8
.go	move	d0,(a0)+
	bra.b	.loop
.exit	lea	YSinTab,a0       ; YSinus-Tabelle vormultiplizieren
	move	#1024-1,d7
.lp	move	(a0),d0
	muls	#Breite,d0		; Screenbreite/8
	move	d0,(a0)+
	dbf	d7,.lp
.CopWave	lea	LogoWaveCop,a0
	move.l	#$7007fffe,d0
	move.l	#$01020000,d1
	moveq	#Hoehe-1,d7
.coplp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	add.l	#$01000000,d0
	dbf	d7,.coplp
.modWaveTab	moveq	#0,d0
	lea	CopWaveTab,a0
	move	(a0),d0
.orlp	or.b	#$80,d0
	move	d0,(a0)+
	move	(a0),d0
	bpl.b	.orlp

	rts

;------------------------------------------------------------------------------
;-------------------------------------------------------- VERTICAL BLANK ROUTNE
;------------------------------------------------------------------------------


VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$fed,$dff180		; Rasterzeitmessung Anfang (rot

	bsr.b	LogoDancer

;	move	#$765,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0010,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte
	
;---------------------------------------------------------- LOGO DANCER

LogoDancer:	lea	TBuffer(pc),a2			; Tribble Buffering
	movem.l	(a2),d0-d2
	exg.l	d0,d1
	exg.l	d1,d2
	movem.l	d0-d2,(a2)
	move.l	d0,a0
	lea	WavePlanes+2(pc),a1
	lea	WavePlanes+10(pc),a2
PicToCop	move	d0,4(a1)
	move	d0,4(a2)
	swap	d0
	move	d0,(a1)
	move	d0,(a2)
	add.l	#63*Breite,a0
	add.l	#63*Breite,d1
ClearHiddenScreen:					; Clear Hidden Screen
	wblt
	move.l	#$1000000,$40(a6)
	move	#0,$66(a6)
	move.l	d1,$54(a6)
	move	#[Hoehe*64]+[Breite*4],$58(a6)

;---------------------------------------------------------- Do Main Effect

LogoScretch:	lea	SingLogo(pc),a1			; Logo Scretch
	lea	1(a0),a5	; center logo
	lea	(a1),a2
.sinadd	lea	YSinTab(pc),a3
	move	YSinPtr(pc),d0
	addq	#8,d0
	and	#1023,d0
	move	d0,YSinPtr
	lea	(a3,d0.w),a3	; neue sinstartpos
.scretch	moveq	#0,d0
	lea	ScretchTab(pc),a4
	move	ScretchPtr(pc),d0
;	addq	#4,d0
	and	#511,d0
	move	d0,ScretchPtr
	lea	(a4,d0.w),a4	; neue scretchstartpos
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.b	#$80,d2
	moveq	#Breite-1,d7
.byteloop	moveq	#8-1,d6
.print	add.b	(a4)+,d3
	move.b	d3,d4
	and.b	#$f,d3
	lsr.b	#4,d4
	beq.b	.redo
	lea	(a1),a2
.redo	lea	(a2),a1
	move	(a3)+,d0	; Sinus   addieren	
	rept	4
	move	(a1)+,d1
	beq.b	.nextX		; 0=Y-Endkennung 
	add	d0,d1
	or.b	d2,(a5,d1.w)	; bset
	move	(a1)+,d1
	add	d0,d1
	or.b	d2,(a5,d1.w)	; bset
	endr
.nextX	ror.b	#1,d2		; xpos=xpos+1
	dbf	d6,.print
	addq.l	#1,a5
	dbf	d7,.byteloop
DoCopWave:	moveq	#0,d0				; Copperlisten Scroller
	lea	CopWaveTab(pc),a1
	lea	LogoWaveCop+6(pc),a2
	move.b	CopWavePtr(pc),d0
	addq.b	#3,d0
	and.b	#$ff,d0
	move.b	d0,CopWavePtr
	lea	(a1,d0.w),a1
	wblt
	move.l	#$00000006,$64(a6)
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	movem.l	a1-a2,$50(a6)
	move	#[Hoehe*64]+1,$58(a6)
CPUFill:	moveq	#0,d0				; Fill Picture
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	qrept	2
	move.l	a0,a1		; StartAdr sichern
	qrept	Hoehe-1		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d2/d4/d6	; Neue Daten aus Bmp holen
	eor.l	d0,d1		;
	eor.l	d2,d3		;
	eor.l	d4,d5		;
	eor.l	d6,d7		;
	movem.l	d1/d3/d5/d7,(a1)	; Modifizierte Daten zurückschreiben
	lea	Breite(a1),a1	; Eine Zeile tiefer 
	endqr
	lea	16(a0),a0
	endqr
	move.l	a0,a1		; StartAdr sichern
	qrept	Hoehe-1		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d2	; Neue Daten aus Bmp holen
	eor.l	d0,d1		;
	eor.l	d2,d3		;
	movem.l	d1/d3,(a1)	; Modifizierte Daten zurückschreiben
	lea	Breite(a1),a1	; Eine Zeile tiefer 
	endqr
	rts

;---------------------------------------------------------- Demo-Pointer

	cnop	0,8

TBuffer		dc.l	Screen1,Screen2,Screen3
YSinPtr		dc.w	0
ScretchPtr		dc.w	0
CopWavePtr		dc.w	0

;---------------------------------------------------------- System-Pointer

stackptr		dc.l	0
syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase		dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte				; back to user state code


;---------------------------------------------------------- Includes

	cnop	0,8
CopWaveTab	include	logowaver/CopWaveTab16-720.i	; xSinTab
	dc.w	$ffff

	cnop	0,8
YSinTab:	include	logowaver/Sintab32-720.i	; ySinTab

	cnop	0,8
SingLogo	incbin	logowaver/MotionLogo3.256x90.b	; singtab
	dc.w	$ffff
	even

	incdir
	cnop	0,8
ScretchTab	rept	2
	qrept	512
	dc.b	16
	endqr
	endr



;	include	logowaver/ScretchTab2.10-720.i	; kommatabelle
	
;---------------------------------------------------------- Copperlist

	cnop	0,8
cop:	dc.w	$106,0,$1fc,0

	dc.w	$180,$543,$182,$654
	dc.w	$184,$432,$186,$654

	dc.w	$188,0,$18a,0,$18c,0,$18e,0,$190,0
	dc.w	$192,0,$194,0,$196,0,$198,0,$19a,0
	dc.w	$19c,0,$19e,0

	dc.w	$8e,$3061,$90,$30d1,$92,$30,$94,$d8
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$2200

WavePlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
Clearplane	dc.w	$e8,0,$ea,0
TxtPlane	dc.w	$ec,0,$ee,0
LogoWaveCop	ds.w	4*Hoehe
	dc.w	$f007,$fffe
	dc.w	$9c,$8010
	dc.l	$fffffffe


;---------------------------------------------------------- BitplaneSpace

Screen1:	ds.b	256*44
Screen2:	ds.b	256*44
Screen3:	ds.b	256*44

