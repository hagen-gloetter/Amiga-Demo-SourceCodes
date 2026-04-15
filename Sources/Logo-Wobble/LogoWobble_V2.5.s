
; 		Logowobble V1.6
;
; 	written by Duke of Haze Design of ?? on the 30.8.93
;
;
; Die Idee zum son' ding zu machen kam mir bei ner mtv session mit ner
; c&a young collection werbung. 
;
; P.S.: Man bin ich zur zeit kreativ drauf ! (ob das wohl an der liebe liegt ?)
;
; So ! speedmäßig ist das ding jetzt voll ausgereitzt ...
; und ist ca. 20-25 lines schneller als 1.5 ( blitter macht's moeglich !)

;---------------------------------------------------------- INIT DEMO

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
	move	#$0083e0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable
initcop	lea	copwob,a0
	move.l	#$6001fffe,d0
	move.l	#$01020000,d1
	move	#110-1,d7
.lp	move.l	d0,(a0)+
	move.l	d1,(a0)+
	add.l	#$01000000,d0
	dbf	d7,.lp
.center	lea	xsintab,a0
	move	(a0),d0
.lp2:	or	#$70,d0
	move	d0,(a0)+
	move	(a0),d0
	bpl	.lp2
.initSc	lea	ScPl+2(pc),a0
	move.l	#Scrollscreen+2,d0
	move	d0,4(a0)
	swap 	d0
	move	d0,(a0)
.initSp	lea	Spr1,a0
	moveq	#5-1,d7
	move	#375,d0
	move	#60,d1
	move	d0,d4
	move	d1,d5
.spr	moveq	#0,d3		; a0/d2/d0-d1 | Sprdaten/Sprhöhe/x-ypos
	move.b	d1,(a0)			; E0-E7
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3			; E8
.noE8:	add.w	#12,d1			; Spr Höhe
	move.b	d1,2(a0)		; L0-L7
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3			; L8
.noL8:	lsr.w	#1,d0			; H1-H8
	bcc.b	.noH0
	bset	#0,d3			; L8
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	add	#16,d4
	move	d4,d0
	move	d5,d1
	lea	56(a0),a0
	dbf	d7,.spr
	move.l	#Spr1,d0
	lea	Sprite+2,a0
	moveq	#5-1,d7
.slp	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add	#56,d0
	addq	#8,a0
	dbf	d7,.slp
	jsr	mt_init

;---------------------------------------------------------- WAITVBEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	4(a6),d0
	and.l	#$fffff00,d0		
	bne.s	WaitVBeam

;	move	#$f00,$dff180		; Rasterzeitmessung Beginn (rot)

;---------------------------------------------------------- TRIBBLE BUFFERING

TBuff:	lea	FrontScreen(pc),a0
	lea	Planes+2(pc),a1
	movem.l	(a0),d0-d2
	exg	d0,d1
	exg	d1,d2
	movem.l	d0-d2,(a0)
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
	move	d2,(a1)
	swap	d2
	move	d2,4(a1)

;---------------------------------------------------------- CLEAR DEL SCREEN

.ClearDelScreen:
	btst	#14,$02(a6)
	bne.b	.ClearDelScreen
	move.l	#$1000000,$40(a6)
	clr.w	$66(a6)
	move.l	d1,$54(a6)
	move	#[120*64]+[320/16],$58(a6)

;---------------------------------------------------------- MAIN ROUTINE

	bsr.w	DoWobble

;---------------------------------------------------------- MOUSE WAIT

;	move	#$0f0,$dff180		; Rasterzeitmessung Ende (grün)
	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.w	WaitVBeam
	jsr	mt_end


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

ysinptr		dc.w	0
syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
FrontScreen:	dc.l	Screen1
DelScreen:	dc.l	Screen2
HiddenScreen:	dc.l	Screen3
gfxname		dc.b	'graphics.library',0
		even

		incdir	dh1:code/sources/
Hazetab:	incbin	`logowobble/mtntab.b`


;---------------------------------------------------------- COPPERLIST

cop:	dc.w	$1fc,0,$106,0,$100,0
Sprite:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0
	dc.w	$140,0,$150,0,$160,0,$170,0
	dc.w	$148,0,$158,0,$168,0,$178,0
	dc.w	$1a0,0,$1a2,$fff,$1a4,$555,$1a6,$000
	dc.w	$1a8,0,$1aa,$fff,$1ac,$555,$1ae,$000
	dc.w	$1b0,0,$1b2,$fff,$1b4,$555,$1b6,$000
	dc.w	$1b8,0,$1ba,$fff,$1bc,$555,$1be,$000
	dc.w	$2001,$fffe
	dc.w	$100,$1200,$108,-40,$10a,-40
cols:	dc.w	$180,$888,$182,$bbb,$184,$777,$186,$aaa
	dc.w	$8e,$2181,$90,$2bc1,$92,$38,$94,$d0
	dc.w	$102,0,$104,$10;,$108,0,$10a,0
	dc.w	$6101,$fffe,$108,0,$10a,0
Planes:	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$100,$2200
copwob	ds.w	4*110
	dc.w	$d901,$fffe,$100,$0,$102,0
	dc.w	$fb01,$fffe
	dc.w	$100,$1200,$182,$999
	dc.w	$92,$30,$94,$d4,$108,2,$10a,0
ScPl:	dc.w	$e0,0,$e2,0
	dc.w	$ffe1,$fffe
	dc.w	$2b01,$fffe,$100,0
	dc.l	$fffffffe

;---------------------------------------------------------- YSinTab

YSintab:	;	(512 Werte)
	dc.w	$1900,$1900,$1a40,$1a40,$1a40,$1a40,$1b80,$1b80,$1b80,$1b80
	dc.w	$1cc0,$1cc0,$1cc0,$1cc0,$1e00,$1e00,$1e00,$1e00,$1f40,$1f40
	dc.w	$1f40,$1f40,$1f40,$2080,$2080,$2080,$2080,$21c0,$21c0,$21c0
	dc.w	$21c0,$2300,$2300,$2300,$2300,$2300,$2440,$2440,$2440,$2440
	dc.w	$2580,$2580,$2580,$2580,$2580,$26c0,$26c0,$26c0,$26c0,$26c0
	dc.w	$2800,$2800,$2800,$2800,$2800,$2940,$2940,$2940,$2940,$2940
	dc.w	$2a80,$2a80,$2a80,$2a80,$2a80,$2a80,$2bc0,$2bc0,$2bc0,$2bc0
	dc.w	$2bc0,$2bc0,$2d00,$2d00,$2d00,$2d00,$2d00,$2d00,$2d00,$2e40
	dc.w	$2e40,$2e40,$2e40,$2e40,$2e40,$2e40,$2e40,$2f80,$2f80,$2f80
	dc.w	$2f80,$2f80,$2f80,$2f80,$2f80,$2f80,$30c0,$30c0,$30c0,$30c0
	dc.w	$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0
	dc.w	$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200
	dc.w	$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200
	dc.w	$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200,$3200
	dc.w	$3200,$3200,$3200,$3200,$3200,$3200,$30c0,$30c0,$30c0,$30c0
	dc.w	$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0,$30c0
	dc.w	$2f80,$2f80,$2f80,$2f80,$2f80,$2f80,$2f80,$2f80,$2f80,$2e40
	dc.w	$2e40,$2e40,$2e40,$2e40,$2e40,$2e40,$2e40,$2d00,$2d00,$2d00
	dc.w	$2d00,$2d00,$2d00,$2d00,$2bc0,$2bc0,$2bc0,$2bc0,$2bc0,$2bc0
	dc.w	$2a80,$2a80,$2a80,$2a80,$2a80,$2a80,$2940,$2940,$2940,$2940
	dc.w	$2940,$2800,$2800,$2800,$2800,$2800,$26c0,$26c0,$26c0,$26c0
	dc.w	$26c0,$2580,$2580,$2580,$2580,$2580,$2440,$2440,$2440,$2440
	dc.w	$2300,$2300,$2300,$2300,$2300,$21c0,$21c0,$21c0,$21c0,$2080
	dc.w	$2080,$2080,$2080,$1f40,$1f40,$1f40,$1f40,$1f40,$1e00,$1e00
	dc.w	$1e00,$1e00,$1cc0,$1cc0,$1cc0,$1cc0,$1b80,$1b80,$1b80,$1b80
	dc.w	$1a40,$1a40,$1a40,$1a40,$1900,$1900,$1900,$1900,$17c0,$17c0
	dc.w	$17c0,$17c0,$1680,$1680,$1680,$1680,$1540,$1540,$1540,$1540
	dc.w	$1400,$1400,$1400,$1400,$12c0,$12c0,$12c0,$12c0,$12c0,$1180
	dc.w	$1180,$1180,$1180,$1040,$1040,$1040,$1040,$0f00,$0f00,$0f00
	dc.w	$0f00,$0f00,$0dc0,$0dc0,$0dc0,$0dc0,$0c80,$0c80,$0c80,$0c80
	dc.w	$0c80,$0b40,$0b40,$0b40,$0b40,$0b40,$0a00,$0a00,$0a00,$0a00
	dc.w	$0a00,$08c0,$08c0,$08c0,$08c0,$08c0,$0780,$0780,$0780,$0780
	dc.w	$0780,$0780,$0640,$0640,$0640,$0640,$0640,$0640,$0500,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$03c0,$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	dc.w	$0280,$0280,$0140,$0140,$0140,$0140,$0140,$0140,$0140,$0140
	dc.w	$0140,$0140,$0140,$0140,$0140,$0140,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0140,$0140,$0140,$0140,$0140,$0140,$0140,$0140
	dc.w	$0140,$0140,$0140,$0140,$0140,$0140,$0280,$0280,$0280,$0280
	dc.w	$0280,$0280,$0280,$0280,$0280,$03c0,$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0640,$0640,$0640,$0640,$0640,$0640,$0780,$0780,$0780,$0780
	dc.w	$0780,$0780,$08c0,$08c0,$08c0,$08c0,$08c0,$0a00,$0a00,$0a00
	dc.w	$0a00,$0a00,$0b40,$0b40,$0b40,$0b40,$0b40,$0c80,$0c80,$0c80
	dc.w	$0c80,$0c80,$0dc0,$0dc0,$0dc0,$0dc0,$0f00,$0f00,$0f00,$0f00
	dc.w	$0f00,$1040,$1040,$1040,$1040,$1180,$1180,$1180,$1180,$12c0
	dc.w	$12c0,$12c0,$12c0,$12c0,$1400,$1400,$1400,$1400,$1540,$1540
	dc.w	$1540,$1540,$1680,$1680,$1680,$1680,$17c0,$17c0,$17c0,$17c0
	dc.w	$1900,$1900


SprMOveTab:	; from 0 degrees to 90 degrees. amount of values = 256
	dc.w	0,2,5,7,9,11,14,16
	dc.w	18,20,23,25,27,29,32,34
	dc.w	36,39,41,43,45,48,50,52
	dc.w	54,57,59,61,63,65,68,70
	dc.w	72,74,77,79,81,83,85,88
	dc.w	90,92,94,96,99,101,103,105
	dc.w	107,110,112,114,116,118,120,123
	dc.w	125,127,129,131,133,135,137,139
	dc.w	142,144,146,148,150,152,154,156
	dc.w	158,160,162,164,166,168,170,172
	dc.w	174,176,178,180,182,184,186,188
	dc.w	190,192,194,196,198,200,202,204
	dc.w	206,207,209,211,213,215,217,219
	dc.w	220,222,224,226,228,229,231,233
	dc.w	235,236,238,240,242,243,245,247
	dc.w	248,250,252,253,255,257,258,260
	dc.w	262,263,265,266,268,270,271,273
	dc.w	274,276,277,279,280,282,283,285
	dc.w	286,287,289,290,292,293,294,296
	dc.w	297,299,300,301,303,304,305,306
	dc.w	308,309,310,311,313,314,315,316
	dc.w	317,319,320,321,322,323,324,325
	dc.w	326,327,328,329,330,332,333,333
	dc.w	334,335,336,337,338,339,340,341
	dc.w	342,343,344,344,345,346,347,348
	dc.w	348,349,350,351,351,352,353,353
	dc.w	354,355,355,356,357,357,358,358
	dc.w	359,359,360,361,361,362,362,362
	dc.w	363,363,364,364,365,365,365,366
	dc.w	366,366,367,367,367,367,368,368
	dc.w	368,368,369,369,369,369,369,369
	dc.w	370,370,370,370,370,370,370,370
	dc.l	0

;---------------------------------------------------------- SETDOTS 

DoWobble:
	move.l	d0,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	lea	HazeTab(pc),a0
	lea	YSintab(pc),a2
	move	ysinptr(pc),d1
	addq	#6,d1
	and	#1023,d1
	move	d1,ysinptr
	rept	6*320
	move	(a0)+,d0
	beq.b	*+16		; 8ung fixer jump (nicht die feine eng, aber..)
	add	(a2,d1.w),d0
	move.b	d0,d2
	lsr	#3,d0
	not.b	d2
	bset	d2,(a1,d0.w)
	addq	#2,d1		; jump to here
	and	#1023,d1
	endr

;---------------------------------------------------------- XWobble

DoXWobble:
	moveq	#0,d0
	lea	copwob+6,a2
	lea	XSintab(pc),a0
	move	xsinptr(pc),d0
	add.b	#2,d0
	and.b	#255,d0
	move	d0,xsinptr
	lea	(a0,d0.w),a0
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move.l	#$9f00000,$40(a6)
	move.l	#$fffffff,$44(a6)
	move.l	#$0000006,$64(a6)
	movem.l	a0/a2,$50(a6)
	move	#[110*64]+[16/16],$58(a6)

;	move	#$f,$dff180		; Rasterzeitzwischenstand


;---------------------------------------------------------- CPU FILL

CPUFill:				; Geniestrech !
	lea	(a1),a0			; Adr der zu füllenden Bitmap
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	rept	5
	move.l	a0,a1			; StartAdr sichern
	rept	115			; Höhe des zu füllenden Bereichs
	movem.l	(a1),d0-d1		; Neue Daten aus Bmp holen
	eor.l	d0,d2			;
	eor.l	d1,d3			;
	movem.l	d2/d3,(a1)		; Modifizierte Daten zurückschreiben
	lea	40(a1),a1		; Eine Zeile tiefer 
	endr
	addq	#8,a0			; +32 Pixel
	endr

;---------------------------------------------------------- Scroller

Scroller:
	lea	counter(pc),a0
	subq	#2,counter
	bpl.b	.soft
.hard:	moveq	#0,d0
	lea	Font(pc),a0
	move.l	TextPointer(pc),a5
	move.b	(a5)+,d0
	bne.b	.no0
	lea	Scrolltext(pc),a5
	move.b	(a5)+,d0
.no0:	move.l	a5,TextPointer
	sub	#$20,d0
	lsl	#5,d0
	lea	(a0,d0.w),a0		; offset zur quelle addieren
	lea	ScrollScreen+46(pc),a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#0,$64(a6)
	move	#44,$66(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[16/16],$58(a6)
	move	#$f,counter
.soft:	lea	ScrollScreen(pc),a1
	lea	2(a1),a0
.wblt2:	btst	#14,$02(a6)
	bne.b	.wblt2
	move	#0,$64(a6)
	move	#0,$66(a6)
	move.l	#$e9f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[368/16],$58(a6)
;	move	#$0f,$dff180
	bsr	mt_music
;	move	#$f00,$dff180
	rts

;---------------------------------------------------------- Scroller Defs

counter:	dc.w	0
TextPointer:	dc.l	Scrolltext
Scrolltext:
	dc.b	`TURN ON THE TUBE, WHAT DO I SEE ?   `
	dc.b	`A BUNCH OF HATEFUL PEOPLE TALKING TO ME   `
	dc.b	`THE CRAP THEY SAY'S BEEN HEARD BEFORE   `
	dc.b	`AND THAT'S WHAT STARTED UP THE 2ND WORLD WAR   `
	dc.b	`   `
	dc.b	`SO MANY PEOPLE SEE WHAT'S GOING ON   `
	dc.b	`HEADS SHOULD BE LIFTED   `
	dc.b	`   `
	dc.b	`KEEP YOUR EYE ON THE TWISTED   `
	dc.b	`WE'VE SEEN IT ALL BEFORE   `
	dc.b	`LITTLE MINDS CAN'T BE SHIFTED   `
	dc.b	`WATCH OUT THEY ARE BACK FOR MORE   `
	dc.b	`   `
	dc.b	`THEY CALL IT PRIDE TO WAVE THE FLAG   `
	dc.b	`SHAVING THE HAIR OFF THEIR BRAINLESS HEADS   `
	dc.b	`I THINK THE WORLD HAS SEEN ENOUGH   `
	dc.b	`THERE IS TOO MUCH TALKING NOW IT'S TIME TO GET TOUGH   `
	dc.b	`   `
	dc.b	`TOO MANY PEOPLE KNOW WHAT'S GOING DOWN   ` 
	dc.b	`HEADS SHOULD BE LIFTED   `
	dc.b	`   `
	dc.b	`KEEP YOUR EYE ON THE TWISTED   `
	dc.b	`WE'VE SEEN IT ALL BEFORE   `
	dc.b	`LITTLE MINDS CAN'T BE SHIFTED   `
	dc.b	`WATCH OUT THEY ARE BACK FOR MORE   `
	dc.b	`   `
	dc.b	`HEY TWISTED - WHAT'S IN YOUR HEAD - SO TWISTED   `
	dc.b	`HEY TWISTED - GO CLEAR YOUR MIND - YOU'RE MISLED   `
	dc.b	`   `
	dc.b	`STEPS SHOULD BE TAKEN TO STOP WHAT THEY'RE MAKIN'   `
	dc.b	`HEADS SHOULD BE LIFTED... TO SEE WHAT'S GOING ON   `
	dc.b	`   `
	dc.b	`THEY SPREAD THEIR MENTAL DISEASE   `
	dc.b	`IGNORANCE NEEDS A LEADER TO MAKE THEIR MASS INCREASE   `
	dc.b	`   `
	dc.b	`SO KEEP YOUR EYE ON THE TWISTED...   `
	dc.b	`   `
	dc.b	`LYRICS TAKEN FROM "KEEP YOUR EYE ON THE TWISTED"   `
	dc.b	`BY PINK CREAM 69                                 ` 
	dc.b	`THIS IS THE FIRST INTRO RELEASE EVER FROM   `
	dc.b	`(HAZE) OF >MOTION< !      SEE YOU SOON IN ANOTHER   `
	dc.b	`KEWL INTRO BY (HAZE)                         ` 
	dc.b	`CODE BY (DUKE)        IDEA BY (FNORD) & (DUKE)         `
	dc.b	`(HAZE) TO BOLDLY GO, WHERE NO SANE HAS GONE BEFORE !   `
	DC.B	`                  (C)  BY HAZE OF MOTION             <<<    `
	dc.b	0
	even

Font:		incbin	`logowobble/Font16x16x1.raw`
ScrollScreen:	ds.b	48*50


;----------------------------------------------------------Sinustabelle

xsinptr		dc.w	0
XSintab:	; 	(128 Werte)
	dc.w	7,7,8,8,9,9,9,10,10,10,11,11,11,12,12,12
	dc.w	13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,15
	dc.w	15,15,15,15,15,15,15,15,14,14,14,14,14,13,13,13
	dc.w	13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,7
	dc.w	7,7,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,1,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,7
copyofxtab:
	dc.w	7,7,8,8,9,9,9,10,10,10,11,11,11,12,12,12
	dc.w	13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,15
	dc.w	15,15,15,15,15,15,15,15,14,14,14,14,14,13,13,13
	dc.w	13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,7
	dc.w	7,7,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,1,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	dc.w	1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,7
	dc.w	-1

;---------------------------------------------------------- BITPLANES

		include	`makros/haze80x12x2.spr`
		include	`makros/streplay3.s`
mt_data:	incbin	`tunes/mod.tears`
Screen1:	dcb.b	120*40,0
Screen2:	dcb.b	120*40,0
Screen3:	dcb.b	120*40,0

