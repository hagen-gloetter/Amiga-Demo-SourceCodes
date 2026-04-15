;               T        T              T       T


;---------------------------------------------------------- Definitionen

PF1_Breite	=	352/8
PF1_Hoehe	=	320*2

PF2_Breite	=	384/8
PF2_Hoehe	=	288


;---------------------------------------------------------- Makros

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm



;---------------------------------------------------------- START OF GAMECODE

	section	BallerSpiel,code_c	; code to chipmem

x:	move.l	a7,stackptr		; store system stackpointer
	movem.l	d0-d7/a0-a6,-(a7)	; store registers
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

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; Supervisor
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6

;---------------------------------------------------------- INITS

Init_PlayField1:			; Background inizialisieren
	moveq	#4-1,d7
	move.l	#HinterGrund+320*PF1_Breite*4,d0
	lea	PF1_Planes+2(pc),a1
.bplini	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq.l	#8,a1
	swap	d0
	add.l	#PF1_Breite,d0
	dbf	d7,.bplini
Init_PlayField1_Colors:
	lea	PF1_Colors(pc),a1
	lea	BaukastenCols1(pc),a0
	moveq	#16-1,d7
.colorlp	move.l	(a0)+,(a1)+
	dbf	d7,.colorlp

Fill_PlayField1_Once:
	lea	Baukasten1(pc),a0
	lea	PlayField1+320*PF1_Breite*4,a1
	lea	Level1_Start-11(pc),a2
	move.l	a1,a3

	moveq	#9-1,d6
.ylp	moveq	#11-1,d7
	move.l	a1,$54(a6)
.xlp	wblt
	move	#0,$64(a6)			; BltAmod
	move	#PF1_Breite-32/8,$66(a6)	; BltDmod
	move.l	#$09f00000,$40(a6)		; BltCon 0+1
	move.l	#-1,$44(a6)			; Bltmask A+D
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[32/16],$58(a6)
	addq.l	#4,a1
	dbf	d7,.xlp	
	add.l	#32*4*PF1_Breite,a3
	move.l	a3,a1
	dbf	d6,.ylp	

;---------------------------------------------------------- INITS END


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
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
.exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	move.l	syscop1(pc),$80(a6)	; restore sys copper1
	move.l	syscop2(pc),$84(a6)	; restore sys copper2
	move	dmacon(pc),d0		; restore sys dmacon
	move	adkcon(pc),d1		; restore sys adkcon
	move	intena(pc),d2		; restore interenable
	or.w	#$8000,d0
	or.w	#$8000,d1
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

VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE


;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte



	incdir	Game:

Level1_Tab:	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	include	Level1_Tab.s
Level1_Start:	even
Baukasten1	include	BlockList1.s		; Blöcke vom Baukasten -1-
BaukastenCols1	include	BackColTab1.s		; Farben vom Baukasten -1-


;---------------------------------------------------------- Pointer

LevelPointer	dc.l	Level1_Start-11


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
	rte			; back to user state code

;---------------------------------------------------------- Copperlist

Copperlist:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$3171,$90,$30d1,$92,$30,$94,$d8
	dc.w	$102,0,$104,$10
	dc.w	$108,PF1_Breite*3	; BplMod even
	dc.w	$10a,PF1_Breite*3	; BplMod odd
	dc.w	$100,$4200		; BplCON0

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
