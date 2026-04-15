*	JoyTest   ( just a simple Hack of a ½h )
;		  Code testet alle Richtungen des sticks un' gibt s'e aus
;		  vor - z'rueck - rechts - links - feuer

*	Codin' by Hagen Glötter on the 10.01.'92 a.d.


mainlp:	bsr.s	joy
	btst	#6,$bfe001	;LMT
	bne.s	mainlp
	moveq	#0,d0
	rts

joy:	move.w	$dff00c,d0
	btst	#1,d0		; RIGHT
	bne.s	right
	btst	#9,d0		; LEFT
	bne.s	left
testud:	move.w	d0,d1
	lsr.w	d1
	eor.w	d1,d0
	btst	#0,d0		; BACK
	bne.s	backw
	btst	#8,d0		; FORW
	bne.s	forw
tsttgr:	btst	#7,$bfe001	; TGR
	beq.s	trpl
	btst	#2,$dff016	; RMT
	beq.s	rmaus
	rts
right:	move.l	#rtxt,d2
	bsr.s	TXTout
	bra.s	testud
left:	move.l	#ltxt,d2
	bsr.s	TXTout
	bra.s	testud
backw:	move.l	#dtxt,d2
	bsr.s	TXTout
	btst	#7,$bfe001
	beq.s	trmi
	rts
trmi:	move.l	#ftxt,d2
	bsr.s	TXTout
	rts
forw:	btst	#7,$bfe001
	beq.s	trpl
	move.l	#utxt,d2
	bsr.s	TXTout
	rts
trpl:	move.l	#ftxt,d2
	bsr.s	TXTout
	rts
rmaus:	move.l	#rmtxt,d2
	bsr.s	TXTout
	rts

TXTout:	move.l	$4.w,a6		; Exec,a6
	lea	dosname(pc),a1	; Dos,a1
	jsr	-408(a6)	; openold
	move.l	d0,a6		; save dosptr
	jsr	-60(a6)		; output
	move.l	d0,d1		; text,d1
;	move.l	#TXT,d2		; txtptr,d2
	move.l	#13,d3		; laenge,d3
;	sub.l	d2,d3		; txtlaenge im mem
	jsr	-48(a6)		; Write
	move.l	a6,a1		; dosptr,a1
	move.l	$4.w,a6		; exec,a6
	jsr	-414(a6)	; closelib
	rts

ftxt:		dc.b	12,"F E U E R !",10 ; 12=cls 10=crt
rtxt:		dc.b	12,"rechts     ",10
ltxt:		dc.b	12,"links      ",10
utxt:		dc.b	12,"vorwaerts  ",10
dtxt:		dc.b	12,"rueckwaerts",10	
rmtxt:		dc.b	12,"rechte maus",10

dosname:	dc.b	"dos.library",0

