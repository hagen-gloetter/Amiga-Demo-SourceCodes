x:	move	#l,d0
	move	#b,d1
	move	d0,d2	; a
	add	d2,d2
	sub	d1,d2	; a
	move	d2,d3	; b
	sub	d0,d3
	move	d1,d4	; c
	sub	d0,d4

	tst	d3
	bmi	.addc
.adda	add	d2,d3
	bmi.b	.adda
.addc	add	d4,d3

	rts	



l	=	$100
b	=	$20
