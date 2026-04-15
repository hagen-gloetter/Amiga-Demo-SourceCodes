
	dc.w	$0001,$7ffe		; WaitBlt
	dc.w	$0001,$7ffe		; WaitBlt
CopCls:	dc.w	$54,0,$56,0		; Bltddat
	dc.w	$40,$0100,$42,$0000	; Bltcon0+1
	dc.w	$66,0			; Bltdmod
	dc.w	$58,(320*64+20)		; BltSize
	
