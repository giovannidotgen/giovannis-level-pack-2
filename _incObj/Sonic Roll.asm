; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:
		tst.b	(f_jumponly).w
		bne.s	Sonic_NoRoll
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right	being pressed?
		bne.s	Sonic_NoRoll		; if yes, branch
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.s	Sonic_ChkWalk	; if yes, branch		
		move.w	obInertia(a0),d0
		bpl.s	.ispositive
		neg.w	d0

	.ispositive:
		cmpi.w	#$100,d0		; is Sonic moving at $80 speed or faster?
		bhs.s	Sonic_ChkRoll		; if not, branch
		btst	#3,obStatus(a0)
		bne.s	Sonic_NoRoll
		move.b	#id_Duck,obAnim(a0)

	Sonic_NoRoll:
		rts	
; ===========================================================================

Sonic_ChkWalk:
		cmpi.b	#id_Duck,obAnim(a0)	; is Sonic ducking?
		bne.s	Sonic_NoRoll
		move.b	#id_Walk,obAnim(a0)	; if so, enter walking animation
		rts

Sonic_ChkRoll:
		btst	#2,obStatus(a0)	; is Sonic already rolling?
		beq.s	.roll		; if not, branch
		rts	
; ===========================================================================

.roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		addq.w	#5,obY(a0)
		move.w	#sfx_Roll,d0
		jsr	(PlaySound_Special).l	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) ; set inertia if 0

	.ismoving:
		rts	
; End of function Sonic_Roll