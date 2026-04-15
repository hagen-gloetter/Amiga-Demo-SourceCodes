שתשתÿץw/ÿץw/ÿץw/ÿץw/ÿץw/ÿץw/ÿץw/ÿץw/ÿץw/


	move.b	#$00,$bfec01
wait:
	move.b	$bfec01,d0
	tst.b	d0
	cmp.b	#$74,$bfec01
	beq.s	.quit
	bra.s	wait
.quit	rts
			


