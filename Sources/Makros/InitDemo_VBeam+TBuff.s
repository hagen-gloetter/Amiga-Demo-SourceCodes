
	section	code,code_c

;---------------------------------------------------------- INIT DEMO

START:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6		; CustomRegBase to a6
	move	#$4000,$9a(a6)		; Forbid Interrupts
	move	#$0020,$96(a6)		; Forbid Sprites
.lp:	tst.b	$006(a6)		; wait for y0 für einen
	bne.s	.lp			; flackerfreien Übergang
	move.l	#CopperList,$84(a6)	; Copperliste2 laden und
	move	#$123,$8a(a6)		; über Copjmp2 aktivieren

;---------------------------------------------------------- WAITVBEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	4(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

;------------------------------------------------------ DOUBLE BUFFERING

DBuff:	lea	FrontScreen(pc),a0
	lea	Planes+2(pc),a1
	movem.l	(a0),d0-d2
	exg	d0,d1
	exg	d1,d2
	movem.l	d0-d2,(a0)
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	swap	d2

;--------------------------------------------------------- CLEARDELSCREEN

.ClearDelScreen:
	btst	#14,$02(a6)
	bne.b	.ClearDelScreen
	move.l	#$1000000,$40(a6)
	move	#0,$66(a6)
	move.l	d1,$54(a6)
	move	#[256*64]+[320/16],$58(a6)

;---------------------------------------------------------- MAIN ROUTINE

	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.s	WaitVBeam

;---------------------------------------------------------- EXIT DEMO

Exit:	lea	$dff000,a6
	move	#$8020,$96(a6)		; allow  Sprites
	move	#$c00,$9a(a6)		; permit Interrupts
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;---------------------------------------------------------- COPPERLIST

CopperList:
	dc.w	$180,0,$182,$777
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,0,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.l	$fffffffe

;---------------------------------------------------------- POINTER

FrontScreen:	dc.l	Screen1
DelScreen:	dc.l	Screen2
HiddenScreen:	dc.l	Screen3

;---------------------------------------------------------- BITPLANES

Screen1:	dcb.b	10240,0
Screen2:	dcb.b	10240,0
Screen3:	dcb.b	10240,0


