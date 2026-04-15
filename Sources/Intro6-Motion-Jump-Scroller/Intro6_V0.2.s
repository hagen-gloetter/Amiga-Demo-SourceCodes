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

	btst	#2,$dff016
	beq.b	.nop
	
	bsr	DoScroller

.nop	lea	$dff000,a6
;	move	#$f00,$180(a6)
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


initFont	move.l	#BackGround,d0
;	move.l	#FontPlane,d0			; TST
	lea	ScrollerPlanes+2,a0
	moveq	#4-1,d7
.plp	mcop	d0,a0
	addq.l	#8,a0
	add.l	#40,d0
	dbf	d7,.plp
	rts

initFontColors	lea	Font+80*40*4,a0
	lea	FontColors,a1
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp
	rts



;--------------------------------------------------------------- HauptRoutine
;--------------------------------------------------------------- HauptRoutine
;--------------------------------------------------------------- HauptRoutine

DoScroller


MoveScrollerUp
	lea	FontPlane+4*40,a0
	lea	FontPlane,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[127*4*64]+[320/16],$58(a6)

MergeScreens:	lea	BackDrop,a0
	lea	FontPlane,a1
	lea	BackGround,a2

	move	#4*10*100-1,d7
.lp
	move.l	(a0),d0	; FNT 1
	or.l	40(a0),d1	; FNT 2
	or.l	80(a0),d2	; FNT 3
	or.l	120(a0),d3	; FNT 4

	move.l	(a1)+,d0	; HG

	eor.l	d1,d0

	or.l	(a0)+,d0	; FNT 0
	


	move.l	d0,(a2)+	; BG
	dbf	d7,.lp

;---------------------------- 

.newLetter	subq	#1,copyPtr
	bpl.w	.end
	move	#$f,copyPtr

	lea	Font,a0
	lea	FontPlane+108*4*40,a2
;	lea	FontPlane,a2				;TST
	move	#20-1,d7


.Scroller:	moveq	#0,d0
	move.l	TextPointer,a5
	move.b	(a5)+,d0
	bne.b	.go
	lea	ScrollText,a5		; Org. Txt nach a0
	move.b	(a5)+,d0
.go	move.l	a5,TextPointer
	cmp	#1,d0
	beq.b	.end
	sub	#32,d0
	add	d0,d0
	cmp	#40,d0
	blt.b	.line0			; X > 3 then 2te Reihe
	cmp	#80,d0			; X > H then 3te Reihe
	blt.b	.line1
	cmp	#120,d0			; X > \ then 4te Reihe
	blt.b	.line2
	addq	#2,d0    ; Rhetor-Fehler ausbügeln
	cmp	#160,d0			; X > n then 5te Reihe
	blt.b	.line3
.line4:	add	#15*40*4+120,d0
.line3:	add	#15*40*4+120,d0
.line2:	add	#15*40*4+120,d0
.line1:	add	#15*40*4+120,d0
.line0:	lea	(a0,d0.w),a1
	wblt
	move	#38,$64(a6)
	move	#38,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a1-a2,$50(a6)
	move	#[16*4*64]+[16/16],$58(a6)
	addq.l	#2,a2
	dbf	d7,.Scroller
.end	rts


	wblt
	move	#00,$42(a6)
	move.l	#-1,$44(a6)
	move	#00,$62(a6)
	move	#00,$64(a6)
	move	#00,$66(a6)
;		  ----ABCD76543210
	move	#%0000110100000001,$40(a6)
	movem.l	a0-a2,$4c(a6)
	move	#[120*4*64]+[320/16],$58(a6)


	pop
TextPointer	dc.l	ScrollText

	;	`12345678901234567890
	;	`---------||---------`
ScrollText
	dc.b	`    Civil war in`,1
	dc.b	`     Jugoslavia`,1
	dc.b	1
	dc.b	`A flood disaster in`,1
	dc.b	`        India`,1
	dc.b	1
	dc.b	`An Ozonehole in the`,1
	dc.b	`     atmosphere`,1
	dc.b	1
	dc.b	`A dirty air that we`,1
	dc.b	`   breath in fear`,1
	dc.b	1
	dc.b	`  Planet we called `,1
	dc.b	`    mother earth`,1
	dc.b	1
	dc.b	`You are burdened by`,1
	dc.b	` every new childs`,1
	dc.b	`        birth`,1
	dc.b	1
	dc.b	`  the worst plague`,1
	dc.b	`       between`,1
	dc.b	`    time and space`,1
	dc.b	`  are the creatures`,1
	dc.b	`  of the human race`,1
	dc.b	1,1
	dc.b	` Like living in the`,1
	dc.b	`        dark`,1
	dc.b	1
	dc.b	` We close our eyes`,1
	dc.b	1
	dc.b	` Like living in the`,1
	dc.b	`        dark`,1
	dc.b	1
	dc.b	` We are walking on`,1
	dc.b	`        Ice`,1
	dc.b	1
	dc.b	` Like living in the`,1
	dc.b	`        dark`,1
	dc.b	1
	dc.b	` We are paying the`,1
	dc.b	`        price`,1
	dc.b	1
	dc.b	` Like living in the`,1
	dc.b	`        dark`,1
	dc.b	1
	dc.b	`Living sleepwaling`,1
	dc.b	`        lives`,1

	dc.b	1,1,1
	dc.b	1,1,1
	dc.b	0
	even

copyPtr		dc.w	0 ; ptr für neue FontLine

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
Font	incbin	intro6/font320x80x4.int
BackDrop	incbin	intro6/Backdrop320x120x4.int


	section	CopperList,data_c

		pop
Copperlist:		dc.w	$106,$20,$1fc,%0001100 ; 64spr
		dc.w	$8e,$3081,$90,$30c1
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

		dc.w	$c607,$fffe,$100,$0
FontColors		ds.l	16
		dc.w	$c7e1,$fffe,$100,$4200

ScrollerPlanes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0


		dc.l	$fffffffe


BackGround		ds.b	40*4*121

FontPlane		ds.b	40*4*128
