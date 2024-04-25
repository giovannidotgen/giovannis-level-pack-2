ClrPalBuffer:
	moveq	#((v_pal_buffer_end-v_pal_buffer)/4)-1,d0
	move.l	a0,-(sp)
	lea		(v_pal_buffer).l,a0
	
.clear:
	clr.l	(a0)+
	dbf		d0,.clear
	
	movea.l	(sp)+,a0
	rts