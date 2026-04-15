;TOSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
;               T        T              T       T

;	converts all anim phases to one file & from int to raw

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
	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

	bsr	toraw

.bplini	move.l	#Bitplane,d0
	lea	BitPlanes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI		; get sys VBI+VBR-Offset
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


;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	cnop	0,8
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- Pointer

	cnop	0,8
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
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
BitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

	cnop	0,8
Bitplane:	ds.b	10240


toRaw:	lea	Pics,a0		
	lea	Rawbuffer,a1

	move	#32-1,d6
.lp	moveq	#4-1,d7	
.copylp	wblt
	move	#12,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*64]+[32/16],$58(a6)
	addq	#4,a0
	add	#128,a1
	dbf	d7,.copylp
	dbf	d6,.lp

RawBuffer	ds.b	512*32


	incdir	game:iff/PredatorAnim/
Pics:	inciff	vor1
	inciff	vor2
	inciff	vor3
	inciff	vor4
	inciff	vor5
	inciff	vor6
	inciff	vor7
	inciff	vor8
	inciff	rück1
	inciff	rück2
	inciff	rück3
	inciff	rück4
	inciff	rück5
	inciff	rück6
	inciff	rück7
	inciff	rück8
	inciff	right1
	inciff	right2
	inciff	right3
	inciff	right4
	inciff	right5
	inciff	right6
	inciff	right7
	inciff	right8
	inciff	left1
	inciff	left2
	inciff	left3
	inciff	left4
	inciff	left5
	inciff	left6
	inciff	left7
	inciff	left8
	inciffp	vor1
	

