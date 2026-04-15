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
	add.l	#40,d0
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

	
mloop:
	btst	#6,$bfe001		; Wait for left  mouse button
	bne.b	.rtst
.c	btst	#6,$bfe001		; Wait for left  mouse button
	beq.b	.c
	add	#2,mod1
	add	#2,mod2
.rtst	btst	#2,$dff016		; Wait for right mouse button
	bne.b	.t
.d	btst	#2,$dff016		; Wait for right mouse button
	beq.b	.d
	sub	#2,mod1
	sub	#2,mod2


.t	btst	#7,$bfe001		; Wait for left  mouse button
	bne.b	mloop


	RemoveVBI
	rts


	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6


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
Copperlist:		dc.w	$106,$20,$1fc,%0001111 ; 64spr
		dc.w	$180,888,$182,$555
		dc.w	$8e,$3081,$90,$30c1,$92,$38,$94,$d0
		dc.w	$102,0,$104,$10
		dc.w	$108
mod1		dc.w	$98 ;4*40-8
		dc.w	$10a
mod2		dc.w	$98 ;4*40-8
		dc.w	$100,$5200
KillSpr		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0

Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
Colors		dc.w	32*2
		dc.l	$fffffffe

	incdir	DH2:IFF/BencPics/
	pop
Picture	Inciff	320x256x5_Another_Land
PicColors	Inciffp	320x256x5_Another_Land
