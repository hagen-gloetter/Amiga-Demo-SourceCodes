
; wer hätte sich das träumen lassen ? ich tippe freiwillig bsys kompatible
; dinger wie screens & windows ! seufz wie weit ist es mir mir nur gekommen !

OpenLib		=	-552
CloseLib	=	-414
OpenScreen	=	-198
CloseScreen	=	-66
OpenWindow	=	-204
CloseWindow	=	-72

x:	move.l	4.w,a6
	move.l	#IntuitionName,a1		; Open Intuition Lib
	moveq	#37,d0				; kick 2.0 only
	jsr	OpenLib(a6)
	blo.b	end
	move.l	d0,IntuitionBase

	move.l	d0,a6

opSc	lea	ScreenDefs,a0			; Open Screen
	jsr	OpenScreen(a6)	
	beq.b	clInt
	move.l	d0,ScreenPointer
	move.l	d0,ScreenPointer2

opWin	lea	WindowDefs,a0			; Open Window
	jsr	OpenWindow(a6)
	beq.b	clSc
	move.l	d0,WindowPointer

MAUS:	btst	#6,$bfe001	;LMT
	btst	#2,$dff016	;RMT
	bne.s	MAUS

clWin	move.l	WindowPointer,a0			; Close Window
	jsr	CloseWindow(a6)
clSc	move.l	ScreenPointer,a0		; Close Screen
	jsr	CloseScreen(a6)
clInt	move.l	IntuitionBase,a1		; Close Intuition Lib
	jsr	CloseLib(a6)
end	moveq	#0,d0
	rts


;---------------------------------------------------------- DATEN-SECTION

IntuitionBase	dc.l	0
IntuitionName	dc.b	"intuition.library",0

ScreenPointer	dc.l	0
WindowPointer	dc.l	0

ScreenDefs	dc.w	0	; linke Ecke
		dc.w	0	; obere Ecke
		dc.w	640	; Breite
		dc.w	256	; Höhe
		dc.w	2	; Tiefe
		dc.b	2,3	; Farben
		dc.w	$c000	; Modus
		dc.w	15	; Typ
		dc.l	0	; Zeichensatz
		dc.l	ScTitel	; Titel
		dc.l	0	; Gadgeds
		dc.l	0	; Bitmap

ScTitel		dc.b	"TEST-Screen"	
		even
		
WindowDefs	dc.w	0	; linke Ecke
		dc.w	10	; obere Ecke
		dc.w	640	; Breite
		dc.w	246	; Höhe
		dc.b	0,3	; Farben
		dc.l	$300	; Event Flags (IDCMP)
		dc.l	$150f	; Window Flags 
		dc.l	0	; Zeiger auf 1. Gadget
		dc.l	0	; Check Mark
		dc.l	WinTitel; Titel
ScreenPointer2	dc.l	0	; ScreenPointer
		dc.l	0	; Bitmap
		dc.w	640	; min. Breite
		dc.w	246	; min. Höhe
		dc.w	640	; max. Breite
		dc.w	246	; max. Höhe
		dc.w	15	; Screentyp

WinTitel	dc.b	"TEST-Window",0
		even

