	wblt
	move	#42,$66(a6)		; mod d
	move.l	#$01000000,$40(a6)	; clr

	move.l	GegnerTabelleOld,a0
	lea	Mulu48Tab,a3
	move.l	Hiddenscreen,a1
	moveq	#16-1,d7		; max 32 gegner
.GegnerTest	move	(a0),d0		; 1ster eintrag -1 (leer)
	bmi.b	.nextEntry		; ja! nächster
	move	2(a0),d1		; get y coord
	lsr	#3,d0		; get start byte
	add	d1,d1		; to word
	move	(a3,d1.w),d1		; get line mulu 48	
	add	d0,d1		; start byte fürs löschen
	lea	(a1,d1.w),a2

.bltclr	btst	#14,$02(a6)		; blitter finished ?
	bne.b	.cls_by_68000		; then proz
	move.l	a2,$54(a6)		; ziel d
	move	#[4*32*64]+[48/16],$58(a6)	; bltsize
	bra.b	.nextEntry		; go on
	
.cls_by_68000
	moveq	#32*4-1,d6		; höhe
	moveq	#0,d0
.llp	
	move.l	d0,(a2)
	move	d0,4(a2)
	add.l	#48,a2		; nxt line (int)
	dbf	d6,.llp

.nextEntry	lea	11*2(a0),a0		; next line in tab
	dbf	d7,.GegnerTest		; rest machen
	rts
