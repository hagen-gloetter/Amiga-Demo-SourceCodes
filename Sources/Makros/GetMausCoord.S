;	Sugar-Mouse by Duke of Prestige 27.2.93


MouseOut:
	lea	$dff00a,a0
	move	(a0),d0
	lea	OldMouse,a1
	move	d0,d1
	lsr	#8,d1
	sub.b	(a1),d1
	ext	d1
	add	d1,4(a1)
	bpl.b	.noclip1
	clr	4(a1)
.noclip1:
	cmp	#256-32,4(a1)
	blo.b	.noclip2
	move	#256-32,4(a1)
.noclip2:
	sub.b	1(a1),d0
	ext	d0
	add	d0,2(a1)
	bpl.b	.noclip3
	clr	2(a1)

.noclip3:
	cmp	#640-32,2(a1)
	blo.b	noclip4
	move	#640-32,2(a1)
.noclip4:
	move	(a0),(a1)
	rts


OldMouse	dc.w	0
MouseX:		dc.w	0
MouseY:		dc.w	0

