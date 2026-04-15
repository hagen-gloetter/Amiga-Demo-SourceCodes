;	Iff-Display-Test

x:	lea	Pic,a0

getFORM	cmp.l	#"FORM",(a0)+
	bne.b	getFORM
	move.l	(a0),d0

getILBM	cmp.l	#"ILBM",(a0)+
	bne.b	getILBM
	move.l	(a0),d0

getBMHD	cmp.l	#"BMHD",(a0)+
	bne.b	getBMHD
	move.l	(a0)+,d0		; 20
	move	(a0)+,d1		; Breite
	move	(a0)+,d2		; Höhe
	move.l	(a0)+,d0		; 0
	move.b	(a0)+,d0		; Planes
	move.b	(a0)+,d0		; 0
	move.l	(a0)+,d0		; 0

	rts




	incdir	`Duke_Sources_6:tests/`
Pic	incbin	`testbild1`
