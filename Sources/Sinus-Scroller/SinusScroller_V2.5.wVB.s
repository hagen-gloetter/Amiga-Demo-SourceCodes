;TOSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
*******************************************************************
*****  SinusScroller V2.1 Coded & © by Hagen Glötter 9.11.92  *****
*******************************************************************

; Sinus & Copperscroller sind jetzt nicht mehr VBI getakte und läuft
; deshalb auch einwandfrei auf Turborechnern (getestet) !! (VERY STOLZ)
; Einfach gut ! Bei Duke ist's einfach gut ......

	section sinusscroller,code_c

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking terminieren
	bsr.w	PreCalc
	bsr.w	initBitPlane
	bsr.w	initCopScroll
	bsr.w	DoSpr
	move.l	#-1,$44(a6)		; Blittermaske killen
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2
	bsr.w	mt_init

;--------------------------------------------------------------------

WaitVBeam:
	lea	$dff000,a6
	move.l	$4(a6),d0
	and.l	#$000ff00,d0
	cmp.l	#$0002000,d0
	bne.b	WaitVBeam
;	move	#$500,$dff180		; Rasterzeitmessung Anfang (rot)
	bsr.w	SinusScroller
	bsr.w	CopScroller
;	move	#$050,$dff180		; Rasterzeitmessung Ende   (grün)
	bsr.w	mt_music
;	move	#$050,$dff180		; Rasterzeitmessung Music  (blau)
	btst	#6,$bfe001
	bne.b	WaitVBeam
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	bsr.w	mt_off
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts
	
;--------------------------------------------------------------------

InitBitPlane:
	lea	Screen1(pc),a0
	lea	Planes(pc),a2
	move	#$e0,d1
	move.l	a0,d0
	swap	d0
	move	d1,(a2)+
	move	d0,(a2)+
	addq	#2,d1
	move	d1,(a2)+
	move	a0,(a2)+
	move	d0,Screen1H
	move	a0,Screen1L
	lea	Screen2(pc),a0
	move.l	a0,d0
	swap	d0
	move	d0,Screen2H
	move	a0,Screen2L

InitLogoPlane:
	lea	LScreen(pc),a0
	lea	LPlane(pc),a2
	move	#$e0,d1
	moveq	#4-1,d7
.lp	move.l	a0,d0
	swap	d0
	move	d1,(a2)+
	move	d0,(a2)+
	addq	#2,d1
	move	d1,(a2)+
	move	a0,(a2)+
	addq	#2,d1
	add	#2400,a0
	dbf	d7,.lp
	lea	Logo,a0
	lea	LScreen,a1
	moveq	#4-1,d7
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#-1,$44(a6)
	clr.l	$64(a6)
	move	#%0000100111110000,$40(a6)
	clr	$42(a6)
	movem.l	a0-a1,$50(a6)
	move	#[32*64]+[320/16],$58(a6)
	add	#1280,a0
	add	#2400,a1
	dbf	d7,.wblt
	lea	LCols(pc),a1
	move	#$180,d0
	moveq	#16-1,d1
.clp:	move	d0,(a1)+
	move	(a0)+,(a1)+
	addq	#2,d0
	dbf	d1,.clp
	rts

;--------------------------------------------------------------------

initCopScroll:
	lea	Bcol,a2
	move.l	#$6e07fffe,d0
	move.l	#$01800000,d1
	move	#$0182,d2
	move.l	ColPtr,a5
	move	#135-1,d7
.lp:	move.l	d0,(a2)+	
	move.l	d1,(a2)+	
	move	d2,(a2)+	
	move	(a5),d3
	bne.b	.go
	lea	ColTab,a5	
	move	(a5),d3
.go:	move	d3,(a2)+	
	move.l	a5,ColPtr
	add.l	#$01000000,d0
	addq	#2,a5
	dbf	d7,.lp
	rts

;--------------------------------------------------------------------

CopScroller:
	lea	Bcol+22(pc),a0
	lea	Bcol+10(pc),a1
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#-1,$44(a6)
	move	#10,$64(a6)
	move	#10,$66(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[134*64]+[16/16],$58(a6)
	lea	Bcol,a0
	move.l	ColPtr,a5
	move	(a5),d0
	bne.b	.go
	lea	ColTab,a5	
	move	(a5),d0
.go:	addq	#2,a5
	move.l	a5,ColPtr
	move	d0,1618(a0)
	rts

;--------------------------------------------------------------------

BltScroll:
	move	ScWait,d0
	beq.b	.nwait
	subq	#1,d0
	move	d0,ScWait
	rts
.nwait:	move	Scptr(pc),d1
	subq	#1,d1
	bne.w	.NoLtr
	moveq	#0,d0
	move.l	TextPointer(pc),a5
	move.b	(a5),d0
	bne.b	.no0
	lea	ScrollText(pc),a5
	move.b	(a5),d0
.no0:	cmp	#1,d0
	bne.b	.no1
	move	#100,ScWait
	addq	#1,a5
	move.b	(a5),d0
.no1:	sub	#$20,d0
	lsl.l	#5,d0
	addq	#1,a5
	move.l	a5,TextPointer
.print:	lea	Scroller+42(pc),a1
	lea	Font(pc),a0
	add	d0,a0
.wb3:	btst	#14,$02(a6)
	bne.b	.wb3
	move	#-1,$44(a6)
	move	#0,$64(a6)
	move	#40,$66(a6)
	move.l	#$9f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[16/16],$58(a6)
	lea	Scroller(pc),a1
	lea	2(a1),a0
.lwblt:	btst	#14,$02(a6)
	bne.b	.lwblt
	clr.l	$64(a6)
	move	ScSpeed,d3
	move	#$9f0,d4
	or	d3,d4
	move	d4,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[320/16],$58(a6)
	move	#16,Scptr
	rts

;--------------------------------------------------------------------

.NoLtr:	move	d1,Scptr
	lea	Scroller(pc),a1
	lea	2(a1),a0
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	#-1,$44(a6)
	clr.l	$64(a6)
	move	ScSpeed,d3
	move	#$9f0,d4
	or	d3,d4
	move	d4,$40(a6)
	clr	$42(a6)
	movem.l	a0-a1,$50(a6)
	move	#[16*64]+[320/16],$58(a6)
	rts

;--------------------------------------------------------------------

SinusScroller:
	bsr.w	BltScroll
	move	BPtr(pc),d0
	bne.b	.sc2
.sc1:	lea	Planes(pc),a0
	move	Screen2H(pc),2(a0)
	move	Screen2L(pc),6(a0)
	move	#1,BPtr
	lea	Screen1(pc),a3
	bsr.w	Clr
	bra.b	DoSin
.sc2:	lea	Planes(pc),a0
	move	Screen1H(pc),2(a0)
	move	Screen1L(pc),6(a0)
	clr	BPtr
	lea	Screen2(pc),a3
	bsr.w	Clr
DoSin:	lea	Scroller+2(pc),a1
	move.l	SinPtr(pc),a5
	move	(a5),d5
	bne.b	.no0
	lea	Sintab(pc),a5
	move	(a5),d5
.no0:	addq	#8,a5
	move.l	a5,SinPtr
.wbltr:	btst	#14,$02(a6)
	bne.b	.wbltr
	move	#38,d0				; Modulo B
	move	#40,d1				; Modulo A
	move	d0,d2				; Modulo D
	movem	d0-d2,$62(a6)			; Modulo B
	move.l	#$0dfc0000,$40(a6)		; Bltcon0 + Bltcon1
	move	#%1000000000000000,d3		; Mask A 1
	move	#-1,$46(a6)			; Mask A 2
	moveq	#20,d6
.lp2:	move	d3,d4				; restore mask A
	moveq	#16,d7
.lp:	move.l	a3,a0				; restore Source
	move	(a5),d5
	bne.b	.noend
	lea	Sintab,a5
	move	(a5),d5
.noend:	add	d5,a0				; add offset
	move.l	a0,a2				; D = B
.wblt:	btst	#14,$02(a6)
	bne.b	.wblt
	move	d4,$44(a6)			; Mask A
	movem.l	a0-a2,$4c(a6)			; Quelle B+A+D
	move	#[16*64]+[16/16],$58(a6)	; BltSize
	addq	#2,a5
	lsr	#1,d4
	subq	#1,d7
	bne.b	.lp
	addq	#2,a3
	addq	#2,a1
	subq	#1,d6
	bne.b	.lp2
	rts

;--------------------------------------------------------------------

Clr:	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a7,StoreA7
	move.l	a3,a7
	add	#5460,a7	; 134*40 (+20)
	lea	Fill(pc),a6
	movem.l	(a6)+,d0-d7/a0-a5
	sub.l	a6,a6
	rept	91	
	movem.l	d0-d7/a0-a6,-(a7)
	endr
	move.l	StoreA7,a7
	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------

DoSpr:	lea	DSpr(pc),a0
	lea	SprDat(pc),a1
	move	#417,d0
	move	#248,d1
	bsr.b	CalcCW
	add	#28,a0
	add	#8,a1
	move	#433,d0
	move	#248,d1
CalcCW:	move.l	a0,d4
	swap	d4
	move	d4,2(a1)
	move	a0,6(a1)
	moveq	#0,d3
	moveq	#6,d2
	move.b	d1,(a0)
	btst	#8,d1
	beq.b	.noE8
	bset	#2,d3
.noE8:	add.w	d2,d1
	move.b	d1,2(a0)
	btst	#8,d1
	beq.b	.noL8
	bset	#1,d3
.noL8:	lsr.w	#1,d0
	bcc.b	.noH0
	bset	#0,d3
.noH0:	move.b	d0,1(a0)
	move.b	d3,3(a0)
	rts	

;--------------------------------------------------------------------

PreCalc:
	lea	SinTab(pc),a5
.lp:	move	(a5),d5
	bne.b	.go
	rts
.go:	move	d5,d0
	lsl	#5,d5				;  d5*32
	lsl	#3,d0				;  +d0*8
	add	d0,d5				; = mulu #40,d5
	move	d5,(a5)
	addq	#2,a5
	bra.b	.lp

;--------------------------------------------------------------------

SinTab:	; 400 Werte
	dc.w	60,61,62,63,64,65,66,67,68,68,69,70,71,72,73,74
	dc.w	75,76,77,78,79,79,80,81,82,83,84,85,86,86,87,88
	dc.w	89,90,91,91,92,93,94,95,95,96,97,98,98,99,100,100
	dc.w	101,102,102,103,104,104,105,106,106,107,107,108
	dc.w	109,109,110,110,111,111,112,112,113,113,113,114
	dc.w	114,115,115,115,116,116,116,117,117,117,118,118
	dc.w	118,118,119,119,119,119,119,119,120,120,120,120
	dc.w	120,120,120,120,120,120,120,120,120,120,120,120
	dc.w	120,119,119,119,119,119,119,118,118,118,118,117
	dc.w	117,117,116,116,116,115,115,115,114,114,113,113
	dc.w	113,112,112,111,111,110,110,109,109,108,107,107
	dc.w	106,106,105,104,104,103,102,102,101,100,100,99
	dc.w	98,98,97,96,95,95,94,93,92,91,91,90,89,88,87,86
	dc.w	86,85,84,83,82,81,80,79,79,78,77,76,75,74,73,72
	dc.w	71,70,69,68,68,67,66,65,64,63,62,61,60,59,58,57
	dc.w	56,55,54,53,52,52,51,50,49,48,47,46,45,44,43,42
	dc.w	41,41,40,39,38,37,36,35,34,34,33,32,31,30,29,29
	dc.w	28,27,26,25,25,24,23,22,22,21,20,20,19,18,18,17
	dc.w	16,16,15,14,14,13,13,12,11,11,10,10,9,9,8,8,7,7,7,6
	dc.w	6,5,5,5,4,4,4,3,3,3,2,2,2,2,1,1
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,5
	dc.w	6,6,7,7,7,8,8,9,9,10,10,11,11,12,13,13
	dc.w	14,14,15,16,16,17,18,18,19,20,20,21,22,22,23,24
	dc.w	25,25,26,27,28,29,29,30,31,32,33,34,34,35,36,37
	dc.w	38,39,40,41,41,42,43,44,45,46,47,48,49,50,51,52
	dc.w	52,53,54,55,56,57,58,59
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	` -------> CODING BY DUKE OF PRESTIGE IN '92 <--------- `
	dc.b	`CALL OUR BOARD (EHQ) +049-07152-55546 IF YA WANNA HAVE `
	dc.b	`SOME HACK TALK WITH ME, BUT NOW FUCK YOUR SLIMY EYES `
	dc.b	`AND HANDS OUT OF MY CODE !      -SIGNED OFF DUKE/PST-  `
ColTab:	dc.w	$f0f,$f0f,$f0f,$f0f,$f0f,$f0e,$f0e,$f0e,$f0e,$f0e
	dc.w	$f0d,$f0d,$f0d,$f0d,$f0d,$f0c,$f0c,$f0c,$f0c,$f0c
	dc.w	$f0b,$f0b,$f0b,$f0b,$f0b,$f0a,$f0a,$f0a,$f0a,$f0a
	dc.w	$f09,$f09,$f09,$f09,$f09,$f08,$f08,$f08,$f08,$f08
	dc.w	$f07,$f07,$f07,$f07,$f07,$f06,$f06,$f06,$f06,$f06
	dc.w	$f05,$f05,$f05,$f05,$f05,$f04,$f04,$f04,$f04,$f04
	dc.w	$f03,$f03,$f03,$f03,$f03,$f02,$f02,$f02,$f02,$f02
	dc.w	$f01,$f01,$f01,$f01,$f01,$f00,$f00,$f00,$f00,$f00
	dc.w	$f10,$f10,$f10,$f10,$f10,$f20,$f20,$f20,$f20,$f20
	dc.w	$f30,$f30,$f30,$f30,$f30,$f40,$f40,$f40,$f40,$f40
	dc.w	$f50,$f50,$f50,$f50,$f50,$f60,$f60,$f60,$f60,$f60
	dc.w	$f70,$f70,$f70,$f70,$f70,$f80,$f80,$f80,$f80,$f80
	dc.w	$f90,$f90,$f90,$f90,$f90,$fa0,$fa0,$fa0,$fa0,$fa0
	dc.w	$fb0,$fb0,$fb0,$fb0,$fb0,$fc0,$fc0,$fc0,$fc0,$fc0
	dc.w	$fd0,$fd0,$fd0,$fd0,$fd0,$fe0,$fe0,$fe0,$fe0,$fe0
	dc.w	$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0,$ff0
	dc.w	$ef0,$ef0,$ef0,$ef0,$ef0,$df0,$df0,$df0,$df0,$df0
	dc.w	$cf0,$cf0,$cf0,$cf0,$cf0,$bf0,$bf0,$bf0,$bf0,$bf0
	dc.w	$af0,$af0,$af0,$af0,$af0,$9f0,$9f0,$9f0,$9f0,$9f0
	dc.w	$8f0,$8f0,$8f0,$8f0,$8f0,$7f0,$7f0,$7f0,$7f0,$7f0
	dc.w	$6f0,$6f0,$6f0,$6f0,$6f0,$5f0,$5f0,$5f0,$5f0,$5f0
	dc.w	$4f0,$4f0,$4f0,$4f0,$4f0,$3f0,$3f0,$3f0,$3f0,$3f0
	dc.w	$2f0,$2f0,$2f0,$2f0,$2f0,$1f0,$1f0,$1f0,$1f0,$1f0
	dc.w	$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0
	dc.w	$0f1,$0f1,$0f1,$0f1,$0f1,$0f2,$0f2,$0f2,$0f2,$0f2
	dc.w	$0f3,$0f3,$0f3,$0f3,$0f3,$0f4,$0f4,$0f4,$0f4,$0f4
	dc.w	$0f5,$0f5,$0f5,$0f5,$0f5,$0f6,$0f6,$0f6,$0f6,$0f6
	dc.w	$0f7,$0f7,$0f7,$0f7,$0f7,$0f8,$0f8,$0f8,$0f8,$0f8
	dc.w	$0f9,$0f9,$0f9,$0f9,$0f9,$0fa,$0fa,$0fa,$0fa,$0fa
	dc.w	$0fb,$0fb,$0fb,$0fb,$0fb,$0fc,$0fc,$0fc,$0fc,$0fc
	dc.w	$0fd,$0fd,$0fd,$0fd,$0fd,$0fe,$0fe,$0fe,$0fe,$0fe
	dc.w	$0ff,$0ff,$0ff,$0ff,$0ff,$0ff,$0ff,$0ff,$0ff,$0ff
	dc.w	$0ef,$0ef,$0ef,$0ef,$0ef,$0df,$0df,$0df,$0df,$0df
	dc.w	$0cf,$0cf,$0cf,$0cf,$0cf,$0bf,$0bf,$0bf,$0bf,$0bf
	dc.w	$0af,$0af,$0af,$0af,$0af,$09f,$09f,$09f,$09f,$09f
	dc.w	$08f,$08f,$08f,$08f,$08f,$07f,$07f,$07f,$07f,$07f
	dc.w	$06f,$06f,$06f,$06f,$06f,$05f,$05f,$05f,$05f,$05f
	dc.w	$04f,$04f,$04f,$04f,$04f,$03f,$03f,$03f,$03f,$03f
	dc.w	$02f,$02f,$02f,$02f,$02f,$01f,$01f,$01f,$01f,$01f
	dc.w	$00f,$00f,$00f,$00f,$00f,$00f,$00f,$00f,$00f,$00f
	dc.w	$10f,$10f,$10f,$10f,$10f,$20f,$20f,$20f,$20f,$20f
	dc.w	$30f,$30f,$30f,$30f,$30f,$40f,$40f,$40f,$40f,$40f
	dc.w	$50f,$50f,$50f,$50f,$50f,$60f,$60f,$60f,$60f,$60f
	dc.w	$70f,$70f,$70f,$70f,$70f,$80f,$80f,$80f,$80f,$80f
	dc.w	$90f,$90f,$90f,$90f,$90f,$a0f,$a0f,$a0f,$a0f,$a0f
	dc.w	$b0f,$b0f,$b0f,$b0f,$b0f,$c0f,$c0f,$c0f,$c0f,$c0f
	dc.w	$d0f,$d0f,$d0f,$d0f,$d0f,$e0f,$e0f,$e0f,$e0f,$e0f
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0

;--------------------------------------------------------------------

ScWait: 	dc.w	0
ScPtr:		dc.w	1
ScSpeed:	dc.w	%1111000000000000
BPtr:		dc.w	1
Screen1H:	dc.w	0
Screen1L:	dc.w	0
Screen2H:	dc.w	0
Screen2L:	dc.w	0
TextPointer:	dc.l	Scrolltext
SinPtr:		dc.l	SinTab
ColPtr:		dc.l	ColTab
intena:		dc.w	0
oldVBI:		dc.l	0
StoreA7:	dc.l	0
Fill:		dcb.l	14,0
eqpos1:		dc.w	0
eqpos2:		dc.w	0
eqpos3:		dc.w	0
eqpos4:		dc.w	0
gfxname:	dc.b	'graphics.library',0
 even

;--------------------------------------------------------------------

Scrolltext:	;*********************
	dc.b	` GOOD EVENING    `,1
	dc.b	` LADIES AND GENTLEMEN`,1
	dc.b	` WE ARE PROUD TO PRESENT YOU ANOTHER COOL`
	dc.b	` DEMONSTRATION MADE BY PRESTIGE !!      `
	dc.b	`     The Credits:    `,1
	dc.b	`    Coding by DUKE   `,1
	dc.b	`   Artworks by ALPHA `,1
	dc.b	`     Font by DUKE    `,1
	dc.b	`                     `
	dc.b	`----------------------------------------------------  `
	dc.b	$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
	dc.b	$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,1
	dc.b	` _____________________________________________________ `
 	dc.b	`                     `
 	dc.b	0
	even

;--------------------------------------------------------------------

Cop:	dc.w	$106,0,$1fc,0
	dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
	dc.w	$100,$4200,$108,0,$10a,0
SprDat:	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$1a0,0,$1a2,$888,$1a4,$777,$1a6,$555
LPlane:	ds.l	4*2
Lcols:	ds.l	16
	dc.w	$6d07,$fffe,$100,$1200
Planes:	ds.l	2
BCol:	ds.w	6*135
	dc.w	$f307,$fffe,$180,$001
	dc.w	$f407,$fffe,$180,$002,$108,-80,$10a,-80
	dc.w	$f507,$fffe,$180,$003,$182,$000
	dc.w	$f607,$fffe,$180,$004,$182,$006
	dc.w	$ffe1,$fffe
	dc.w	$3001,$fffe,$180,$117
	dc.w	$3101,$fffe,$180,$228
	dc.w	$3201,$fffe,$180,$339
	dc.w	$3301,$fffe,$180,$44a
	dc.w	$3401,$fffe,$180,$55b
	dc.w	$3501,$fffe,$180,$66c
	dc.w	$3601,$fffe,$180,$77d
	dc.w	$3701,$fffe,$180,$88e
	dc.w	$3801,$fffe,$180,$99f
	dc.w	$3901,$fffe,$180,$aaf
	dc.l	$fffffffe

DSpr:	dc.w	$0000,$0000
	dc.w	$b1d2,$ca40,$0052,$0000
	dc.w	$7052,$4a00,$0252,$0000
	dc.w	$13de,$1850,$0000,$0000
	dc.w	$0000,$0000
	dc.w	$971a,$04a6,$9400,$0000
	dc.w	$f714,$102c,$9400,$0000
	dc.w	$9710,$04b0,$0000,$0000

;--------------------------------------------------------------------

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
	bne.s	mt_clear
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint
	move.b	mt_data+$3b6,mt_maxpart+1
	rts

;--------------------------------------------------------------------

mt_off:
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

;--------------------------------------------------------------------

mt_music:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra.w	mt_rout2
mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts
mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq.w	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts
mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts
mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts
mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts
mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts
mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
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
	lea	$dff0a0,a5		;******************
	lea	mt_aud1temp(PC),a6
	move	eqpos1,d5		; EquilizerNo. nach d5
	bsr.w	mt_playit
	move	d5,eqpos1		; wenn d5=1 dann war's 'n Ton
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	move	eqpos2,d5
	bsr.w	mt_playit
	move	d5,eqpos2
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	move	eqpos3,d5
	bsr.w	mt_playit
	move	d5,eqpos3
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	move	eqpos4,d5
	bsr.w	mt_playit
	move	d5,eqpos4
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls
	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096
	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:	rts
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
	beq.s	mt_nosamplechange
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
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange
mt_displace: 
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	moveq	#1,d5		;**************************
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon
	moveq	#1,d5		;**************************
mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)
mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
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

;--------------------------------------------------------------------

mt_aud1temp:	ds.w	10
		dc.w	1
		ds.w	2
mt_aud2temp:	ds.w	10
		dc.w	2
		ds.w	2
mt_aud3temp:	ds.w	10
		dc.w	4
		ds.w	2
mt_aud4temp:	ds.w	10
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

		incdir	`codes:`

Scroller:	ds.b	840
Screen1:	ds.b	5600
Screen2:	ds.b	5600
Font:		include	`Makros/DukeFont.hex`
LScreen:	ds.b	4*2400
Logo:		incbin	`sinusscroller/Prestige2.320x32x3`
mt_data:	incbin	`tunes/mod.Crystal`


