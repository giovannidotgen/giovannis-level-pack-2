; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

GiantRing:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	dc.w GRing_Main-GRing_Index
		dc.w GRing_Animate-GRing_Index
		dc.w GRing_Collect-GRing_Index
		dc.w GRing_Delete-GRing_Index
; ===========================================================================

GRing_Main:	; Routine 0
		move.l	#Map_GRing,obMap(a0)
		move.w	#$2000+($D740/$20),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.b	#2,obPriority(a0)
		move.b	#$52,obColType(a0)

GRing_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)
		out_of_range_S3.w	DeleteObject
		bsr.w	GRing_LoadGFX		; now with DPLCs!
		bra.w	DisplaySprite
; ===========================================================================

GRing_Collect:	; Routine 4
		subq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.w	GRing_PlaySnd
		move.b	#id_RingFlash,0(a1) ; load giant ring flash object
		st.b	(v_gfxbigring+1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,$3C(a1)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0	; has Sonic come from the left?
		bcs.s	GRing_PlaySnd	; if yes, branch
		bset	#0,obRender(a1)	; reverse flash	object
		clr.b	(v_dust).w		; delete dust object

GRing_PlaySnd:
		move.w	#sfx_GiantRing,d0
		jsr	(PlaySound_Special).l	; play giant ring sound
		bra.w	GRing_Animate
; ===========================================================================

GRing_Delete:	; Routine 6
		bra.w	DeleteObject

; ==========================================================================

GRing_LoadGFX:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	(v_gfxbigring).w,d0 ; has frame changed?
		beq.s	.nochange	; if not, branch

		move.b	d0,(v_gfxbigring).w
		lea	(GRing_DynPLC).l,a2 ; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5	; read "number of entries" value
		subq.b	#1,d5
		bmi.s	.nochange	; if zero, branch
		move.w	#$D740,d4
		move.l	#Art_BigRing,d6
		
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
		
GRing_DynPLC:
		include "_maps\Giant Ring DPLCs.asm"