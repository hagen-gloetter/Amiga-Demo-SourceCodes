


	section	code,code_p		; code to chipmem
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
.eff_init:
	move.l	#blk_Screen,d0
	lea	eff_pl+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

	lea	eff_pl,a0
	lea	eff_cop,a1
	move.l	#$2fe1fffe,d0
	move.l	#$3007fffe,d1
	movem.l	(a0),d2-d3
	moveq	#20-1,d7
.eff_lp	movem.l	d0-d3,(a1)
	add.l	#$10000000,d0
	add.l	#$10000000,d1
	add	#16,a1
	dbf	d7,.eff_lp

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

;-------------------------------------------------------- MAIN ROUTINE
	move	eff_wait(pc),d0
	beq.b	.doeff
	subq	#1,d0
	move	d0,eff_wait
	bra.w	.end
	
.doeff:	lea	blocks,a0
	lea	blk_Screen+76,a1
	move	eff_counter,d0
	move	eff_flag,d1
	bne.b	.down
.up:	cmp	#10,d0
	beq.b	.ofl
	move	d0,d1
	add	d0,d0
	add	d0,d0
	addq	#1,d1
	move	d1,eff_counter
	lea	(a0,d0.w),a0
	bra.b	.wblt
.ofl:	bchg	#0,eff_flag
	add	d0,d0
	add	d0,d0
	lea	(a0,d0.w),a0
	bra.b	.wblt
.down:	cmp	#0,d0
	beq.b	.ofl
	move	d0,d1
	add	d0,d0
	add	d0,d0
	subq	#1,d1
	move	d1,eff_counter
	lea	(a0,d0.w),a0
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#40,$64(a6)
	move	#76,$66(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[32/16],$58(a6)
.multi	lea	blk_Screen+76,a0
	lea	blk_Screen,a1
	moveq	#19-1,d7
.wblt2:	btst	#14,$02(a6)
	bne.b	.wblt2
	move	#76,$64(a6)
	move	#76,$66(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[32/16],$58(a6)
	lea	4(a1),a1
	dbf	d7,.wblt2
	move	#1,eff_wait
.end
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

eff_wait	dc.w	0
eff_flag	dc.w	0
eff_counter	dc.w	0
eff_pl		dc.w	$e0,0,$e2,0

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

		incdir	`Duke_Sources_6:`


;---------------------------------------------------------- Copperlist

	section	chipdata,data_c
		incdir	dh1:code/sources/
Blocks:		incbin	`intro4/muster352x16x1.raw`

cop:	dc.w	$106,0,$1fc,0
	dc.w	$180,$555,$182,$888
	dc.w	$8e,$3181,$90,$30c1,$92,$3c,$94,$d4
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$9200
Planes:	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
eff_cop	ds.w	8*20
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

	section	Bitplanes,bss_c		; code to chipmem

blk_Screen:	ds.b	80*16
