; ---------------------------------------------------------------------------
; Object 7C - flash effect when	you collect the	giant ring
; ---------------------------------------------------------------------------

RingFlash:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Flash_Index(pc,d0.w),d1
		jmp	Flash_Index(pc,d1.w)
; ===========================================================================
Flash_Index:	dc.w Flash_Main-Flash_Index
		dc.w Flash_ChkDel-Flash_Index
		dc.w Flash_EndLevel-Flash_Index
; ===========================================================================

Flash_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Flash,obMap(a0)
		move.w	#$253B,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$FF,obFrame(a0)

Flash_ChkDel:	; Routine 2
		bsr.s	Flash_Collect
		out_of_range_S3.w	DeleteObject
		bsr.w	Flash_LoadGFX
		bra.w	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Flash_Collect:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_9F76
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#8,obFrame(a0)	; has animation	finished?
		bcc.s	Flash_End	; if yes, branch
		cmpi.b	#3,obFrame(a0)	; is 3rd frame displayed?
		bne.s	locret_9F76	; if not, branch
		movea.l	$3C(a0),a1	; get parent object address
		move.b	#6,obRoutine(a1) ; delete parent object
		move.b	#id_Null,(v_player+obAnim).w ; make Sonic invisible
		move.b	#1,(f_bigring).w ; stop	Sonic getting bonuses
		clr.b	(v_invinc).w	; remove invincibility
		clr.b	(v_shield).w	; remove shield
		clr.b	(f_timecount).w	; freeze timer

locret_9F76:
		rts	
; ===========================================================================

Flash_End:
		addq.b	#2,obRoutine(a0)
		move.w	#0,(v_player).w ; remove Sonic object
		move.b	#60,obTimeFrame(a0)	; set a 1 second timer
		addq.l	#4,sp			; prematurely end object execution
		rts	
; End of function Flash_Collect

; ===========================================================================

Flash_EndLevel:	; Routine 4
		sub.b	#1,obTimeFrame(a0)
		beq.s	.zero
		rts
		
	.zero:
; Fetch Save data
		lea		(v_level_savedata).w,a1
		moveq	#0,d0
		move.w	(v_levselitem).w,d0
		lsl.w	#3,d0	; save data size is 8
		adda.l	d0,a1
		
; Time
		move.l	(v_time),d1
		move.l	d1,d2
		swap	d2
		cmp.b	1(a1),d2	; test minutes
		blt.s	Time_SaveRecord		; if lower, save
		move.l	d1,d2
		lsl.l	#8,d2
		cmp.b	2(a1),d2	; test seconds
		blt.s	Time_SaveRecord		; if lower, save
		cmp.b	3(a1),d1	; test frames
		bge.s	Time_AdvanceToNext	; if higher, advance to next
		
	Time_SaveRecord:
		move.l	(v_time),(a1)		; copy time to save data
	
	Time_AdvanceToNext:
		adda.l	#4,a1

; Rings
		moveq	#0,d2
		move.w	(v_rings),d2
		cmp.w	(a1),d2		; test rings
		blt.s	Rings_AdvanceToNext	; if not higher, advance to next
		move.w	(v_rings),(a1)
		
	Rings_AdvanceToNext:	
		adda.l	#2,a1
		
; Red Star Rings
		lea		(v_redstar_collection).w,a2
		moveq	#4,d0
		
		
	.looprings:
		movea.l	a2,a3	; copy red star ring buffer address
		adda.l	d0,a3	; get exact RSR address
		btst	d0,(a1)	; test if ring was collected already
		bne.s	.skip	; if yes, skip check entirely
		tst.b	(a3)	; check if ring was collected
		beq.s	.skip	; if not, skip this ring
		bset	d0,(a1)	; mark RSR as collected
		
	.skip:
		dbf		d0,.looprings
		adda.l	#1,a1
		
; Exits
		moveq	#0,d0
		move.b	obSubtype(a0),d0	; get Exit ID
		bset	d0,(a1)				; mark as found	
			
		move.b	#id_LevelEnd,(v_gamemode).w
		bra.w	DeleteObject

Flash_LoadGFX:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	(v_gfxbigring+1).w,d0 ; has frame changed?
		beq.s	.nochange	; if not, branch

		move.b	d0,(v_gfxbigring+1).w
		lea	(Flash_DynPLC).l,a2 ; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5	; read "number of entries" value
		subq.b	#1,d5
		bmi.s	.nochange	; if zero, branch
		move.w	#$A760,d4
		move.l	#Art_BigFlash,d6
		
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
		
Flash_DynPLC:
		include "_maps\Ring Flash DPLC.asm"