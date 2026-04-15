;               T            T              T       T

;

	section	code,code_p


DotsX	=	50
DotsY	=	20

;--------------------------------------------------------------- Makros
	incdir	codes:
	include	makros/-My_Makros.s

;--------------------------------------------------------------- Start of Code
x:	KillSystem

	bsr	initCoords

	move.l	#copperlist,$80(a6)
	StartVBI

.maus	btst	#6,$bfe001
;	btst	#2,$dff016
	bne.b	.maus

;--------------------------------------------------------------- Recall System
	RemoveVBI
	rts

;--------------------------------------------------------------- Interrupt

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	bsr	DotScroll
	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;--------------------------------------------------------------- Inits

;--------------------------------------------------------------- HauptRoutine

DotScroll:
	lea	Scroller+2,a0
	lea	Scroller,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$f9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[80/16],$58(a6)


	lea	FrontScreen(pc),a0
	movem.l	(a0),d1-d3
	exg.l	d1,d2
	exg.l	d2,d3
	movem.l	d1-d3,(a0)
				; Show new FrontScreen
	lea	Planes+2,a0
	mcop	d1,a0
	add.l	#7000,d1
	addq.l	#8,a0
	mcop	d1,a0
				; Clear Del-Screen
	wblt
	move.l	#$1000000,$40(a6)
	clr.l	$64(a6)
	move.l	d3,$54(a6)
	move	#[170*2*64]+[320/16],$58(a6)

	move.l	d2,a4
	moveq	#0,d2
	lea	Coords(pc),a0

	moveq	#DotsY-1,d7
.ylp	moveq	#DotsX-1,d6
.xlp	movem	(a0)+,d0-d1
	move.b	d0,d2	; d0-d1 x-y
	lsr	#3,d0	
	add	d1,d0
	not.b	d2			; Soft-Shift-Wert holen
	bset	d2,(a4,d0.w)
	dbf	d6,.xlp
	dbf	d7,.ylp

	lea	Scroller,a0

	add.l	#100*40,a4

	moveq	#16-1,d7
.lp
	move.l	(a0),(a4)
	move.l	4(a0),4(a4)
	move	8(a0),8(a4)
	add	#10,a0
	add	#40,a4
	dbf	d7,.lp
	rts



initCoords:	lea	Coords(pc),a0
	moveq	#DotsY-1,d6
	move	#10*40,d1
.ylp:	moveq	#DotsX-1,d7
	moveq	#01,d0
.xlp:	move	d0,(a0)+
	move	d1,(a0)+
	addq	#1,d0	; x spread
	dbf	d7,.xlp
	add	#40,d1	; y spread
	dbf	d6,.ylp
	rts





FrontScreen:	dc.l	Screen1
HiddenScreen:	dc.l	Screen2
DelScreen:	dc.l	Screen3

Coords:	ds.l	DotsX*DotsY

;--------------------------------------------------------------- SysPointer

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
vbr_exception		dc.l	$4e7a7801
		rte	; back to user state code



;---------------------------------------------------------- CopperListe
	section	Copperlist,data_c

		pop
Copperlist:		dc.w	$106,$20,$1fc,%0001100 ; 64spr
		dc.w	$180,888,$182,$555
		dc.w	$8e,$4181,$90,$30c1
		dc.w	$92,$38,$94,$d0
		dc.w	$102,0,$104,$10
		dc.w	$108,0,$10a,0
		dc.w	$100,$2200
Sprite		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0

Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
Colors		dc.w	$180,0,$182,$00a
		dc.w	$184,$aaa,$186,$fff

		dc.w	$4007,$fffe,$180,$007
		dc.w	$4107,$fffe,$180,$000
		dc.w	$f007,$fffe,$180,$007,$100,0
		dc.w	$f107,$fffe,$180,$000


		dc.l	$fffffffe

Scroller	dcb.b	16*10,$f

	section	Planes,bss_c

Screen1:	ds.b	2*7000		;320*175/8
Screen2:	ds.b	2*7000
Screen3:	ds.b	2*7000

