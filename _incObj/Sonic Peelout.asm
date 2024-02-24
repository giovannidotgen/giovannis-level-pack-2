; ---------------------------------------------------------------------------
; Subroutine to make Sonic perform a peelout
; ---------------------------------------------------------------------------
; If you use this makes sure to search for ;Peelout in Sonic1.asm
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_Peelout:
		btst	#1,f_spindash(a0)
		bne.s	SCDPeelout_Launch
		cmpi.b	#id_LookUp,obAnim(a0) ;check to see if your looking up
		bne.s	@return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	@return
		move.b	#id_Run,obAnim(a0)
		move.w	#0,spindashcharge(a0)
		move.w #sfx_PeeloutCharge,d0 
        jsr (PlaySound_Special).l	; play peelout sound
		addq.l	#4,sp
		bset	#1,f_spindash(a0)
		
		clr.w	obInertia(a0)
 
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
 
	@return:
		rts	
; ---------------------------------------------------------------------------
 
SCDPeelout_Launch:
		move.b	(v_jpadhold2).w,d0
		btst	#0,d0
		bne.w	SCDPeelout_Charge
		bclr	#1,f_spindash(a0)	; stop Dashing
		cmpi.b	#$1E,spindashcharge(a0)	; have we been charging long enough?
		move.b	#0,obAnim(a0)	; launches here (peelout sprites)
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		btst	#0,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)
 
@dontflip:
		bclr	#7,obStatus(a0)
		move.w	#sfx_PeeloutRelease,d0 
        jsr (PlaySound_Special).l	; play release sound
		bra.w	SCDPeelout_ResetScr
; ---------------------------------------------------------------------------
 
SCDPeelout_Charge:				; If still charging the dash...
		move.w	(v_sonspeedmax).w,d1	; get top peelout speed
		move.w	d1,d2
		add.w	d1,d1
		tst.b   (v_shoes).w 		; test for speed shoes
		beq.s	@noshoes
		asr.w	#1,d2
		sub.w	d2,d1

@noshoes:
		addi.w	#$64,obInertia(a0)		; increment speed
		cmp.w	obInertia(a0),d1
		bgt.s	@inctimer
		move.w	d1,obInertia(a0)

@inctimer:
		addq.b	#1,spindashcharge(a0)		; increment timer
		cmpi.b	#$1E,spindashcharge(a0)
		bcs.s	SCDPeelout_ResetScr
		move.b	#$1E,spindashcharge(a0)
		jmp 	SCDPeelout_ResetScr
		
SCDPeelout_Stop_Sound:
		move.w	#sfx_PeeloutStop,d0
        jsr (PlaySound_Special).l	; stop sound		
		clr.w	obInertia(a0)

SCDPeelout_ResetScr:
		addq.l	#4,sp			; increase stack ptr ; was 4
		cmpi.w	#$60,(v_lookshift).w
		beq.s	@finish
		bcc.s	@skip
		addq.w	#4,(v_lookshift).w
 
	@skip:
		subq.w	#2,(v_lookshift).w
 
	@finish:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		rts
		