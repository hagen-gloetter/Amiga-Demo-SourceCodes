
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

	bsr.b	dokreis

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

	move	#2500,d7

	moveq	#60,d0	; X
	moveq	#63,d1	; Y
.lp
	move	d0,d2
	asr	#4,d2	; x/32
	add	d2,d1	; y+x/32
	move	d1,d3
	asr	#4,d3	; y/32
	sub	d3,d0	; x-y/32

.bset	move	d0,d2
	move	d1,d3
	
	add	#160,d2	; sc x
	add	#100,d3	; sc y

	move	d3,d4	; x320
	lsl	#8,d3
	lsl	#6,d4
	add	d4,d3

	add	d2,d3

	move.b	d3,d2
	lsr	#3,d3
	not.b	d2
	bset	d2,(a0,d3.w)

	dbf	d7,.lp

	rts


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

