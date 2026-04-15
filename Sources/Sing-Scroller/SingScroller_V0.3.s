;TOSAAAABADGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPOPMK
;               T        T              T       T

;	48*48 SinusScroller
;	code by Duke of Motion


wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


	incdir	Codes:SingScroller/

	section	code,code_c		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1		; use base-pointer
	move.l	$26(a1),syscop1	; store systemcopper1 start adr
	move.l	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon	; store sys dmacon
	move	$010(a6),adkcon	; store sys adkcon
	move	$01c(a6),intena	; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

.bplini	move.l	#Screen1,d0
	lea	BitPlanes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- PreCalcScrollTab

PreCalcScrollerTabs:
	lea	Font,a0	; Sing-Tabelle vormultiplizieren
.loop	move	(a0),d0
	bmi.b	.exit		; 0 =Endkennung ges
	beq.b	.go		; -1=Endkennung y
	muls	#40,d0		; Screenbreite/8
.go	move	d0,(a0)+
	bra.b	.loop
.exit
	lea	YSinTab,a0     ; YSinus-Tabelle vormultiplizieren
	move	#1024-1,d7	; 1024 Werte
.lp	move	(a0),d0
	muls	#40,d0	; Screenbreite/8
	move	d0,(a0)+
	dbf	d7,.lp

GetVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI		; get sys VBI+VBR-Offset
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)		; kick own VBI in
	move	#%1100000000100000,$9a(a6)	; start it

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
	or.w	#$8000,d0
	move	adkcon(pc),d1		; restore sys adkcon
	or.w	#$8000,d1
	move	intena(pc),d2		; restore interenable
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	move.l	stackptr(pc),a7
	moveq	#0,d0
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$500,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE
	bsr.w	Buffering

	move	#$050,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte




;---------------------------------------------------------- SCROLLER

Buffering	lea	FrontScreen(pc),a2		; Tribble Buffering
	movem.l	(a2),d0-d2
	exg.l	d0,d1
	exg.l	d1,d2
	movem.l	d0-d2,(a2)
	move.l	d0,a0

.FrontScrToCop	lea	BitPlanes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

ClearHiddenScreen:				; Clear Hidden Screen
	wblt
	move.l	#$1000000,$40(a6)
	move	#0,$66(a6)
	move.l	d1,$54(a6)
	move	#[248*64]+[320/16],$58(a6)

;---------------------------------------------------------- bset

.scroller	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	lea	Hiddenscroller,a1
	move.l	a0,a5		; save a0

	lea	ySinTab,a3
	move	ySinPtr,d0
	addq	#6,d0
	and	#1023,d0
	move	d0,ySinPtr
	lea	(a3,d0.w),a3
	move.b	#$80,d2

	move	#40-1,d7
.byteloop	moveq	#8-1,d6
.bset	move	(a3)+,d0	; Sinus   addieren	
;	move	#40*50,d0
.1	move	(a1),d1
	beq.b	.nextX	; 0=Y-Endkennung nur bei even, da paare
	add	d0,d1
	or.b	d2,(a0,d1.w)	; bset
.2	move	2(a1),d1
	add	d0,d1
	or.b	d2,(a0,d1.w)	; bset
.3	move	4(a1),d1
	beq.b	.nextX	
	add	d0,d1
	or.b	d2,(a0,d1.w)	
.4	move	6(a1),d1
	add	d0,d1
	or.b	d2,(a0,d1.w)	; bset
.5	move	8(a1),d1
	beq.b	.nextX
	add	d0,d1
	or.b	d2,(a0,d1.w)
.6	move	10(a1),d1
	add	d0,d1
	or.b	d2,(a0,d1.w)	; bset
.7	move	12(a1),d1
	beq.b	.nextX
	add	d0,d1
	or.b	d2,(a0,d1.w)
.8	move	14(a1),d1
	add	d0,d1
	or.b	d2,(a0,d1.w)	; bset

.nextX	ror.b	#1,d2		; xpos=xpos+1
	lea	16(a1),a1
	dbf	d6,.bset
	addq	#1,a0
	dbf	d7,.byteloop


;---------------------------------------------------------- Move the hidden one

.moveHiddenScroller
	move	scrollcnt,d5
	bne.w	.noNewChar

.NewChar:	move	#48,scrollcnt	; refresh pointer
	lea	Font(pc),a2
	moveq	#0,d0
	moveq	#0,d1
	move.l	ScrollPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	lea	ScrollText(pc),a0
	move.b	(a0)+,d0
.no0:	move.l	a0,ScrollPtr
	sub.b	#65,d0	; kleiner 65 
	bmi.b	.space	; ja, dann isch's a space
	move	d0,d1	;\
	lsl	#8,d0	; \
	lsl	#8,d1	;  } *768
	add	d1,d1	; /
	add	d1,d0	;/

.copyLetter	lea	(a2,d0.w),a0
	lea	HiddenScroller+16*320,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[48*64]+8,$58(a6)
	bra.b	.noNewChar

.space	lea	HiddenScroller+16*320,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	a1,$54(a6)
	move	#[48*64]+8,$58(a6)


.noNewChar	subq	#1,scrollcnt
	lea	Hiddenscroller+16,a1
	lea	Hiddenscroller,a2	; Z D
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a1-a2,$50(a6)
	move	#[360*64]+8,$58(a6)


	move.l	a5,a0
	moveq	#0,d0				; Fill Picture
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	qrept	2
	move.l	a0,a1		; StartAdr sichern
	qrept	249		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d2/d4/d6	; Neue Daten aus Bmp holen
	eor.l	d0,d1		;
	eor.l	d2,d3		;
	eor.l	d4,d5		;
	eor.l	d6,d7		;
	movem.l	d1/d3/d5/d7,(a1)	; Modifizierte Daten zurückschreiben
	lea	40(a1),a1	; Eine Zeile tiefer 
	endqr
	lea	16(a0),a0
	endqr
	move.l	a0,a1		; StartAdr sichern
	qrept	249		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d2	; Neue Daten aus Bmp holen
	eor.l	d0,d1		;
	eor.l	d2,d3		;
	movem.l	d1/d3,(a1)	; Modifizierte Daten zurückschreiben
	lea	40(a1),a1	; Eine Zeile tiefer 
	endqr
	rts



	rts







;---------------------------------------------------------- Demo_Pointer

scrollcnt	dc.w	0
ScrollPtr	dc.l	ScrollText
FrontScreen	dc.l	Screen1,Screen2,Screen3
YSinTab	include	sintab1.i			; 512.w
ySinPtr	dc.w	0

ScrollText	dc.b	`MOTION CRAZY FOOLS WITHOUT ANY RULEZ `
	dc.b	`ABCDEFGHIJKLMNOPQRSTUVWXYZ`
	dc.b	0
	even

;---------------------------------------------------------- SYS_Pointer

stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte		; back to user state code


;---------------------------------------------------------- Font

Font:	incbin	ShebertFont.coords.b
	dc.l	$fffffffff		; Endkennung
	
;---------------------------------------------------------- Copperlist

cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$070
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
BitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

HiddenScroller	ds.b	16*368

Screen1:	ds.b	10240
Screen2:	ds.b	10240
Screen3:	ds.b	10240
