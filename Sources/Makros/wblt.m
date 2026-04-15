wblt	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm
