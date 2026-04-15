

FontSize	= 336/8*192

write		=	1	; 0=Test only
				; 1=Write to Disk 

wblt:	macro
.\@:	btst	#14,$02(a6)
	bne.b	.\@
	endm


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
	move	#$0083c0,$96(a6)	; dmacon data
	move	#$007fff,$9c(a6)	; clear irq request
	move	#$004000,$9a(a6)	; interrupt disable


;---------------------------------------------------------- MAIN ROUTINE

	lea	ParalellFont,a2
	lea	LinearFont,a1

	moveq	#4-1,d6
.ylp	move.l	a2,a0
	moveq	#7-1,d7
.xlp	wblt
	move.l	#-1,$44(a6)
	move	#42-6,$64(a6)
	move	#0,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[48*64]+[48/16],$58(a6)
	add.l	#6,a0
	add.l	#48*48/8,a1
	dbf	d7,.xlp
	add.l	#336/8*48,a2
	dbf	d6,.ylp

Hau_die_Bitplanes_in_die_Copperliste:
	move.l	#Bitplane,d0
	lea	BitPlanes+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

Testen_wir_die_Font_indem_wir_sie_in_die_Bitplane_nageln:

	lea	LinearFont,a0
	lea	Bitplane,a2

	moveq	#5-1,d6
.ylp	move.l	a2,a1
	moveq	#6-1,d7
.xlp	wblt
	move.l	#-1,$44(a6)
	move	#0,$64(a6)
	move	#40-6,$66(a6)
	move.l	#$09f00000,$40(a6)
	movem.l	a0-a1,$50(a6)
	move	#[48*64]+[48/16],$58(a6)
	add.l	#48*6,a0
	add.l	#6,a1
	dbf	d7,.xlp
	add.l	#320/8*48,a2
	dbf	d6,.ylp


;------------------------------------------------------ WAIT FOR VERTICAL BEAM

WaitVBeam:
	lea	$dff000,a6
	move.l	$04(a6),d0
	and.l	#$00ff000,d0
	cmp.l	#$0011000,d0
	bne.s	WaitVBeam
;	move	#$f00,$dff180		; Rasterzeitmessung Beginn (rot)

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

;---------------------------------------------------------- SYS_Pointer

syscop1		dc.l	0
syscop2		dc.l	0
intena		dc.w	0
dmacon		dc.w	0
adkcon		dc.w	0
gfxname		dc.b	'graphics.library',0
		even

;---------------------------------------------------------- AUTO SEQUENCE

		printt
		printt
		printt
		printt	`Paralell to Linear Font Converter V1.0`
		printt
		printt
		if	write=1
		auto	j\wb\LinearFont\LinearFontEnd\
		endif


;---------------------------------------------------------- DATA SECTION

		section	data,data_c


cop:		dc.w	$106,0,$1fc,0
		dc.w	$180,0,$182,$070
		dc.w	$8e,$3181,$90,$30c1,$92,$38,$94,$d0
		dc.w	$102,0,$104,$0,$108,0,$10a,0
		dc.w	$100,$1200
BitPlanes:	dc.w	$e0,0,$e2,0
		dc.w	$ffff,$fffe


		incdir	Codes:SingScroller/
ParalellFont:	incbin	Shebert336x192.raw

;---------------------------------------------------------- NewFontFormat

LinearFont:	ds.b	FontSize
LinearFontEnd:	dc.b	`-ENDE-`	; Is nur als Test gedacht

Bitplane:	ds.b	10240		; ZusatzPuffer :-)

