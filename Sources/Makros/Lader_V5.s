;FastLoad5.0 (No Blitter used,VBeamSync,FastSelect,Files [pics+code])
;by Ozzy 1992-93
;Copyright (c) Ozzy 1992-93
;All rights reserved.

;ACHTUNG FIXE ADRESSEN FÜR 0.5-1MB CHIP

mfmbuffer: 	equ	$50000	;Adresse der MFM-Daten
decodeto:	equ	$5000   ;Adresse der Daten

SektorLang	EQU	$200	;Sektorlänge (512 bytes) 
SyncWort	EQU	$4489	;SyncWort
SektorMax	EQU	11	;Anzahl Sektoren
FormatByte	EQU	$FF	;Formatbyte für Amiga-Format

	org	$7f000
	load	$7f000

start;	lea	$1000,sp
	lea	$bfd100,a5
	lea	$dff000,a6
	move.w	#$4000,$9a(a6)

	MOVE.W	$02(a6),D1
	MOVE.W	#$7FFF,$96(a6)
;	MOVE.L	#cop,$84(a6)
	CLR.W	$88(a6)
	OR.W	#$83C0,D1
	MOVE.W	D1,$96(a6)

	lea	filelist(pc),a3
	move.w	#4,filecounter		;Anzahl der Files
.fileloop
	move.l	#coplist,$84(a6)
	move.b	(a3)+,num_tracks
	move.b	(a3)+,new_track
	move.l	(a3)+,decrunchto
	bsr.s	LoadNextFile
	movem.l	d0-d7/a0-a6,-(sp)
	lea	decodeto,a0
	move.l	decrunchto,a1
	bsr.w	decrunch
	cmpi.l	#$50494300,decodeto	; 'PIC',0
	beq.s	.next
	cmpi.l	#'CODE',decodeto
	bne.s	.next
	move.l	decrunchto,a1
	jsr	(a1)
.next	movem.l	(sp)+,d0-d7/a0-a6
	subq.w	#1,filecounter
	bne.s	.fileloop
	rts


LoadNextFile:	
	movem.l	d0-d7/a0-a4,-(sp)
	lea	mfmbuffer,a0
	move.l	#$aaaaaaaa,(a0)+
	move.w	#$4489,(a0)

	bsr.w	select_drive
	bsr.w	diskready
	lea	decodeto,a1

	lea	old_track,a4
	moveq	#0,d4
	move.l	d4,d5
	move.b	(a4)+,d4	;track old
	move.b  (a4),d5		;track new
	cmp.b	d4,d5
	bhi.s	place_if_higher	
place_if_lower:
	exg	d4,d5
	sub.b	d4,d5
	beq.s	gerade
	lsr.b	#1,d5
	bset	#1,(a5)
low_loop
	bsr.w	trackdown
	subq.b	#1,d5
	bne.s	low_loop
	bra.s	on_position	

place_if_higher:
	sub.b	d4,d5		;Differenz aus den beiden Nummern
	beq.s	gerade		;wenn d4=d5,dann gerade, da 0
	lsr.b	#1,d5		;die Differenz/2 ergibt die Anzahl der Cyl.
	beq.s	ungerade
high_loop
	bsr.w	trackup
	subq.b	#1,d5
	bne.s	high_loop
	
on_position
	move.b	(a4),-1(a4)	;old=new
	btst	#0,(a4)		;noch auf ungerade testen
	bne.s	ungerade
readloop:
gerade:						;Falls tracknummer gerade
	bset	#2,(a5)				;Kopf 0
	bsr.b	diskready
	lea	mfmbuffer+6,a0
	bsr.b	readtrack
	bsr.w	waitdiskdma
	bsr.w	decodetrack
	add.b	#1,old_track
	subq.b	#1,num_tracks
	beq.s	allread	
	adda.l	#SektorLang*SektorMax,a1
	
ungerade:					;Falls tracknummer ungerade
	bclr	#2,(a5)				;Kopf 1
	bsr.b	diskready
	lea	mfmbuffer+6,a0
	bsr.b	readtrack
	bsr.b	waitdiskdma
	bsr.w	decodetrack
	add.b	#1,old_track
	subq.b	#1,num_tracks
	beq.s	allread
	adda.l	#SektorLang*SektorMax,a1

	bsr.b	trackup
	bra.b	readloop
	
allread:
	moveq	#0,d0
	move.b	drive_selected,d0
	bset	d0,(a5)
	nop
	nop
	bset	#7,(a5)
	nop
	nop
	bclr	d0,(a5)
	movem.l	(a7)+,d0-d7/a0-a4
	rts

diskready
	bsr.w	delay
sig	btst	#5,$bfe001
	bne.s	sig
	rts

readtrack:
	move.w	#$4000,$24(a6)
	move.l	a0,$20(a6)
	move.w	#2,$9c(a6)
	move.w	#$4489,$7e(a6)
	move.w	#$8500,$9e(a6)
	move.w	#$a000,$24(a6)
	move.w	#$a000,$24(a6)
waitdiskdma:
	btst	#1,$1f(a6)
	beq.s	waitdiskdma
	move.w	#$4000,$24(a6)
	rts
trackup
	bclr	#1,(a5)
	bclr	#0,(a5)
	nop
	nop
	bset	#0,(a5)
	bsr.b	diskready
	rts
trackdown
	bset	#1,(a5)
	bclr	#0,(a5)
	nop
	nop
	bset	#0,(a5)
	bsr.b	diskready
	rts

; select drive
;d0/d6/d7

select_drive:
	move.b	drive_selected,d0
selectloop:
	move.b	#$79,(a5)		;Laufwerk an
	nop
	nop
	bclr	d0,(a5)
	moveq	#82,d7
t0l:
	btst	#4,$bfe001
	beq.s	track0found
	bset	#1,(a5)
	bclr	#0,(a5)
	nop
	nop
	bset	#0,(a5)
	bsr.w	delay
	dbf	d7,t0l		;Wenn nach 82 Zylindern nichts kommt
	bra.s	nextdrive	;nächtes Laufwerk (mehr als 82 gibts nicht)
track0found
	bclr	#1,(a5)
	bclr	#0,(a5)
	nop
	nop
	bset	#0,(a5)
	bsr.w	delay
	bset	#1,(a5)
	bclr	#0,(a5)
	nop
	nop
	bset	#0,(a5)
	bsr.b	delay
	btst	#2,$bfe001		;Disk im Laufwerk
	bne.b	disk_in_drive		;ja?=>Track 2 lesen
nextdrive:
	bset	d0,(a5)			;aus
	nop
	nop
	bset	#7,(a5)
	nop
	nop
	bclr	d0,(a5)	
	cmpi.b	#6,d0			;bei Laufwerk 3 angelangt
	bne.s	weiter
	moveq	#3,d0
	cmpi.b	drive_selected,d0
	bhi.s	weiter1
	move.b	drive_selected,d0
	subq.b	#1,d0
;	bsr.w	wrong_disk		;ja=>Message (keine Diskette...)
weiter1
	subq	#1,d0
weiter
	addq.b	#1,d0
	bra.w	selectloop
disk_in_drive:
	clr.b	old_track
	bset	#2,(a5)			;kopf 0
	bsr.w	diskready
	lea	mfmbuffer,a0		;Spur lesen
	move.l	#$aaaaaaaa,(a0)+
	move.w	#$4489,(a0)+
	bsr.w	readtrack
	lea	$5000(a0),a1
	bsr.b	decodetrack
mod01	cmpi.l	#"PDD0",8(a1)		;Diskettenkennung vergleichen. Wird
	bne.s	nextdrive		;später bei diskchange modifiziert 
	move.b	d0,drive_selected	;in drive_selected steht am Schluß die
end1	rts				;Laufwerksnummer als bit
					;(für Drive-Select)

delay:
	move.l	4(a6),d6
	and.l	#$0000ff00,d6
	cmpi.l	#$00008000,d6
	bne.b	delay
.wait1	move.l	4(a6),d6
	and.l	#$0000ff00,d6
	cmpi.l	#$00008500,d6
	bne.s	.wait1
	rts
	
wrong_disk:
	move.w	drive_selected,d0
	subq.w	#1,d0
	btst	#6,$bfe001		;<-----hier noch message einfügen
	bne.s	wrong_disk
	rts

drive_selected	dc.b	3	;drive selected
old_track	dc.b	0	;old track
new_track	dc.b	0	;new track
num_tracks	dc.b	0	;num tracks

;------------------------------------------------
;Track decodieren
;>= A0 = Zeiger auf Quelle
;>= A1 = Zeiger auf Ziel

decodetrack:
	suba.l	#6,a0
	movem.l	d0/d2/a0-a3,-(a7)	;Register löschen
	move.l	#$55555555,d4	;Maske zum Decodieren
	move.l	a0,a2
	move.l	a1,a3		;Zeiger auf Ziehl
	move.w	#SektorMax,d2	;11 Sektoren
	moveq	#0,d3		;Sektorposition im Puffer
dloop:
	move.l	a2,a0
	move.w	#$440,d0
	mulu	d3,d0
	lea	(a0,d0.l),a0
floop:	cmpi.w	#SyncWort,(a0)+  ;SyncWort finden
	bne.s	floop
syncfound: 
	cmpi.w	#SyncWort,(a0)	;Noch ein SyncWort
	bne.s	Header
	adda.l	#2,a0		;Ja=>Ein Wort weiter 
Header:	move.l	(a0)+,D1	;Header decodieren
	move.l	(a0)+,D0
	and.l	d4,d1
	and.l	d4,d0
	lsl.l	#1,D1
	or.l	D0,D1
	swap	d1
	lsr.w	#8,d1
	cmpi.b	#FormatByte,d1	;DOS-Sektor?
	beq.s	dosfound	
	moveq	#0,d1
	bra.s	dloop
dosfound:
	swap	d1
	lsr.w	#8,d1		;Sektornummer
	cmpi.b	#SektorMax,d1
	bhi.s	dloop
	move.l	a3,a1		;Ziel

	lsl.w	#8,d1		;Offset für unko. Sektor (Nummer*512)
	add.w	d1,d1
	adda.l	#$30,a0		;Position hinter Label
	add.w	d1,a1		;Adresse für unko. Puffer

	movem.l	d2-d3/a2-a3,-(a7)	;Register retten
	move.l	#SektorLang/4-1,d3	;Länge eines Sektors
	lea	SektorLang(a0),a2	;Adresse für 2. Hälfte
decode_cpu:
	move.l	(a0)+,d0
	move.l	(a2)+,d1
	and.l	d4,d0
	and.l	d4,d1
	lsl.l	#1,d0
	or.l	d1,d0
	move.l	d0,(a1)+
	dbra	d3,decode_cpu
	movem.l	(a7)+,d2-d3/a2-a3	;Register zurückholen

	addq.w	#1,d3			;Sektorposition +1
	subq.w	#1,d2			;Zähler -1
	bne.b	dloop			;weiter, wenn nicht Null
	movem.l	(a7)+,d0/d2/a0-a3	;Register zurückholen
	rts

;------------------------------------------------
;a0=src a1=dest

decrunch:
	movem.l	d0-d7/a0-a6,-(sp)
	adda.l	#6,a0
	move.l	(a0)+,d1	;OrgLen
	move.l	(a0)+,d2	;CrLen
	move.l	a0,a2
	bsr.s	FastDecruncher
.NotCrunched:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
** Decrunch by Thomas Schwarz (only necessary code)
**-------------------------------------------------------------------
** This is the pure Decrunch-Routine
** The Registers have to be loaded with the following values:
** a1: Adr of Destination (normal)	** a2: Adr of Source (packed)
** d1: Len of Destination		** d2: Len of Source
**-------------------------------------------------------------------
FastDecruncher:
	move.l	a1,a5		;Decrunched Anfang (hier Ende des Decrunchens)
	add.l	d1,a1
	add.l	d2,a2
	move.w	-(a2),d0	;Anz Bits in letztem Wort
	move.l	-(a2),d6	;1.LW
	moveq	#16,d7		;Anz Bits
	sub.w	d0,d7		;Anz Bits, die rotiert werden müssen
	lsr.l	d7,d6		;1.Bits an Anfang bringen
	move.w	d0,d7		;Anz Bits, die noch im Wort sind
	moveq	#16,d3
	moveq	#0,d4
.DecrLoop:
	cmpa.l	a5,a1		;cmp.l
	beq.w	.DecrEnd	;ble  ;a1=a5: fertig (a1<a5: eigentlich Fehler)

	bsr.s	.BitTest
	bcc.s	.InsertSeq	;1.Bit 0: Sequenz
	moveq	#0,d4
** einzelne Bytes einfügen **
.InsertBytes:
	moveq	#8,d1
	bsr.w	.GetBits
	move.b	d0,-(a1)
	dbf	d4,.InsertBytes
	bra.s	.DecrLoop
*------------
.SpecialInsert:
	moveq	#14,d4
	moveq	#5,d1
	bsr.s	.BitTest
	bcs.s	.IB1
	moveq	#14,d1
.IB1:	bsr.s	.GetBits
	add.w	d0,d4
	bra.s	.InsertBytes
*------------
.InsertSeq:
** Anzahl der gleichen Bits holen **
	bsr.s	.BitTest
	bcs.s	.AB1
	moveq	#1,d1			;Maske: 0 (1 AB)
	moveq	#1,d4			;normal: Summe 1
	bra.s	.ABGet
.AB1:
	bsr.s	.BitTest
	bcs.s	.AB2
	moveq	#2,d1			;Maske: 01 (2 ABs)
	moveq	#3,d4			;ab hier: Summe mindestens 3
	bra.s	.ABGet
.AB2:
	bsr.s	.BitTest
	bcs.s	.AB3
	moveq	#4,d1			;Maske: 011 (4 ABs)
	moveq	#7,d4			;hier: Summe 11
	bra.s	.ABGet
.AB3:
	moveq	#8,d1			;Maske: 111 (8 ABs)
	moveq	#$17,d4			;hier: Summe 11
.ABGet:
	bsr.s	.GetBits
	add.w	d0,d4			;d0: Länge der Sequenz - 1
	cmp.w	#22,d4
	beq.s	.SpecialInsert
	blt.s	.Cont
	subq.w	#1,d4
.Cont:
** SequenzAnbstand holen **
	bsr.s	.BitTest
	bcs.s	.DB1
	moveq	#9,d1			;Maske: 0 (9 DBs)
	moveq	#$20,d2
	bra.s	.DBGet
.DB1:
	bsr.s	.BitTest
	bcs.s	.DB2
	moveq	#5,d1			;Maske: 01 (5 DBs)
	moveq	#0,d2
	bra.s	.DBGet
.DB2:
	moveq	#14,d1			;Maske: 11 (12 DBs)
	move.w	#$220,d2
.DBGet:
	bsr.s	.GetBits
	add.w	d2,d0
	lea	0(a1,d0.w),a3		;a3 auf Anf zu kopierender Seq setzten
.InsSeqLoop:
	move.b	-(a3),-(a1)		;Byte kopieren
	dbf	d4,.InsSeqLoop

	bra.w	.DecrLoop
*------------
.BitTest:
	subq.w	#1,d7
	bne.s	.BTNoLoop
	moveq	#16,d7			;hier kein add notwendig: d7 vorher 0
	move.w	d6,d0
	lsr.l	#1,d6			;Bit rausschieben und Flags setzen
	swap	d6			;ror.l	#16,d6
	move.w	-(a2),d6		;nächstes Wort holen
	swap	d6			;rol.l	#16,d6
	lsr.w	#1,d0			;Bit rausschieben und Flags setzen
	rts
.BTNoLoop:
	lsr.l	#1,d6			;Bit rausschieben und Flags setzen
	rts
*----------
.GetBits:				;d1:AnzBits->d0:Bits
	move.w	d6,d0			;d6:Akt Wort
	lsr.l	d1,d6			;nächste Bits nach vorne bringen
	sub.w	d1,d7			;d7:Anz Bits, die noch im Wort sind
	bgt.s	.GBNoLoop
;	add.w	#16,d7			;BitCounter korrigieren
	add.w	d3,d7			;BitCounter korrigieren
	ror.l	d7,d6			;restliche Bits re rausschieben
	move.w	-(a2),d6		;nächstes Wort holen
	rol.l	d7,d6			;und zurückrotieren
.GBNoLoop:
	add.w	d1,d1			;*2 (in Tab sind Ws)
	and.w	.AndData-2(pc,d1.w),d0	;unerwünschte Bits rausschmeißen
	rts
*----------
.AndData:
	dc.w	%1,%11,%111,%1111,%11111,%111111,%1111111
	dc.w	%11111111,%111111111,%1111111111
	dc.w	%11111111111,%111111111111
	dc.w	%1111111111111,%11111111111111
*-----------
.DecrEnd:
	rts		;a5: Start of decrunched Data
filecounter	dc.w	0
filelist
	dc.b	13,2
	dc.l	$40000
	dc.b	13,15
	dc.l	$40000
	dc.b 	10,28
	dc.l	$40000
	dc.b	1,38
	dc.l	$40000
	dc.w	-1
decrunchto	dc.l	0
; Das kennt ihr sicher
coplist	
	dc.w	$0120,7,$0122,$FFFC
	dc.w	$0124,7,$0126,$FFFC
	dc.w	$0128,7,$012A,$FFFC
	dc.w	$012C,7,$012E,$FFFC
	dc.w	$0130,7,$0132,$FFFC
	dc.w	$0134,7,$0136,$FFFC
	dc.w	$0138,7,$013A,$FFFC
	dc.w	$013C,7,$013E,$FFFC
;	dc.w	$8e,$7f81,$90,$8ea1,$92,$58,$94,$f0-64
;	dc.w	$182,$fff
;	dc.w	$100,$1200,$108,0
;	dc.w	$e0,pic/$10000,$e2,pic&$ffff
	dc.w	$180,0,$2007,-2,$180,-1,$2107,-2,$180,$006,$f007,-2
	dc.w	$180,$fff,$f107,-2,$180,0
	dc.w	-1,-2
;pic:	ds.b	192/8*15	;incbin	"dh1:bootpic.raw192x15x1"
end:	END
