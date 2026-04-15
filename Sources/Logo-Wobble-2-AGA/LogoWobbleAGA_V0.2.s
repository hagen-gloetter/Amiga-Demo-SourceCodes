;  Haze of MoTioN presents a new Demonstration !

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
.bplini	move.l	#Screen1,d0
	lea	Planes+2(pc),a1
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

	bsr.w	MuluSingTab		; precalculate Ycoords
	bsr.w	MuluYSinTab		; precalculate YSinTab


initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)

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

MuluSingTab:					; Sing-Tabelle vormultiplizieren
	lea	SingLogo,a0
.loop	move	(a0),d0
	beq.b	.exit		; 0 =Endkennung ges
	bmi.b	.go		; -1=Endkennung y
	mulu	#320,d0		; Screenbreite/8
.go	move	d0,(a0)+
	bra.b	.loop
.exit	rts

MuluYSinTab:                            ; YSinus-Tabelle vormultiplizieren
	lea	XSinTab,a0
	lea	YSinTab,a1
	move	#512-1,d7
.lp	move	(a0)+,d0
	mulu	#320,d0		; Screenbreite/8
	move	d0,(a1)+
	dbf	d7,.lp
	rts


;------------------------------------------------------------------------------
;-------------------------------------------------------- VERTICAL BLANK ROUTNE
;------------------------------------------------------------------------------


VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot

TribbleBuffering:
	lea	TBuffer(pc),a2
	movem.l	(a2),d0-d1/a0
	exg.l	d1,a0
	exg.l	d0,d1
	movem.l	d0-d1/a0,(a2)

	lea	Planes+2(pc),a1
.PicToCop	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- Clear Hidden Screen

ClearHiddenScreen:
.wblt	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#$1000000,$40(a6)
	move	#0,$66(a6)
	move.l	d1,$54(a6)
	move	#[100*64]+[320/16],$58(a6)

;---------------------------------------------------------- Do Y Wobble

Wobble:	lea	SingLogo(pc),a1	; a0 already loaded
	move.l	a1,a2
	lea	YSinTab(pc),a5
	move	YSinPtr(pc),d0
	addq	#8,d0
	and	#1023,d0
	move	d0,ysinptr
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3		; y coord
;
	lea	ScretchTab,a3
	move	ScretchPtr,d5
	addq	#2,d5
	and	#$ff,d5
	move	d5,ScretchPtr
	move	(a3,d5.w),d4

	move	d4,d5
	and	#$f,d5			; nachkommastelle isolieren
	move	d5,d6
.lp	add	d4,d6
	and	#$1f,d6
	add	d4,d6



.printMyDots
	move	(a1)+,d1
	beq.b	.exitY		; 0=Endkennung
	bmi.b	.nextX		;-1=Y-Endkennung 
	add	(a5,d0.w),d1	; sinus addieren
	add	d3,d1		; xpos addieren
	move.b	d1,d2
	lsr	#3,d1
	not.b	d2
	bset	d2,(a0,d1.w)
	bra.b	.printMyDots
.nextX	addq	#1,d3			; xpos=xpos+1
	addq	#2,d0
	and	#1023,d0
	bra.b	.printMyDots	

.exitY
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Demo-Pointer

TBuffer		dc.l	Screen1,Screen2,Screen3
XSinPtr		dc.w	0
YSinPtr		dc.w	0
ScretchPtr		dc.w	0

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


XSinTab	include	logowobble2/WaveSinTab.i

YSinTab	ds.w	512

ScretchTab	include	logowobble2/WobbleTab.i			; kommatabelle
SingLogo	incbin	logowobble2/MTNSingLogo2.256x64.bin	; singtab
	dc.l	0
	even
	
;---------------------------------------------------------- Copperlist
	cnop	0,8
cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe


;---------------------------------------------------------- BitplaneSpace

Screen1:	ds.b	10240
Screen2:	ds.b	10240
Screen3:	ds.b	10240
