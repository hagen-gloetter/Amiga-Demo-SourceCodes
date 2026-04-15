
	section code,code_c

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initBitPlane
	move	#$0020,$96(a6)
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2


WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.s	WaitVBeam

	lea	$dff000,a6
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts


;---------------------------------------------------------- InitBitPlane

InitBitPlane:
	move.l	#Bitplane,d0
	lea	Planes+2(pc),a0
	move	#10240,d1
	moveq	#4-1,d7
.lp:	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	d1,d0
	addq	#8,a0
	dbf	d7,.lp
	rts

;---------------------------------------------------------- Copperliste

cop:	dc.w	$180,0
	dc.w	$8e,$3181,$90,$30c1
	dc.w	$92,$38,$94,$d0
	dc.w	$108,0,$10a,0
	dc.w	$100,$4200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitPlaneSpace

BitPlane:	ds.b	4*10240

