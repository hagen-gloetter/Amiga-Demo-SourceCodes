


	section	code,code_c		; code to chipmem
x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0			; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1			; use base-pointer
	move.l	$26(a1),syscop1		; store systemcopper1 start addr
	move.l	$32(a1),syscop2		; store systemcopper2 start addr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon		; store sys dmacon
	move	$010(a6),adkcon		; store sys adkcon
	move	$01c(a6),intena		; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
.bplini	move.l	#Bitplane,d0
	lea	Planes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)

;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:
	lea	$dff000,a6
	move.l	VectorBase,a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon,d0		; restore sys dmacon
	move	adkcon,d1		; restore sys adkcon
	move	intena,d2		; restore interenable
	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$c000,d2
	move	d0,$96(a6)
	move	d1,$9e(a6)
	move	#$7fff,$9c(a6)
	move	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	moveq	#0,d0
	rts


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr.w	TypeWriter

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- TYPE WRITER

lf	=	8			; Linefeed (Platz bis zur next zeile)
ml	=	256/lf			; max Lines ( wieviele lines printen ?)

TypeWriter:
	move	freezer(pc),d0
	beq	.go
	subq	#1,d0
	btst	#2,$dff016		; rmt skips wait
	bne.b	.noskip
	moveq	#0,d0
.noskip	move	d0,freezer
	rts
.go	lea	Bitplane+10(pc),a1
	lea	Font(pc),a2
	move	xoffset(pc),d1
	move	yoffset(pc),d2
	add	d1,a1
	add.l	d2,a1
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
	cmp	#59,d1
	bne.b	.nojump
	moveq	#0,d1
	add	#lf*80,d2		; y = y+1
	cmp	#640*ml,d2
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
	move.l	a0,TxtPtr
	rts

.cls:	btst	#14,$02(a6)		; zu löschender Screen in a1
	bne.b	.cls
	moveq	#0,d0
	move	d0,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	#Bitplane,$54(a6)
	move	#[256*64]+[640/16],$58(a6)
	move	d0,xoffset
	move	d0,yoffset
	rts


TxtPtr:		dc.l	Text
freezer:	dc.w	0		; wait for refresh
xoffset:	dc.w	0		; writer x offset
yoffset		dc.w	0		; writer y offset
;Font		include `8x8HexFont.hex`
Font		include `8x8Fantasy.hex`

;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d0
		rte				; back to user state code

;---------------------------------------------------------- Copperlist

cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$aaa
	dc.w	$8e,$3081,$90,$30c1,$92,$3c,$94,$d4
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$9200
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

Bitplane:	ds.b	20480

Text:	; Sonderzeichen:	0 = Ende
	;			1 = Cls
	;			2 = Wait,Sekunden

	dc.b	`00000000001111111111222222222223333333334444444444555555555`
	dc.b	`01234567890123456789012345678901234567890123456789012345679`
	dc.b	2,100,1
	dc.b	`                                                           `
	dc.b	`               Keep your eye on the twisted                `
	dc.b	`               ----------------------------                `
	dc.b	`                                                           `
	dc.b	`             turn on the tube, what do I see ?             `
	dc.b	`           a bunch of hateful people talking to me         `
	dc.b	`             the crap they say's been heard before         `
	dc.b	`          and that's what started up the 2nd World War     `
	dc.b	`                                                           `
	dc.b	`             so many people see what's going on            `
	dc.b	`                   heads should be lifted                  `
	dc.b	`                                                           `
	dc.b	`                 keep your eye on the twisted              `
	dc.b	`                   we've seen it all before                `
	dc.b	`                 little minds can't be shifted             `
	dc.b	`                watch out they are back for more           `
	dc.b	`                                                           `
	dc.b	`              they call it pride to wave the flag          `
	dc.b	`           shaving the hair off their brainless heads      `
	dc.b	`               I think the world has seen enough           `
	dc.b	`   there is too much talking now it's time to get tough    `
	dc.b	`                                                           `
	dc.b	`            too many people know what's going down         `
	dc.b	`                     heads should be lifted                `
	dc.b	`                                                           `
	dc.b	`                  keep your eye on the twisted             `
	dc.b	`                     we've seen it all before              `
	dc.b	`                  little minds can't be shifted            `
	dc.b	`                 watch out they are back for more          `
	dc.b	2,100,1
	dc.b	`                                                           `
	dc.b	`      hey twisted - what's in your head - so twisted       `
	dc.b	`     hey twisted - go clear your mind - you're misled      `
	dc.b	`                                                           `
	dc.b	`     steps should be taken to stop what they're makin'     `
	dc.b	`     heads should be lifted... to see what's going on      `
	dc.b	`                                                           `
	dc.b	`               they spread their mental disease            `
	dc.b	`   ignorance needs a leader to make their mass increase    `
	dc.b	`                                                           `
	dc.b	`               so keep your eye on the twisted...          `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	`     Lyrics taken from "Keep your eye on the twisted"      `
	dc.b	`                    by Pink Cream 69                       `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	`                                                           `
	dc.b	2,10,1
	dc.b	0,0,0,0

