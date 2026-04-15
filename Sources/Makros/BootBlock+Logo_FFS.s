; 	 How to make a BootBlock 
;	by Duke of Prestige 20.2.93 


WriteToDisk	=	0	; 1=write 0=don't write

	IFEQ	WriteToDisk-1
bb:	dc.b	'DOS',1		; 1 = FastFileSys 0=OldFileSys
	dc.l	0		; CheckSum
	dc.l	$370		; Rootblock
	ENDC

;---------------------------------------------------------- NonSysRout

x:	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	#$4000,$9a(a6)
	move	#$0020,$96(a6)
DoCop:	lea	$50000,a0
	lea	CTab(pc),a1
	move.l	#$01000200,(a0)+
	move.l	#$01800000,(a0)+
	move.l	#$8049fffe,d0
	move	#$0180,d1
	moveq	#5-1,d5
.lp3:	moveq	#8-1,d6
.lp2:	moveq	#40-1,d7
	move.l	d0,(a0)+
.lp:	moveq	#0,d2
	move	d1,(a0)+
	move.b	(a1)+,d3
	beq.b	.no1		
	moveq	#-1,d2
.no1:	move	d2,(a0)+
	dbf	d7,.lp
	sub	#40,a1
	add.l	#$01000000,d0
	dbf	d6,.lp2
	add	#40,a1
	dbf	d5,.lp3
	move.l	#$fffffffe,(a0)
	move.l	#$50000,$84(a6)
	move	#$1234,$8a(a6)
;mloop:	btst	#6,$bfe001
;	bne.b	mloop
	lea	$dff000,a6
	move	#$8020,$96(a6)
	move	#$c00,$9a(a6)
	movem.l	(a7)+,d0-d7/a0-a6

;---------------------------------------------------------- SysRout

BBbeg:	move.l	4.w,a6			; ExecBase
	lea	expansionlib(pc),a1	; Libname
	moveq	#37,d0			; lib version
	jsr	-552(a6)		; openlib
	tst.l	d0
	beq.b	.noexlib	; open failed
	move.l	d0,a1
	bset	#6,$22(a1) 	; set flag 6 (no output till cli)
	jsr	-414(a6)	; closelib

.noexlib:
	lea	Doslib(pc),a1	; Doslib
	jsr	-96(a6)		; findresident doslib
	tst.l	d0	
	beq.b	.nodoslib	; fail
	move.l	d0,a0
	move.l	$16(a0),a0	; ???
	moveq	#0,d0		; Returncode all roger
	rts

.nodoslib:
	moveq	#-1,d0		; Returncode fuck off
	rts

doslib:		dc.b	'dos.library',0
expansionlib:	dc.b	'expansion.library',0,0

CTab:	dc.b	1,1,1,0,0,1,1,1,0,0,1,1,1,1,0,1,1,1,1,0
	dc.b	1,1,1,1,0,1,0,1,1,1,1,0,1,1,1,1,0,0,0,0
	dc.b	0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,1,0
	dc.b	1,0,0,0,0,1,0,1,0,1,1,0,1,1,1,1,0,0,0,0
	dc.b	1,0,0,0,0,1,0,0,1,0,1,0,0,0,0,0,0,0,1,0
	dc.b	1,0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,0,0
	dc.b	1,0,0,0,0,1,0,0,1,0,1,1,1,1,0,1,1,1,1,0
	dc.b	1,0,0,0,0,1,0,1,1,1,1,0,1,1,1,1,0,0,0,0,0

	dc.b	`                                       `
	dc.b	`           MOTION             `
	dc.b	`           ===============             `
	dc.b	`                                       `
	dc.b	`Strong and brave warriors to the Grave `
	dc.b	`                                       `
	dc.b	`Call our Boards:                       `
	dc.b	`Central Link         +49-7152-55546    `
	dc.b	`House of Justice     +49-7152-902518   `
	dc.b	`                                       `
	dc.b	`                                       `
	dc.b	`                                       `
	dc.b	`                                       `
	

END:	IFEQ	WriteToDisk-1
	IF	END-BB>1024
	FAIL
	ENDC
	auto	ws1\bb\0\2\cc1\
	ENDC
