;               T            T              T       T

;

	section	code,code_p

;--------------------------------------------------------------- Makros
	incdir	codes:
	include	makros/-My_Makros.s

;--------------------------------------------------------------- Start of Code
x:	KillSystem

	bsr	initColors
	bsr	FillOnce


	move.l	#copperlist,$80(a6)
	StartVBI

.maus	btst	#6,$bfe001
;	btst	#2,$dff016
	bne.b	.maus

;--------------------------------------------------------------- Recall System
	RemoveVBI
	rts

;--------------------------------------------------------------- Interrupt

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6

	bsr	Scroll8Way

	lea	$dff000,a6
	mw	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;--------------------------------------------------------------- Inits

FillOnce:	lea	Baukasten,a3
	lea	BitPlane,a1
	lea	BitPlane,a2
	moveq	#9-1,d7		; y
.y	moveq	#11-1,d6		; x
.x	moveq	#1,d0

	lsl.l	#8,d0
	add.l	d0,d0
	lea	(a3,d0.l),a0

.blt	wblt
	move.l	#-1,$44(a6)
	move	#0,$64(a6)
	move	#52,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)
	addq.l	#4,a1
	dbf	d6,.x
	add.l	#56*32*4,a2
	move.l	a2,a1
	dbf	d7,.y
	rts


initColors	lea	BaukastenCols,a1
	lea	colors,a0
	move	#$180,d0
	moveq	#16-1,d7
.clp	move	d0,(a0)+
	move	(a1)+,(a0)+
	addq	#2,d0
	dbf	d7,.clp
	rts




;--------------------------------------------------------------- HauptRoutine

Speed	dc.w	2

Scroll8Way


JoyStick:	moveq	#0,d1		; x
	moveq	#0,d2		; y
	move	$c(a6),d0		; Stick 1
.right	btst	#1,d0		; RIGHT
	beq.b	.left
	add	Speed,d1
.left	btst	#9,d0		; LEFT
	beq.b	.ud
	sub	Speed,d1
.ud	move	d0,d3
	lsr	d3
	eor	d3,d0
.back	btst	#0,d0		; BACK
	beq.b	.ahead
	add	Speed,d2
.ahead	btst	#8,d0		; FORW
	beq.b	.joyend
	sub	Speed,d2
.joyend	btst	#7,$bfe001		; SPEED + 
	bne.b	.noFast
	move	#4,speed
	bra.b	JoyEnd
.noFast	move	#2,speed

JoyEnd	move	LevelX(pc),d3
	move	LevelY(pc),d4
	move	d3,oldX
	move	d4,oldY

Kill_Overflows	add	d3,d1		; new Xpos
	bpl.b	.x1
	moveq	#0,d1		; x min
.x1	cmp	#320*9,d1
	ble.b	.x2		; x max
	move	#320*9,d1
.x2	move	d1,LevelX

	add	d4,d2		; new Y pos
	bpl.b	.y1
	moveq	#0,d2		; x min
.y1	cmp	#256*9,d2
	ble.b	.y2		; x max
	move	#256*9,d2
.y2	move	d2,LevelY

;	add	#32,d1	; nix left & upper column
;	add	#32,d2	; (einfacher zu rechnen no minus )

SoftScrollX	move	d1,d0
	not	d0
	and	#$f,d0	; get softscroll
	move	d0,d3
	lsl	#4,d3	; gen. odd planes
	or	d3,d0
	move	d0,softscroll+2
	lsr	#3,d1	; pix -> byte
	move.l	d1,d0	; store d1->d0 
	
SoftScrollY	divu	#11*32,d2	; durch geshöhe
	swap	d2
	ext.l	d2
	move	d2,d3	; store d2->d3

	move	d2,d4	; d2*56
	lsl	#6,d2	;	 *64
	lsl	#3,d4	;	 *8
	sub	d4,d2	;	=*56 = new offset
	lsl.l	#2,d2	; mulu	#4,d2

writeIntoCopper	move.l	#Bitplane,d4

	add.l	d4,d1	; bpladr + xoffset /no yoffset
	add.l	d4,d0
	add.l	d2,d0	; bpladr + xoffset + yoffset

	moveq	#4-1,d7
	lea	Planes1+2,a0
	lea	Planes2+2,a1
.bplp	mcop	d0,a0	; bplane + yoffset
	mcop	d1,a1	; warp + no yoffset
	addq.l	#8,a0
	addq.l	#8,a1
	add.l	#56,d0
	add.l	#56,d1
	dbf	d7,.bplp

CopperWarp	move	#352+$31,d2
	sub	d3,d2
	cmp	#255,d2
	ble.b	.nowait
.wait	move.l	#$ffe1fffe,warp
	and	#$ff,d2
	move.b	d2,warp+4
	bra.b	.softend
.nowait	move.l	#01040010,warp
	move.b	d2,warp+4
.softend

HardScrollX	move	LevelX(pc),d0
	move	LevelY(pc),d1
	move	LastX(pc),d2
	move	LastY(pc),d3

.demand_to_prt	move	d0,d4
	and	#$ffe0,d2	; old 		32 bit
	and	#$ffe0,d4	; new

	cmp	d4,d2	; cmp neu-alt

	bmi.b	.x_blt_right
	beq.b	HardScrollY	; x pos not changed

.x_blt_left	lsr	#3,d0	; get byte offset
	subq	#6,d0
	bmi.w	.overflows	; kleener 0 spalte ?
	move	d0,x_col
	move	LevelX(pc),LastX
	move	y_col(pc),y_for_x
	move	#2*2,x_cnt
	bra.b	HardScrollY

.x_blt_right	lsr	#3,d0
	add	#40,d0
	cmp	#10*320/8,d0	; greeser 400 spalte ?
	bge.b	.overflows
	move	d0,x_col
	move	LevelX(pc),LastX
	move	y_col(pc),y_for_x
	move	#2*2,x_cnt
	bra.b	HardScrollY

.overflows	move	#-1,x_cnt	; don't print out of plane

;--------------------------------------------------------- Hardscroll y
;	levely d1   lasty d3

HardScrollY	move	y_col(pc),d4
	lsr	#5,d1
	cmp	d1,d3

	bmi.b	.x_blt_down
	beq.b	.endY	; x pos not changed

.x_blt_up	subq	#1,d4
	bpl.b	.nomax
	moveq	#11-1,d4
	bra.b	.nomax

.x_blt_down	addq	#1,d4
	cmp	#11,d4
	blo.b	.nomax
	moveq	#0,d4
	bra.w	.nomax

.nomax	move	d4,y_col
	move	d4,y_for_x

.endy

;--------------------------------------------------------- y latte printen

.print_x	move	x_cnt(pc),d7		; printen?
	bmi.b	.nix_x_to_do		; ja-nein
	move	x_col(pc),d0		; welche spalte ?
	move	x_tab(PC,d7.w),d6	; =dbf
	subq	#2,d7		; dbf-2
	move	d7,x_cnt		; copy back
	
	lea	Bitplane,a2
	ext.l	d0
.SpaltenLoop	moveq	#0,d1
	move	d4,d1
	cmp	#11,d1
	blo.b	.go
	sub	#11,d1
	moveq	#-1,d4		; -1+1=0
.go	addq	#1,d4
	add	d1,d1
	add	d1,d1
	move.l	y_mulu(pc,d1.w),d1
	add.l	d0,d1

	lea	(a2,d1.l),a1
	lea	Baukasten+10*512,a0	; rudern
	wblt
	move	#0,$64(a6)
	move	#52,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)
	
	dbf	d6,.SpaltenLoop
	move	d4,y_for_x

.nix_x_to_do	rts

LastX	dc.w	0
LastY	dc.w	0

y_for_x	dc.w	0	; =ycol for y add

x_col	dc.w	0
x_cnt	dc.w	-1	; bei 1. mal nix
x_tab	dc.w	4-1,4-1,3-1	; -1 wegen dbf  =11

y_col	dc.w	0
y_cnt	dc.w	-1	; bei 1. mal nix
y_tab	dc.w	4-1,4-1,4-1,3-1; -1 wegen dbf = 14

y_mulu	dc.l	00*7168,01*7168,02*7168,03*7168,04*7168,05*7168
	dc.l	06*7168,07*7168,08*7168,09*7168,10*7168,11*7168





LevelX	dc.w	0
LevelY	dc.w	0
oldX	dc.w	0
oldy	dc.w	0


;--------------------------------------------------------------- SysPointer
		pop
stackptr		dc.l	0
syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase		dc.l	0
vbr_exception		dc.l	$4e7a7801
		rte	; back to user state code




	section	Baukasten,data_c

		incdir
Baukasten:	incbin	Game:raw/BlockList_V2.0.b
BaukastenCols	incbin	Game:raw/Palette_HinterG_1.raw


;---------------------------------------------------------- CopperListe
	section	Copperlist,data_c

		pop
Copperlist:		dc.w	$106,$20,$1fc,%0001100 ; 64spr
		dc.w	$180,888,$182,$555
		dc.w	$8e,$3181,$90,$30c1
		dc.w	$104,$10

		dc.w	$92,$30,$94,$d8
		dc.w	$108,12+3*56,$10a,12+3*56

Sprite		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$100,$4200
Colors		ds.l	16
SoftScroll		dc.w	$102,0
Planes1		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
Warp		dc.w	$30e1,$fffe,$3007,$fffe
;		dc.w	$180,$0987		;kontrollfarbe
Planes2		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
		dc.l	$fffffffe


BitPlane	dcb.b	56*351*4,$01
	dcb.b	56*4,$ff
	ds.b	40


