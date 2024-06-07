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
		lea		(v_redstar_collection).w,a1		; get collection array
		moveq	#0,d0		
		move.b	obSubtype(a0),d0				; get subtype				
		andi.b	#$7F,d0							; clear MSB		
		adda.l	d0,a1
		tst.b	(a1)							; was this ring collected?
		beq.s	RedStar_Display					; keep as is if no
		bset	#7,obSubtype(a0)				; display as collected if yes
		clr.b	obColType(a0)					; also make intangible (temp)
		
RedStar_Display:
		move.b	(v_ani1_frame).w,obFrame(a0) ; set frame
		bsr.w	RedStar_LoadGFX
		jmp		RememberState
		
RedStar_Collect:
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		moveq	#4-1,d4
		lea		Redstar_SparklePos,a2
		moveq	#0,d2
		moveq	#0,d3
		
	.makesparkles:
		jsr		FindFreeObj
		bne.s	.delete
		
		; Make a sparkle
		move.b	#id_Rings,(a1)
		move.b	#6,obRoutine(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#$7B2,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#1,obPriority(a1)

		; Set its coordinates
		move	d4,d1
		add.b	d1,d1
		add.b	d1,d1
		move.l	(a2,d1.w),d2
		move.w	obX(a0),obX(a1)
		add.w	d2,obX(a1)
		swap	d2
		move.w	obY(a0),obY(a1)
		add.w	d2,obY(a1)
		
		dbf		d4,.makesparkles
		
	.delete:	
		lea		(v_redstar_collection).w,a1		; get collection array
		moveq	#0,d0		
		move.b	obSubtype(a0),d0				; get subtype				
		andi.b	#$7F,d0							; clear MSB		
		adda.l	d0,a1
		st.b	(a1)							; mark ring as collected	
		ori.b	#1,(f_redstar_update).w
	
		move.w	#sfx_GiantRing,d0
		jsr	(PlaySound_Special).l	; play giant ring sound	
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
		tst.b	obSubtype(a0)		; MSB = ring was collected
		bpl.s	.readentry
		move.l	#Art_GrayStarRing,d6
		
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
		
Redstar_SparklePos:
		dc.w	-8, -8
		dc.w	-8, 8
		dc.w	8, -8
		dc.w	8, 8
		even