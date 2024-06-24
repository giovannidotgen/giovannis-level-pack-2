; ---------------------------------------------------------------------------
; Object 4F - New Record Icon
; ---------------------------------------------------------------------------

Obj4F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	NewRecord_Index(pc,d0.w),d1
		jmp	NewRecord_Index(pc,d1.w)

; ===========================================================================
NewRecord_Index:	dc.w NewRecord_Init-NewRecord_Index
					dc.w NewRecord_Flash-NewRecord_Index
; ===========================================================================		

NewRecord_Init:
		addq.b	#2,obRoutine(a0)
		move.b	#9,obFrame(a0)
		move.l	#Map_Got,obMap(a0)
		move.w	#($A800/$20),obGfx(a0)
		move.b	#0,obRender(a0)
;		move.w	#$A0,obX(a0)
;		move.w	#$A0,obScreenY(a0)
		move.b	#$7F,$3F(a0)
		
NewRecord_Flash:
		sub.b	#$4,$3F(a0)
		bmi.s	.skip
		jmp		DisplaySprite
		
	.skip:	
		rts	