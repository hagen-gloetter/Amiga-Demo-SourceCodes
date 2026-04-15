.eff:	moveq	#40-1,d7
.wlp:	move.l	$04(a6),d0
	and.l	#$000ff00,d0
	cmp.l	#$0001f00,d0
	bne.s	.wlp
	dbf	d7,.wlp
	lea	col,a0
	sub	#$111,(a0)
	cmp	#0,(a0)
	bne.b	.eff
