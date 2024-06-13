; ================================================================
; "GIOVANNI" Splash Screen
; Art and code by Giovanni
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

Giovanni_FG_Offset: equ $28
Giovanni_BG_Offset: equ -$28

GiovanniSplash:
    move.b  #$E4,d0					; set music ID to "stop music"
    jsr     PlaySound_Special		; play ID
    jsr     PaletteFadeOut			; fade palettes out
    jsr     ClearScreen.w			; clear the plane mappings
	lea		(vdp_control_port).l,a6
	
	; setup VDP
	
	move.w	#$8004,(a6)	; 8-colour mode
	move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
	move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
	move.w	#$9001,(a6)	; 64-cell hscroll size
	move.w	#$9200,(a6)	; window vertical position
	move.w	#$8B03,(a6)

    ; load art, mappings and the palette

    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_Giovanni).l,a0			; load compressed mappings address
    move.w  #320,d0             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$46140003,d0				; VRAM location
    moveq   #29,d1						; width - 1
    moveq   #3,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM
	
    lea     ($FF0000).l,a1				; load dump location	
    lea     (Map_GiovanniB).l,a0			; load compressed mappings address
    move.w  #320,d0             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$66000003,d0				; VRAM location
    moveq   #29,d1						; width - 1
    moveq   #3,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM
	
    move.l  #$68000000,($C00004).l		; VRAM location
    lea     (Nem_Giovanni).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display
    lea 	Pal_Giovanni.l,a0        	; load this palette
    lea (v_pal_dry).l,a1        		; get beginning of palette line
    move.w  #$3,d0						; number of entries / 4
 
Giovanni_PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,Giovanni_PalLoop				; repeat until done

; optimized version
	lea		(v_hscrolltablebuffer+$184).w,a0
	move.w	#240,d0						; get distance
	move.w	#29,d1						; lines to affect - 1
	
Giovanni_SetDistance:
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	neg.w	d0
	dbf		d1,Giovanni_SetDistance
	
    move.b  #sfx_Teleport,d0		; set sound ID
    jsr     PlaySound_Special		; play ID	
	move	#28,d4
	
Giovanni_DeformLoop:
    move.b  #6,(v_vbla_routine).w		; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (does not decrease "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.w   Giovanni_GotoTitle         	; if so, branch	
	move	d4,d3
	bsr.w	Giovanni_Reform				; perform deformation
	moveq	#0,d5
	move.w	(v_hscrolltablebuffer+$184).w,d5	; get first line's coordinates
	add.w	#Giovanni_FG_Offset,d5							; get offset
	tst.w	d5								; test the first line
	bne.s	Giovanni_DeformLoop			; if not 0, perform deformation again

	lea		(vdp_data_port).l,a6
	move.l	#$4FE00003,4(a6)
	move.w	#$F,d1
	
.blanktile:
	move.w	#0,(a6)
	dbf	d1,.blanktile
	lea	(Art_S2Text).l,a5				; fetch the text graphics
	move.w	#$39F,d1					; amount of data to be loaded
; load text
Giovanni_LoadText:
	move.w	(a5)+,(a6)					; load the text
	dbf	d1,Giovanni_LoadText 			; repeat until done

    move.w  #1*60,(v_demolength).w     	; set delay time (1 second on a 60hz system)

Giovanni_Delay1:
    move.b  #2,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.w   Giovanni_GotoTitle         	; if so, branch	
    tst.w   (v_demolength).w           	; has the delay time finished?
    bne.s   Giovanni_Delay1				; if not, branch

Lines_AdjustInt:

	lea		(v_hscrolltablebuffer+$220).w,a0
	lea		(Lines_AdjustData).w,a1

.loop:
	move.w	(a1)+,d0
	bmi.s	Credits_Render
	
	moveq	#7,d1

.loop2:	
	move.w	d0,(a0)
	adda.l	#4,a0
	dbf		d1,.loop2
	
	bra.s	.loop

Credits_Render:
	lea	($C00000).l,a6
	lea	(Text_Giovanni).l,a1 ; where to fetch the lines from	
	move.l	#$48840003,d4	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#1,d1		; number of lines of text to be displayed -1

.looptext
	move.l	d4,4(a6)
	moveq	#35,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,.looptext

    move.b  #sfx_Ring,d0			; set sound ID
    jsr     PlaySound_Special		; play ID	
	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$F,(v_awcount).w
	move.l	#Pal_SplashText,(p_awtarget).w
	move.l	#$FFFFFB20,(p_awreplace).w
	
Giovanni_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.w   Giovanni_GotoTitle         	; if so, branch	
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	Giovanni_TextFadeIn
	
    move.w  #3*60,(v_demolength).w     	; set delay time (3 seconds on a 60hz system)

Giovanni_MainLoop:
    move.b  #2,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   Giovanni_GotoTitle         	; if so, branch
    tst.w   (v_demolength).w           	; has the delay time finished?
    bne.s   Giovanni_MainLoop			; if not, branch
 
Giovanni_GotoTitle:
    move.b  #id_GLP2Title,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return


Lines_AdjustData:
	dc.w	$0, $4, -1

; ===============================================================
; Subroutine that deforms the screen until all of its lines are properly centered
; ===============================================================

Giovanni_Reform:

	lea		(v_hscrolltablebuffer+$184).w,a0
	move	#29,d1						; lines to affect - 1

Giovanni_ReformLoop:
	tst.w	d3							; check timer
	bpl.s	.common						; if positive, skip the line

	moveq	#0,d5
	move.w	(a0),d5						; get scanline position
	add.w	#Giovanni_FG_Offset,d5		; get global offset
	tst.w	d5							; check for scanline's position
	bmi.s	.negative					; if negative, branch
	beq.s	.common						; if zero, skip the line
	
	subq.w	#8,(a0)
	bra.s	.common
	
.negative:
	addq.w	#8,(a0)

.common:

	adda.l	#2,a0

	tst.w	d3							; check timer
	bpl.s	.commonBG					; if positive, skip the line

	moveq	#0,d5
	move.w	(a0),d5						; get scanline position
	add.w	#Giovanni_BG_Offset,d5		; get global offset
	tst.w	d5							; check for scanline's position
	bmi.s	.negativeBG					; if negative, branch
	beq.s	.commonBG					; if zero, skip the line
	
	subq.w	#8,(a0)
	bra.s	.commonBG
	
.negativeBG:
	addq.w	#8,(a0)

.commonBG:
	subq	#1,d3
	adda.l	#2,a0	
	
	dbf		d1,Giovanni_ReformLoop
	
	tst		d4
	bmi.s	.return
	subq	#1,d4
	
.return:	
	rts

; ===============================================================
; Giovanni Splash Screen assets
; ===============================================================

;Nem_Giovanni
Map_Giovanni:
Map_GiovanniA: incbin "tilemaps\Giovanni Splash A.bin"
	even
Map_GiovanniB: incbin "tilemaps\Giovanni Splash B.bin"
	even	
Pal_Giovanni: incbin "palette\Giovanni Splash.bin"
	even
Pal_SplashText:	incbin "palette\Sonic 2 Text used in Splash Screen.bin"
	even
Text_Giovanni: 

				dc.b	"IT'S STILL JOE-VANNI, NOT GEO-VANNI."
				dc.b	"                                    "
	even