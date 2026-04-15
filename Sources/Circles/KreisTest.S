
;			 Kreisalgo 2te Runde

;	echt goiler Algo... diesmal malt er Spiralen auf den Screen
;	Der Algo ist glaub ich eine der Erklaerungen, die die
;	Kornkreise in Südengland entstehen .... Zufall !
;	.... buhu er hat das Muli erschossen !

	section Kreismalereien,code_c

go:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initBitPlane
	move	#$0020,$96(a6)
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2

	move	#2500,d7
WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

	bsr	DoKreis

	dbf	d7,WaitVBeam

mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.b	mloop

	lea	$dff000,a6
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts


;---------------------------------------------------------- InitBitPlane

DoKreis:
	lea	BitPlane(pc),a0
	
.lp	move	x,d0
	move	y,d1
	move	d0,d2			; d0=d2=x
	move	d1,d3			; d1=d3=y

.newX:	asr	#5,d1
	sub	d1,d0
	move	d0,x
	
.newY:	asr	#5,d2
	add	d3,d2
	move	d2,y

	add	#140,d0
	add	#80,d3
	
	mulu	#320,d3
	add	d0,d3

	move.b	d3,d0
	lsr	#3,d3
	not.b	d0
	bset	d0,(a0,d3.w)

	rts


x:	dc.w	40
y:	dc.w	10


;---------------------------------------------------------- InitBitPlane

InitBitPlane:
	move.l	#Bitplane,d0
	lea	Planes+2(pc),a0
.lp:	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	rts

;---------------------------------------------------------- Copperliste

cop:	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$3181,$90,$30c1
	dc.w	$92,$38,$94,$d0
	dc.w	$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitPlaneSpace

BitPlane:	ds.b	10240

