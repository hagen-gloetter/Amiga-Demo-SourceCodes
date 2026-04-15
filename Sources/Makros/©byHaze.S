initHazeSpr
	move.l	#Spr1,d0
	lea	Sprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp
showspr	lea	Spr1,a0
	moveq	#5-1,d7
	move	#375,d0			; X-coord
	move	#060,d1			; Y-coord
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3			; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	move.b	d1,(a0)			; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	add.w	#12,d1			; Spr Höhe
	move.b	d1,2(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	add	#16,d4
	move	d4,d0
	move	d5,d1
	lea	56(a0),a0
	dbf	d7,.spr

Sprite:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0
	dc.w	$140,0,$150,0,$160,0,$170,0
	dc.w	$148,0,$158,0,$168,0,$178,0
	dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$000
	dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$000
	dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$000
	dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$000

	include	`duke_sources_5:makros/haze80x12x2.spr`
