;               T        T              T       T

HinterGrundScroller:
	tst	LevelEndFlag
	bne.b	.ScrollEnde	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move	SoftScrollPtr(pc),d0
	bhi.b	.weiterscrollen
.wirSindOben	move	#320,d1
	sub	d0,d1		; Überlauf merken, subtrahieren
	move	d1,d0		; und zurückschreiben
.weiterscrollen	sub	ScrollSpeed(pc),d0
	move	d0,SoftScrollPtr
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

	move	PrintPointer(pc),d4
	add	ScrollSpeed(pc),d4
	btst	#5,d4
	beq.b	.go
	bsr.w	PrintNewLine
.go	move	d4,PrintPointer
.scrollende	rts

;---------------------------------------------------------- HardScroll

PrintNewLine:
	and	#31,d4		; reset print counter
.getPrintTarget	lea	LineOffSets(pc),a3
	move	BG_LinePtr(pc),d1
	add	d1,d1
	add	d1,d1
	move.l	(a3,d1),a1
	move.l	a1,a3		; for copy down
	move.l	LevelPointer(pc),a2
	lea	Baukasten1(pc),a4
.BlockCopyRoutine
	moveq	#11-1,d7
.xlp	moveq	#0,d2
	move.b	(a2)+,d2
	bmi.w	.exception
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
	lea	(a3),a0
	lea	(a0),a1
	add.l	#PF1_Breite*32*4*10,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[PF1_Breite/2],$58(a6)
	move	BG_LinePtr,d1
	subq	#1,d1
	bpl.b	.go
	moveq	#10-1,d1
.go	move	d1,BG_LinePtr
	rts
.exception:	move	#0,ScrollSpeed
	move	#$f,LevelEndFlag
	rts

;---------------------------------------------------------- BG_ScrollPointer

SoftScrollPtr	dc.w	320	; pos, wo wir grad beim scrollen sind
LevelPointer	dc.l	Level1_Start-121 ; Zu Printender block vom level 
PrintPointer	dc.w	0	; Pointer, wann wir line printen
BG_LinePtr	dc.w	8	; Poiter auf akt. LinePrintPos
LevelEndFlag	dc.w	0	; if 1= no more scrolling
