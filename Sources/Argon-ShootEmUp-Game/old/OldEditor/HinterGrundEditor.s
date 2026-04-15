;TOSAAAAAFPCAAAABGCKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPODOE
;               T        T              T       T



	incdir	Game:

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

	section	code,code_c		; code to chipmem
x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1		; use base-pointer
	move.l	$26(a1),syscop1	; store systemcopper1 start adr
	move.l	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon	; store sys dmacon
	move	$010(a6),adkcon	; store sys adkcon
	move	$01c(a6),intena	; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6


InitScreens	move.l	#GameScreen,d0		; init GameScreen
	lea	GamePlane+2,a0
	bsr	InitBplLoop

	move.l	#BlockScreen,d0       ; init BlockScreen
	lea	BlockPlane+2,a0
	bsr	InitBplLoop

	lea	Blocks,a0
	lea	BlockEnd,a1
	sub.l	a0,a1
	move.l	a1,d0
	lsr.l	#8,d0
	lsr.l	#1,d0
	move	d0,lineMax
	divu	#11,d0
	add	#1,d0	
	move	d0,d7

	lea	Blocks,a0
	lea	BlockScreen,a1
	move.l	a1,a2

.copy	moveq	#11-1,d6
.copyline	wblt
	move	#0,$64(a6)
	move	#40,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)	; 1Block
	add.l	#512,a0
	addq.l	#4,a1
	dbf	d6,.copyline
	add.l	#44*32*4,a2
	move.l	a2,a1
	dbf	d7,.copy

;---------------------------------------------------------- INITS

	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI		; get sys VBI+VBR+Offset
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)		; kick own VBI in
	move	#%1100000000100000,$9a(a6)	; start it

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:	lea	$dff000,a6
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon(pc),d0		; restore sys dmacon
	or.w	#$8000,d0
	move	adkcon(pc),d1		; restore sys adkcon
	or.w	#$8000,d1
	move	intena(pc),d2		; restore interenable
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	move.l	stackptr(pc),a7
	moveq	#0,d0
	rts


;-------------------------------------------------------- InitBplLoop

InitBplLoop:	move	#4-1,d7
.blp	move	d0,4(a0)
	swap	d0
	move     d0,(a0)
	swap	d0
	addq	#8,a0
	add	#44,d0
	dbf	d7,.blp
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	cnop	0,8
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	DoTheFun

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- MAIN ROUTINE

DoTheFun:	move	JoyWait,d0
	bne.b	
joy:	move.w	$dff00c,d0
	btst	#1,d0		; RIGHT
	bne.s	right
	btst	#9,d0		; LEFT
	bne.s	left
.testud:	move.w	d0,d1
	lsr.w	d1
	eor.w	d1,d0
	btst	#0,d0		; BACK
	bne.s	backw
	btst	#8,d0		; FORW
	bne.s	forw
.tsttgr:	btst	#7,$bfe001		; TGR
	beq.w	trpl
	btst	#2,$dff016		; RMT
	beq.w	rmaus

	clr	JoyWait
	rts

right	cmp	#10,BlockPos
	beq	.nop
	addq	#1,BlockPos
.nop	rts

left	cmp	#0,BlockPos
	beq	.nop
	subq	#1,BlockPos
.nop	rts

forw	cmp	#11,BlockPos
	blo	.nop
	sub	#11,BlockPos
	lea	BlockPlane,a0
	move.l	#Blockscreen,d0
	sub	#176,BlockScreenPtr	
	add	BlockScreenPtr,d0
	bsr	InitBplLoop
.nop	rts

backw	move	lineMax,d0
	move	BlockPos,d1
	cmp	d0,d1
	bge	.nop
	add	#11,BlockPos
	lea	BlockPlane,a0
	move.l	#Blockscreen,d0
	add	#176,BlockScreenPtr	
	add	BlockScreenPtr,d0
	bsr	InitBplLoop
.nop	rts

trpl;	bsr	copyBlockUp
	rts
rmaus	move	#$ff0,$180(a6)
	rts


;---------------------------------------------------------- Pointer

	cnop	0,8

JoyWait	dc.w	0
BlockScreenPtr	dc.w	0
BlockPos	dc.w	0
lineMax	dc.w	0
xpos	dc.w	0

stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte		; back to user state code

;---------------------------------------------------------- Copperlist


	cnop	0,8
cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$2171,$90,$41d1,$92,$30,$94,$d8
	dc.w	$102,0,$104,0,$108,132,$10a,132
	dc.w	$100,$4200
Colors	include	"BackColTab1.i"
GamePlane:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0

;	dc.w	$ffe1,$fffe
	dc.w	$7007,$fffe,$180,$f00
	dc.w	$7107,$fffe,$180,$0,$100,$4200
BlockPlane:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
;	dc.w	$3107,$fffe,$100,0
	dc.l	$fffffffe

;---------------------------------------------------------- Baukasten

	cnop	0,8
Blocks	incbin	"BlockList1.b"
BlockEnd	dc.b	`Hallo`

;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
GameScreen:	ds.b	4*352/8*3*240


BlockScreen	ds.b	4*352/8*32*10

