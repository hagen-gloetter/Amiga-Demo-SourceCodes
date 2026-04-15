WaitVBeam:
	move.l	$dff004,d0
	and.l	#$000ff00,d0
	cmp.l	#$0001100,d0
	bne.s	WaitVBeam
