;TOSPJPKPJPKAAAABCPLAAAADBEIAAAABBKNAAAAAAHFAAAAAAHFAAAAAAHFAAAAAAHFAAAAAAHFAGAEKNMN
;               T            T              T       T


	incdir	codes:makros/
	include	-My_Makros.s
	incdir	codes:spiel/

	section	code,code_p		; code to chipmem

x:	KillSystem

	move.l	#Picture,d0
	lea	Planes+2,a0
	moveq	#5-1,d7
.bpllp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#44,d0
	addq.l	#8,a0
	dbf	d7,.bpllp
	lea	PicColors,a0
	lea	Colors,a1
	move	#$180,d0
	moveq	#32-1,d7
.clp	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d7,.clp


	ml	#copperlist,$80(a6)	; copper1 start address
	StartVBI

	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop


	RemoveVBI
	rts


	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6

	lea	Block,a0
	lea	Picture,a1
	move.l	a1,a2
	moveq	#8-1,d6
.lp2	move.l	a2,a1
	moveq	#11-1,d7
.lp	wblt
	move.l	#-1,$44(a6)
	move	#0,$64(a6)
	move	#44-4,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
;	move	#[32*4*64]+[32/16],$58(a6)
;	addq.l	#4,a1
;	dbf	d7,.lp
;	lea	5632(a2),a2
;	dbf	d6,.lp2
	


;	mw	#$f00,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- SysPointer

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

;---------------------------------------------------------- Copperliste

	section	Coppelist,data_c

		pop
Copperlist:		dc.w	$106,$20,$1fc,%0001100 ; 64spr
		dc.w	$180,888,$182,$555
		dc.w	$8e,$3081,$90,$30d1,$92,$30,$94,$d8
		dc.w	$102,0,$104,$0
		dc.w	$108,44*3,$10a,44*3
		dc.w	$100,$4200
KillSpr		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0

Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
Colors		ds.w	16*2
		dc.l	$fffffffe

Picture	ds.b	5*44*256

	incdir	DH2:IFF/GamePics/
Block	inciff	block005
Piccolors	inciffp	block005
