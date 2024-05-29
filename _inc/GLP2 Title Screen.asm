; ================================================================
; "GLP2'S LEVEL PACK 2" Title Screen
; Code by GLP2.gen
; Logo by Cinossu
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

GLP2Title:
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
    lea     (Map_GLP2).l,a0				; load compressed mappings address
    move.w  #320,d0             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$40040003,d0				; VRAM location
    moveq   #29,d1						; width - 1
    moveq   #6,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM
	
    move.l  #$68000000,($C00004).l		; VRAM location
    lea     (Nem_GLP2).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display

    lea 	Pal_Giovanni.l,a0        	; load this palette
    lea 	(v_pal_dry).l,a1        		; get beginning of palette line
    move.w  #$3,d0						; number of entries / 4
 
GLP2_PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,GLP2_PalLoop				; repeat until done

GLP2_TestRender:
	lea	($C00000).l,a6
	lea	(Text_GLP2).l,a1 ; where to fetch the lines from	
	move.l	#$48840003,d4	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#1,d1		; number of lines of text to be displayed -1

.looptext
	move.l	d4,4(a6)
	moveq	#35,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,.looptext

	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$F,(v_awcount).w
	move.l	#Pal_SplashText,(p_awtarget).w
	move.l	#$FFFFFB20,(p_awreplace).w
	
GLP2_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.w   GLP2_GotoTitle         	; if so, branch	
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	GLP2_TextFadeIn
	
GLP2_MainLoop:
    move.b  #2,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   GLP2_GotoTitle         	; if so, branch
	bra.s	GLP2_MainLoop
 
GLP2_GotoTitle:
    move.b  #id_Title,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return

; ===============================================================
; GLP2 Splash Screen assets
; ===============================================================
Map_GLP2:
	incbin		"tilemaps\GLP2 Title.bin"
Text_GLP2: 
				dc.b	"TEST                                "
				dc.b	"                                    "
	even