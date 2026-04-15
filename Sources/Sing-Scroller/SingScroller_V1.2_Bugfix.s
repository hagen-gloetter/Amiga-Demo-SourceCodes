;               T        T              T       T


;	48*48 SING SINUSSCROLLER	CODE BY DUKE OF MOTION

; Basicly v0.9 but optimized & bugfixed


; So gehts:	- Font in max. 6 x-Linien auflösen
;	- Fontcoords in matrix (320+48*6) kopieren
;	- ypos aus matrix lesen und sinus addieren
;	- punkte auf screen setzen uny mit cpu und blitter y füllen

;					Last change: 18.07.96


;--------------------------------------------------------------- INCLUDE MAKROS

	incdir	Codes:SingScroller/
	include	makros:-Base_makros.s

;--------------------------------------------------------------------- LET'S GO


x:	movem.l	d0-d7/a0-a6,-(a7)	; store registers
	move.l	$4.w,a6			; get execbase
	lea	gfxname(pc),a1		; set library pointer

.check_for_AGA	move.w	$dff07c,d0
	cmpi.b	#$f8,d0		; IS THE AGA CHIPSET PRESENT???
	bne.w	.noAGA		; Neee !
	st	AGA
.noAGA	moveq	#39,d0		; lib version
 	jsr	-$228(a6)		; openlibrary but only if >= 39
 	beq.w	.no39Lib		; no! if insn't a v39
	st	AGA
	bra.b	.loadview
.no39Lib	moveq	#0,d0		; lib version 0 (geht immer)
 	jsr	-$228(a6)		; openlibrary
	beq.w	noGfxLib		; not enough mem free -> bye bye
.loadview	move.l	d0,gfxbase		; für closelibrary
	move.l	d0,a6
	move.l	$22(a6),viewport
	move.l	$26(a6),syscop1	; store systemcopper1 start adr
	move.l	$32(a6),syscop2	; store systemcopper2 start adr
	move.l	#0,a1		; (kein x-beliebiger Wert!)
	jsr	-222(a6)		; LOADVIEW
	jsr	-270(a6)		; WAITTOF
	jsr	-270(a6)		; WAITTOF

.demo_init	lea	$dff000,a6		; customregbase to a6
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

;--------------------------------------------------------INITS

.bplini	move.l	#Screen1,d0
	lea	BitPlanes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

;---------------------------------------------------------- PreCalcScrollTab

PreCalcScrollerTabs:
	lea	Font,a0	; Sing-Tabelle vormultiplizieren
.loop	move	(a0),d0
	bmi.b	.exit		; 0 =Endkennung ges
	beq.b	.go		; -1=Endkennung y
	add	d0,d0		; wortlänge
.go	move	d0,(a0)+
	bra.b	.loop
.exit
	lea	YSinTab(pc),a0     ; YSinus-Tabelle vormultiplizieren
	move	#2048-1,d7	; 1024 Werte
.lp	move	(a0),d0
	add	d0,d0	; Screenbreite/8
	move	d0,(a0)+
	dbf	d7,.lp

createMuluTab	lea	MuluTab,a0	; MultiplikationsTabelle
	moveq	#1,d0
	move	#256-1,d7
.lp	move	d0,d1
	muls	#40,d1	; Screenbreite/8
	move	d1,(a0)+
	addq	#1,d0
	dbf	d7,.lp	

;---------------------------------------------------------- GETVBR


.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)		; SUPERVISOR
	move.l	d7,VectorBase		; save it
.68000	lea	$dff000,a6
	move	$A(a6),mouse		; save Mouseposition


	move.l	#cop,$80(a6)		; copper1 start address
	move	#$001234,$88(a6)	; copjump 1

initVBI	move.l	VectorBase(pc),a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000010000,$9a(a6)
	jsr	tp_init
	
;---------------------------------------------------------- MOUSE WAIT
	
mloop:	btst	#6,$bfe001		; Wait for left  mouse button
	bne.b	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:	lea	$dff000,a6
	move.l	VectorBase(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
	move	mouse(pc),$36(a6)	; restore Mouseposition

exit:	move	#$7fff,$9a(a6)		; disable interrupts
	move	#$7fff,$96(a6)		; disable dmacon
	jsr	tp_end
	lea	$dff000,a6
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

	move.l	gfxbase(pc),a6		; gfxbase einladen
	move.l	viewport(pc),a1		; alter Viewport
	jsr	-222(a6)		; LOADVIEW
	move.l	4.w,a6		; execbase in a6
	move.l	gfxbase(pc),a1		; für closelibrary
	jsr	-414(a6)		; CLOSELIBRARY

noGfxLib:	movem.l	(a7)+,d0-d7/a0-a6	; restore registers
	moveq	#0,d0
	rts

;-------------------------------------------------------- VERTICAL BLANK ROUTNE

	pop
VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$500,$dff180		; Rasterzeitmessung Anfang (rot)

;-------------------------------------------------------- MAIN ROUTINE

	bsr.b	SingSinScroller

	btst	#2,$dff016		; Wait for right mouse button
	bne.b	.end
	move	#$070,$dff180		; Rasterzeitmessung Ende (grün)
.end	jsr	tp_play
	move	#$0010,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte


;---------------------------------------------------------- SCROLLER


	pop
SingSinScroller	lea	FrontScreen(pc),a1	; Tribble Screen Buffer
	move.l	8(a1),d0
	move.l	4(a1),a0
	move.l	0(a1),d2
	move.l	d0,0(a1)
	move.l	a0,8(a1)
	move.l	d2,4(a1)

.FrontScrToCop	lea	BitPlanes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

ClearHiddenScreen:				; Clear Hidden Screen
	wblt
	move.l	#-1,$44(a6)			; only once
	move.l	#$01000000,$40(a6)
	move	#00,$66(a6)
	move.l	d2,$54(a6)
	move	#[200*64]+[320/16],$58(a6)	; etvl 200

;---------------------------------------------------------- bset

.scroller	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d6
	lea	Hiddenscroller,a1
	move.l	a0,a5		; save a0
	move.l	a1,a2

	lea	ySinTab(pc),a3
	move	ySinPtr(pc),d0
	add	#14,d0		; wobbelvalue
	and	#2047,d0
	move	d0,ySinPtr
	lea	(a3,d0.w),a3
	move.b	#$80,d2	; Maske

	lea	MuluTab(pc),a4

	moveq	#40-1,d7
.bset	move	(a3)+,d0	; Sinus   addieren	
;	move	#100,d0	; L I N E A R  T E S T 
.1	move	(a1)+,d1
	beq.b	.nextX	; 0=Y-Endkennung nur bei even, da paare
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.2	move	(a1)+,d1
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.3	move	(a1)+,d1
	beq.b	.nextX	
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.4	move	(a1)+,d1
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.5	move	(a1)+,d1
	beq.b	.nextX
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.6	move	(a1)+,d1
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.7	move	(a1)+,d1
	beq.b	.nextX
	add	d0,d1
	move	(a4,d1),d3
	or.b	d2,(a0,d3.w)
.8	move	(a1)+,d1
	add	d0,d1
.nextX	add	#16,d6
	lea	(a2,d6),a1
	ror.b	#1,d2		; xpos=xpos+1
	bcc.b	.bset		; Carry=0 then nö
	addq.l	#1,a0
	dbf	d7,.bset


;---------------------------------------------------------- Move the hidden one


.moveHiddenOne	lea	Hiddenscroller,a2	; Z D
	lea	32(a2),a1		; Q A	(scrollspeed)
	wblt
	move.l	#0,$64(a6)		; Koordinaten um ein word nach
	move	#0,$66(a6)		; links verschieben
	move	#$09f0,$40(a6)
	movem.l	a1-a2,$50(a6)
	move	#[366*64]+8,$58(a6)	; 320+48-2 

	move.l	a5,a0
	lea	80(a0),a0 ; net ok aber die 1. 2 Z der Font sind leer
CPU_Fill:	moveq	#0,d0		; Fill Font
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	a0,a1		; StartAdr sichern
	rept	197		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0/d1/d2/d3	; Neue Daten aus Bmp holen
	eor.l	d0,d4		;
	eor.l	d1,d5		;
	eor.l	d2,d6		;
	eor.l	d3,d7		;
	movem.l	d4/d5/d6/d7,(a1)	; Modifizierte Daten zurückschreiben
	lea	40(a1),a1		; Eine Zeile tiefer 
	endr

	lea	16(a0),a0		; add #16,a0

.Blitter_Fill	lea	40(a0),a1		; a0=   a
	move.l	a1,a2		; a1=a2 b=d  
	moveq	#24,d0		; blitter modulo
	wblt
	move.l	#-1,$44(a6)		; only once
	move	#$0d3c,$40(a6)
	move	d0,$62(a6)
	move	d0,$64(a6)
	move	d0,$66(a6)
	movem.l	a0-a2,$4c(a6)			; bad
	move	#[197*64]+[128/16],$58(a6)	; etvl 200

.CPU_Fill2	lea	16(a0),a0
	move.l	a0,a1		; StartAdr sichern
	rept	197		; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0-d1		; Neue Daten aus Bmp holen
	eor.l	d0,d2		;
	eor.l	d1,d3		;
	movem.l	d2-d3,(a1)		; Modifizierte Daten zurückschreiben
	lea	40(a1),a1		; Eine Zeile tiefer 
	endr

.dumpNewLetter	move	scrollcnt(pc),d5
	bne.w	.printEnd
.GetChar:	lea	Font,a2
	moveq	#0,d0
	move.l	ScrollPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	lea	ScrollText(pc),a0
	move.b	(a0)+,d0
.no0:	move.l	a0,ScrollPtr
	sub.b	#65,d0	; kleiner 65 
	bmi.b	.space	; ja, dann isch's a space
	move	d0,d2
	lea	Fonttab(pc),a3
	add	d2,d2	; make b->w
	move	(a3,d2.w),d2
	lsr.b	#1,d2
	move	d2,scrollcnt	; refresh pointer
	lsl	#8,d0	; \
	move	d0,d1	;  } *768
	add	d1,d1	; /
	add	d1,d0	;/
.copyLetter	lea	(a2,d0.w),a0
	lea	HiddenScroller+16*320,a1
	wblt
	move	#0,$64(a6)
	move	#0,$66(a6)
	move	#$09f0,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[48*64]+8,$58(a6)
	bra.b	.printEnd
.space	lea	HiddenScroller+16*320,a1
;	wblt
;	move	#0,$64(a6)		; löschen nur d aktiv
;	move	#0,$66(a6)
;	move	#$0100,$40(a6)
;	move.l	a1,$54(a6)
;	move	#[48*64]+8,$58(a6)
	move	#24,scrollcnt		; Space ist immer 48/2
.printEnd	subq	#1,Scrollcnt
	rts


;---------------------------------------------------------- SYS_Pointer

		pop
AGA		dc.w	0	; AGA=$ff noAGA=0
viewport		dc.l	0
gfxbase		dc.l	0
mouse		dc.w	0
syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0,0
oldVBI		dc.l	0
VectorBase		dc.l	0
vbr_exception		dc.l	$4e7a7801		; movec vbr,d0
		rte		; back to user state code


;---------------------------------------------------------- Demo_Pointer

scrollcnt	dc.w	0
ScrollPtr	dc.l	ScrollText
FrontScreen	dc.l	Screen1,Screen2,Screen3
YSinTab	include	sintab1.i			; 2048.w
ySinPtr	dc.w	0

	pop
ScrollText	dc.b	`MOTION       `
 DC.B	` THE WAY OF THE TAO  `
 DC.B	` `
 DC.B	` ONCE AN APPRENTICE ASKED A MASTER WHAT LANGUAGES HE KNEW  AND THE`
 DC.B	` MASTER THOUGHT A WHILE  AND NAMED MANY  ANF THE APPRENTICE SAID `
 DC.B	`  MUST I KNOW ALL THOSE TO BE A MASTER    AND THE MASTER REPLIED   NO `
 DC.B	` MY SON  YOU NEED TO LEARN AS MANY AS YOU NEED TO DO ALL THE MACHINE CAN DO `
 DC.B	` HE IS A MASTER WHO CAN MAKE THE MACHINE DO ALL THE MACHINE CAN DO  `
 DC.B	` SO THE APPRENTICE ASKED   CAN THIS BE DNE IN ANY LANGUAGE    AND THE`
 DC.B	` MASTER REPLIED   NO  ONLY IN ASSEMBLER  BUT IN THE OTHER LANGUAGES`
 DC.B	` MAY BE DONE MANY THINGS  SO TO BE A MASTER YOU MAY KNOW WHATEVER`
 DC.B	` LANGUAGES SUIT YOUR FANCY  BUT YOU MUST KNOW ASSEMBLER  FOR IT IS THE`
 DC.B	` LANGUAGE OF THE TAO   AND THE APPRENTICE ASKED   OF ALL THE LANGUAGES`
 DC.B	` YOU KNOW  WHITCH DO YOU USE    AND THE MASTER SMILED AND SAID `
 DC.B	`  ASSEMBLER  `
 DC.B	`  BUT MASTER   THE APPRENTICE ASKED   I VE HEARD ONE SAY THAT WHEN`
 DC.B	` AT LAST THR MACHINE YOU USED TO CODE FOR BECAME OBSOLETE  HE WAS ABLE`
 DC.B	` TO PORT HIS CODE BY COMPILING IT FOR THE NEW MACHINE  AND YOU HAD TO`
 DC.B	` TRANSLATE YOURS  IS THIS NOT A GREAT ADVANTAGE    AND THE MASTER SMILED`
 DC.B	` AND SAID   MY SON  THAT ONE HAS MOVED TO A BETTER MACHINE  AND DOES NOT`
 DC.B	` KNOW IT  HIS COMPILER CREATES CODE THAT PAINS THE EYE TO SEE IN DEBUG IT`
 DC.B	` IS SO UGLY  BUT HE KNOWS NOT  FOR HE HAS NEVER SEEN IT  WHEN I PORTED`
 DC.B	` MY CODE  I WAS GIVEN THE CHANGE TO LEARN A NEW INSTRUCTION SET  AND TO`
 DC.B	` DISCOVER ALL THE WONDERFUL THINGS DONE BY THE MASTERS WHO WROTE THE BIOS`
 DC.B	` AND THE OPERATING SYSTE  AND THAT ONE CURSETH THEM FOR THE WAY THEY HATH`
 DC.B	` ALLOCATED THE MEMORY  AND HE DOTH NOT KNOW OF THE MIRACLES THEY HAVE`
 DC.B	` PERFORMED  IS THAT THE WAY OF THE TAO  `
 DC.B	`          `
	DC.B	`THE CREDITS  CODE AND FONT BY DUKE OF MOTION `
	dc.b	`     `
	dc.b	` HAZE  OMNIA ROMAE VERNALIA SUNT `
	dc.b	`               `
	dc.b	0
	even

;---------------------------------------------------------- Font

	pop
	;	 A  B  C  D  E  F  G  H  I  J  K  L  M
FontTab	dc.w	35,36,29,40,28,29,36,38,14,24,36,28,42
	dc.w	34,41,34,41,35,30,35,38,41,41,32,36,31
	;	 N  O  P  Q  R  S  T  U  V  W  X  Y  Z

	pop
MuluTab:	ds.w	256		; MultiplikationsTabelle


	include	makros/tp3.s		; play routine

;---------------------------------------------------------- Copperlist

	section	DATA,code_c

	pop
Font:	incbin	ShebertFont.coords.b	; ins chip weil blt getchar
	dc.l	$fffffffff		; Endkennung


	pop
cop:	dc.w	$106,0,$1fc,$0
	dc.w	$180,$0001,$182,$354
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10,$108,0,$10a,0
	dc.w	$100,0
	dc.w	$1007,$fffe,$180,$033		; col1
	dc.w	$4007,$fffe,$180,$000		; col2
	dc.w	$4207,$fffe,$180,$404		; col3

	dc.w	$4901,$fffe

	dc.w	$100,$1200
BitPlanes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0

	dc.w	$ffe1,$fffe
	dc.w	$9c,$8010			; vbi
	dc.w	$1007,$fffe,$180,$000		; col4
	dc.w	$1207,$fffe,$180,$033		; col5

	dc.l	$fffffffe


Song	incbin	tunes/TP3.UnitA ;ChipTune3 ;TP3.TRAVOLTA ;tp3.industrial2


;---------------------------------------------------------- BitplaneSpace

	section	Bitplanes,bss_c

	pop
HiddenScroller	ds.b	16*368
	pop
Screen1:	ds.b	10240
	pop
Screen2:	ds.b	10240
	pop
Screen3:	ds.b	10240
