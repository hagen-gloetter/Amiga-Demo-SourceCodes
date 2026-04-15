;TOSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
;  Haze of MoTioN presents a new Demonstration !

;	CopperIRQ

	incdir	dh1:code/sources/

Hoehe		=	100

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

;---------------------------------------------------------- START OF CODE

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
.bplini	move.l	#TextScreen,d0
	lea	TextPlane+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- DEMO-INITS

	bsr.w	PrecalculateTabs


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

PrecalculateTabs:
	lea	SingLogo,a0	; Sing-Tabelle vormultiplizieren
.loop	move	(a0),d0
	beq.b	.YSin		; 0 =Endkennung ges
	bmi.b	.go		; -1=Endkennung y
	muls	#320,d0		; Screenbreite/8
.go	move	d0,(a0)+
	bra.b	.loop

.Ysin	lea	YSinTab,a0	; YSinus-Tabelle vormultiplizieren
	move	#512-1,d7
.lp	move	(a0),d0
	muls	#320,d0		; Screenbreite/8
	move	d0,(a0)+
	dbf	d7,.lp
.CopWave	lea	LogoWaveCop,a0
	move.l	#$7007fffe,d0
	move.l	#$01020000,d1
	moveq	#100-1,d7
.coplp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	add.l	#$01000000,d0
	dbf	d7,.coplp
.modifyTab	lea	CopWaveTab(pc),a0
	move	#256-1,d7	
.mlp	move	(a0),d0
	lsl	#4,d0
	addq	#8,d0
	move	d0,(a0)+
	dbf	d7,.mlp
	rts


;------------------------------------------------------------------------------
;-------------------------------------------------------- VERTICAL BLANK ROUTNE
;------------------------------------------------------------------------------

	cnop	0,8

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot

TribbleBuffering:
	lea	TBuffer(pc),a2
	movem.l	(a2),d0-d1/a0
	exg.l	d1,a0
	exg.l	d0,d1
	movem.l	d0-d1/a0,(a2)

.PicToCop:	lea	LogoPlanes+02(pc),a1
	lea	LogoPlanes+10(pc),a2
	move	d0,4(a1)
	move	d0,4(a2)
	swap	d0
	move	d0,(a1)
	move	d0,(a2)

;---------------------------------------------------------- Clear Hidden Screen

ClearHiddenScreen:
	wblt
	move	#$0100,$40(a6)
	move	#$0000,$42(a6)
	move	#0,$66(a6)
	move.l	d1,$54(a6)
	move	#[Hoehe*64]+[320/16],$58(a6)

;---------------------------------------------------------- Do Y Wobble

LogoScretch:	lea	SingLogo(pc),a1	; a0 already loaded
	lea	(a1),a2
	lea	YSinTab(pc),a5
	move	YSinPtr(pc),d0
	addq	#8,d0
	and	#1023,d0
	move	d0,ysinptr
	moveq	#0,d1
	moveq	#0,d2
	moveq	#20,d3		; y coord

	lea	ScretchTab(pc),a3
	move.b	ScretchPtr(pc),d5
	addq.b	#2,d5
	and.b	#$ff,d5
	move.b	d5,ScretchPtr

.scretch	addq.b	#1,d5
	and.b	#$ff,d5
	add.b	(a3,d5.w),d6
	move.b	d6,d7
	and.b	#$f,d6
	lsr.b	#4,d7
	tst.b	d7
	beq.b	.same
.other	move.l	a1,a2
	bra.b	.printMyDots
.same	move.l	a2,a1
.printMyDots	move	(a1)+,d1
	beq.b	.EndScretch	; 0=Endkennung
	bmi.b	.nextX		;-1=Y-Endkennung 
	add	(a5,d0.w),d1	; sinus addieren
	add	d3,d1		; xpos addieren
	move.b	d1,d2
	lsr	#3,d1
	not.b	d2
	bset	d2,(a0,d1.w)
	bra.b	.printMyDots
.nextX	addq	#1,d3			; xpos=xpos+1
	addq	#4,d0
	and	#1023,d0
	bra.b	.scretch
.EndScretch						; A0 = BUSY !

DoCopWave:	moveq	#0,d0
	lea	CopWaveTab(pc),a1
	lea	LogoWaveCop+6(pc),a2
	move.b	WavePtr(pc),d0
	addq.b	#2,d0
	and.b	#$ff,d0
	move.b	d0,WavePtr
	lea	(a1,d0.w),a1

	wblt
	move	#0,$64(a6)
	move	#6,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a1-a2,$50(a6)
	move	#[100*64]+1,$58(a6)


CPUFill:	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	qrept	5
	move.l	a0,a1		; StartAdr sichern
	qrept	Hoehe		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d2	; Neue Daten aus Bmp holen
	eor.l	d0,d1		;
	eor.l	d2,d3		;
	movem.l	d1/d3,(a1)	; Modifizierte Daten zurückschreiben
	lea	40(a1),a1	; Eine Zeile tiefer 
	endqr
	addq	#8,a0		; +32 Pixel
	endqr

VBIend
	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0010,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Demo-Pointer
		cnop	0,8

TBuffer		dc.l	Screen1,Screen2,Screen3
XSinPtr		dc.w	0
YSinPtr		dc.w	0
ScretchPtr		dc.w	0
WavePtr		dc.w	0

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
YSinTab	include	logowobble2/WaveSinTab.i

	cnop	0,8
CopWaveTab	include	LogoWobble2/CopWaveTab.i	; $102 wave tab
	include	LogoWobble2/CopWaveTab.i	; 2x wegen blt

	cnop	0,8
ScretchTab	include	logowobble2/WobbleTab3.i	; kommatabelle

	cnop	0,8
SingLogo	incbin	logowobble2/SingMtnLogo2.160x80.b ; singtab
	dc.l	0
	even
	
;---------------------------------------------------------- Copperlist

	cnop	0,8
cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$060
	dc.w	$8e,$6181,$90,$01c1,$92,$38,$94,$d0
	dc.w	$102,8,$104,$10,$108,0,$10a,0

	dc.w	$180,$cba
	dc.w	$5007,$fffe,$180,$fff
	dc.w	$5107,$fffe,$100,$1200
	dc.w	$180,$fff
	dc.w	$182,$400
	dc.w	$184,$ddd ; wobblex
	dc.w	$186,$4f0 ;
	dc.w	$188,$999 ; |
	dc.w	$18a,$4f0 ;
	dc.w	$18c,$666 ; ges
	dc.w	$18e,$00a

TextPlane	dc.w	$e0,0,$e2,0
	dc.w	$6f07,$fffe,$100,$2200
LogoPlanes	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
LogoWaveCop	ds.w	4*100
	dc.w	$d307,$fffe,$100,$1200
	dc.w	$f107,$fffe,$100,$0200
	dc.w	$f207,$fffe,$180,$fff
	dc.w	$f307,$fffe,$180,$abc
	dc.w	$9c,$8010
	dc.l	$fffffffe


;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
TextScreen:	dcb.b	160*40
Screen1:	ds.b	Hoehe*40
Screen2:	ds.b	Hoehe*40
Screen3:	ds.b	Hoehe*40
