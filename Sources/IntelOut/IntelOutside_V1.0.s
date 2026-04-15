
;		 Intel Outside
; or how to show a pc-lamer that he isn't welcome
; by Dukeof Pleasure in '93

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

;------------------------------------------------------ INIT BITPLANE

initbpl	move.l	#Bitplane,d0
	lea	Planes+2(pc),a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- FADE PICTURE IN

	lea	col+2,a0
fadeIn:	move	#300,d7
.lp	lea	$dff000,a6
.wait	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	.wait
	dbf	d7,.lp
	add	#$111,(a0)
	cmp	#$fff,(a0)
	bne.b	fadeIn

;---------------------------------------------------------- HOLD PICTURE

hold:	move	#6000,d7
.lp	lea	$dff000,a6
.wait	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	.wait
	dbf	d7,.lp

;---------------------------------------------------------- FADE PICTURE OUT

fadeOut:move	#300,d7
.lp	lea	$dff000,a6
.wait	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	.wait
	dbf	d7,.lp
	sub	#$111,(a0)
	cmp	#$000,(a0)
	bne.b	fadeOut

;---------------------------------------------------------- EXIT TO SYSTEM

	lea	$dff000,a6
	move	#$7fff,$9a(a6)		; disable interrupts
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

;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- Copperlist


cop:	dc.w	$180,0,$106,0,$1fc,0
col:	dc.w	$182,$000
	dc.w	$8e,$4f81,$90,$0cc1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$1200
Planes:	dc.w	$e0,0,$e2,0
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

		incdir	dh1:code/sources/
Bitplane:	incbin `intelout/iout320x192x1.raw`
