;TOSAAAABGLLAAAABONJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPPPPMKGM
;               T        T              T       T



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
	move	#$0083e0,$96(a6)	; dmacon data
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
	divu	#11,d0
	add	#1,d0	
	move	d0,d1
	mulu	#11,d1
	move	d1,lineMax
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
InitSprite:	move.l	#Spritepointer,d0		; init Pointer
	lea	copsprite+2,a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)

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

	incdir	Game:

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
	bsr 	PrintSprite
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- JoyTest

DoTheFun:
joy:	move.w	$dff00c,d0
	btst	#1,d0		; RIGHT
	bne.s	right
	btst	#9,d0		; LEFT
	bne.s	left
.testud:	move.w	d0,d1
	lsr.w	d1
	eor.w	d1,d0
	btst	#0,d0		; BACK
	bne.w	backw
	btst	#8,d0		; FORW
	bne.s	forw
.tsttgr:	btst	#7,$bfe001		; TGR
	beq.w	trpl
	btst	#2,$dff016		; RMT
	beq.w	rmaus
	move 	#$fff,$180(a6)
	clr	JoyWait
	rts

;-------------------------------------------------------- Joy rechts
right	move	joywait,d0
	bne.s	.nop
	cmp	#10,BlockPos
	beq	.nop
	add	#32,xpos	
	addq	#1,BlockPos
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy links
left	move	joywait,d0
	bne.s	.nop
	cmp	#0,BlockPos
	beq	.nop
	sub	#32,xpos	
	subq	#1,BlockPos
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy vor
forw	move	joywait,d0
	bne.s	.nop
	cmp	#11,BlockPos
	blo	.nop
	sub	#11,BlockPos
	lea	BlockPlane+2,a0
	moveq	#0,d0
	move	BlockScreenPtr,d0
	sub	#176*32,d0
	move	d0,BlockScreenPtr
	add.l	#Blockscreen,d0
	bsr	InitBplLoop
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy zurück
backw	move	joywait,d0
	bne.s	.nop
	move	lineMax,d0
	move	BlockPos,d1
	cmp	d0,d1
;	cmp	#55,BlockPos
	bge	.nop
	add	#11,BlockPos
	lea	BlockPlane+2,a0
	moveq	#0,d0
	move	BlockScreenPtr,d0
	add	#176*32,d0
	move	d0,BlockScreenPtr
	add.l	#Blockscreen,d0
	bsr	InitBplLoop
	st	joywait
.nop	rts

;-------------------------------------------------------- Maus Rechts

rmaus	move	#$ff0,$180(a6)
	rts

;-------------------------------------------------------- FEUER-KNOPF

trpl	moveq	#0,d0
	lea	Blocks,a0
	move	Blockpos,d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	add.l	d0,a0
	lea	GameScreen,a1

	moveq	#0,d0
	move	GameX,d0
	cmp	#44,d0
	bne.s	.nocarry
	moveq	#0,d0
	move	d0,GameX
	add	#1,GameY
.nocarry	moveq	#0,d1
	move	GameY,d1
	mulu	#176*32,d1
	add.l	d0,d1
	add.l	d1,a1
	wblt
	move	#0,$64(a6)
	move	#40,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)
	addq	#4,GameX
	rts

;------------------------------------------------------ Sprite im SelectScreen

Printsprite:	lea	Spritepointer,a0
	move	xpos,d0		; X-coord
	move	#273,d1		; Y-coord
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3  		; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	move.b	d1,(a0)		; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	add	#32,d1			; Spr Höhe
	move.b	d1,4(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	move.b	d0,1(a0)
	move.b	d3,5(a0)
	rts


;-------------------------------------------------------- FEUER-KNOPF






;---------------------------------------------------------- Pointer

	cnop	0,8


GameX	dc.w	0	; ?pos im gamescreen
GameY	dc.w	0

JoyWait	dc.w	0
BlockScreenPtr	dc.w	0
BlockPos	dc.w	0
lineMax	dc.w	0
xpos	dc.w	112

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
cop:	dc.w	$106,$20,$1fc,%0000100
	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$2171,$90,$41d1,$92,$30,$94,$d8
	dc.w	$102,0,$104,$10,$108,132,$10a,132
	dc.w	$100,$4200
CopSprite:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0
	dc.w	$1a0,$fff,$1a2,$fff,$1a4,$fff,$1a6,$fff
	dc.w	$1a8,$444,$1aa,$550,$1ac,$a0a,$1ae,$f00
	dc.w	$1b0,$444,$1b2,$055,$1b4,$00a,$1b6,$0ff
	dc.w	$1b8,$444,$1ba,$500,$1bc,$0a0,$1be,$f0f
Colors	include	"BackColTab1.i"
GamePlane:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0

	dc.w	$ffe1,$fffe
	dc.w	$1007,$fffe,$180,$f00
	dc.w	$1107,$fffe,$180,$0,$100,$4200
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


	cnop	0,8
BlockScreen	ds.b	4*352/8*32*10

	cnop	0,8
Spritepointer:
	dc.l	0,0
	dc.l	$ffffffff,0
	dc.l	$ffffffff,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$C0000003,0
	dc.l	$ffffffff,0
	dc.l	$ffffffff,0
	dc.l	0,0
