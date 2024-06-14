; ================================================================
; "GLP2'S LEVEL PACK 2" Title Screen
; Code by giovanni.gen
; Logo by Cinossu
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

GLP2LevelSelect:
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
	move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)	

; Plane mappings (BG)
    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_MainMenu).l,a0				; load compressed mappings address
    move.w  #$4020,d0	             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$60000003,d0				; VRAM location
    moveq   #63,d1						; width - 1
    moveq   #31,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM	
	
; Graphics (BG)	
    move.l  #$44000000,($C00004).l		; VRAM location
    lea     (Nem_MainMenu).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display

; Graphics (Text)
	lea		(vdp_data_port).l,a6
	move.l	#$4FE00003,4(a6)
	move.w	#$F,d1
	
.blanktile:
	move.w	#0,(a6)
	dbf	d1,.blanktile
	
	lea	(Art_S2Text).l,a5				; fetch the text graphics
	move.w	#$39F,d1					; amount of data to be loaded
	
.LoadText:
	move.w	(a5)+,(a6)					; load the text
	dbf	d1,.LoadText 				; repeat until done	

; Palette (is loaded by DynPaletteTransition)
    lea 	Pal_Giovanni.l,a0        	; load this palette
    lea 	(v_pal_dry_dup).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
.PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,.PalLoop				; repeat until done

    lea 	Pal_SplashText.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$20).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
.PalLoop2:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,.PalLoop2				; repeat until done

    lea 	Pal_MainMenu.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$40).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
.PalLoop3:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,.PalLoop3				; repeat until done

; DynPaletteTransition variable initialization
	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$2F,(v_awcount).w
	move.l	#v_pal_dry_dup,(p_awtarget).w
	move.l	#v_pal_dry,(p_awreplace).w

; Initialize Menu Structure
LevelSelect_InitRender:
	bsr.w	LevelSelect_Headings
	bsr.w	LevelSelect_LevelInfo
	
; Fade in	
LevelSelect_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	LevelSelect_TextFadeIn
	
; Main loop	
LevelSelect_MainLoop:
    move.b  #2,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   LevelSelect_StartPressed    ; if so, branch
	bsr.w	LevelSelect_Controls
	bra.s	LevelSelect_MainLoop
 
; Quit Menu
LevelSelect_StartPressed:
	lea		(LevelSelect_LevelEntries).l,a0
	lea		(v_level_savedata).w,a1
	moveq	#0,d0
	move.w	(v_levselitem).w,d0
	add.w	d0,d0
	adda.l	d0,a0
	lsl.w	#2,d0	; save data size is 8
	adda.l	d0,a1
	move.w	(a0),(v_zone).w	; set level
    move.b  #id_Level,(v_gamemode).w    ; set the screen mode to Level
	moveq	#0,d0
	move.w	d0,(v_rings).w	; clear rings
	move.l	d0,(v_time).w	; clear time
	move.l	d0,(v_redstar_collection).w
	move.b	d0,(v_redstar_collection+4).w

; load Red Star Rings
	lea		(v_redstar_collection).w,a2
	lea		(v_level_savedata).w,a1
	adda.l	#LSD_RedStar,a1	; get RSR buffer
	moveq	#4,d2
		
.looprings:
	movea.l	a2,a3	; copy red star ring buffer address
	adda.l	d2,a3	; get exact RSR address
	btst	d2,(a1)	; test if ring was collected
	beq.s	.skip	; if yes, skip check entirely
	st.b	(a3)	; mark RSR as collected
	
.skip:
	dbf		d2,.looprings
	
	move.b	d0,(v_lastlamp).w
	move.b	#bgm_Fade,d0
	bra.w	PlaySound_Special ; fade out music

; ===============================================================
; Controls routine
; ===============================================================
LevelSelect_Controls:

		move.b	(v_jpadpress1).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	.leftright	; if yes, branch
		rts	

.leftright:	
		move.w  (v_levselitem).w,d2        ; load choice number		
		btst	#2,d1		; is left pressed?
		beq.s	.right	; if not, branch
		subq.w	#1,d2		; subtract 1 to selection
		bpl.s	.right
		move.w  #1,d2     
		
.right:
		btst	#3,d1		; is right pressed?
		beq.s	.refresh	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#1,d2
		ble.s	.refresh
		move.w	#0,d2	
		
.refresh:
		move.w	d2,(v_levselitem).w
		bra.w	LevelSelect_LevelInfo
;		move.w	#SndID_Blip,d0
;		jmp	(PlaySound).l			

; ===============================================================
; Foreground Plane Graphics Rendering Routines
; ===============================================================

LevelSelect_Headings:
	lea	($C00000).l,a6
	lea	(LevelSelect_Heading1).l,a1 ; where to fetch the lines from	
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	move.l	#$41040003,4(a6)
	moveq	#12,d2		; number of characters to be rendered in a line -1
	bra.w	SingleLineRender

; ===============================================================

LevelSelect_LevelInfo:
	lea	($C00000).l,a6
	lea	(LevelSelect_LevelNames).l,a1 ; where to fetch the lines from
	move.w	(v_levselitem).w,d1
	mulu.w	#11,d1
	adda.l	d1,a1	
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	move.l	#$41220003,4(a6)
	moveq	#10,d2		; number of characters to be rendered in a line -1
	bra.w	SingleLineRender

; ===============================================================
; GLP2 Level Select assets
; ===============================================================

LevelSelect_LevelEntries:
	dc.b	id_SBZ,	0
	dc.b	id_MZ,	0
	even

LevelSelect_LevelNames:
	dc.b	"SCRAP BRAIN"
	dc.b	"MARBLE     "
	even

LevelSelect_Heading1:
	dc.b	"SELECT LEVEL:"
	even