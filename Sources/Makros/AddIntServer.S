	move.l	4.w,a6
	lea	IntStruct(pc),a1
	moveq	#5,d0				; vblank
	jsr	-120(a6)			; Disable
	jsr	-168(a6)			; AddIntServer

mloop:	btst	#6,$bfe001		; Wait for left  mouse button
	bne.w	mloop

	move.l	4.w,a6
	lea	IntStruct(pc),a1
	moveq	#5,d0
	jsr	-174(a6)			; RemIntServer
	jsr	-126(a6)			; Enable

	rts

VBI:
	movem.l	d0-a6,-(sp)
	move	#$f00,$dff180
	movem.l	(sp)+,d0-a6
	moveq	#0,d0
	rts

IntStruct
	dc.l	0,0
	dc.b	2,127			; 
	dc.l	0,0,VBI
