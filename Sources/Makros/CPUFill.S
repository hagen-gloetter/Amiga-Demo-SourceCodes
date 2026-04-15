CPUFill:
	lea	Bitmap(pc),a0		; Adr der zu füllenden Bitmap
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#5-1,d6
	
.lp2:	move.l	a0,a1			; StartAdr sichern
	move	#220-1,d7		; Höhe des zu füllenden Bereichs
.lp:	movem.l	(a1),d0/d2		; Neue Daten aus Bmp holen
	eor.l	d0,d1			;
	eor.l	d2,d3			;
	movem.l	d1/d3,(a1)		; Modifizierte Daten zurückschreiben
	lea	40(a1),a1		; Eine Zeile tiefer 
	dbf	d7,.lp
	addq	#8,a0			; +32 Pixel

	dbf	d6,.lp2
	rts


Bitmap:
