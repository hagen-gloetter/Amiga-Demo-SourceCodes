	section code,code_c

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initBitPlane
	move.l	#Cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2
	bsr.w	initVBI
mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.b	mloop
	bsr.w	removeVBI
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;---------------------------------------------------------- INITVBI

initVBI:
	lea	$dff000,a6
	move	$1c(a6),intena
	move.l	$6c.w,oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c.w
	move	#%1100000000100000,$9a(a6)
	move	#$0020,$96(a6)
	rts

;---------------------------------------------------------- REMOVEVBI

removeVBI:
	lea	$dff000,a5
	move	#$7fff,$9a(a5)
	move.l	oldVBI(pc),$6c.w
	move	intena(pc),d0
	or	#$8000,d0
	move	d0,$9a(a5)
;	lea	gfxname(pc),a1	; only when using CopList1
;	moveq	#0,d0
;	move.l	4.w,a6
;	jsr	-552(a6)
;	move.l	d0,a4
;	move.l	38(a4),$80(a5)
;	move	#0,$88(a5)
	move	#$8020,$96(a5)
	move	#$c00,$9a(a5)
	rts

intena:		dc.w	0
oldVBI:		dc.l	0
;gfxname:	dc.b	'graphics.library',0
; even

;---------------------------------------------------------- INITBITPLANE

InitBitPlane:
	lea	BitPlane(pc),a0
	lea	Planes(pc),a2
	move	#10240,d4	; Höhe*Breite/8
	move	#$e0,d1
	moveq	#4-1,d7
.lp:	move.l	a0,d0
	swap	d0
	move	d1,(a2)+
	move	d0,(a2)+
	addq	#2,d1
	move	d1,(a2)+
	move	a0,(a2)+
	addq	#2,d1
	add	d4,a0
	dbf	d7,.lp
	rts

;---------------------------------------------------------- VBI

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	bsr.w	
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- COPPERLISTE

Cop:	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$108,0,$10a,0,$102,0,$180,0
	dc.w	$100,$4200
Planes:	ds.l	2*4
	dc.l	$fffffffe

BitPlane:	ds.b	4*10240

