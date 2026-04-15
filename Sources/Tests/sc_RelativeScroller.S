
; Absolute Overscan-Blitter-16x16-Scroller
; This Scroller takes max. 2 Rasterlines !

; Der Scroller beachtet die Buchstabenbreite ab A bis Z !
; Sonderzeichen sind default-mäßig 15pix breit, sonst überarbeitet
; sich der Tabellensklave noch !

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
.bplini	move.l	#ScrollScreen+2,d0
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

	move	#10000,d7
.lp	dbf	d7,.lp
	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE


	bsr	scroller

	move	#$00,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

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
	dc.w	$180,$000,$182,$aaa
	dc.w	$8e,$a061,$90,$b0e1,$92,$30,$94,$d8
	dc.w	$102,0,$104,$10,$108,2,$10a,8
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.l	$fffffffe

Scroller:			; d0-d1/a0-a3
	subq	#2,sc_counter	; nix byte! pixel
	bpl.b	.soft
.hard:	moveq	#0,d0
	lea	sc_Font(pc),a0
	move.l	sc_TxtPtr(pc),a2
	lea	sc_widthtab(pc),a3
	move.b	(a2)+,d0
	bne.b	.no0
	lea	sc_Text(pc),a2
	move.b	(a2)+,d0
.no0:	move.l	a2,sc_TxtPtr
	sub	#$20,d0
	move	d0,d1
	lsl	#$05,d0
	lea	(a0,d0.w),a0		; offset zur quelle addieren
	lea	ScrollScreen+46(pc),a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#$0000002c,$64(a6)	; 44
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[16/16],$58(a6)
.width:	sub	#$20,d1
	bpl.b	.go
	moveq	#0,d1
.go:	move.b	(a3,d1.w),d1
	move	d1,sc_counter		; Charwidth
.soft	lea	ScrollScreen(pc),a1
	lea	2(a1),a0
.wblt2:	btst	#14,$02(a6)
	bne.b	.wblt2
	move	#0,$66(a6)
	move	#$e9f0,$40(a6)		; softshift
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[368/16],$58(a6)
	rts

sc_counter:	dc.w	0

sc_TxtPtr:	dc.l	sc_Text
sc_Text:
	DC.B	`(C)  BY HAZE OF MOTION                 `
	dc.b	0
	even

		incdir	`df1:`
sc_Font:	incbin	`tests/sc_Font16x16x1.raw`

sc_widthtab:	; 26 Werte ( Space + 25 Buchstaben)
	dc.b	15,7
	rept	26
	dc.b	15
	endr

ScrollScreen:	ds.b	48*50+2

