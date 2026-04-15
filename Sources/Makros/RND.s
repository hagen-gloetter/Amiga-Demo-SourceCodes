;	Rnd Generator

;	liefert Rndzahl in d0.l


RandomInit:
	move.w	$dff014,d0
	mulu	$dff014,d0
	move.l	d0,RND
	rts

Random:	lea	RND(pc),a0
	move.w	(a0),d0
	mulu	#51479,d0
	addi.l	#3715436908,d0
	move.l	d0,(a0)
	rts

RND:	dc.l 0

