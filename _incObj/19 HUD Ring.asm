HUDRing:
	tst.w	obGfx(a0)
	bne.s	.display
	
	move.w	#$98,obX(a0)
	move.w	#$9F,obScreenY(a0)
	move.l	#Map_Ring,obMap(a0)
	move.w	#$A7B2,obGfx(a0)
	move.b	#0,obRender(a0)
	move.b	#0,obPriority(a0)
	
.display:
	move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
	jmp		DisplaySprite