;               T        T              T       T


;---------------------------------------------------------- Definitionen

PF1_Breite	=	352/8	; 44
PF1_Hoehe	=	320*2

PF2_Breite	=	384/8	; 48
PF2_Hoehe	=	288


BPLCon0	= 	%0000010000010001
;		 abcdefghijklmnop
;	 a = HIRES
;	 b = BPU2 \
;	 c = BPU1  } select num of bitplanes, from 0 thru 7
;	 d = BPU0 / 
;	 e = HOMOD - old HAM, and HAM8 AGA (if bit 4 is set)
;	 f = DBLPF - double playfield
;	 g = COLOR - Composite video (Genlock)
;	 h = GAUD  - Composite audio
;	 i = ?
;	 j = superhires 1280x 35ns
;	 k = BPLHWRM - screen black and white, no copcolors
;	 l = 8 planes (then bits 12-14 must be 0)
;	 m = LPEN - Light pen
;	 n = LACE - Interlace mode
;	 o = ERSY - External resync
;	 p = ECSENA Enable bplcon3 register (ECS-AGA)



BPLCon2	= 	%0000000001000000
;		 abcdefghijklmnop
;	 a = -
;	 b = \  Select one of the 8 BitPlanes
;	 c =  } in ZDBPEN genlock mod
;	 d = /
;	 e = Use BITPLANEKEY - use bitplane as genlock bits
;	 f = Use COLORKEY - colormapped genlock bit
;	 g = Kill ExtraHalfBrite (for a normal 6bpl pic)
;	 h = Enable 14Mhz clock (not sure, can be 07)
;	 i = All color tabs are reads (not sure, can be 08)
;	 j = PField 2 priority over PField 1
;	 k = \
;	 l =  } PField 2 sprite priority
;	 m = /
;	 n = \
;	 o =  } PField 1 sprite priority
;	 p = /


bplcon3	= 	%0000000000000000 
;		 abcdefghijklmnop
;	 a = \
;	 b =  } LOCT palette select 256
;	 c = /
;	 d = PF2OF0 \
;	 e = PF2OF1  } second playfield's offset in coltab
;	 f = PF2OF2 /
;	 g = palette high or low nibble colour
;	 h = AGA SPRES0 \
;	 i = AGA SPRES1 /sprite hires,lores,superhires
;	 j = ECS BRDRBLNK Border blank
;	 k = ECS BRDRTRAN Border opaque
;	 l = ?
;	 m = ZDCLKEN - zd pin outputs a 14mhz cloc
;	 n = EXTBLKZD - external blank ored into trnsprncy
;	 o = EXTBLNKEN - external blank enable


bplcon4	= 	%0000000000000000 
;		 aaaaaaaabcdefghi
;	 a = bits 8 to 15: switch colours
;	 b = OSPRM4 \
;	 c = OSPRM4  \
;	 d = OSPRM4  / CHOOSE ODD SPRITE PALETTE
;	 e = OSPRM4 /
;	 f = ESPRM4 \
;	 g = ESPRM5  \
;	 h = ESPRM6  / CHOOSE EVEN SPRITE PALETTE
;	 i = ESPRM7 /




DMACon0	=	%1000001111100000
;		 abcdefghijklmmmm
;	a = set/clear
;	b = Blitter busy
;	c = Blitter zero
;	d = -
;	e = -
;	f = Blitter priority over cpu	
;	g = Enable DMA activity (always set this!)
;	h = Bitplane enable
;	i = Copper enable
;	j = Blitter enable
;	k = Sprite enable
;	l = Disk enable
;	m = Audio channels enable



BG_BlockLine0	=	00*PF1_Breite*32*4
BG_BlockLine1	=	01*PF1_Breite*32*4
BG_BlockLine2	=	02*PF1_Breite*32*4
BG_BlockLine3	=	03*PF1_Breite*32*4
BG_BlockLine4	=	04*PF1_Breite*32*4
BG_BlockLine5	=	05*PF1_Breite*32*4
BG_BlockLine6	=	06*PF1_Breite*32*4
BG_BlockLine7	=	07*PF1_Breite*32*4
BG_BlockLine8	=	08*PF1_Breite*32*4
BG_BlockLine9	=	09*PF1_Breite*32*4
BG_BlockLine10	=	10*PF1_Breite*32*4
BG_BlockLine11	=	11*PF1_Breite*32*4
BG_BlockLine12	=	12*PF1_Breite*32*4
BG_BlockLine13	=	13*PF1_Breite*32*4
BG_BlockLine14	=	14*PF1_Breite*32*4
BG_BlockLine15	=	15*PF1_Breite*32*4
BG_BlockLine16	=	16*PF1_Breite*32*4
BG_BlockLine17	=	17*PF1_Breite*32*4
BG_BlockLine18	=	18*PF1_Breite*32*4
BG_BlockLine19	=	19*PF1_Breite*32*4


	incdir	Game:


;---------------------------------------------------------- Makros

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm

;---------------------------------------------------------- START OF GAMECODE

	section	BallerSpiel,code_c	; code to chipmem

x:
	move.l	a7,stackptr		; store system stackpointer
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
;	move.l	#CopperList,$80(a6)	; copper1 start address
;	move	#$001234,$88(a6)	; copjump 1
	move	#DMACon0,$96(a6)	; dmacon data
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
	lea	Baukasten1(pc),a4
	lea	BG_BlockLine9+Hintergrund,a1
	moveq	#0,d0
	move.l	a1,a3
	lea	Level1_Start-110,a2
	moveq	#10-1,d6
.ylp	moveq	#11-1,d7
.xlp	move.b	(a2)+,d0
	lsl	#8,d0
	add	d0,d0
	lea	(a4,d0),a0
	wblt
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
.copyWholeLineDown
	lea	BG_BlockLine9+Hintergrund,a0
	lea	BG_BlockLine19+Hintergrund,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*4*64]+[PF1_Breite/2],$58(a6)
	
Fill_PlayField2_Once:
	move.l	#Screen1,d0
	lea	PF2_Planes+2,a0
	moveq	#4-1,d7
.initbpl	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq.l	#8,a0
	add.l	#PF2_Breite,d0	
	dbf	d7,.initbpl

;---------------------------------------------------------- Kick our copper in


	move.l	#CopperList,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1


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
	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	bsr.w	ActionPlayfield

;-------------------------------------------------------- MAIN ROUTINE
	bsr.w	HinterGrundScroller
	move	#$00f,$dff180		; Rasterzeitmessung Ende (grün)
	wblt
	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte




ActionPlayfield:
	lea	VorderGrund,a0		; Double Buffering
	movem.l	(a0),d0-d1
	exg.l	d1,d0
	movem.l	d0-d1,(a0)
	moveq	#4-1,d7
	lea	PF2_Planes+2,a0
.dbuff	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	addq.l	#8,a0
	add.l	#PF2_Breite,d0	
	dbf	d7,.dbuff
	rts

;---------------------------------------------------------- MAIN INCLUDES

HG_Scroller	include	PF1_Scroller_V1.0.s	; Code vom HinterGrundScroller

ScrollSpeed	dc.w	1		; Speed vom Hintergrund

;-----------------------------------------------------------------------



LineOffSets	include	BG_LineOffsets.i	; Direkt jump offset Adrs .l
				; für den Hintergrundscroller


Level1_Tab:	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
	include	Level1_Tab.i
Level1_Start:	even


TestShip	incbin	TestShip_8p.b		; ShipAnim 8 phasen
TestShipCols	include	TestShipCols.i		; TestCols

Baukasten1	incbin	BlockList1.b		; Blöcke vom Baukasten -1-
BaukastenCols1	include	BackColTab1.i		; Farben vom Baukasten -1-


;---------------------------------------------------------- Pointer

VorderGrund:	dc.l	Screen1,Screen2

stackptr	dc.l	0
syscop1	dc.l	0
syscop2	dc.l	0
intena	dc.w	0
dmacon	dc.w	0
adkcon	dc.w	0
gfxname	dc.b	'graphics.library',0,0
oldVBI	dc.l	0
VectorBase	dc.l	0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d7
	rte			; back to user state code

;---------------------------------------------------------- Copperlist

Copperlist:	dc.w	$106,0,$1fc,0
	dc.w	$180,0,$182,$555
	dc.w	$8e,$2171,$90,$41d1,$92,$30,$94,$d8
	dc.w	$102,0
	dc.w	$108,PF1_Breite*3	; BplMod even
	dc.w	$10a,PF1_Breite*3	; BplMod odd
	dc.w	$1f07,$fffe
	dc.w	$100,BPLCon0		; BplCON0
	dc.w	$104,BPLCon2		; BplCon2
	dc.w	$106,BPLCon3		; BplCon3
	dc.w	$10c,BPLCon4		; BplCon4
	
PF1_Planes:	dc.w	$e0,0,$e2,0		; 0
	dc.w	$e8,0,$ea,0		; 2
	dc.w	$f0,0,$f2,0		; 4
	dc.w	$f8,0,$fa,0		; 6
PF1_Colors	ds.w	2*16

PF2_Planes:	dc.w	$e4,0,$e6,0		; 1
	dc.w	$ec,0,$ee,0		; 3
	dc.w	$f4,0,$f6,0		; 5
	dc.w	$fc,0,$fe,0		; 7
	dc.l	$fffffffe

;---------------------------------------------------------- BitplaneSpace


Screen1:	ds.b	4*PF2_Breite*PF2_Hoehe
Screen2:	ds.b	4*PF2_Breite*PF2_Hoehe

HinterGrund:	ds.b	4*PF1_Breite*PF1_Hoehe
