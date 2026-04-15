
; Converter from Pic (48x72x4=432x4=1728) to CopperColors


TabSize	=	48*72
x:	move	#$4000,$dff09a

	lea	Pic(pc),a0
	lea	4*432(a0),a1		; Colorpalette
	lea	Coltab(pc),a2

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

	move	#218-1,d6
.lp2	swap	d6
	move	0*432(a0),d0		; pl0
	move	1*432(a0),d1		; pl1
	move	2*432(a0),d2		; pl2
	move	3*432(a0),d3		; pl3
	moveq	#16-1,d7
.lp	swap	d7
	rol	#1,d0
	rol	#1,d1
	rol	#1,d2
	rol	#1,d3
	move	d0,d4
	move	d1,d5
	move	d2,d6
	move	d3,d7
	and	#$1,d4
	and	#$1,d5
	and	#$1,d6
	and	#$1,d7
	lsl	#1,d5
	lsl	#2,d6
	lsl	#3,d7
	add	d4,d7
	add	d5,d7
	add	d6,d7
	add	d7,d7
	move	(a1,d7.w),(a2)+
	swap	d7
	dbf	d7,.lp
	add	#2,a0
	swap	d6
	dbf	d6,.lp2
	rts

ColTab:	ds.w	TabSize

Pic:	incbin	`duke_sources_5:zoomanim/Testdose.raw`



