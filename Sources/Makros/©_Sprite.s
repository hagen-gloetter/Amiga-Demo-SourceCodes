DKESpr:	lea	DSpr(pc),a0
	lea	SprDat(pc),a1
	move	#417,d0		; xcoord
	move	#248,d1		; ycoord
	bsr.b	.CalcCW
	add	#28,a0
	add	#8,a1
	move	#433,d0		; xcoord
	move	#248,d1		; ycoord
.CalcCW:move.l	a0,d4
	swap	d4
	move	d4,2(a1)
	move	a0,6(a1)
	moveq	#0,d3
	moveq	#6,d2
	move.b	d1,(a0)
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3
.noE8:	add.w	d2,d1
	move.b	d1,2(a0)
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3
.noL8:	lsr.w	#1,d0
	bcc.b	.noH0
	bset	#0,d3
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	rts	

DSpr:	dc.w	$0000,$0000
	dc.w	$b1d2,$ca40,$0052,$0000
	dc.w	$7052,$4a00,$0252,$0000
	dc.w	$13de,$1850,$0000,$0000
	dc.w	$0000,$0000
	dc.w	$971a,$04a6,$9400,$0000
	dc.w	$f714,$102c,$9400,$0000
	dc.w	$9710,$04b0,$0000,$0000

SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
