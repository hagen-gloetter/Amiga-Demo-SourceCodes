
; Weired Raster

	section Raster,code_c

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)		; Multitasking aus
	bsr.w	initCopperlist
	bsr.w	InitColtab
	move	#$0020,$96(a6)
	move.l	#cop,$84(a6)		; Copperlist
	move	#123,$8a(a6)		; Copjmp2

WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam

;	move	#$0f0,$dff180		; Rasterzeitmessung Anfang (grün)

;---------------------------------------------------------- MAIN ROUTINE

PerRaster:
	lea	Space+6(pc),a0
	lea	Colsintab(pc),a4
	lea	Sintab(pc),a5
	move	TabOffset(pc),d5
	moveq	#80,d4			; interleave add
	move	#2047,d6		; tab and
	add	#20,d5			; tab add
	and	d6,d5			; overflow kill
	move	d5,TabOffset
	move	#240-1,d7
.lp:	move	(a5,d5.w),d0
	move	d0,(a0)
	add	d4,d0
	move	d0,4(a0)
	move	(a4,d5.w),d0
	move	d0,8(a0)
	move	d5,d1
	add	#500,d1
	and	d6,d1
	move	(a4,d1.w),d0
	move	d0,12(a0)
	addq	#2,d5
	and	d6,d5
	lea	20(a0),a0
	dbf	d7,.lp

;---------------------------------------------------------- MOUSEWAIT

;	move	#$f00,$dff180		; Rasterzeitmessung Ende (rot)

mloop:	btst	#6,$bfe001		; LMT
;	btst	#2,$dff016		; RMT
	bne.s	WaitVBeam

	lea	$dff000,a6
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;--------------------------------------------------------- initCopperlist

initCopperlist:
	lea	Space(pc),a0
	move.l	#$31e1fffe,d0	
	move.l	#$00e20014,d1	
	move.l	#$00e60064,d2	
	move.l	#$01820f00,d3	
	move.l	#$0184000f,d4	
	move	#240-1,d7
.lp:	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	move.l	d4,(a0)+
	add.l	#$01000000,d0
	dbf	d7,.lp
.mulu:	lea	SinTab(pc),a0
	move	(a0),d0
.mulutab:
	mulu	#160,d0
	add	#20,d0
	move	d0,(a0)+
	move	(a0),d0
	cmp	#$ffff,d0
	bne.b	.mulutab
	rts
	
InitColtab:
	lea	ColSinTab(pc),a0
	lea	Colors(pc),a1
	move	#1030,d7
.clp:	move	(a0),d0		; Get sin 
	add	d0,d0		; Byte to word
	move	(a1,d0.w),d0	; Get color
	move	d0,(a0)+	; write color
	dbf	d7,.clp
	rts

;---------------------------------------------------------- Pointer

TabOffset:	dc.w	0

;---------------------------------------------------------- Tabellen

	incdir	dh1:Code/Sources/

SinTab:    ; from 00 degrees to 360 degrees. amount of values = 1024
	include	perraster/SinTab.tab
ColSinTab: ; from 90 degrees to 180 degrees. amount of values = 1024
	include	perraster/ColSinTab.tab
Colors:	   ; 64 Farbwerte
;	include	perraster/Colors.tab

	dc.w	$0f0,$0f2,$0f4,$0f6,$0f8,$0fa,$0fc,$0fe,$0ef,$0cf,$0af,$08f
	dc.w	$06f,$04f,$02f,$00f,$00f,$20f,$50f,$70f,$a0f,$c0f,$f0f,$f0d
	dc.w	$f0d,$f0b,$f09,$f08,$f06,$f04,$f02,$f00,$f00,$f02,$f04,$f06
	dc.w	$f08,$f09,$f0b,$f0d,$f0d,$f0f,$c0f,$a0f,$70f,$50f,$20f,$00f
	dc.w	$00f,$02f,$04f,$06f,$08f,$0af,$0cf,$0ef,$0fe,$0fc,$0fa,$0f8
	dc.w	$0f6,$0f4,$0f2,$0f0,$0f0,$0f0

;----------------------------------------------------------- Copperliste

cop:	dc.w	$180,0,$186,$0f0
	dc.w	$8e,$3231,$90,$22f1,$92,$38,$94,$d0
	dc.w	$102,0,$104,0,$108,120,$10a,120
.hi:	dc.w	$e0,$07,$e4,$07
	dc.w	$3107,$fffe,$180,$aaa
	dc.w	$3207,$fffe,$180,0
	dc.w	$100,$2200
Space:	ds.b	240*20
	dc.w	$2207,$fffe,$100,0,$180,$aaa
	dc.w	$e0,$04,$e4,$04
	dc.w	$2307,$fffe,$180,0
	dc.l	$fffffffe

>Extern	`perraster/perraster640x128x2.int`,$70000
