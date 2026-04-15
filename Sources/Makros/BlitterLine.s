; d0/d1/d2/d3/a0 | x1/y1/x2/y2/bitplane adress

draw_line:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a6
.wblt:	btst	#14,2(a6)
	bne.b	.wblt
	move.w	#-1,$72(a6)
	move.l	#-1,$44(a6)
	move.w	#320/8,$60(a6)
	move.w	#320/8,$66(a6)
	move.w	#$8000,$74(a6)
	cmp.w	d1,d3
	bgt.s	.ok1
	exg	d0,d2
	exg	d1,d3
.ok1:	move.w	d0,d4
	move.w	d1,d5
	mulu	#320/8,d5
	add.w	d5,a0
	lsr.w	#4,d4
	add.w	d4,d4
	lea	(a0,d4.w),a0
	sub.w	d0,d2
	sub.w	d1,d3
	moveq	#15,d5
	and.l	d5,d0
	ror.l	#4,d0
	move.w	#4,d0
	tst.w	d2
	bpl.b	.op1
	addq.w	#1,d0
	neg.w	d2
.op1:	cmp.w	d2,d3
	ble.b	.op2
	exg	d2,d3
	subq.w	#4,d0
	add.w	d0,d0
.op2:	move.w	d3,d4
	sub.w	d2,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d3,d3
	move.w	d3,d6
	sub.w	d2,d6
	bpl.b	.op3
	or.w	#16,d0
.op3:	add.w	d3,d3
	add.w	d0,d0
	add.w	d0,d0
	addq.w	#1,d2
	lsl.w	#6,d2
	addq.w	#2,d2
	swap	d3
	move.w	d4,d3
	or.l	#$0bca0001,d0
.wblt2:	btst	#14,2(a6)
	bne.b	.wblt2
	move.w	d6,$52(a6)
	move.l	d3,$62(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.l	d0,$40(a6)
	move.w	d2,$58(a6)
	movem.l	(sp)+,d0-d7/a0-a6
EndLine:rts
