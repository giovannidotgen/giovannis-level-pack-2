; ---------------------------------------------------------------------------
; Animation script - springs
; ---------------------------------------------------------------------------
Ani_Spring:	
		dc.w @vertical-Ani_Spring
		dc.w @verticalBounce-Ani_Spring
		dc.w @horizontal-Ani_Spring
		dc.w @horizontalBounce-Ani_Spring
		dc.w @diagonal-Ani_Spring
		dc.w @diagonalBounce-Ani_Spring

@vertical:			dc.b $F,0,$FF		
@verticalBounce:	dc.b 0,	1, 0, 0, 2, 2, 2, 2, 2,	2, 0, $FD,0
@horizontal:		dc.b $F,3,$FF
@horizontalBounce:	dc.b 0,	4, 3, 3, 5, 5, 5, 5, 5,	5, 3, $FD,2
@diagonal:			dc.b $F,6,$FF
@diagonalBounce:	dc.b 0,	7, 6, 6, 8, 8, 8, 8, 8,	8, 6, $FD,4

		even