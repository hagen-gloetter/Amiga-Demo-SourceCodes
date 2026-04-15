
;---------------------------------------------------------- CODEFATHER

; X rot
	;new Y = Ykoord * cos (alpha) + Zkoord * sin (alpha)
	;new Z = Zkoord * cos (alpha) - Ykoord * sin (alpha)

; Y rot
	;new X = Xkoord * cos (beta) + Zkoord * sin (beta)
 	;new Z = Zkoord * cos (beta) - Xkoord * sin (beta)

; Z rot
 	;new X = Xkoord * cos (gamma) + Ykoord * sin (gamma)
 	;new Y = Ykoord * cos (gamma) - Xkoord * sin (gamma)

EyePos
	;Zneu = Z-EyePos
	;ScreenX = Zoomstartpos*Xkoord / Zneu
	;ScreenY = Zoomstartpos*Ykoord / Zneu


EyePos = 3000
ZoomStartPos = 200

Object:
	dc.w	Xkrd1,Ykrd1,Zkrd1	;punkt1
	dc.w	Xkrd2,Ykrd2,Zkrd2	;punkt2
	dc.w	Xkrd3,Ykrd3,Zkrd3
	dc.w	Xkrd4,Ykrd4,Zkrd4

;---------------------------------------------------------- THE BOP

VecStars: from Boris
	y2= (y3*dist/z3+dist)+Screen/2
	x2= (x3*dist/z3+dist)+Screen/2


