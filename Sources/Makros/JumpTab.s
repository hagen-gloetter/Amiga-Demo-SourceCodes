

	add.w	d0,d0
	add.w	d0,d0
	move.l	Skript(PC,d0.w),a0
	jmp	(a0)

Skript:	dc.l	
