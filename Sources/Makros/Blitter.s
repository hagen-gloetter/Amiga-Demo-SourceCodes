
wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[*64]+[/16],$58(a6)
