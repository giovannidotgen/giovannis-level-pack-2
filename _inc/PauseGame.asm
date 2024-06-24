; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:
		nop	
		tst.w	(f_pause).w	; is game already paused?
		bne.s	Pause_StopGame	; if yes, branch
		btst	#bitStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Pause_DoNothing	; if not, branch

Pause_StopGame:
		move.w	#1,(f_pause).w	; freeze time
		SMPS_Pause

Pause_Loop:
		move.b	#$10,(v_vbla_routine).w
		bsr.w	WaitForVBla
		btst	#bitA,(v_jpadpress1).w ; is button A pressed?
		beq.s	Pause_ChkStart	; if not, branch
		move.b	#id_LevelSelect,(v_gamemode).w ; set game mode to level select
		nop	
		bra.s	Pause_EndMusic
; ===========================================================================

Pause_ChkStart:
		btst	#bitStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Pause_Loop	; if not, branch

Pause_EndMusic:
		SMPS_Unpause

Unpause:
		move.w	#0,(f_pause).w	; unpause the game

Pause_DoNothing:
		rts	
; ===========================================================================

Pause_SlowMo:
		move.w	#1,(f_pause).w
		SMPS_Unpause
		rts	
; End of function PauseGame
