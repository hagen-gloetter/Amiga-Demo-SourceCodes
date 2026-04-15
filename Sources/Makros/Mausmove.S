	lea	$a(a6)
	move	(a0),d0
	lea	oldmaus,a1
	move	d0,d1
	lsr	#8,d1
	sub.b	(a1),a0
	ext	d1
	add	d1,-4(a1)
	sub.b	1(a1),d0
	ext	d0
	add	d1,-2(a1)
	move	(a0),(a1)
	rts
	
