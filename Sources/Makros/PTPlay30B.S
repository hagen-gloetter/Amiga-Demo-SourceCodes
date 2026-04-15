*****************************************************************
*               »» Protracker 3.00B playroutine ««              *
* Written by Tom "Outland" Bech, Ivar "Heatseeker" J. Olsen,	*
* 	and  Bjarte "Krest" Andreassen of Cryptoburners.	*
* Based upon Protracker 1.1A playroutine written by Lars Hamre. *
*          VBlank version. Not optimised in any way.            *
*****************************************************************
* Call pt_InitMusic before start. Then call pt_PlayMusic at VB. *
* To stop the music, call pt_StopMusic.                         *
* Please note that in this version, all SetTempo commands are   *
* ignored. This assembly language program has been tested with  *
* the Devpac 3.02, AsmOne 1.2, MCAsm 1.5 and a68k assemblers and*
* may have to be modified for other assemblers.			*
*****************************************************************

; FileFormat offsets
sd_songname	EQU	0	;songname offset
sd_sampleinfo	EQU	20	;first sample starts here
sd_numofpatt	EQU	950	;number of patterns are stored here
sd_pattpos	EQU	952	;pattern positions table is here
sd_mahokakt	EQU	1080	;"M.K." :)
sd_patterndata	EQU	1084	;first pattern starts at this position

; Song offsets. W/L/B means word/longword/byte length.
n_note		EQU	0  	;W
n_cmd		EQU	2  	;W
n_cmdlo		EQU	3  	;low B of cmd
n_start		EQU	4  	;L
n_length	EQU	8  	;W
n_loopstart	EQU	10 	;L
n_replen	EQU	14 	;W
n_period	EQU	16 	;W
n_finetune	EQU	18 	;B
n_volume	EQU	19 	;B
n_dmabit	EQU	20 	;W
n_toneportdirec	EQU	22 	;B
n_toneportspeed	EQU	23 	;B
n_wantedperiod	EQU	24 	;W
n_vibratocmd	EQU	26 	;B
n_vibratopos	EQU	27 	;B
n_tremolocmd	EQU	28 	;B
n_tremolopos	EQU	29 	;B
n_wavecontrol	EQU	30 	;B
n_glissfunk	EQU	31 	;B
n_sampleoffset	EQU	32 	;B
n_pattpos	EQU	33 	;B
n_loopcount	EQU	34 	;B
n_funkoffset	EQU	35 	;B
n_wavestart	EQU	36 	;L
n_reallength	EQU	40 	;W
n_trigger	EQU	42 	;B
n_samplenum	EQU	43 	;B

InitMusic
	movem.l	d0-d3/a0-a2,-(sp)
	lea	music,a0
	move.l	#`HAZE`,1080(a0)
	move.l	a0,pt_songdataptr
	lea	sd_pattpos(a0),a1
	moveq	#128-1,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#$1e,d3
pt_lop2 move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.b	pt_lop
	move.l	d1,d2
pt_lop	dbra	d0,pt_lop2
	addq.w	#1,d2
	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	pt_samplestarts(pc),a1
	add.w	#2*20+2,a0		;find first sample length
	moveq	#31-1,d0
pt_lop3 move.l	a2,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbra	d0,pt_lop3
	move.b	#6,pt_speed		;default speed
	or.b	#2,$bfe001
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	clr.b	pt_songpos
	clr.b	pt_counter
	clr.b	pt_pattpos
	movem.l	(sp)+,d0-d3/a0-a2
	rts

StopMusic
	movem.l	d0/a0,-(sp)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
;	move.w	#$000f,$dff096		;stop audiodma activity
	movem.l	(sp)+,d0/a0
	rts

PlayMusic
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	pt_songdataptr(pc),a0
	addq.l	#1,pt_counter
	move.l	pt_counter(pc),d0
	cmp.l	pt_currspeed(pc),d0
	blo.b	pt_nonewnote
	clr.l	pt_counter
	tst.b	pt_pattdelaytime2
	beq.b	pt_getnewnote
	bsr.b	pt_nonewallchannels
	bra.w	pt_dskip

pt_nonewnote
	bsr.b	pt_nonewallchannels
	bra.w	pt_nonewpositionyet

pt_nonewallchannels
	lea	pt_audchan1temp(pc),a6
	lea	$dff0a0,a5
	bsr.w	pt_checkeffects
	lea	pt_audchan2temp(pc),a6
	lea	$dff0b0,a5
	bsr.w	pt_checkeffects
	lea	pt_audchan3temp(pc),a6
	lea	$dff0c0,a5
	bsr.w	pt_checkeffects
	lea	pt_audchan4temp(pc),a6
	lea	$dff0d0,a5
	bra.w	pt_checkeffects

pt_getnewnote
	lea	12(a0),a3
	lea	sd_pattpos(a0),a2
	lea	sd_patterndata(a0),a0
	moveq	#0,d1
	move.l	pt_songposition(pc),d0
	move.b	0(a2,d0.w),d1
	asl.l	#8,d1				;*1024
	asl.l	#2,d1

	add.l	pt_patternposition(pc),d1
	move.l	d1,pt_patternptr
	clr.w	pt_dmacontemp
	lea	$dff0a0,a5
	lea	pt_audchan1temp(pc),a6
	moveq	#1,d2
	bsr.w	pt_playvoice
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	lea	$dff0b0,a5
	lea	pt_audchan2temp(pc),a6
	moveq	#2,d2
	bsr.b	pt_playvoice
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	lea	$dff0c0,a5
	lea	pt_audchan3temp(pc),a6
	moveq	#3,d2
	bsr.b	pt_playvoice
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	lea	$dff0d0,a5
	lea	pt_audchan4temp(pc),a6
	moveq	#4,d2
	bsr.b	pt_playvoice
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	bra.w	pt_setdma

pt_checkmetronome
	cmp.b	pt_metrochannel,d2
	bne.w	pt_return
	move.b	pt_metrospeed,d2
	beq.w	pt_return
	move.l	pt_patternposition,d3
	lsr.l	#4,d3
	divu	d2,d3
	swap	d3
	tst.w	d3
	bne.w	pt_return
	and.l	#$00000fff,(a6)
	or.l	#$10d6f000,(a6) 	;play sample $1f at period $0d6 (214)
	rts

pt_playvoice
	tst.l	(a6)
	bne.b	pt_plvskip
	bsr.w	pt_pernop
pt_plvskip
	move.l	0(a0,d1.l),(a6)		;read one track from pattern
	bsr.b	pt_checkmetronome
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2		;get lower 4 bits of instrument
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0			;get higher 4 bits of instrument
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.b	pt_setregisters		;instrument was zero
	moveq	#0,d3
	lea	pt_samplestarts(pc),a1
	move	d2,d4
	move.b	d2,n_samplenum(a6)
	subq.l	#1,d2
	lsl.l	#2,d2
	mulu	#30,d4
	move.l	0(a1,d2.l),n_start(a6)
	move.w	0(a3,d4.l),n_length(a6)
	move.w	0(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 		;get repeat
	tst.w	d3
	beq.b	pt_noloop
	move.l	n_start(a6),d2		;get start
	asl.w	#1,d3
	add.l	d3,d2			;add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0		;get repeat
	add.w	6(a3,d4.l),d0		;add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	;save replen
	bra.b	pt_setregisters

pt_noloop
	move.l	n_start(a6),d2
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	;save replen
pt_setregisters
	move.w	(a6),d0
	and.w	#$0fff,d0
	beq.w	pt_checkmoreeffects	;if no note ->
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0 		;finetune?
	beq.b	pt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0			;toneportamento?
	beq.b	pt_chktoneporta
	cmp.b	#5,d0			;toneportamento + volslide?
	beq.b	pt_chktoneporta
	cmp.b	#9,d0			;sample offset?
	bne.b	pt_setperiod
	bsr.w	pt_checkmoreeffects
	bra.b	pt_setperiod

pt_dosetfinetune
	bsr.w	pt_setfinetune
	bra.b	pt_setperiod

pt_chktoneporta
	bsr.w	pt_settoneporta
	bra.w	pt_checkmoreeffects

pt_setperiod
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	pt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#$24,d7
pt_ftuloop
	cmp.w	0(a1,d0.w),d1
	bhs.b	pt_ftufound
	addq.l	#2,d0
	dbra	d7,pt_ftuloop
pt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#37*2,d1
	add.l	d1,a1
	move.w	0(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0
	beq.w	pt_checkmoreeffects

	move.w	n_dmabit(a6),$dff096
	btst	#2,n_wavecontrol(a6)
	bne.b	pt_vibnoc
	clr.b	n_vibratopos(a6)
pt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.b	pt_trenoc
	clr.b	n_tremolopos(a6)
pt_trenoc
	move.w	n_length(a6),4(a5)	;set length
	move.l	n_start(a6),(a5)	;set start
	bne.b	pt_sdmaskp
	clr.l	n_loopstart(a6)
	moveq	#1,d0
	move.w	d0,4(a5)
	move.w	d0,n_replen(a6)
pt_sdmaskp
	move.w	n_period(a6),d0
	move.w	d0,6(a5)		;set period
	st	n_trigger(a6)
	move.w	n_dmabit(a6),d0
	or.w	d0,pt_dmacontemp
	bra.w	pt_checkmoreeffects
 
pt_setdma
	move.b	pt_timeout,$bfe701	;timerb hi
	move.b	pt_timeout+1,$bfe601	;timerb lo
	move.b	#%000011001,$bfef01	;set commandbits: oneshot & clk & start
pt_timerwait1
	btst	#0,$bfef01		;timeout on timerb? (icr timerb)
	bne.s	pt_timerwait1		;nope...
	move.w	pt_dmacontemp,d0
	and.w	pt_activechannels,d0	;mask out inactive channels
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.b	pt_timeout,$bfe701	;timerb hi
	move.b	pt_timeout+1,$bfe601	;timerb lo
	move.b	#%000011001,$bfef01	;set commandbits: oneshot & clk & start
pt_timerwait2
	btst	#0,$bfef01		;timeout on timerb? (icr timerb)
	bne.s	pt_timerwait2		;nope...
	lea	$dff000,a5
	lea	pt_audchan4temp(pc),a6
	move.l	n_loopstart(a6),$d0(a5)
	move.w	n_replen(a6),$d4(a5)
	lea	pt_audchan3temp(pc),a6
	move.l	n_loopstart(a6),$c0(a5)
	move.w	n_replen(a6),$c4(a5)
	lea	pt_audchan2temp(pc),a6
	move.l	n_loopstart(a6),$b0(a5)
	move.w	n_replen(a6),$b4(a5)
	lea	pt_audchan1temp(pc),a6
	move.l	n_loopstart(a6),$a0(a5)
	move.w	n_replen(a6),$a4(a5)

pt_dskip
	add.l	#16,pt_patternposition
	move.b	pt_pattdelaytime,d0
	beq.b	pt_dskpc
	move.b	d0,pt_pattdelaytime2
	clr.b	pt_pattdelaytime
pt_dskpc
	tst.b	pt_pattdelaytime2
	beq.b	pt_dskpa
	subq.b	#1,pt_pattdelaytime2
	beq.b	pt_dskpa
	sub.l	#16,pt_patternposition
pt_dskpa
	tst.b	pt_pbreakflag
	beq.b	pt_nnpysk
	sf	pt_pbreakflag
	moveq	#0,d0
	move.b	pt_pbreakposition(pc),d0
	lsl.w	#4,d0
	move.l	d0,pt_patternposition
	clr.b	pt_pbreakposition
pt_nnpysk
	cmp.l	#1024,pt_patternposition
	bne.b	pt_nonewpositionyet
pt_nextposition	
	moveq	#0,d0
	move.b	pt_pbreakposition(pc),d0
	lsl.w	#4,d0
	move.l	d0,pt_patternposition
	clr.b	pt_pbreakposition
	clr.b	pt_posjumpassert
	addq.l	#1,pt_songposition
	and.l	#$7f,pt_songposition
	move.l	pt_songposition(pc),d1
	move.l	pt_songdataptr(pc),a0
	cmp.b	sd_numofpatt(a0),d1
	blo.b	pt_nonewpositionyet
	clr.l	pt_songposition
pt_nonewpositionyet
	tst.b	pt_posjumpassert
	bne.b	pt_nextposition
	movem.l	(sp)+,d0-d7/a0-a6
	rts

pt_checkeffects
	bsr.b	pt_chkefx2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts

pt_chkefx2
	bsr.w	pt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.b	pt_return
	move.b	n_cmd(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq.b	pt_arpeggio
	cmp.b	#1,d0
	beq.w	pt_portaup
	cmp.b	#2,d0
	beq.w	pt_portadown
	cmp.b	#3,d0
	beq.w	pt_toneportamento
	cmp.b	#4,d0
	beq.w	pt_vibrato
	cmp.b	#5,d0
	beq.w	pt_toneplusvolslide
	cmp.b	#6,d0
	beq.w	pt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq.w	pt_ecommands
pt_setback
	move.w	n_period(a6),6(a5)
	cmp.b	#7,d0
	beq.w	pt_tremolo
	cmp.b	#$a,d0
	beq.w	pt_volumeslide
pt_return
	rts

pt_pernop
	move.w	n_period(a6),6(a5)
	rts

pt_arpeggio
	moveq	#0,d0
	move.l	pt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#1,d0
	beq.b	pt_arpeggio1
	cmp.w	#2,d0
	beq.b	pt_arpeggio2
pt_arpeggio0
	move.w	n_period(a6),d2
	bra.b	pt_arpeggioset

pt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.b	pt_arpeggiofind

pt_arpeggio2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
pt_arpeggiofind
	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#37*2,d1
	lea	pt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#$24,d7
pt_arploop
	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.b	pt_arpeggioset
	addq.l	#2,a0
	dbra	d7,pt_arploop
	rts

pt_arpeggioset
	move.w	d2,6(a5)
	rts

pt_fineportaup
	tst.l	pt_counter
	bne.b	pt_return
	move.b	#$0f,pt_lowmask
pt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	pt_lowmask,d0
	move.b	#$ff,pt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#$0071,d0
	bpl.b	pt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#$0071,n_period(a6)
pt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts

pt_fineportadown
	tst.l	pt_counter
	bne.w	pt_return
	move.b	#$0f,pt_lowmask
pt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	pt_lowmask,d0
	move.b	#$ff,pt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#$0358,d0
	bmi.b	pt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#$0358,n_period(a6)
pt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts

pt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	pt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
pt_stploop
	cmp.w	0(a0,d0.w),d2
	bhs.b	pt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.b	pt_stploop
	moveq	#35*2,d0
pt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.b	pt_stpgoss
	tst.w	d0
	beq.b	pt_stpgoss
	subq.w	#2,d0
pt_stpgoss
	move.w	0(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.b	pt_cleartoneporta
	bge.w	pt_return
	move.b	#1,n_toneportdirec(a6)
	rts

pt_cleartoneporta
	clr.w	n_wantedperiod(a6)
	rts	
 
pt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.b	pt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
pt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq.w	pt_return
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.b	pt_toneportaup
pt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.b	pt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.b	pt_toneportasetper

pt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.b	pt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

pt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.b	pt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	pt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
pt_glissloop
	cmp.w	0(a0,d0.w),d2
	bhs.b	pt_glissfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.b	pt_glissloop
	moveq	#35*2,d0
pt_glissfound
	move.w	0(a0,d0.w),d2
pt_glissskip
	move.w	d2,6(a5) 		;set period
	rts

pt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.b	pt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.b	pt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
pt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	pt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
pt_vibskip2
	move.b	d2,n_vibratocmd(a6)
pt_vibrato2
	move.l	a4,-(sp)
	move.b	n_vibratopos(a6),d0
	lea	pt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.b	pt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	pt_vib_rampdown
	move.b	#255,d2
	bra.b	pt_vib_set
pt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	pt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	pt_vib_set
pt_vib_rampdown2
	move.b	d0,d2
	bra.b	pt_vib_set
pt_vib_sine
	move.b	0(a4,d0.w),d2
pt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.b	pt_vibratoneg
	add.w	d2,d0
	bra.b	pt_vibrato3
pt_vibratoneg
	sub.w	d2,d0
pt_vibrato3
	move.w	d0,6(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	move.l	(sp)+,a4
	rts

pt_toneplusvolslide
	bsr.w	pt_toneportnochange
	bra.w	pt_volumeslide

pt_vibratoplusvolslide
	bsr.b	pt_vibrato2
	bra.w	pt_volumeslide

pt_tremolo
	move.l	a4,-(sp)
	move.b	n_cmdlo(a6),d0
	beq.b	pt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.b	pt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
pt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	pt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
pt_treskip2
	move.b	d2,n_tremolocmd(a6)
pt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	pt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.b	pt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	pt_tre_rampdown
	move.b	#255,d2
	bra.b	pt_tre_set
pt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	pt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	pt_tre_set
pt_tre_rampdown2
	move.b	d0,d2
	bra.b	pt_tre_set
pt_tre_sine
	move.b	0(a4,d0.w),d2
pt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.b	pt_tremoloneg
	add.w	d2,d0
	bra.b	pt_tremolo3
pt_tremoloneg
	sub.w	d2,d0
pt_tremolo3
	bpl.b	pt_tremoloskip
	clr.w	d0
pt_tremoloskip
	cmp.w	#$40,d0
	bls.b	pt_tremolook
	move.w	#$40,d0
pt_tremolook
	move.w	d0,8(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	move.l	(sp)+,a4
	addq.l	#4,sp
	rts

pt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.b	pt_sononew
	move.b	d0,n_sampleoffset(a6)
pt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.b	pt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	rts
pt_sofskip
	move.w	#1,n_length(a6)
	rts

pt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.b	pt_volslidedown
pt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.b	pt_vsuskip
	move.b	#$40,n_volume(a6)
pt_vsuskip
	move.b	n_volume(a6),d0
	rts

pt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
pt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.b	pt_vsdskip
	clr.b	n_volume(a6)
pt_vsdskip
	move.b	n_volume(a6),d0
	rts

pt_positionjump
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.l	d0,pt_songposition
pt_pj2	clr.b	pt_pbreakposition
	st 	pt_posjumpassert
	rts

pt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.b	pt_volumeok
	moveq	#$40,d0
pt_volumeok
	move.b	d0,n_volume(a6)
	rts

pt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.b	pt_pj2
	move.b	d0,pt_pbreakposition
	st	pt_posjumpassert
	rts

pt_setspeed
	move.b	3(a6),d0
	and.w	#$ff,d0
	beq.b	pt_speednull
;	cmp.w	#32,d0			;change this for lev6/cia users
;	blo.b	normspd			;it updates the countervalues (tempo)
;	move.w	d0,realtempo		;for the bpm timer
;	movem.l	d0-d7/a0-a6,-(sp)
;	st	updatetempo
;	jsr	settempo
;	movem.l	(sp)+,d0-d7/a0-a6
;	rts
pt_normspd
	clr.l	pt_counter
	move.w	d0,pt_currspeed+2
	rts
pt_speednull
	rts

pt_checkmoreeffects
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq.w	pt_sampleoffset
	cmp.b	#$b,d0
	beq.w	pt_positionjump
	cmp.b	#$d,d0
	beq.b	pt_patternbreak
	cmp.b	#$e,d0
	beq.b	pt_ecommands
	cmp.b	#$f,d0
	beq.b	pt_setspeed
	cmp.b	#$c,d0
	beq.w	pt_volumechange
	bra.w	pt_pernop

pt_ecommands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.b	pt_filteronoff
	cmp.b	#1,d0
	beq.w	pt_fineportaup
	cmp.b	#2,d0
	beq.w	pt_fineportadown
	cmp.b	#3,d0
	beq.b	pt_setglisscontrol
	cmp.b	#4,d0
	beq.w	pt_setvibratocontrol
	cmp.b	#5,d0
	beq.w	pt_setfinetune
	cmp.b	#6,d0
	beq.w	pt_jumploop
	cmp.b	#7,d0
	beq.w	pt_settremolocontrol
	cmp.b	#8,d0
	beq.w	pt_karplusstrong
	cmp.b	#$e,d0
	beq.w	pt_patterndelay
	cmp.b	#9,d0
	beq.w	pt_retrignote
	cmp.b	#$a,d0
	beq.w	pt_volumefineup
	cmp.b	#$b,d0
	beq.w	pt_volumefinedown
	cmp.b	#$c,d0
	beq.w	pt_notecut
	cmp.b	#$d,d0
	beq.w	pt_notedelay
	cmp.b	#$f,d0
	beq.w	pt_funkit
	rts

pt_filteronoff
	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts	

pt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

pt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

pt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

pt_jumploop
	tst.l	pt_counter
	bne.w	pt_return
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.b	pt_setloop
	tst.b	n_loopcount(a6)
	beq.b	pt_jumpcnt
	sub.b	#1,n_loopcount(a6)
	beq.w	pt_return
pt_jmploop
	move.b	n_pattpos(a6),pt_pbreakposition
	st	pt_pbreakflag
	rts

pt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.b	pt_jmploop

pt_setloop
	move.l	pt_patternposition,d0
	lsr.l	#4,d0
	and.b	#63,d0
	move.b	d0,n_pattpos(a6)
	rts

pt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

pt_karplusstrong
	movem.l	d1-d2/a0-a1,-(sp)
	move.l	n_loopstart(a6),a0
	move.l	a0,a1
	move.w	n_replen(a6),d0
	add.w	d0,d0
	subq.w	#2,d0
pt_karplop
	move.b	(a0),d1
	ext.w	d1
	move.b	1(a0),d2
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a0)+
	dbra	d0,pt_karplop
	move.b	(a0),d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a0)
	movem.l	(sp)+,d1-d2/a0-a1
	rts

pt_retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.w	pt_rtnend
	move.l	pt_counter,d1
	bne.b	pt_rtnskp
	move.w	n_note(a6),d1
	and.w	#$0fff,d1
	bne.w	pt_rtnend
	move.l	pt_counter,d1
pt_rtnskp
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.w	pt_rtnend
pt_doretrg
	move.w	n_dmabit(a6),$dff096	;audio dma off
	move.l	n_start(a6),(a5)	;set sampledata pointer
	move.w	n_length(a6),4(a5)	;set length
	move.w	n_period(a6),6(a5)
	moveq	#0,d0
	move.b	n_volume(a6),d0

	move.b	pt_timeout,$bfe701	;timerb hi
	move.b	pt_timeout+1,$bfe601	;timerb lo
	move.b	#%000011001,$bfef01	;set commandbits: oneshot & clk & start
pt_timerwait3
	btst	#0,$bfef01		;timeout on timerb? (icr timerb)
	bne.s	pt_timerwait3		;nope...

	move.w	n_dmabit(a6),d0
	bset	#15,d0
	move.w	d0,$dff096

	move.b	pt_timeout,$bfe701	;timerb hi
	move.b	pt_timeout+1,$bfe601	;timerb lo
	move.b	#%000011001,$bfef01	;set commandbits: oneshot & clk & start
pt_timerwait4
	btst	#0,$bfef01		;timeout on timerb? (icr timerb)
	bne.s	pt_timerwait4		;nope...

	move.l	n_loopstart(a6),(a5)
	move.l	n_replen(a6),4(a5)
pt_rtnend
	move.l	(sp)+,d1
	rts

pt_volumefineup
	tst.l	pt_counter
	bne.w	pt_return
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra.w	pt_volslideup

pt_volumefinedown
	tst.l	pt_counter
	bne.w	pt_return
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra.w	pt_volslidedown2

pt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.l	pt_counter,d0
	bne.w	pt_return
	clr.b	n_volume(a6)
	rts

pt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.l	pt_counter,d0
	bne.w	pt_return
	move.w	(a6),d0
	and.w	#$0fff,d0
	beq.w	pt_return
	move.l	d1,-(sp)
	bra.w	pt_doretrg

pt_patterndelay
	tst.l	pt_counter
	bne.w	pt_return
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	pt_pattdelaytime2
	bne.w	pt_return
	addq.b	#1,d0
	move.b	d0,pt_pattdelaytime
	rts

pt_funkit
	tst.l	pt_counter
	bne.w	pt_return
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq.w	pt_return
pt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.b	pt_funkend
	lea	pt_funktable(pc),a0
	move.b	0(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.b	pt_funkend
	clr.b	n_funkoffset(a6)
	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.b	pt_funkok
	move.l	n_loopstart(a6),a0
pt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
pt_funkend
	movem.l	(sp)+,a0/d1
	rts

pt_funktable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

pt_vibratotable	
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

pt_periodtable
; -> tuning 0
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113,0
; -> tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113,0
; -> tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112,0
; -> tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111,0
; -> tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110,0
; -> tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109,0
; -> tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109,0
; -> tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108,0
; -> tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120,0
; -> tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119,0
; -> tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118,0
; -> tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118,0
; -> tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117,0
; -> tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116,0
; -> tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115,0
; -> tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114,0

pt_audchan1temp	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
pt_audchan2temp	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
pt_audchan3temp	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
pt_audchan4temp	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

pt_samplestarts	dcb.l	31,0

pt_timeout	dc.w	330		;cia-b timeout-value
pt_counter	dc.l	0
pt_currspeed	dc.l	6
pt_pattpos	dc.w	0
pt_dmacontemp	dc.w	0
pt_activechannels
		dc.w	%00001111
pt_patternptr	dc.l	0
pt_patternposition
		dc.l	0
pt_songposition	dc.l	0	
pt_songdataptr	dc.l	0
pt_metrospeed	dc.b	0
pt_metrochannel	dc.b	0
pt_speed	dc.b	6
pt_songpos	dc.b	0
pt_pbreakposition
		dc.b	0
pt_posjumpassert
		dc.b	0
pt_pbreakflag	dc.b	0
pt_lowmask	dc.b	0
pt_pattdelaytime
		dc.b	0
pt_pattdelaytime2
		dc.b	0
		even

