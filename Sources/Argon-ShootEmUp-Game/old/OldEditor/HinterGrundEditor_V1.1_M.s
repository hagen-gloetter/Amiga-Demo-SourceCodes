;TOSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
;               T        T              T       T

	incdir	codes:
	include	Makros/-My_Makros.s

	section	code,code_c		; code to chipmem
x:	ml	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	ml	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	mq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	ml	d0,a1		; use base-pointer
	ml	$26(a1),syscop1	; store systemcopper1 start adr
	ml	$32(a1),syscop2	; store systemcopper2 start adr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	mw	$002(a6),dmacon	; store sys dmacon
	mw	$010(a6),adkcon	; store sys adkcon
	mw	$01c(a6),intena	; store sys intena
	mw	#$007fff,$9a(a6)	; clear interrupt enable
	mw	#$007fff,$96(a6)	; clear dma channels
	mw	#$0083e0,$96(a6)	; dmacon data
	ml	#cop,$80(a6)		; copper1 start address
	mw	#$001234,$88(a6)	; copjump 1
	mw	#$007fff,$9c(a6)	; clear irq request
	mw	#$004000,$9a(a6)	; interrupt disable
	mw	#$20,$1dc(a6)

.getVBR	ml	4.w,a6
	mq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	ml	d7,VectorBase		; save it
.68000	lea	$dff000,a6


InitScreens	ml	#GameScreen+380160,d0		; init GameScreen
	lea	GamePlane+2,a0
	bsr	InitBplLoop

	ml	#BlockScreen,d0       ; init BlockScreen
	lea	BlockPlane+2,a0
	bsr	InitBplLoop

	lea	Blocks,a0
	lea	BlockEnd,a1
	sub.l	a0,a1
	ml	a1,d0
	lsr.l	#8,d0
	lsr.l	#1,d0
	divu	#11,d0
	add	#1,d0	
	mw	d0,d1
	mulu	#11,d1
	mw	d1,lineMax
	mw	d0,d7
	lea	Blocks,a0
	lea	BlockScreen,a1
	ml	a1,a2
.copy	mq	#11-1,d6
.copyline	wblt
	ml	#-1,$44(a6)
	mw	#0,$64(a6)
	mw	#40,$66(a6)
	ml	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	mw	#[32*4*64]+[32/16],$58(a6)	; 1Block
	add.l	#512,a0
	addq.l	#4,a1
	dbf	d6,.copyline
	add.l	#44*32*4,a2
	ml	a2,a1
	dbf	d7,.copy
InitSprite:	ml	#Spritepointer,d0		; init Pointer
	lea	copsprite+2,a0
	mw	d0,4(a0)
	swap	d0
	mw	d0,(a0)

;---------------------------------------------------------- INITS

	ml	#cop,$80(a6)		; copper1 start address
	mw	#$001234,$88(a6)	; copjump 1
initVBI	ml	VectorBase(pc),a0
	ml	$6c(a0),oldVBI		; get sys VBI+VBR+Offset
	mw	#$7fff,$9a(a6)
	ml	#VBI,$6c(a0)		; kick own VBI in
	mw	#%1100000000100000,$9a(a6)	; start it

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:	lea	$dff000,a6
	ml	VectorBase(pc),a0
	mw	#$7fff,$9a(a6)
	ml	oldVBI(pc),$6c(a0)
exit:	mw	#$7fff,$9a(a6)		; disable interrupts
	mw	#$7fff,$96(a6)		; disable dmacon
	ml	syscop1(pc),$80(a6)	; restore sys copper1
	ml	syscop2(pc),$84(a6)	; restore sys copper2
	mw	dmacon(pc),d0		; restore sys dmacon
	or.w	#$8000,d0
	mw	adkcon(pc),d1		; restore sys adkcon
	or.w	#$8000,d1
	mw	intena(pc),d2		; restore interenable
	or.w	#$c000,d2
	mw	d0,$96(a6)
	mw	d1,$9e(a6)
	mw	#$7fff,$9c(a6)
	mw	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	ml	stackptr(pc),a7
;------------------------------------------------------------ SAVE TAB
	ml	$4.w,a6
	lea	dosname,a1
	mq	#0,d0
	jsr	-552(a6)
	ml	d0,a6
	beq.b	nolib	
	ml	#filename,d1
	mw	#1006,d2
	jsr	-30(a6)
	ml	d0,filehandle
	beq.b	closelib
	ml	d0,d1
	ml	#leveltab,d2
	ml	levelpointer,d3
	sub.l	#LevelTab,d3
	jsr	-48(a6)
	ml	filehandle,d1
	jsr	-36(a6)
closelib:	ml	a6,a1
	ml	$4.w,a6
	jsr	-414(a6)			
nolib:
	mq	#0,d0
	rts

	incdir	Game:

;-------------------------------------------------------- InitBplLoop

InitBplLoop:	mw	#4-1,d7
.blp	mw	d0,4(a0)
	swap	d0
	mw     d0,(a0)
	swap	d0
	addq	#8,a0
	add	#44,d0
	dbf	d7,.blp
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	cnop	0,8
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	mw	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr	DoTheFun
	bsr 	PrintSprite
;	mw	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;-------------------------------------------------------- JoyTest

DoTheFun:
	mw	rmtflag,d0
	bne.w 	secondjoy
joy:	mw	#273,ypos		; spr runterforcen
	mw	$dff00c,d0
	btst	#1,d0		; RIGHT
	bne.s	right
	btst	#9,d0		; LEFT
	bne.s	left
.testud:	mw	d0,d1
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
	clr	JoyWait
	rts

;-------------------------------------------------------- Joy rechts
right	mw	joywait,d0
	bne.s	.nop
	cmp	#432,xpos
	beq	.nop
	add	#32,xpos	
	addq	#1,BlockPos
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy links
left	mw	joywait,d0
	bne.s	.nop
	cmp	#112,xpos
	beq.b	.nop
	sub	#32,xpos	
	subq	#1,BlockPos
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy vor
forw	mw	joywait,d0
	bne.s	.nop
	cmp	#11,BlockPos
	blo	.nop
	sub	#11,BlockPos
	lea	BlockPlane+2,a0
	mq	#0,d0
	mw	BlockScreenPtr,d0
	sub	#176*32,d0
	mw	d0,BlockScreenPtr
	add.l	#Blockscreen,d0
	bsr	InitBplLoop
	st	joywait
.nop	rts

;-------------------------------------------------------- Joy zurück
backw	mw	joywait,d0
	bne.s	.nop
	mw	lineMax,d0
	mw	BlockPos,d1
	cmp	d0,d1
;	cmp	#55,BlockPos
	bge	.nop
	add	#11,BlockPos
	lea	BlockPlane+2,a0
	mq	#0,d0
	mw	BlockScreenPtr,d0
	add	#176*32,d0
	mw	d0,BlockScreenPtr
	add.l	#Blockscreen,d0
	bsr	InitBplLoop
	st	joywait
.nop	rts

;-------------------------------------------------------- Maus Rechts

rmaus	
	st	rmtflag	
	mw	gameX,d0
	beq.b	.nope
	mw	xpos,xposold
	mw	ypos,yposold
	mw	gamex,gamexold
	mw	gamey,gameyold
	mulu	#8,d0
	add	#112-32,d0
	mw	d0,xpos
	mw	d0,xposstop
	mw	ypos,d1
	sub	#64,d1
	mw	d1,ypos
	rts
.nope:
	clr	rmtflag
	rts

;-------------------------------------------------------- FEUER-KNOPF

trpl	mw	joywait,d0
	bne.w	.nop

	mq	#0,d0
	lea	Blocks,a0
	mw	Blockpos,d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	add.l	d0,a0

	mw	GameX,d0
	cmp	#44,d0
	bne.w	.nocarry
	mq	#0,d0
	mw	d0,GameX

.megacopy	lea	GameScreen,a1
	lea	GameScreen+176*32,a0
	mq	#0,d0
	mw	#35200,d0	
	mq	#11-1,d7
.copylp	wblt
	mw	#0,$64(a6)
	mw	#0,$66(a6)
	ml	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	mw	#[200*4*64]+[352/16],$58(a6)
	add.l	d0,a0
	add.l	d0,a1
	dbf	d7,.copylp
	wblt
	mw	#0,$64(a6)
	mw	#0,$66(a6)
	ml	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	mw	#[168*4*64]+[352/16],$58(a6)
	rts

.nocarry	mq	#0,d0
	mq	#0,d1
	lea	GameScreen,a1
	mw	GameX,d0
	add.l	d0,a1
	mw	gameY,d1
	lsl.l	#2,d1
	mulu	#44,d1
	add.l	d1,a1
	add.l	#30976,a1
	wblt
	mw	#0,$64(a6)
	mw	#40,$66(a6)
	ml	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	mw	#[32*4*64]+[32/16],$58(a6)
	addq	#4,GameX
	st	joywait
	mw	fireflag,d0
	beq.b	.do_it_normal
	ml	Levelpointer,a0
	ml	tabpointer,d1
	sub.l	d1,a0
	mw	blockpos,d0
	mb 	d0,(a0)
	mw	gameyold,gamey
	mw	gamexold,gamex
	mw	gamey,d1 
	lsl.l	#2,d1
	mulu	#44,d1
	ml	#GameScreen,d0		; init GameScreen
	add.l	d1,d0
	lea	GamePlane+2,a0
	bsr	InitBplLoop
	clr.l	tabpointer
	clr	fireflag	
	rts
.do_it_normal:
	ml	Levelpointer,a0
	mw	blockpos,d0
	mb 	d0,(a0)+
	ml	a0,levelpointer
.nop	rts

;------------------------------------------------------ Sprite im SelectScreen

Printsprite:	lea	Spritepointer,a0
	mw	xpos,d0		; X-coord
	mw	ypos,d1		; Y-coord
	mw	d0,d4
	mw	d1,d5
.spr	mq	#0,d3  	; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	mb	d1,(a0)	; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	add	#32,d1			; Spr Höhe
	mb	d1,4(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	mb	d0,1(a0)
	mb	d3,5(a0)
	rts


;-------------------------------------------------------- Zweite Joyroutine

secondjoy:
	mw	$dff00c,d0
	btst	#1,d0		; RIGHT
	bne.s	rechts
	btst	#9,d0		; LEFT
	bne.w	links
.testud:	mw	d0,d1
	lsr.w	d1
	eor.w	d1,d0
	btst	#0,d0		; BACK
	bne.w	zurueck
	btst	#8,d0		; FORW
	bne.w	vor
.tsttgr:	btst	#7,$bfe001		; TGR
	beq.w	feuer
	btst	#2,$dff016		; RMT
	beq.w	rechteM
	clr	JoyWait
	rts
rechts:
	mw	joywait,d0
	bne.s	.nop
	mw	gameY,d1
	cmp	#2160,d1
	bne.b	.doit
	mw	xposstop,d0		;rechte stop pos. nach d0
	mw	xpos,d1
	cmp	d0,d1
	beq	.nop
.doit
	cmp	#432,xpos
	beq	.nop
	addq	#4,GameX
	add	#32,xpos	
	sub.l	#1,tabpointer
	st	joywait
.nop	rts


links:
	mw	joywait,d0
	bne.s	.nop
	cmp	#112,xpos
	beq.b	.nop
	sub	#32,xpos
	add.l	#1,tabpointer	
	st	joywait
	subq	#4,GameX
.nop	rts

zurueck:
	mw	joywait,d0
	bne.w	.nop
	mq	#0,d1
	mw	GameY,d1
	cmp	#2160,d1
	beq.b	.nop
	ml	tabpointer,d2
	sub.l	#11,d2
	bmi.b	.nop
	ml	d2,tabpointer
	add	#32,d1
	mw	d1,gameY
	lsl.l	#2,d1
	mulu	#44,d1
	ml	#GameScreen,d0		; init GameScreen
	add.l	d1,d0
	lea	GamePlane+2,a0
	bsr	InitBplLoop
	st	joywait
.nop	rts

vor:
	mw	joywait,d0
	bne.w	.nop
	mq	#0,d1
	mw	GameY,d1
	beq.b	.nop
	sub	#32,d1
	mw	d1,gameY
	lsl.l	#2,d1
	mulu	#44,d1
	ml	#GameScreen,d0		; init GameScreen
	add.l	d1,d0
	lea	GamePlane+2,a0
	bsr	InitBplLoop
	add.l	#11,tabpointer
	st	joywait
.nop	rts

feuer:
	mq	#0,d0
	mq	#0,d1
	lea	GameScreen,a1
	subq	#4,gamex
	mw	GameX,d0
	add.l	d0,a1
	mw	gameY,d1
	lsl.l	#2,d1
	mulu	#44,d1
	add.l	d1,a1
	add.l	#30976,a1
	wblt
	mw	#0,$64(a6)
	mw	#40,$66(a6)
	ml	#$01000000,$40(a6)
	ml	a1,$54(a6)
	mw	#[32*4*64]+[32/16],$58(a6)
	st	joywait
	clr	rmtflag
	mw	xposold,xpos
	mw	yposold,ypos
	st	fireflag
	add.l	#1,tabpointer
	rts

rechtem:
	mw	xposold,xpos
	mw	yposold,ypos
	mw	gameyold,gamey
	mw	gamexold,gamex
	mw	gamey,d1 
	lsl.l	#2,d1
	mulu	#44,d1
	ml	#GameScreen,d0		; init GameScreen
	add.l	d1,d0
	lea	GamePlane+2,a0
	bsr	InitBplLoop
	clr	tabpointer
	clr	rmtflag
	clr	fireflag
	rts

;---------------------------------------------------------- Pointer

	cnop	0,8


tabpointer	dc.l	0	; Pointer fuer die veraenderungen
			; im screen
GameX	dc.w	0	; ?pos im gamescreen
GameY	dc.w	2160
gamexold	dc.w	0
gameyold	dc.w	0	
rmtflag	dc.w	0	; rechte maus gedrueckt ?
fireflag	dc.w	0
JoyWait	dc.w	0	; ist der joy wieder in der mitte ?
BlockScreenPtr	dc.w	0	; welche reihe der blocks printen ?
BlockPos	dc.w	0	; auf welcher pos der blocks sind wir ?
lineMax	dc.w	0	; max. hoehe
xpos	dc.w	112	; anfans pos fuer das sprite!
ypos	dc.w	273	; ypos des sprites
xposold	dc.w	0	; save the block xpos des sprites
xposstop	dc.w	0	; wo muss das sprite stoppen im screen
yposold	dc.w	0	; save the block ypos des sprites
stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
dosname	dc.b	"dos.library",0
filename	dc.b	"dh5:Leveltabelle01.txt",0
	cnop	0,8
filehandle	dc.l	0
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
BlockEnd	dc.b	`gnurz`

;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
GameScreen:	ds.b	4*352/8*240*10


	cnop	0,8
BlockScreen	ds.b	4*352/8*32*10

	cnop	0,8
Spritepointer:
	dc.l	0,0
	dc.l	$ffffffff,0
	dc.l	$ffffffff,0
	qrept	28
	dc.l	$C0000003,0
	endqr
	dc.l	$ffffffff,0
	dc.l	$ffffffff,0
	dc.l	0,0

levelpointer:
	dc.l	leveltab

LevelTab	ds.b	11*10000
leveltabend:
	dc.b	$ff

