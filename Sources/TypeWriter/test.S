
TypeWriter:
	move	freezer(pc),d0
	beq	.go
	subq	#1,d0
	btst	#2,$dff016		; rmt skips wait
	bne.b	.noskip
	moveq	#0,d0
.noskip	move	d0,freezer
	rts
.go	lea	Bitplane(pc),a1
	lea	Font(pc),a2
	move	xoffset(pc),d1
	move	yoffset(pc),d2
.GetChar:
	moveq	#0,d0
	move.l	TxtPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	lea	Text(pc),a0
	move.b	(a0)+,d0
.no0:	move.l	a0,TxtPtr
	cmp	#1,d0			; clear
	beq	.cls
	cmp	#2,d0			; wait
	beq	.wait
.print:	sub	#32,d0
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,000(a1)	; copy 1. line
	move.b	(a3)+,080(a1)	; copy 2. line
	move.b	(a3)+,160(a1)	; copy 3. line
	move.b	(a3)+,240(a1)	; copy 4. line
	move.b	(a3)+,320(a1)	; copy 5. line
	move.b	(a3)+,400(a1)	; copy 6. line
	move.b	(a3)+,480(a1)	; copy 7. line
	move.b	(a3)+,560(a1)	; copy 8. line
	addq	#1,d1		; x = x+1
	cmp	#70,d1
	bne.b	.nojump
	lea	640*8(a1),a1
	moveq	#0,d1
	addq	#1,d2		; y = y+1
	cmp	#32,d2
	bne.b	.nojump
	moveq	#0,d1
	moveq	#0,d2
.nojump	move	d1,xoffset
	move	d2,yoffset
	rts

.wait:	move.b	(a0)+,d0
	move	d0,d1			; convert into seconds (x50)
	move	d0,d2
	lsl	#5,d0
	lsl	#4,d1
	lsl	#1,d2
	add	d2,d0
	add	d1,d0
	move	d0,freezer
	rts

.cls:	btst	#14,$02(a6)		; zu löschender Screen in a1
	bne.b	.cls
	move	#0,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	a1,$54(a6)
	move	#[256*64]+[640/16],$58(a6)
	rts


TxtPtr:		dc.l	Text
freezer:	dc.w	0		; wait for refresh
xoffset:	dc.w	0		; writer x offset
yoffset		dc.w	0		; writer y offset

Text:	dc.b	`Hallo leute was geht ? `
	dc.b	$ff

Font		include `8x8HexFont.hex`

Bitplane	ds.b	10240

