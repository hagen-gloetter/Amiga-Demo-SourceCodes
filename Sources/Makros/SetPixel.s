	move.b	d1,d2
	lsr	#3,d1
	not.b	d2
	bset	d2,(a0,d1.w)
