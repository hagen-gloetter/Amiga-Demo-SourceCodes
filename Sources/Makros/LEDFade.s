

;	LED-FADE ON/OFF  Coded by Demon
;  Laesst PLED langsam an und ausgehen
;  Using  D0-D3


Fade:	move	#128,d2
	move	#32,d3
	bchg	#1,$bfe001
w1:	move	d2,d0
	move	#128,d1
	sub	d0,d1
w2:	dbf	d1,w2
	bchg	#1,$bfe001
w3:	dbf	d0,w3
	bchg	#1,$bfe001
	dbf	d3,w1
	move	#32,d3
	subi	#1,d2
	bcc	w1
	rts

