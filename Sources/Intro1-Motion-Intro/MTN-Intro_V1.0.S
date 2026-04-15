
; INTRO 1 by Duke of Haze done for Motion on the 29.11.93 

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
	move.l	#Copperlist,$80(a6)	; copper1 start address
	move	#$001234,$88(a6)	; copjump 1
	move	#$0083e0,$96(a6)	; dmacon data + sprdma
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
.bplini	move.l	#LogoScreen,d0
	lea	Planes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	addq	#8,a1
	move.l	#TextScreen,d0
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
	swap	d0
	add	#80,d0
	addq	#8,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)
.initcop:
	lea	coptab,a0
	move.l	#$10e1fffe,d0
	move.l	#$1107fffe,d1
	move.l	#$01800888,d2
	move.l	#$01820888,d3
	move.l	#$01000000,d4
	move	#310-1,d7
.lp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.l	d4,d0
	add.l	d4,d1
	dbf	d7,.lp

initSpr	move.l	#Spr1,d0
	lea	Sprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp

;---------------------------------------------------------- GET VECTORBASE

.getVBR	move.l	4.w,a6
	moveq	#$f,d0
	moveq	#$0,d7
	and.b	$129(a6),d0		; are we at least a 68010?
	beq.b	.68000
	lea.l	vbr_exception(pc),a5	; addr of function to get VBR
	jsr	-30(a6)			; Supervisor
	move.l	d7,pr_Vectorbasept	; save it
.68000	lea	$dff000,a6
	bsr.w	Typewriter

;---------------------------------------------------------- START VBI

initVBI	move.l	pr_Vectorbasept,a0
	move.l	$6c(a0),oldVBI
	move	#$7fff,$9a(a6)
	move.l	#VBI,$6c(a0)
	move	#%1100000000100000,$9a(a6)	; Start VBI
	bsr.w	pr_init

.noexit	cmp	#2,demoflag		; no exit till screen is faded in
	bne.b	.noexit

;---------------------------------------------------------- MOUSE WAIT

mloop:	move	demoflag,d0
	bmi.b	removeVBI
	btst	#6,$bfe001		; Wait for left  mouse button
;	btst	#2,$dff016		; Wait for right mouse button
	bne.s	mloop

;---------------------------------------------------------- EXIT TO SYSTEM

removeVBI:
	move.w	#-1,pr_musicfadedirection
	move.w	#-1,demoflag
.wait	cmp.w	#-2,demoflag
	bne.s	.wait
.lp	tst.w	pr_musicfadect		; Now fading out...
	bne.s	.lp
	bsr.w	pr_end
	lea	$dff000,a6
	move.l	pr_Vectorbasept(pc),a0
	move	#$7fff,$9a(a6)
	move.l	oldVBI(pc),$6c(a0)
.exit	move	#$7fff,$9a(a6)		; disable interrupts
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
	moveq	#0,d0
	rts


;------------------------------------------------------------------------------

;------------------------------------------------------- VERTICAL BLANK ROUTINE

;------------------------------------------------------------------------------


VBI:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
;	move	#$f00,$dff180		; Rasterzeitmessung Anfang (rot)

	tst	demoflag
	bmi.w	Fadeout
	bne.w	vbimain			; jump to vbi mainroutine

;---------------------------------------------------------- FADE DEMO IN

FadeIn:	move	fadecounter(pc),d0	; fade mtn logo in
	beq.w	.movesprin
.fadein	lea	coltab(pc),a0
	lea	coptab+014,a1
	lsl	#4,d0
	lea	(a1,d0.w),a1
	moveq	#64-1,d7
.lp	move	(a0)+,(a1)
	add	#16,a1
	dbf	d7,.lp
	sub	#1,fadecounter
	bra.w	vbiEnd
.MoveSprIn
	move	sprpos(pc),d0
	cmp	#380,d0
	beq.b	sprdone
	addq	#8,d0			; sprite speed
	move	d0,sprpos
	bsr.w	MoveSpr
	bra.w	vbiEnd
sprdone	move	#1,demoflag
	bra.w	vbiEnd

;---------------------------------------------------------- FADE DEMO OUT

Fadeout:
	cmp	#-2,demoflag
	beq.b	.picweg
.sprweg	move	sprpos(pc),d0
	cmp	#60,d0			; end pos
	beq.b	.sprout
	subq	#8,d0			; sprite speed
	move	d0,sprpos
	bsr.w	MoveSpr
	bsr.w	Typewriter|.cls
	bra.w	vbiEnd
.sprout	move	#-2,demoflag
	bra.w	vbiEnd
.picweg	cmp	#302,fadecounter	; max pos
	bge.w	vbiEnd
	move	fadecounter(pc),d0
	lea	coltab2(pc),a0
	lea	coptab+010,a1
	lsl	#4,d0
	lea	(a1,d0.w),a1
	moveq	#8-1,d7
.lp	move	(a0),(a1)
	move	(a0)+,4(a1)
	add	#16,a1
	dbf	d7,.lp
	add	#2,fadecounter
	bra.w	vbiEnd

;---------------------------------------------------------- INTRO-MAIN-ROUTINE

vbiMain:
	bsr.w	Typewriter

vbiEnd:	bsr.w	pr_music
;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	lea	$dff000,a6
	move	#$0020,$9c(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rte

;---------------------------------------------------------- MOVE SPRITE MACRO

MoveSpr	lea	Spr1,a0
	moveq	#5-1,d7
	move	#285,d1
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3
	move.b	d1,(a0)
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3
.noE8:	add.w	#12,d1
	move.b	d1,2(a0)
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3
.noL8:	lsr.w	#1,d0
	bcc.b	.noH0
	bset	#0,d3
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	add	#16,d4
	move	d4,d0
	move	d5,d1
	lea	56(a0),a0
	dbf	d7,.spr
	rts

;---------------------------------------------------------- TYPE WRITER

ml	=	27		; maximal lines printed on screen

TypeWriter:
	move	freezer(pc),d0
	beq.b	.go
	subq	#1,d0
	btst	#2,$dff016		; rmt skips wait
	bne.b	.noskip
	moveq	#0,d0
.noskip	move	d0,freezer
	rts
.go	tst	clearflag
	bne.w	.cls
	lea	Font(pc),a2
.lp	lea	TextScreen+640,a1
	move	xoffset(pc),d1
	move	yoffset(pc),d2
	cmp	#640*ml,d2		; overflow !
	bgt	.overfl
	add	d1,a1
	add	d2,a1
.GetChar:
	moveq	#0,d0
	move.l	TxtPtr(pc),a0
	move.b	(a0)+,d0
	bne.b	.no0
	bsr.w	.cls
	lea	Text(pc),a0
	move.b	(a0)+,d0
.no0:	move.l	a0,TxtPtr
	cmp	#1,d0			; clear
	beq.w	.cls
	cmp	#2,d0			; wait
	beq.w	.wait
	cmp	#3,d0			; xskip
	beq.w	.xskip
	cmp	#4,d0			; yskip
	beq.w	.yskip
	cmp	#5,d0			; return
	beq.w	.eol
	cmp	#6,d0			; allow exit 
	beq.w	.exit
	cmp	#7,d0			; quit
	beq.w	.quit
.print:	sub	#32,d0
	beq.b	.skip			; don't print spaces !
	lsl	#03,d0
	lea	(a2,d0.w),a3
	move.b	(a3)+,000(a1)	; copy 1. line
	move.b	(a3)+,080(a1)	; copy 2. line
	move.b	(a3)+,160(a1)	; copy 3. line
	move.b	(a3)+,240(a1)	; copy 4. line
	move.b	(a3)+,320(a1)	; copy 5. line
	move.b	(a3)+,400(a1)	; copy 6. line
	move.b	(a3)+,480(a1)	; copy 7. line
	move.b	(a3)+,560(a1)	; copy 8. line
.skip:	addq	#1,d1		; x = x+1
	cmp	#79,d1
	bne.b	.nojump
	moveq	#00,d1
	add	#008*80,d2		; y = y+1
	cmp	#640*ml,d2
	ble.b	.nojump
.overfl	moveq	#$00,d1
	moveq	#$00,d2
	move	#70,freezer
	move	#$ff,clearflag
.nojump	move	d1,xoffset
	move	d2,yoffset
	rts

.wait:	move.b	(a0)+,d0
	move	d0,d1			; convert into seconds (x50)
	move	d0,d2
	lsl	#5,d0
	lsl	#4,d1
	lsl	#1,d2
	add	d2,d0
	add	d1,d0
	move	d0,freezer
	move.l	a0,TxtPtr
	rts

.cls:	move.l	a7,stack
	lea	fill(pc),a7
	movem.l	(a7),d0-d6/a0-a6	; clear	all regs ex. d7 & a7
	lea	TextScreen+20480,a7
	move	#365-1,d7
.clslp	movem.l	d0-d6/a0-a6,-(a7)
	dbf	d7,.clslp
	move.l	stack(pc),a7
	lea	$dff000,a6	
	move	d0,xoffset
	move	d0,yoffset
	move	d0,clearflag
	rts

.xskip	add.b	#10,d1			; tab
	cmp.b	#79,d1			; über den rand ?
	blo.b	.ok			; ne
.eol	moveq	#0,d1			; jo = next line
.yskip	add	#640+80,d2		; add 1 y line
	move	d2,yoffset
.ok	move	d1,xoffset
	rts

.exit	move	#2,demoflag
	rts
.quit	move.w	#-1,demoflag
	rts

;---------------------------------------------------------- TYPER-POINTER

stack:		dc.l	0		; store sys stack
freezer:	dc.w	0		; wait with printing
clearflag:	dc.w	0		; end of screen
xoffset:	dc.w	0		; writer x offset
yoffset		dc.w	0		; writer y offset
fill:		dcb.l	14,0		; clear stored
TxtPtr:		dc.l	PreText

;---------------------------------------------------------- SOUND POINTER

includefadingroutine	=	1
packedsongformat	=	1
fadingsteps		=	8	; 1-8

;---------------------------------------------------------- DEMO-POINTER

fadecounter	dc.w	246		; fix !	fadepos-logo
sprpos		dc.w	60		; fix ! movepos-spr
demoflag	dc.w	0	; 0=init 1=main 2=wait -1=fadeout -2=exit

;---------------------------------------------------------- SYS-POINTER

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
oldVBI		dc.l	0
gfxname		dc.b	'graphics.library',0,0
vbr_exception	dc.l	$4e7a7801		; movec vbr,d7
		rte				; back to user state code

;---------------------------------------------------------- COLOUR TABLES

Coltab:		dc.w	$000,$100,$200,$300,$400,$500,$600,$700 ; FadeInTab
		dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
		dc.w	$f10,$f20,$f30,$f40,$f50,$f60,$f60,$f70
		dc.w	$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0 ;
		dc.w	$ff2,$ff3,$ff4,$ff5,$ff6,$ff6,$ff7,$ff8
		dc.w	$ff9,$ffa,$ffb,$ffc,$ffc,$ffd,$ffe,$fff
		dc.w	$eee,$ddd,$ccc,$bbb,$bbb,$aaa,$aaa,$aaa
		dc.w	$aaa,$aaa,$aaa,$aaa,$aaa,$aaa,$aaa,$aaa
Coltab2:	dc.w	$888,$888,$888,$888,$99b,$88b,$77c,$55d

;---------------------------------------------------------- INCLUDES

		incdir	dh1:code/sources/
		include	`makros/prorunner.s`
Font:		include	`intro1/8x8Romanhex.s`


;---------------------------------------------------------- INIT TEXT

PreText:
 dc.b	1,4
 dc.b	`PLEASE STAND BY: Checking CPU !`,2,1,5
 dc.b	`.`,2,1,`.`,2,1,5,4
 dc.b	`PLEASE STAND BY: Checking RAM !`,2,1,5
 dc.b	`.`,2,1,5,4
 dc.b	`PLEASE STAND BY:`,2,1,` Calculating Text !`,2,1,5
 dc.b	`....................................................`,2,1,5,4
 dc.b	`PLEASE STAND BY: Correcting Spelling !`,2,1,5
 dc.b	`.`,2,1,`.`,2,1,`.`,2,1,`. `,5,4
 dc.b	`PLEASE STAND BY: Detecting Joystick !`,2,1,5
 dc.b	`..............................`,2,1,5,4
 dc.b	`PLEASE STAND BY: Precalculating Scrolltext for next Demo !`,2,1,5
 dc.b	`..................`,2,1,5,4
 dc.b	`PLEASE STAND BY: Reading TV-Movie !`,2,1,5
 dc.b	`..................`,2,1,5,4
 dc.b	`PLEASE STAND BY: Inserting useless NOPs!`,2,1,5
 dc.b	`...................................................................`,5
 dc.b	`...................................................................`,5
 
;---------------------------------------------------------- TYPER TEXT

Text:	; Sonderzeichen:	0 = Restart Text
	;			1 = Cls
	;			2 = Wait, Sekunden
	;			3 = xSkip (10 Spalten)
	;			4 = ySkip ( 1 Zeile)
	;			5 = Return
	;			6 = Allow Exit (MUST BE SET! Somewhere in Text)
	;			7 = Quit Intro


 dc.b	1,4,4,4,4,4
 dc.b	3,3,3,`     -=) HAZE (=-`,5,4
 dc.b	3,3,3,`          of`,5,4
 dc.b	3,3,3,`        MOTION`,5,4
 dc.b	3,3,3,`       presents`,5,4
 dc.b	3,3,3,`        a new`,5,4
 dc.b	3,3,3,`        Intro`,5,4
 dc.b	2,8

 dc.b	1,4,4,4,4
 dc.b	3,` Hab ich Euch gearscht ?`,2,2,3,`Weil:`,2,1,`.`,2,1,`.`,2,1,`. `,5,4
 dc.b	3,` Das ist nur ein Test `,2,2,`        Der Pause-Funktion`,5,4,4 
 dc.b	3,` Ach ja !  Solltest Du mit dem Gedanken spielen dieses    `,5,4
 dc.b	3,` tolle, geniale, meisterhafte, durchgestylte spitzen Intro`,5,4
 dc.b	3,` abzubrechen ..... `,2,3,`   Vergiss es !! Denk nicht mal daran !`,5,4
 dc.b	3,` Du kommst eh nicht raus !  HAR! HAR! HAR!    But now...   `,5,4,4,4
 dc.b	3,`          S T A R T   O F   T R A N S M I S S I O N`,2,6,6;(EXIT)

 dc.b	1,4,4,4,4
 dc.b	3,`Hach ja... So ein neues Intro gibt mir doch mal wieder 'ne`,5,4
 dc.b	3,`Gelegenheit mich bzw. uns (Haze) in Erinnerung zu rufen und`,5,4
 dc.b	3,`ein paar Messages abzulassen.`,5,4
 dc.b	3,`Und zwar an die folgenden Typen: `,5,2,5,1
 dc.b	4,4

 dc.b	1,4,4,3,3,3,`-) Hubba (-`,5,4
 dc.b	3,`Wie laeuft's denn so bei deinem Ziwi-Job bzw. Lehrgang ??`,5
 dc.b	3,`Wo ich grad dran denk.. wie sieht's mit der Anim aus ?`,5
 dc.b	3,`Haste se schon umgepinselt ?? Wenn ja ruf mich an !`,5
 dc.b	3,`Ich hab mit der andern schon ein bisschen rumgetestet und`,5
 dc.b	3,`hab dabei festgestellt, dass geloopte Anims besser kommen.`,5
 dc.b	3,`Du, wie sieht's denn mit Fonts aus ? Ich braeuchte unbedingt`,5
 dc.b	3,`zwei 8er und eine 16er `,5
 dc.b	3,`(Ich kann ja eh nur hoffen, dass Du dieses Ding zu sehen kriegst)`,5
 dc.b	2,20,1
 dc.b	4,4,3,3,3,`-) Dr.Dream (-`,5,4
 dc.b	3,`Waer toll, wenn Du Hubba das Ding hier geben wuerdest.`,5
 dc.b	3,`Und vor allem sag Carsten einen Gruss von mir !  Carrion `,5
 dc.b	3,`haben's ja voll drauf ! (doller Sound, and what a voice...`,5
 dc.b	3,`Uebrigens wann und wo ist denn das naechste Meeting ?`,5
 dc.b	3,`P.S. Koenntest Du dann dafuer sorgen, dass mich dann einer`,5
 dc.b	3,`     anruft und es mir mitteilt, weil vom letzten Meeting`,5
 dc.b	3,`     hab ich erst Tage danach was mitbekommen.`,5
 dc.b	2,20,1
 dc.b	4,4,3,3,3,`-) Mad Hatter (-`,5,4
 dc.b	3,`Du, also die Songs von Dir sind echt Hoellengoil !`,5
 dc.b	3,`Nur hab ich mich mit den Chiptunes leicht verhauen...`,5
 dc.b   3,`d.h.: ich hab keine Ahnung mehr welche von Dir sind,`,5
 dc.b	3,`weil erst hat mir Hubba welche gegeben, dann Fnord und`,5
 dc.b	3,`immer alles auf eine Disk, und jetzt fehlt mir echt der`,5
 dc.b	3,`Durchblick, aber ich weiss noch wage, dass die die 40k.x`,5
 dc.b	3,`heissen von Dir sind, aber die andern...????`,5
 dc.b	3,`Ok! Die mit so finnischen s'Moere'Broed-Texten fallen weg`,5
 dc.b	3,`aber es bleiben ca. 3-4 wo ich net sicher bin !`,5
 dc.b	3,`Ich hab uebrigens die Hoellenprobleme damit, deine Songs`,5
 dc.b	3,`von MED in Protracker zu portieren ! Vor allem der Speed`,5
 dc.b	3,`und manche Effecte machen die vollen Schwierigkeiten...`,5
 dc.b	3,`es waer echt nett von Dir, wenn Du mir sagen koenntest,`,5
 dc.b	3,`wie man's richtig macht... Und noch eins ! Verwende bitte`,5
 dc.b	3,`immer den VBI-Timer und NIE den BPM-Counter, weil den packt`,5
 dc.b	3,`meine Replay-Routine net...`,5
 dc.b	3,`Ich freu mich auf weitere kewle Mods von Dir !`,5
 dc.b	2,20,1

 dc.b	4,4,4,4,4
 dc.b	4,4,4,4,4,3,3
 dc.b	`    E `,2,1,`N `,2,1,`D `,2,1,`  O `,2,1,`F `,2,1,`  T`,2,1,` R`,2,1
 dc.b	` A`,2,1,` N`,2,1,` S`,2,1,` M`,2,1,` I`,2,1,` S`,2,1,` S`,2,1,` I`,2,1
 dc.b	` O`,2,1,` N`,2,1,` `,2,50,1
 dc.b	0,0,0,0

;---------------------------------------------------------- CHIPDATA

		section	ChipDatas,data_c

;---------------------------------------------------------- COPPERLIST -1-

Copperlist:	dc.w	$106,$0,$1fc,$0
Sprite:		dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$140,0,$150,0,$160,0,$170,0
		dc.w	$148,0,$158,0,$168,0,$178,0
		dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$000
		dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$000
		dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$000
		dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$000
Screen_Defs	dc.w	$8e,$3181,$90,$30c1,$92,$3c,$94,$d4
		dc.w	$102,$10,$104,$10,$108,0,$10a,0
		dc.w	$100,$b200
Colors		dc.w	$184,$444,$186,$444,$188,$fff
		dc.w	$18a,$fff,$18c,$fff,$18e,$fff
Planes:		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
;		dc.w	$ec,0,$ee,0
coptab:		ds.w	8*310
		dc.l	$fffffffe

;---------------------------------------------------------- MODULE

Module:		incbin	"tunes/mod.chip2.p" 

;---------------------------------------------------------- LOGO-SCREEN

		include	`makros/haze80x12x2.spr`
LogoScreen:	ds.b	43*80
		incbin	`intro1/MTN640x170x1.raw`
		ds.b	43*80

;---------------------------------------------------------- TEXT-SCEENS

		section	TextScreen,bss_c

TextScreen:	ds.b	20480

