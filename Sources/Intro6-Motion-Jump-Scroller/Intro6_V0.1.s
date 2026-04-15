;TOSPJPKPJPKAAAAAAABAAAAAAABAAAAAAABAAAAAAABAAAAAAABAAAAAAABAAAAAAABAAAAAAABAGAFAFPO
;               T            T              T       T

;

	section	code,code_p

;--------------------------------------------------------------- Makros
	incdir	codes:
	include	makros/-My_Makros.s

;--------------------------------------------------------------- Start of Code
x:	KillSystem

	bsr.w	initLogo
	bsr.w	initColors
	bsr.w	initFont
	bsr.w	initFontColors

	move.l	#CopperList,$80(a6)
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

	bsr	Scroller

	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;--------------------------------------------------------------- Inits

initLogo	move.l	#Logo,d0
	lea	Planes+2,a0
	moveq	#4-1,d7
.plp	mcop	d0,a0
	addq.l	#8,a0
	add.l	#40,d0
	dbf	d7,.plp
	rts


initColors	lea	Logo+24000,a0
	lea	colors,a1
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp
	rts


initFont	move.l	#FontPlane,d0
	lea	FontPlanes+2,a0
	moveq	#4-1,d7
.plp	mcop	d0,a0
	addq.l	#8,a0
	add.l	#42,d0
	dbf	d7,.plp
	rts


initFontColors	lea	Font+6400,a0
	lea	FontColors,a1
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp
	rts


;--------------------------------------------------------------- HauptRoutine

Scroller:	sub	#$11,softscroll+2
	bmi.b	HardScroll
	rts

HardScroll:	move.l	ScrollPointer(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.b	.go
	lea	Scrolltext(pc),a0
	move.b	(a0)+,d0
.go	move.l	a0,ScrollPointer
	lea	Font,a2
.print	sub	#65,d0
	add	d0,d0
	lea	(a2,d0.w),a0

	lea	Font,a0
	lea	FontPlane+40,a1

	wblt
	move	#38,$64(a6)
	move	#40,$66(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[20*4*64]+[16/16],$58(a6)

	move	#$ff,softscroll+2

.Scroll	lea	FontPlane,a1
	lea	FontPlane+2,a0
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[20*4*64]+[336/16],$58(a6)
	rts


Scrollpointer	dc.l	Scrolltext

Scrolltext	dc.b	`ABABABAABBBB`
	dc.b	0

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

	section	Logo,data_c

Logo	incbin	intro6/Logo320x150x4.int
Font	incbin	intro6/font320x40x4.int

FontPlane	ds.b	42*40*4

	section	Coppelist,data_c

		pop
Copperlist:		dc.w	$106,$20,$1fc,%0001100 ; 64spr
		dc.w	$8e,$5181,$90,$30c1
		dc.w	$92,$38,$94,$d0
		dc.w	$102,0,$104,$10
		dc.w	$108,40*3,$10a,40*3
		dc.w	$100,$4200
Sprite		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0

Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
Colors		ds.l	16

		dc.w	$e701,$fffe,$100,0
		dc.w	$f7e1,$fffe

		dc.w	$108,42*3,$10a,42*3
		dc.w	$92,$30,$94,$d0
		dc.w	$100,$4200

SoftScroll		dc.w	$102,0
FontPlanes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
FontColors		ds.l	16

		dc.w	$ffe1,$fffe
		dc.w	$0be1,$fffe,$100,0
		dc.l	$fffffffe



