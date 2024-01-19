; ----------------------------------------------------------------------------
; Object 07 - Attracted ring (ported from Sonic and Knuckles)
; ----------------------------------------------------------------------------
Obj07:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj07_subtbl(pc,d0.w),d1
		jmp	Obj07_subtbl(pc,d1.w)
; ===========================================================================
Obj07_subtbl:
		dc.w	Obj07_sub_0-Obj07_subtbl; 0
		dc.w	Obj07_sub_2-Obj07_subtbl; 2
		dc.w	Obj07_sub_4-Obj07_subtbl; 4
		dc.w	Obj07_sub_6-Obj07_subtbl; 6
		dc.w	Obj07_sub_8-Obj07_subtbl; 8
; ===========================================================================

Obj07_sub_0:
		addq.b	#2,obRoutine(a0)
		move.w	obX(a0),$32(a0)
		move.l	#Map_Ring,obMap(a0)
		move.w	#$27B2,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#2,obPriority(a0)
		move.b	#$47,obColType(a0)
		move.b	#8,obActWid(a0)
		
Obj07_sub_2:
		bsr.w	Obj07_Move
		movea.w	$34(a0),a1
		cmpi.b	#2,(v_shield).w
		beq.s	Obj07_sub_3
		move.b	#id_RingLoss,(a0)	; Load object 37 (scattered rings)
		move.b	#2,obRoutine(a0)
		move.b	#-1,(v_ani3_time).w

Obj07_sub_3:
		move.b	(v_ani1_frame).w,obFrame(a0)
		move.w	$32(a0),d0
		bra.w	DisplaySprite
; ===========================================================================

Obj07_sub_4:
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		subq.w	#1,(Perfect_rings_left).w
		bsr.w	CollectRing

Obj07_sub_6:
		lea	(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj07_sub_8:
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj07_Move:
		movea.w	$34(a0),a1
		move.w	#$30,d1
		move.w	obX(a1),d0
		cmp.w	obX(a0),d0
		bcc.s	loc_1A956
		neg.w	d1
		tst.w	obVelX(a0)
		bmi.s	loc_1A960
		add.w	d1,d1
		add.w	d1,d1
		bra.s	loc_1A960
; ===========================================================================

loc_1A956:
		tst.w	obVelX(a0)
		bpl.s	loc_1A960
		add.w	d1,d1
		add.w	d1,d1

loc_1A960:
		add.w	d1,obVelX(a0)
		move.w	#$30,d1
		move.w	$C(a1),d0
		cmp.w	$C(a0),d0
		bcc.s	loc_1A980
		neg.w	d1
		tst.w	obVelY(a0)
		bmi.s	loc_1A988
		add.w	d1,d1
		add.w	d1,d1
		bra.s	loc_1A988
; ===========================================================================

loc_1A980:
		tst.w	obVelY(a0)
		bpl.s	loc_1A988
		add.w	d1,d1
		add.w	d1,d1

loc_1A988:
		add.w	d1,obVelY(a0)
		jmp	(SpeedToPos).l
; ===========================================================================