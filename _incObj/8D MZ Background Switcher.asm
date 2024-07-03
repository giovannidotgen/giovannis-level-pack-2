; ----------------------------------------------------------------------------
; Marble Zone background switcher
; ----------------------------------------------------------------------------
; Sprite_1FCDC:
MZBGSwitcher:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BGSwitcher_Index(pc,d0.w),d1
		jsr	BGSwitcher_Index(pc,d1.w)
	if DebugPathSwappers
		tst.w	(f_debugcheat).w
		bne.w	RememberState
	endc
		; like RememberState, but doesn't display (Sonic 2's MarkObjGone3)
		out_of_range_S3.w	.offscreen
		rts

	.offscreen:
		move.w	respawn_index(a0),d0	; get address in respawn table
		beq.s	.delete		; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again

	.delete:
		jmp		DeleteObject
; ===========================================================================
; off_1FCF0:
BGSwitcher_Index:
		dc.w BGSwitcher_Init-BGSwitcher_Index	; 0
		dc.w BGSwitcher_MainX-BGSwitcher_Index	; 2
		dc.w BGSwitcher_MainY-BGSwitcher_Index	; 4
; ===========================================================================
; loc_1FCF6:
BGSwitcher_Init:
		addq.b	#2,obRoutine(a0) ; => BGSwitcher_MainX
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#$27B2,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#5,obPriority(a0)
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	BGSwitcher_Init_CheckX
;BGSwitcher_Init_CheckY:
		addq.b	#2,obRoutine(a0) ; => BGSwitcher_MainY
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	.word_1FD68(pc,d0.w),$32(a0)
		move.w	obY(a0),d1
		lea	(v_player).w,a1 ; a1=character
		cmp.w	obY(a1),d1
		bhs.w	BGSwitcher_MainY
		move.b	#1,$34(a0)
		bra.w	BGSwitcher_MainY
; ===========================================================================
.word_1FD68:
	dc.w   $20
	dc.w   $40	; 1
	dc.w   $80	; 2
	dc.w  $100	; 3
; ===========================================================================
; loc_1FD70:
BGSwitcher_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	BGSwitcher_Init.word_1FD68(pc,d0.w),$32(a0)
		move.w	obX(a0),d1
		lea	(v_player).w,a1 ; a1=character
		cmp.w	obX(a1),d1
		bhs.s	.jump
		move.b	#1,$34(a0)
.jump:

; loc_1FDA4:
BGSwitcher_MainX:
		tst.w	(v_debuguse).w
		bne.w	.locret
		move.w	obX(a0),d1
		lea	$34(a0),a2
		lea	(v_player).w,a1 ; a1=character
		tst.b	(a2)+
		bne.w	BGSwitcher_MainX_Alt
		cmp.w	obX(a1),d1
		bhi.s	.locret
		move.b	#1,-1(a2)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#1,obStatus(a1)
		bne.s	.locret
.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		clr.b	(v_bgswapper).w
		btst	#3,d0
		beq.s	.jump2
		move.b	#1,(v_bgswapper).w
.jump2:
.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp	(PlaySound_Special).l
	endc
.locret:
		rts
; ===========================================================================
; loc_1FE38:
BGSwitcher_MainX_Alt:
		cmp.w	obX(a1),d1
		bls.s	.locret
		move.b	#0,-1(a2)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#1,obStatus(a1)
		bne.s	.locret
.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		clr.b	(v_bgswapper).w
		btst	#4,d0
		beq.s	.jump2
		move.b	#1,(v_bgswapper).w
.jump2:
.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp	(PlaySound_Special).l
	endc
.locret:
		rts
; ===========================================================================

BGSwitcher_MainY:
		tst.w	(v_debuguse).w
		bne.w	.locret
		move.w	obY(a0),d1
		lea	$34(a0),a2
		lea	(v_player).w,a1 ; a1=character
		tst.b	(a2)+
		bne.s	BGSwitcher_MainY_Alt
		cmp.w	obY(a1),d1
		bhi.s	.locret
		move.b	#1,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#1,obStatus(a1)
		bne.s	.locret
.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		clr.b	(v_bgswapper).w
		btst	#3,d0
		beq.s	.jump2
		move.b	#1,(v_bgswapper).w
.jump2:
.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp	(PlaySound_Special).l
	endc
.locret:
		rts
; ===========================================================================
; loc_1FF42:
BGSwitcher_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.s	.locret
		move.b	#0,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#1,obStatus(a1)
		bne.s	.locret
.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		clr.b	(v_bgswapper).w
		btst	#4,d0
		beq.s	.jump2
		move.b	#1,(v_bgswapper).w
.jump2:
.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp	(PlaySound_Special).l
	endc
.locret:
		rts
; ===========================================================================