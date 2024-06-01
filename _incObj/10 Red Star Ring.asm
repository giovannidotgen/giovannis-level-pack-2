; ---------------------------------------------------------------------------
; Object 10 - Red Star Ring
; ---------------------------------------------------------------------------

Obj10:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RedStar_Index(pc,d0.w),d1
		jmp	RedStar_Index(pc,d1.w)
; ===========================================================================
RedStar_Index:	dc.w RedStar_Init-RedStar_Index
		dc.w 	RedStar_Display-RedStar_Index
		dc.w	RedStar_Collect-RedStar_Index
; ===========================================================================		

RedStar_Init:
		addq.b	#2,obRoutine(a0)
		move.w	obX(a0),$32(a0)
		move.l	#Map_RedStarRing,obMap(a0)
		move.w	#($A760/$20),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#2,obPriority(a0)
		move.b	#$5A,obColType(a0)
		move.b	#$10,obActWid(a0)
		
RedStar_Display:
		move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
		bsr.w	RedStar_LoadGFX
		jmp		RememberState
		
RedStar_Collect:
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		jmp		DeleteObject
		
RedStar_LoadGFX:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	(v_redstar_lastframe).w,d0 ; has frame changed?
		beq.s	.nochange	; if not, branch

		move.b	d0,(v_redstar_lastframe).w
		lea	(DPLC_RedStarRing).l,a2 ; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5	; read "number of entries" value
		subq.b	#1,d5
		bmi.s	.nochange	; if zero, branch
		move.w	#$A760,d4
		move.l	#Art_RedStarRing,d6
		
	.readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,.readentry	; repeat for number of entries
		
	.nochange:
		rts	