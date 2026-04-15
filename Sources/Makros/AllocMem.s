
.alloc:	move.l	4.w,a6
	move.l	#,d0	; Memsize
	move.l	#$10002,d1	; Bedingung
	jsr	-198(a6)	; AllocMem
	beq.b	.end
	move.l	d0,		; MemBlock

.free:	move.l	4.w,a6
	move.l	#,d0	; Memsize
	move.l	,a1	; MemBlock
	jsr	-210(a6)	; FreeMem
.end:	rts

