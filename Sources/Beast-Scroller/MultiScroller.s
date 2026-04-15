	section x,code_c
x:
	movem.l	d0-d7/a0-a6,-(a7)
	move	#$4000,$dff09a	;Multitasking aus
	move	#$0020,$dff096
	move.l	#$ffffffff,$dff044
	bsr.w	ZaunInit
	bsr.w	initPic
	bsr.w	initCol
	bsr.w	initLogo
	move.l	#Cop,$dff084	; Copperlist
	clr	$dff08a
	bsr.w	mt_init
	bsr.b	init			; Call Init to mount the IRQ

mloop:	btst	#6,$bfe001		; Your non IRQ-Rout
	bne.b	mloop

	bsr.w	out			; Call Out to remove the IRQ
	bsr.w	mt_off
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts


***********************************************************

irq:
	movem.l	d0-d7/a0-a6,-(a7)
	bsr.w	Dancer
	bsr.w	Scroller1
	bsr.w	Scroller2
	bsr.w	Scroller3
	bsr.w	Scroller4
	bsr.w	Scroller5
	bsr.w	Scroller6
	bsr.w	Scroller7
	bsr.w	Scroller8
	bsr.w	DogAnim
	bsr.w	DinoAnim
	bsr.w	mt_snd
	move	#$0020,$dff09c		; Restore IRQ Base
	movem.l	(a7)+,d0-d7/a0-a6
	rte

init:	lea	$dff000,a5
	move	$1c(a5),intena		; interrupt installieren
	move.l	$6c.w,oldirq
	move	#$7fff,$9a(a5)
	move.l	#irq,$6c.w
	move	#%1100000000100000,$9a(a5)
	move	#$0020,$96(a5)
	rts

out:	lea	$dff000,a5
	move	#$7fff,$9a(a5)
	move.l	oldirq(pc),$6c.w
	move	intena(pc),d0
	or	#$8000,d0
	move	d0,$9a(a5)
;	lea	gfxname(pc),a1
;	moveq	#0,d0
;	move.l	4.w,a6
;	jsr	-552(a6)
;	move.l	d0,a4
;	move.l	38(a4),$80(a5)

	move	#$8020,$96(a5)
	move	#$c00,$9a(a5)
	rts

intena:		dc.w	0
oldirq:		dc.l	0
gfxname:	dc.b	`graphics.library`,0
 even

*******************************************************

ZaunInit:
	lea	Zaun,a0
	lea	PF2+14320,a1
	moveq	#2-1,d6
	move	#0,$dff064			; Modulo A
	move	#40,$dff066			; Modulo D
	move	#%0000100111110000,$dff040	; Bltcon0
	clr	$dff042				; Bltcon1

zaunle:	moveq	#3-1,d7
.wblt:	btst	#14,$dff002
	bne.b	.wblt
	move.l	a0,$dff050			; Quelle A
	move.l	a1,$dff054			; Ziel   D 
	move	#[21*64]+[320/16],$dff058	; BltSize
	lea	840(a0),a0
	lea	16000(a1),a1
	dbf	d7,.wblt
	lea	Zaun,a0
	lea	PF2+14360,a1
	dbf	d6,zaunle
	rts

********************************************************

InitPic:			; USES: d0-d3/a0-a4
	lea	Pic,a0
	lea	Pf1,a1
	lea	40(a1),a2
	moveq	#2-1,d6
Pic2:	moveq	#3-1,d7
pini:	btst	#14,$dff002
	bne.s	pini
	move.l	a0,$dff050			; Quelle A
	move.l	a1,$dff054			; Ziel   D 
	move	#0,$dff064			; Modulo A
	move	#40,$dff066			; Modulo D
	move	#%0000100111110000,$dff040	; Bltcon0
	clr	$dff042				; Bltcon1
	move	#[200*64]+[320/16],$dff058	; BltSize
	add	#8000,a0
	add	#16000,a1
	dbf	d7,pini
	lea	Pic,a0
	move.l	a2,a1
	dbf	d6,Pic2


*******************************	

	lea	PF1,a3	
	lea	PL1,a2		
	bsr.w	MakePic

	lea	Pf1+1680,a3	
	lea	PL2,a2		
	bsr.w	MakePic

	lea	Pf1+4960,a3	
	lea	PL3,a2		
	bsr.w	MakePic

	lea	Pf1+6560,a3
	lea	PL4,a2		
	bsr.w	MakePic

	lea	Pf1+7280,a3
	lea	PL5,a2		
	bsr.w	MakePic

	lea	Pf1+7760,a3
	lea	PL6,a2		
	bsr.w	MakePic

	lea	Pf1+13600,a3
	lea	PL7,a2		
	bsr.b	MakePic

	lea	Pf1+13760,a3
	lea	PL8,a2		
	bsr.b	MakePic

	lea	Pf1+14080,a3
	lea	PL9,a2		
	bsr.b	MakePic

	lea	Pf1+14480,a3
	lea	PL10,a2		
	bsr.b	MakePic

	lea	Pf1+15120,a3
	lea	PL11,a2
	bsr.b	MakePic	
	
	lea	PF2+14320,a3
	lea	Zpl,a2
	bsr.b	MakePic2

	lea	Pf2,a3
	lea	Pf2pl,a2
MakePic2:
	move	#16000,d4	; Höhe*Breite/8
	move	#$e4,d1		; DFF0E0 nach d1
	moveq	#0,d2		; Löschen für Offset
	moveq	#3-1,d3		; Anzahl der Planen -1
PicToPlane2:
	move.l	a3,a0
	add.l	d2,a0
	move.l	a0,d0	
	swap	d0
	move	d0,a1
	move	d1,(a2)+
	addq	#2,d1
	move	a1,(a2)+
	move	d1,(a2)+
	move	a0,(a2)+
	addq	#6,d1
	add	d4,d2
	dbf	d3,PicToPlane
	rts

MakePic:
	move	#16000,d4	; Höhe*Breite/8
	move	#$e0,d1		; DFF0E0 nach d1
	moveq	#0,d2		; Löschen für Offset
	moveq	#3-1,d3		; Anzahl der Planen -1
PicToPlane:
	move.l	a3,a0
	add.l	d2,a0
	move.l	a0,d0	
	swap	d0
	move	d0,a1
	move	d1,(a2)+
	addq	#2,d1
	move	a1,(a2)+
	move	d1,(a2)+
	move	a0,(a2)+
	addq	#6,d1
	add	d4,d2
	dbf	d3,PicToPlane
	rts


******************************************************
; Logofarben einladen

initCol:lea	Brush+10000,a0
	lea	col,a4
	move	#$180,d0
	moveq	#32-1,d7
clp:	move	d0,(a4)+
	move	(a0)+,(a4)+
	addq	#2,d0
	dbf	d7,clp

Zauncol:
	lea	Zaun+2520,a0
	lea	Zcol,a4
	move	#$190,d0
	moveq	#8-1,d7
.clp:	move	d0,(a4)+
	move	(a0)+,(a4)+
	addq	#2,d0
	dbf	d7,.clp

Dinocol:
	lea	Dog+6144,a0
;	lea	DinoBob+2736,a0
	lea	Dcol,a4
	move	#$190,d0
	moveq	#8-1,d7
.clp:	move	d0,(a4)+
	move	(a0)+,(a4)+
	addq	#2,d0
	dbf	d7,.clp

	rts

*******************************************************
; Logo auf Logoplane kopieren

InitLogo:
	lea	Brush,a0
	lea	Logo+20,a1
	moveq	#5-1,d7
wini:	btst	#14,$dff002
	bne.s	wini
	move.l	a0,$dff050			; Quelle A
	move.l	a1,$dff054			; Ziel   D 
	move	#0,$dff064			; Modulo A
	move	#40,$dff066			; Modulo D
	move	#%0000100111110000,$dff040	; Bltcon0
	clr	$dff042				; Bltcon1
	move	#[50*64]+[320/16],$dff058	; BltSize
	add	#2000,a0
	add	#4000,a1
	dbf	d7,wini

LogoToPic:
	move	#20,d1
	bsr.w	DoTheDance
	rts

*******************************************************

Dancer:	cmp	#1,DDir
	beq.s	DRight
	cmp	#2,DDir
	beq.b	DLeft
	rts

DRight:
	lea	dpl,a4
	move	dspeed,d1
	add	d1,(a4)
	cmp	#$ff,(a4)
	bgt.b	HardRight
	rts

HardRight:
	move	dpos,d1
	subq	#2,d1
	cmp	#0,d1
	bne.b	drend2
	move	#2,ddir
drend2:
	move	d1,dpos
	bsr.b	DoTheDance
	move	#0,dpl
	rts

***********************************************************

DLeft:
	lea	dpl,a4
	move	dspeed,d1
	sub	d1,(a4)
	bmi.b	hardleft
	rts

HardLeft:
	move	dpos,d1
	addq	#2,d1
	cmp	#40,d1
	bne.b	dlend2
	move	#1,Ddir
dlend2:
	move	d1,dpos
	bsr.b	DoTheDance
	move	#$ff,dpl
	rts
	
***********************************************************

DoTheDance:
	lea	Logo,a3		; Bild nach a3
	add	d1,a3
	lea	Planes,a2	; BildPos. in Coplist nach a2
	move	#4000,d4	; Höhe*Breite/8
	moveq	#0,d2		; Löschen für Offset
	moveq	#5-1,d3		; Anzahl der Planen -1
LogoToPlane:
	move.l	a3,d0
	swap	d0
	move	d0,2(a2)
	move	a3,6(a2)
	addq	#8,a2
	lea	(a3,d4.w),a3
	dbf	d3,LogoToPlane
	rts

Dpos:	dc.w	20
Ddir:	dc.w	2		; 1=rechts  2=links
Dspeed:	dc.w	$0044

*************************************************************

DinoAnim:
	sub	#1,Dinocnt2
	bmi.b	DinoRUN
	rts

DinoRUN:
	move	#5,Dinocnt2
	cmp	#1,Dinocnt
	beq.b	Dino1
	cmp	#2,Dinocnt
	beq.b	Dino2
	rts

Dino1:
	lea	DinoBob,a0
	bsr.b	DoTheDinoDance
	move	#2,Dinocnt
	rts
Dino2:
	lea	DinoBob+12,a0
	bsr.b	DoTheDinoDance
	move	#1,Dinocnt
	rts
	
DoTheDinoDance:
	lea	PF2+9764,a1
	moveq	#3-1,d7
.wini:	btst	#14,$dff002
	bne.s	.wini
	move.l	a0,$dff050			; Quelle A
	move.l	a1,$dff054			; Ziel   D 
	move	#12,$dff064			; Modulo A
	move	#68,$dff066			; Modulo D
	move	#%0000100111110000,$dff040	; Bltcon0
	clr	$dff042				; Bltcon1
	move	#[57*64]+[96/16],$dff058	; BltSize
	add	#1368,a0
	add	#16000,a1
	dbf	d7,.wini
	rts

Dinocnt:	dc.w	1
Dinocnt2:	dc.w	0

*************************************************************

Doganim:
	sub	#1,dogwait
	bmi.b	RunningDog
	rts

RunningDog:
	add	#1,dogcount
	move	#5,dogwait
	moveq	#0,d0

	cmp	#1,dogcount
	beq.b	DoRunningDog

	addq	#8,d0
	cmp	#2,dogcount
	beq.b	DoRunningDog

	addq	#8,d0
	cmp	#3,dogcount
	beq.b	DoRunningDog
	
	addq	#8,d0
	cmp	#4,dogcount
	beq.b	DoRunningDog

	add	#1000,d0
	cmp	#5,dogcount
	beq.b	DoRunningDog

	addq	#8,d0
	cmp	#6,dogcount
	beq.b	DoRunningDog

	addq	#8,d0
	cmp	#7,dogcount
	clr	dogcount
	beq.b	DoRunningDog
	rts

DoRunningDog:
	lea	Dog,a0
	lea	(a0,d0.w),a0
	lea	PF2+11856,a1
	moveq	#3-1,d7

	move	#24,$dff064			; Modulo A
	move	#72,$dff066			; Modulo D
	move	#%0000100111110000,$dff040	; Bltcon0
	clr	$dff042				; Bltcon1

.wblt:	btst	#14,$dff002
	bne.s	.wblt
	move.l	a0,$dff050			; Quelle A
	move.l	a1,$dff054			; Ziel   D 
	move	#[32*64]+[64/16],$dff058	; BltSize
	add	#2048,a0
	add	#16000,a1
	dbf	d7,.wblt
	rts

dogcount:	dc.w	0
dogwait:	dc.w	0

*************************************************************

Scroller1:
	lea	Scpl11,a0
	cmp	#2,bp
	beq.b	HH1.1
	cmp	#5,bp
	beq.b	HH1.2
	cmp	#7,bp
	beq.b	HH1.3	
	subq	#$006,(a0)
	addq	#1,bp
	rts	
HH1.1:
	subq	#$03,(a0)
	bsr.b	Hardscroll1
	or	#$0d,scpl11
	addq	#1,bp
	rts
HH1.2:
	subq	#$01,(a0)
	bsr.b	Hardscroll1
	or	#$0b,scpl11
	addq	#1,bp
	rts
HH1.3:
	subq	#$05,(a0)
	bsr.b	Hardscroll1
	or	#$0f,scpl11
	clr	bp
	rts

Hardscroll1:
	move	adder11,d6
	addq	#2,d6
	lea	Pf1+15120,a3
	lea	PL11,a2		
	bsr.w	Rout
	move	d6,adder11
	rts

Scroller2:
	lea	Scpl10,a0
	cmp	#3,bp2
	beq.b	HH2.1
	cmp	#6,bp2
	beq.b	HH2.2
	cmp	#9,bp2
	beq.b	HH2.3	
	cmp	#12,bp2
	beq.b	HH2.4
	cmp	#15,bp2
	beq.b	HH2.5 	
	subq	#$005,(a0)
	addq	#1,bp2
	rts	
HH2.1:	bsr.b	Hardscroll2
	or	#$0b,scpl10
	addq	#1,bp2
	rts

HH2.2:	subq	#$01,(a0)
	bsr.b	Hardscroll2
	or	#$0c,scpl10
	addq	#1,bp2
	rts

HH2.3:	subq	#$02,(a0)
	bsr.b	Hardscroll2
	or	#$0d,scpl10
	addq	#1,bp2
	rts

HH2.4:	subq	#$03,(a0)
	bsr.b	Hardscroll2
	or	#$0e,scpl10
	addq	#1,bp2
	rts

HH2.5:	subq	#$04,(a0)
	bsr.b	Hardscroll2
	or	#$0f,scpl10
	clr	bp2
	rts

Hardscroll2:
	move	adder10,d6
	addq	#2,d6
	lea	Pf1+14480,a3
	lea	PL10,a2		
	bsr.w	Rout
	move	d6,adder10
	rts

Scroller3:
	lea	scpl1,a0
	lea	scpl9,a1
	lea	zscpl,a2

	cmp	#3,bp3
	beq.b	Hardscroll3
	subq	#$04,(a0)
	subq	#$04,(a1)
	subq	#$04,(a2)
	addq	#1,bp3
	rts

Hardscroll3:
	move	adder9,d6
	addq	#2,d6
	lea	Pf1,a3
	lea	PL1,a2		
	bsr.w	Rout
	lea	Pf1+14080,a3
	lea	Pl9,a2
	bsr.w	Rout
	move	d6,adder9			
	or	#$f,scpl1
	or	#$f,scpl9
	or	#$f,zscpl
	clr	bp3
	rts

Scroller4:
	lea	Scpl2,a0
	lea	scpl8,a1
	cmp	#5,bp4
	beq.b	HH4.1
	cmp	#10,bp4
	beq.b	HH4.2
	cmp	#15,bp4
	beq.b	HH4.3	
	subq	#$003,(a0)
	subq	#$003,(a1)
	addq	#1,bp4
	rts	
HH4.1:
	bsr.b	Hardscroll4
	or	#$0d,scpl2
	or	#$0d,scpl8
	addq	#1,bp4
	rts

HH4.2:	subq	#$01,(a0)
	subq	#$01,(a1)
	bsr.b	Hardscroll4
	or	#$0e,scpl2
	or	#$0e,scpl8
	addq	#1,bp4
	rts

HH4.3:	subq	#$02,(a0)
	subq	#$02,(a1)
	bsr.b	Hardscroll4
	or	#$0f,scpl2
	or	#$0f,scpl8
	clr	bp4
	rts

Hardscroll4:
	move	adder8,d6
	addq	#2,d6
	lea	Pf1+1680,a3
	lea	PL2,a2		
	bsr.w	Rout
	lea	Pf1+13760,a3
	lea	PL8,a2		
	bsr.w	Rout	
	move	d6,adder8
	rts

Scroller5:
	lea	scpl3,a0
	lea	scpl7,a1
	cmp	#7,bp5
	beq.b	Hardscroll5	
	subq	#$02,(a0)
	subq	#$02,(a1)
	addq	#1,bp5
	rts	

Hardscroll5:
	move	adder7,d6
	addq	#2,d6
	lea	Pf1+4960,a3
	lea	PL3,a2		
	bsr.w	Rout
	lea	Pf1+13600,a3
	lea	PL7,a2		
	bsr.w	Rout	
	move	d6,adder7
	or	#$f,scpl3
	or	#$f,scpl7
	clr	bp5
	rts	
Scroller6:
	lea	scpl4,a0
	lea	scpl6,a1
	cmp	#15,bp6
	beq.b	Hardscroll6
	subq	#$01,(a0)
	subq	#$01,(a1)
	addq	#1,bp6
	rts	
Hardscroll6:
	move	adder6,d6
	addq	#2,d6
	lea	Pf1+6560,a3
	lea	PL4,a2		
	bsr.w	Rout
	lea	Pf1+7760,a3
	lea	PL6,a2		
	bsr.w	Rout	
	move	d6,adder6
	or	#$f,scpl4
	or	#$f,scpl6
	clr	bp6
	rts		
Scroller7:
	cmp	#0,adax
	bne.b	end7.1
	move	#2,adax
	lea	scpl5,a0
	cmp	#15,bp7
	beq.b	Hardscroll7
	subq	#1,(a0)
	addq	#1,bp7
end7.1:	subq	#1,adax
	rts		

Hardscroll7:
	move	adder5,d6
	addq	#2,d6
	lea	Pf1+7280,a3
	lea	Pl5,a2
	bsr.w	Rout
	move	d6,adder5
	or	#$f,scpl5
	clr	bp7
	rts

Scroller8:
	lea	zscpl,a0
	cmp	#1,bp8
	beq.b	Hardscroll8	
	sub	#$80,(a0)
	lea	scpl10,a0
	sub	#$80,(a0)	
	lea	scpl11,a0
	sub	#$80,(a0)		
	addq	#1,bp8
	rts	

Hardscroll8:
	move	adder12,d6
	addq	#2,d6
	lea	Pf2+14320,a3
	lea	ZPL,a2		
	bsr.b	Rout
	move	d6,adder12

	or	#$f0,zscpl
	or	#$f0,scpl10
	or	#$f0,scpl11
	clr	bp8
	rts	

Rout:	cmp	#40,d6
	bne.b	hiho
	moveq	#0,d6
hiho:	lea	(a3,d6.w),a3
	move	#16000,d4	; Höhe*Breite/8
	moveq	#3-1,d3		; Anzahl der Planen -1
PicPln:	move.l	a3,d0
	swap	d0
	move	d0,2(a2)
	move	a3,6(a2)
	addq	#8,a2
	lea	(a3,d4.w),a3
	dbf	d3,PicPln
	rts

*********************************

bp:		dc.w	0
bp2:		dc.w	0
bp3:		dc.w	0
bp4:		dc.w	0
bp5:		dc.w	0
bp6:		dc.w	0
bp7:		dc.w	0
bp8:		dc.w	0
adax:		dc.w	2
adder5:		dc.w	0
adder6:		dc.w	0
adder7:		dc.w	0
adder8:		dc.w	0
adder9:		dc.w	0
adder10:	dc.w	0
adder11:	dc.w	0
adder12:	dc.w	0

**********************************************************

sndinit:
mt_init:
	lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4:
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear:
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.b	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6,mt_maxpart+1
	rts

; 'mt_end' = sound off

sndoff:
mt_off:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

; die Playroutine jede frame aufrufen !!

snd:
mt_snd:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.b	mt_notsix
	clr.w	mt_counter
	bra.w	mt_rout2

mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.b	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.b	mt_arp2
	lea	$dff0b0,a5
	bsr.b	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.b	mt_arp3
	lea	$dff0c0,a5
	bsr.b	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.b	mt_arp4
	lea	$dff0d0,a5
	bra.b	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq.w	mt_arpegrt
	cmp.b	#$01,d0
	beq.b	mt_portup
	cmp.b	#$02,d0
	beq.b	mt_portdwn
	cmp.b	#$0a,d0
	beq.b	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.b	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.b	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.b	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.b	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.b	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts

mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.b	mt_loop2
	cmp.w	#2,d0
	beq.b	mt_loop3
	cmp.w	#3,d0
	beq.b	mt_loop4
	cmp.w	#4,d0
	beq.b	mt_loop2
	cmp.w	#5,d0
	beq.b	mt_loop3
	rts

mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.b	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.b	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.b	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.b	mt_endpart
	addq.l	#2,a0
	bra.b	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr.w	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr.w	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr.w	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr.w	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.b	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.b	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.b	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.b	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.b	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.b	mt_stop
	clr.l	mt_partnrplay
;	st	Pflag
mt_stop:tst.w	mt_status
	beq.b	mt_stop2
	clr.w	mt_status
	bra.b	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.b	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.b	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.b	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.b	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout:
	tst.w	(a6)
	beq.b	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.b	mt_posjmp
	cmp.b	#$0c,d0
	beq.b	mt_setvol
	cmp.b	#$0d,d0
	beq.b	mt_break
	cmp.b	#$0e,d0
	beq.b	mt_setfil
	cmp.b	#$0f,d0
	beq.b	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back:rts

mt_aud1temp:
	ds.w	10
	dc.w	1
	ds.w	2
mt_aud2temp:
	ds.w	10
	dc.w	2
	ds.w	2
mt_aud3temp:
	ds.w	10
	dc.w	4
	ds.w	2
mt_aud4temp:
	ds.w	10
	dc.w	8
	ds.w	2

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.w	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	ds.l	31
mt_maxpart:	dc.w	0
mt_dmacon:	dc.w	0
mt_status:	dc.w	0

mt_arpeggio:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


Cop:	dc.w	$140,0,$142,0		; SprPos,0
	dc.w	$120,0,$122,0,$124,0
	dc.w	$126,0,$128,0,$12a,0
	dc.w	$12c,0,$12e,0,$130,0
	dc.w	$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0

	dc.w	$100,%0101001000000000	; Bplcon0	
	dc.w	$8e,$2581,$90,$25c1	; dstart/stop
	dc.w	$92,$30,$94,$d0		; ddfstart/stop
	dc.w	$108,38,$10a,38		; planetrennung
col:	ds.l	32			; reserve colspace
Planes:
	dc.w	$e0,0,$e2,0,$e4,0,$e6,0			; reserve planespace
	dc.w	$e8,0,$ea,0,$ec,0,$ee,0			; reserve planespace
	dc.w	$f0,0,$f2,0			; reserve planespace
	dc.w	$102
dpl:	dc.w	$00ff

	dc.w	$5701,$fffe
	dc.w	$100,$0
	dc.w	$e0,0,$e2,0,$e4,0,$e6,0			; reserve planespace
	dc.w	$e8,0,$ea,0,$ec,0,$ee,0			; reserve planespace
	dc.w	$f0,0,$f2,0			; reserve planespace

	dc.w	$6101,$fffe
Pf2pl:	ds.l	2*3
	dc.w	$108,40,$10a,40		; planetrennung
	dc.w	$180,$0
	dc.w	$182,$ccc
	dc.w	$184,$bbb
	dc.w	$186,$aaa
	dc.w	$188,$999
	dc.w	$18a,$888
	dc.w	$18c,$777
	dc.w	$18e,$05b
	dc.w	$190,$555

	dc.w	$6201,$fffe
	dc.w	$8e,$6291,$90,$2ab1	; dstart/stop
	dc.w	$92,$38,$94,$d0		; ddfstart/stop
	dc.w	$100,%0110011000000000	; Bplcon0	
	dc.w	$104,%0000000001000000
PL1:	ds.l	2*3
	dc.w	$102
scpl1:	dc.w	$00f
	dc.w	$7701,$fffe		; Spos1 ff
PL2:	ds.l	2*3
	dc.w	$102
scpl2:	dc.w	$00f
dcol:	ds.l	8
	dc.w	$a001,$fffe		; Spos2 88
	dc.w	$102,0
PL3:	ds.l	2*3
	dc.w	$102
scpl3:	dc.w	$00f
	dc.w	$b401,$fffe		; Spos3 44
PL4:	ds.l	2*3
	dc.w	$102
scpl4:	dc.w	$00f
	dc.w	$bd01,$fffe		; Spos4 22
PL5:	ds.l	2*3
	dc.w	$102
scpl5:	dc.w	$00f
	dc.w	$c301,$fffe		; Spos5 11  MOUNTAINS
PL6:	ds.l	2*3
	dc.w	$102
scpl6:	dc.w	$0f	
	dc.w	$182,$ba9,$184,$a98,$186,$987
	dc.w	$188,$876,$18a,$765,$18c,$654
	dc.w	$ffe1,$fffe
	dc.w	$0c01,$fffe		; Spos4 22 GRASS
	dc.w	$182,$780,$184,$670,$186,$560
	dc.w	$188,$450,$18a,$340,$18c,$230
PL7:	ds.l	2*3
	dc.w	$102
scpl7:	dc.w	$00f
	dc.w	$0e01,$fffe		; Spos4 22 GRASS
PL8:	ds.l	2*3
	dc.w	$102
scpl8:	dc.w	$00f	
	dc.w	$1101,$fffe		; Spos4 22 GRASS
PL9:	ds.l	2*3
	dc.w	$102
scpl9:	dc.w	$000f
	dc.w	$1501,$fffe		; Zaun
	dc.w	$102
zscpl:	dc.w	$00f0
ZPl:	ds.l	6
Zcol:	ds.l	8	
	dc.w	$1801,$fffe
Pl10:	ds.l	2*3
	dc.w	$102
scpl10:	dc.w	$00f
	dc.w	$2001,$fffe
Pl11:	ds.l	2*3
	dc.w	$102
scpl11:	dc.w	$00f
	dc.l	$fffffffe

***********************************************************
Brush:		incbin	`data5:raw/prestige320x50x5`
Pic:		incbin	`data5:raw/spl1.320x200x3`
Zaun:		incbin	`data5:raw/fence.320x21x3`
DinoBob:	incbin	`data5:raw/Dino192x57x3`
Dog:		incbin	`data5:raw/Hund256x64x3`
mt_data:	incbin	`snd3:far from home`

;Zaun:		incbin	`dh2:raw/fence.320x21x3`
;Brush:		incbin	`dh2:raw/qrz320x50x5`
;Pic:		incbin	`dh2:raw/spl1.320x200x3`
;DinoBob:	incbin	`dh2:raw/Dino192x57x3`
;Dog:		incbin	`dh2:raw/Hund256x64x3`
;mt_data:	incbin	`dh2:mods/far from home`

	section	bss,bss_c
Logo:		ds.b	5*4000		; Spare für Sc-Bpl+Logo
PF1:		ds.b	3*16000
PF2:		ds.b	3*16000

