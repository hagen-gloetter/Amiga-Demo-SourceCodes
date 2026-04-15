;               T        T              T       T

HinterGrundScroller:
	tst	LevelEndFlag
	bne.b	.ScrollEnde	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move	SoftScrollPtr,d0
	bpl.b	.weiterscrollen
.wirSindOben	move	#320,d1
	sub	d0,d1		; Überlauf merken, subtrahieren
	move	d1,d0		; und zurückschreiben
.weiterscrollen	sub	ScrollSpeed,d0
	move	PrintPointer,d1
	move	d0,SoftScrollPtr
	add	ScrollSpeed,d1
	btst	#5,d1
	bne.b	PrintNewLine
	move	d1,PrintPointer
	move	d0,d1		;\
	move	d0,d2
	lsl	#7,d0
	lsl	#5,d1		; = Mulu 176
	lsl	#4,d2
	move.l	#HinterGrund,d3
	add.l	d0,d3
	add.l	d1,d3
	add.l	d2,d3		;/
	lea	PF1_Planes+2(pc),a1
	moveq	#4-1,d7
.copyToCopper	move	d3,4(a1)
	swap	d3
	move	d3,(a1)
	addq.l	#8,a1
	swap	d3
	add.l	#PF1_Breite,d3
	dbf	d7,.copyToCopper
.scrollende	rts

;---------------------------------------------------------- HardScroll

PrintNewLine:	and.b	#31,d1
	move	d1,PrintPointer
	move	d1,d4		; rescue printpointer
.getPrintTarget	move.l	LineOffSets,a3
	move	BG_LinePtr,d1
	add	d1,d1
	add	d1,d1
	lea	(a3,d1),a1
	move	d1,d3		; for copy down

	move.l	LevelPointer,a2
	lea	Baukasten1,a4
.BlockCopyRoutine

	moveq	#11-1,d7
.xlp	move.b	(a2)+,d2
	bmi.b	.exception
	lsl	#8,d2
	add	d2,d2
	lea	(a4,d2),a0
	wblt
	move	#0,$64(a6)			; BltAmod
	move	#PF1_Breite-32/8,$66(a6)	; BltDmod
	move.l	#$09f00000,$40(a6)		; BltCon 0+1
	move.l	#-1,$44(a6)			; Bltmask A+D
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)
	addq.l	#4,a1
	dbf	d7,.xlp

	sub.l	#22,a2
	move.l	a2,LevelPointer


.copyWholeLineDown
	lea	(a3,d3),a0
	lea	40(a0),a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[PF1_Breite/2],$58(a6)


	move	BG_LinePtr,d1
	subq	#1,d1
	bge.b	.go
	moveq	#9,d1
.go	move	d1,BG_LinePtr
	move	d4,d1		; rescue printpointer
	rts


.exception:	move	#0,ScrollSpeed
	move	#$f,LevelEndFlag
	rts

ScrollSpeed	dc.w	2	; Speed vom Hintergrund
SoftScrollPtr	dc.w	320

LevelPointer	dc.l	Level1_Start-110 ; Zu Printender block vom level 

PrintPointer	dc.w	0	; Pointer, wann wir line printen

BG_LinePtr	dc.w	8	; Poiter auf akt. LinePrintPos

LevelEndFlag	dc.w	0	; if 1= no more scrolling
