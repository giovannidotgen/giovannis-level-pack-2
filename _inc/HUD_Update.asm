; ---------------------------------------------------------------------------
; Subroutine to	update the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

hudVRAM:	macro loc
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),d0
		endm


HUD_Update:
	;	tst.w	(f_debugmode).w	; is debug mode	on?
	;	bne.w	HudDebug	; if yes, branch
	;	tst.b	(f_scorecount).w ; does the score need updating?
	;	beq.s	.chkrings	; if not, branch

	;	clr.b	(f_scorecount).w
	;	hudVRAM	$DC80		; set VRAM address
	;	move.l	(v_score).w,d1	; load score
	;	bsr.w	Hud_Score

	.chkrings:
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	.chktime	; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero	; reset rings to 0 if Sonic is hit

	.notzero:
		clr.b	(f_ringcount).w
		hudVRAM	$DF00		; set VRAM address
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

	.chktime:
		tst.b	(f_timecount).w	; does the time	need updating?
		beq.w	.chkredstar	; if not, branch
		tst.w	(f_pause).w	; is the game paused?
		bne.w	.finish	; if yes, branch
		lea	(v_time).w,a1
		cmpi.l	#(9*$10000)+(59*$100)+59,(a1)+ ; is the time 9:59:59?
		bne.s	.normal		; if yes, branch
		clr.b	(f_timecount).w
		bra.s	.updatetime

	.normal:
		addq.b	#1,-(a1)	; increment 1/60s counter
		cmpi.b	#60,(a1)	; check if passed 60
		bcs.s	.updatetime
		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment second counter
		cmpi.b	#60,(a1)	; check if passed 60
		bcs.s	.updatetime
		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment minute counter
		cmpi.b	#9,(a1)		; check if passed 9
		bcs.s	.updatetime
		move.b	#9,(a1)		; keep as 9

	.updatetime:
		hudVRAM	$DD80
		moveq	#0,d1
		move.b	(v_timemin).w,d1 ; load	minutes
		bsr.w	Hud_Mins
		
		hudVRAM	$DE00
		moveq	#0,d1
		move.b	(v_timesec).w,d1 ; load	seconds
		bsr.w	Hud_Secs
		
		hudVRAM	$DE80
		moveq	#0,d1
		move.b	(v_timecent).w,d1 ; load frames
		move.b  HUD_CsTimesNTSC(pc,d1.w),d1	; convert into 60Hz centiseconds
		cmpi.l	#(9*$10000)+(59*$100)+59,(v_time).w ; is the time 9:59:59?
		bne.w	.rendercenti	; if not, render as is
		move.b	#99,d1			; force 99
	.rendercenti:
		bsr.w	Hud_Secs		 ; seconds rendering can double as centiseconds rendering	

	.chkredstar:
		tst.b	(f_redstar_update).w	; does the Red Star Ring counter need to be updated?
		beq.s	.finish
		
		hudVRAM	$F2E0
		moveq	#4,d6						; number of Red Star Ring icons -1
		lea		(v_redstar_collection).w,a1
		lea		(Art_StarRingHUD).l,a2
		move.l	d0,4(a6)			
		bra.w	Hud_RedStar		

	.finish:
		rts	

; ===========================================================================
; Centiseconds LUT for NTSC machines.
; Credits to Kilo.
; ===========================================================================

HUD_CsTimesNTSC:
        dc.b    0, 1, 3, 5, 6, 8, 10, 11, 13, 15, 16
        dc.b    18, 20, 21, 23, 25, 26, 28, 30, 31, 33
        dc.b    35, 36, 38, 40, 41, 43, 45, 46, 48, 50
        dc.b    51, 53, 55, 56, 58, 60, 61, 63, 65, 66
        dc.b    68, 70, 71, 73, 75, 76, 78, 80, 81, 83
        dc.b    85, 86, 88, 90, 91, 93, 95, 96, 98, 0
        even		
		
; ===========================================================================

HudDebug:
		bsr.w	HudDb_XY
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	.objcounter	; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero	; reset rings to 0 if Sonic is hit

	.notzero:
		clr.b	(f_ringcount).w
		hudVRAM	$DF40		; set VRAM address
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

	.objcounter:
		hudVRAM	$DEC0		; set VRAM address
		moveq	#0,d1
		move.b	(v_spritecount).w,d1 ; load "number of objects" counter
		bsr.w	Hud_Secs
		tst.b	(f_lifecount).w ; does the lives counter need updating?
		beq.s	.chkbonus	; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives

	.chkbonus:
		tst.b	(f_endactbonus).w ; does the ring/time bonus counter need updating?
		beq.s	.finish		; if not, branch
		clr.b	(f_endactbonus).w
		locVRAM	$AE00		; set VRAM address
		moveq	#0,d1
		move.w	(v_timebonus).w,d1 ; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1 ; load ring bonus
		bsr.w	Hud_TimeRingBonus

	.finish:
		rts	
; End of function HUD_Update

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero:
		locVRAM	$DF00
		lea	Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1C83E
; End of function Hud_LoadZero

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base:
		lea	($C00000).l,a6
	;	bsr.w	Hud_Lives
		locVRAM	$DD80
		lea	Hud_TilesBase(pc),a2
		move.w	#$8,d2

loc_1C83E:
		lea	Art_Hud(pc),a1

loc_1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1C852

loc_1C858:
		dbf	d2,loc_1C842

		rts	
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf	d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
Hud_TilesBase:	dc.b 0, $14, 0, 0, $0, $0
Hud_TilesZero:	dc.b 0, 0, 0, 0
		even
; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY:
		locVRAM	$DC40		; set VRAM address
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
; End of function HudDb_XY


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1C8B2
		addq.w	#7,d2

loc_1C8B2:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,HudDb_XYLoop	; repeat 7 more	times

		rts	
; End of function HudDb_XY2

; ---------------------------------------------------------------------------
; Subroutine to	load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Rings:
		lea	(Hud_100).l,a2
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to	load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Score:
		lea	(Hud_100000).l,a2
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
;		tst.w	d2
;		beq.s	loc_1C8FE
;		move.w	#1,d4

loc_1C8FE:
;		tst.w	d4
;		beq.s	loc_1C92C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf	d6,Hud_ScoreLoop

		rts	

; End of function Hud_Score

Hud_RedStar:
		movea.l	a2,a3		; copy art address

		tst.b	(a1)+		; check if red star ring was collected
		bne.s	.red		; if yes, keep ring as red
		adda.l	#128,a3		; get gray patterns
		
	.red:	
		; move 128 bytes of data into VRAM
		move.l	(a3)+,(a6)	
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)		
		
		dbf		d6,Hud_RedStar
		rts

	

