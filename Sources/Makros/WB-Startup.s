;	WB-Startup

WBStartup:
	move.l	a7,oldsp
	move.l	4.w,a6
	move.l	$114(a6),a1	; Pointer to own Process 
	tst.l	$ac(a1)		; from cli ?
	bne.b	.cli		; ja
	lea	$5c(a1),a2	; Zeiger auf MSGPort
	move.l	a2,a0
	jsr	-384(a6)	; WaitPort
	move.l	a2,a0
	jsr	-372(a6)	; GetMsg
	move.l	d0,WBMsg	; SaveMsg
.cli:

.exit:	move.l	oldsp(pc),a7
	move.l	WBMsg(pc),d1
	beq.b	.cliexit
	move.l	d1,a1
	move.l	4.w,a6
	jsr	-378(a6)	; ReplyMsg
.cliexit:	rts

oldsp:	dc.l	0
wbmsg:	dc.l	0
