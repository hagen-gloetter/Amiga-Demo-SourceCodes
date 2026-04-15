*	Coding:	Demon

	bsr	TXTout
MAUS:
	bsr	led
	btst	#6,$bfe001	;LMT
;	btst	#2,$dff016	;RMT
	bne.s	MAUS
	moveq	#0,d0
	rts

led:
	bset	#1,$bfe001	;Pled
	move.b	#$7f,$bfd100	;\
	move.b	#$77,$bfd100	; Dled
	move.b	#$0,$bfd300	;/	


	move.l #10000,d0	;'Dunkelziffer1'
Schleife:
	subq.l #1,d0
	bne Schleife
	
	bclr	#1,$bfe001	;pled
	move.b	#$7f,$bfd100	;\
	move.b	#$77,$bfd100	; Dled
	move.b	#$ff,$bfd300	;/


	move.l #10000,d0	;'Hellziffer'
Schleife1:
	subq.l #1,d0
	bne Schleife1
	rts
TXTout:
	move.l	$4.w,a6
	lea	dosname(pc),a1
	jsr	-408(a6)
	move.l	d0,a6
	jsr	-60(a6)
	move.l	d0,d1
	move.l	#TXT,d2
	move.l	#21,d3
	jsr	-48(a6)
	move.l	a6,a1
	move.l	$4.w,a6
	jsr	-414(a6)
	rts

TXT:		dc.b	"Coding by Demon    ",10,0
		
dosname:	dc.b	"dos.library",0

