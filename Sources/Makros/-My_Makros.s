;               T        T              T       T

;  Makros by Mirko&Hagen of Motion

;--------------------------------------------------------------------

mb	macro					; move.b
	move.b	\1,\2
	endm

;--------------------------------------------------------------------

mw	macro					; move.w
	move.w	\1,\2
	endm

;--------------------------------------------------------------------

ml	macro					; move.l
	move.l	\1,\2
	endm

;--------------------------------------------------------------------

mq	macro					; moveq
	move.l	\1,\2
	endm

;--------------------------------------------------------------------

mcop	macro					; move to cop
	mw	\1,4(\2)
	swap	\1
	mw	\1,(\2)
	swap	\1
	endm	

;--------------------------------------------------------------------

aq	macro					; addq
	addq	\1,\2
	endm

;--------------------------------------------------------------------

aql	macro					; addq.l
	addq.l	\1,\2
	endm

;--------------------------------------------------------------------

sq	macro					; subq
	subq	\1,\2
	endm

;--------------------------------------------------------------------

sql	macro					; subq.l
	subq.l	\1,\2
	endm

;--------------------------------------------------------------------

pop	macro					; cnop
	cnop	0,8
	endm

;--------------------------------------------------------------------

wblt:	macro					; wblt
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

;--------------------------------------------------------------------

KillSystem:	macro
	ml	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	ml	$4.w,a6		; get execbase
	lea	gfxname,a1		; set library pointer
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
	mw	#$001234,$88(a6)	; copjump 1
	mw	#$0083e0,$96(a6)	; dmacon data
	mw	#$007fff,$9c(a6)	; clear irq request
	mw	#$004000,$9a(a6)	; interrupt disable
	endm

;--------------------------------------------------------------------

StartVBI:	macro
	ml	4.w,a6
	mq	#$f,d0
	and.b	$129(a6),d0		; are we at least at a 68010?
	beq.b	.68000
	lea	vbr_exception,a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	ml	d7,VectorBase		; save it
.68000	lea	$dff000,a6

	ml	VectorBase,a0
	ml	$6c(a0),oldVBI		; get sys VBI+VBR-Offset
	mw	#$7fff,$9a(a6)
	ml	#VBI,$6c(a0)			; kick own VBI in
	mw	#%1100000000100000,$9a(a6)	; start it
	endm

;--------------------------------------------------------------------

RemoveVBI:	macro
	lea	$dff000,a6
	ml	VectorBase,a0
	mw	#$7fff,$9a(a6)
	ml	oldVBI,$6c(a0)
exit:	mw	#$7fff,$9a(a6)		; disable interrupts
	mw	#$7fff,$96(a6)		; disable dmacon
	ml	syscop1,$80(a6)	; restore sys copper1
	ml	syscop2,$84(a6)	; restore sys copper2
	mw	dmacon,d0		; restore sys dmacon
	or.w	#$8000,d0
	mw	adkcon,d1		; restore sys adkcon
	or.w	#$8000,d1
	mw	intena,d2		; restore interenable
	or.w	#$c000,d2
	mw	d0,$96(a6)
	mw	d1,$9e(a6)
	mw	#$7fff,$9c(a6)
	mw	d2,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	ml	stackptr,a7
	mq	#0,d0
	endm

;--------------------------------------------------------------------
