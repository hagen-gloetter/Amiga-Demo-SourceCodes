;               T        T              T       T


PF1_Breite	=	352/8
PF1_Hoehe	=	288*2

PF2_Breite	=	384/8
PF2_Hoehe	=	288


	section	BallerSpiel,code_c	; code to chipmem

x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6		; get execbase
	lea	gfxname(pc),a1		; set library pointer
	moveq	#0,d0		; clear d0
	jsr	-408(a6)		; old open library
	move.l	d0,a1		; use base-pointer
	move.l	$26(a1),syscop1	; store systemcopper1 start addr
	move.l	$32(a1),syscop2	; store systemcopper2 start addr
	jsr	-414(a6)		; close library
	lea	$dff000,a6		; customregbase to a6
	move	$002(a6),dmacon	; store sys dmacon
	move	$010(a6),adkcon	; store sys adkcon
	move	$01c(a6),intena	; store sys intena
	move	#$007fff,$9a(a6)	; clear interrupt enable
	move	#$007fff,$96(a6)	; clear dma channels
	move.l	#CopperList,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable

	moveq	#4-1,d7
	move.l	#HinterGrund,d0
	lea	PF1_Planes+2(pc),a1
.bplini	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq.l	#8,a1
	swap	d0
	add.l	#PF1_Breite,d0
	dbf	d7,.bplini

;------------------------------------------------------ WAIT FOR VERTICAL BEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam
;	move	#$f00,$dff180		; Rasterzeitmessung Beginn (rot)

;---------------------------------------------------------- MAIN ROUTINE




;---------------------------------------------------------- MOUSE WAIT

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	WaitVBeam

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


	incdir	Game:
Baukasten1	include	BlockList1.s		; Blöcke vom Baukasten -1-
BaukastenCols1	include	BackColTab1.s		; Farben vom Baukasten -1-
	


;---------------------------------------------------------- Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- Copperlist

Copperlist:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3181,$90,$30c1,$92,$30,$94,$d8
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,$4200

PF1_Planes:	dc.w	$e0,0,$e2,0		; 0
	dc.w	$e4,0,$e6,0		; 1 
	dc.w	$e8,0,$ea,0		; 2
	dc.w	$ec,0,$ee,0		; 3
	dc.w	$f0,0,$f2,0		; 4

PF1_Colors	ds.w	2*16

PF2_Planes:	dc.w	$f4,0,$f6,0		; 5
	dc.w	$f8,0,$fa,0		; 6
	dc.w	$fc,0,$fe,0		; 7
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace

PlayField2:
VorderGrund:	ds.b	4*PF2_Breite*PF2_Hoehe

PlayField1:
HinterGrund:	ds.b	4*PF1_Breite*PF1_Hoehe

