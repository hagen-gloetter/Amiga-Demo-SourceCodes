* MemCls   Coded by Demon

sichern:
	MOVEM.L	D0-7/A0-6,-(A7)
	LEA	$30000,A0
haupt:
	CMPA.L	#$7F000,A0
	BEQ.S	back
	CLR.L	(A0)+
	BRA.S	haupt
back:
	MOVEM.L	(A7)+,D0-7/A0-6
	CLR.L	D0
	RTS

