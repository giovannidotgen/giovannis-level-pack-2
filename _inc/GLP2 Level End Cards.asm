; ================================================================
; "GLP2'S LEVEL PACK 2" Level End Card
; Code by giovanni.gen
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

GLP2LevelEnd:
    move.b  #$E4,d0					; set music ID to "stop music"
    jsr     PlaySound_Special		; play ID
    jsr     PaletteFadeOut			; fade palettes out
	
	lea	(v_objspace).w,a1
	moveq	#0,d0
	move.w	#$7FF,d1
.ClrObjRam:
	move.l	d0,(a1)+
	dbf	d1,.ClrObjRam ; clear object RAM
	
	lea	($FFFFF628).w,a1
	moveq	#0,d0
	move.w	#$15,d1

.ClrVars1:
	move.l	d0,(a1)+
	dbf	d1,.ClrVars1 ; clear misc variables

	lea	(v_screenposx).w,a1
	moveq	#0,d0
	move.w	#$3F,d1

.ClrVars2:
	move.l	d0,(a1)+
	dbf	d1,.ClrVars2 ; clear misc variables

	lea	(v_oscillate+2).w,a1
	moveq	#0,d0
	move.w	#$47,d1

.ClrVars3:
	move.l	d0,(a1)+
	dbf	d1,.ClrVars3 ; clear object variables	
	
	
    jsr     ClearScreen			; clear the plane mappings
	lea		(vdp_control_port).l,a6
	
	; setup VDP
	
	move.w	#$8004,(a6)	; 8-colour mode
	move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
	move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
	move.w	#$9001,(a6)	; 64-cell hscroll size
	move.w	#$9200,(a6)	; window vertical position
	move.w	#$8B03,(a6)
	move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)	

    ; load art, mappings and the palette
	
    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_MainMenu).l,a0				; load compressed mappings address
    move.w  #$4020,d0	             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$60000003,d0				; VRAM location
    moveq   #63,d1						; width - 1
    moveq   #31,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM	

    move.l  #$44000000,($C00004).l		; VRAM location
    lea     (Nem_MainMenu).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display

    lea 	Pal_Sonic.l,a0        	; load this palette
    lea 	(v_pal_dry_dup).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
.PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,.PalLoop				; repeat until done

    lea 	Pal_GHZ.l,a0        	; load this palette
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

	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$2F,(v_awcount).w
	move.l	#v_pal_dry_dup,(p_awtarget).w
	move.l	#v_pal_dry,(p_awreplace).w
	
GLP2LevelEnd_FadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	GLP2LevelEnd_FadeIn
	
	jsr		GotThroughAct
	
GLP2LevelEnd_MainLoop:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
	jsr		ExecuteObjects		
	jsr		(BuildSprites).l	
	jsr		RunPLC	
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   .GotoTitle         	; if so, branch
	bra.s	GLP2LevelEnd_MainLoop
 
.GotoTitle:
    move.b  #id_LevelSelect,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return

; ===============================================================
; GLP2 Level End Card assets
; ===============================================================
