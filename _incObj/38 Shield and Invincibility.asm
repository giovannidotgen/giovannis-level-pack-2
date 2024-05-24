; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp	Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:	dc.w Shi_Main-Shi_Index
		dc.w Shi_Shield-Shi_Index
		dc.w Shi_Stars-Shi_Index
; ===========================================================================

Shi_Main:	; Routine 0
		
		addq.b	#2,obRoutine(a0)
		move.w	#($AF80/$20),obGfx(a0)	
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
		tst.b	obAnim(a0)	; is object a shield?
		bne.s	.stars		; if not, branch
		move.l	#Map_Shield,obMap(a0)	
		tst.b	(v_invinc).w		; are you invincible?
		beq.w	LoadShieldGraphics	; if not, load shield graphics
		rts
			
; ===========================================================================

.stars:
		addq.b	#2,obRoutine(a0) ; goto Shi_Stars next
		move.l	#Map_Invincibility,obMap(a0)
		bra.w	LoadInvincibilityGraphics
			
; ===========================================================================

Shi_Shield:	; Routine 2
		tst.b	(v_invinc).w	; does Sonic have invincibility?
		bne.s	.remove		; if yes, branch
		tst.b	(v_shield).w	; does Sonic have shield?
		beq.s	.delete		; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea	(Ani_Shield).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l

	.remove:
		rts	

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================

Shi_Stars:	; Routine 4
		tst.b	(v_invinc).w	; does Sonic have invincibility?
		beq.s	Shi_Start_Delete		; if not, branch
		move.w	(v_trackpos).w,d0 ; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1
		bra.s	.trail
; ===========================================================================
		lsl.b	#4,d1
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0
		addq.b	#4,d1
		andi.b	#$F,d1
		move.b	d1,$30(a0)
		bra.s	.b
; ===========================================================================

.trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		bcs.s	.a
		moveq	#0,d1

	.a:
		move.b	d1,$30(a0)

	.b:
		lea	(v_tracksonic).w,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea	(Ani_Shield).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================

Shi_Start_Delete:	
		jmp	(DeleteObject).l

; ===========================================================================
; Subroutines to load uncompressed graphics for the Shield and the 
; Invincibility.
;
; Stacks a0 and a6.
; Clears d1.
; ===========================================================================

LoadShieldGraphics:
		moveq	#0,d2
		moveq	#0,d3
		move.l	#Art_Shield,d1
		move.w	#$AF80,d2
		move.w	#(Art_Shield_End-Art_Shield)/2,d3
		jmp		QueueDMATransfer
		
LoadInvincibilityGraphics:
		moveq	#0,d2
		moveq	#0,d3
		move.l	#Art_Invincibility,d1
		move.w	#$AF80,d2
		move.w	#(Art_Invincibility_End-Art_Invincibility)/2,d3
		jmp		QueueDMATransfer