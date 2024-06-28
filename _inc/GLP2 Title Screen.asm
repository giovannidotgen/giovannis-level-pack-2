; ================================================================
; "GLP2'S LEVEL PACK 2" Level Select
; Code by giovanni.gen
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

GLP2Title:
    move.b  #bgm_Stop,d0					; set music ID to "stop music"
    jsr     PlaySound_Special		; play ID
    jsr     PaletteFadeOut			; fade palettes out
    jsr     ClearScreen.w			; clear the plane mappings
	clr.w	(v_bgscreenposy).w
	clr.w	(v_bgscreenposx).w
	clr.b	(v_GLP2_invertBG).w
	
	lea	(v_objspace).w,a1
	moveq	#0,d0
	move.w	#$7FF,d1
.ClrObjRam:
	move.l	d0,(a1)+
	dbf	d1,.ClrObjRam ; clear object RAM	
	
	lea		(vdp_control_port).l,a6
	
	; setup VDP
	
	move.w	#$8004,(a6)	; 8-colour mode
	move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
	move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
	move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address	
	move.w	#$9001,(a6)	; 64-cell hscroll size
	move.w	#$9200,(a6)	; window vertical position
	move.w	#$8B03,(a6)
	move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)	

    ; load art, mappings and the palette

    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_GLP2).l,a0				; load compressed mappings address
    move.w  #320,d0             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$420A0003,d0				; VRAM location
    moveq   #29,d1						; width - 1
    moveq   #6,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM
	
    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_MainMenu).l,a0				; load compressed mappings address
    move.w  #$4020,d0	             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$60000003,d0				; VRAM location
    moveq   #63,d1						; width - 1
    moveq   #31,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM	
	
    move.l  #$68000000,($C00004).l		; VRAM location
    lea     (Nem_GLP2).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display

    move.l  #$44000000,($C00004).l		; VRAM location
    lea     (Nem_MainMenu).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display

	move.l	#$4C000000,($C00004).l
	lea		(Nem_PressStart).l,a0
	jsr		NemDec

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

    lea 	Pal_Giovanni.l,a0        	; load this palette
    lea 	(v_pal_dry_dup).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
GLP2_PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,GLP2_PalLoop				; repeat until done

    lea 	Pal_SplashText.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$20).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
GLP2_PalLoop2:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,GLP2_PalLoop2				; repeat until done

    lea 	Pal_MainMenu.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$40).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
GLP2_PalLoop3:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,GLP2_PalLoop3				; repeat until done

    lea 	Pal_Title.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$60).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
GLP2_PalLoop4:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,GLP2_PalLoop4				; repeat until done


	moveq	#plcid_Main,d0
	bsr.w	NewPLC		

	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$3F,(v_awcount).w
	move.l	#v_pal_dry_dup,(p_awtarget).w
	move.l	#v_pal_dry,(p_awreplace).w
	
	move.b	#bgm_Menu,d0
	jsr		PlaySound_Special
	
GLP2_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.w   GLP2_GotoTitle         	; if so, branch	
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	GLP2_TextFadeIn
	
	move.b	#id_Obj4F,(v_objspace+$80).w
	move.b	#2,(v_objspace+$80+obRoutine).w
	move.b	#0,(v_objspace+$80+obFrame).w
	move.b	#0,(v_objspace+$80+obRender).w
	move.w	#$120,(v_objspace+$80+obX).w
	move.w	#$120,(v_objspace+$80+obScreenY).w
	move.w	#$6060,(v_objspace+$80+obGfx).w
	move.l	#Map_PressStart,(v_objspace+$80+obMap).w
	
GLP2_MainLoop:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
	jsr		ExecuteObjects
	jsr		BuildSprites
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   GLP2_GotoTitle         	; if so, branch
	bsr.s	GLP2_Camera
	bra.s	GLP2_MainLoop
 
GLP2_GotoTitle:
    move.b  #id_LevelSelect,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return

; ===============================================================
GLP2_Camera:
	cmpi.w 	#$40, v_bgscrposy_dup
	blt.s 	.AddY
	move.w 	#0, v_bgscrposy_dup
	not.b	(v_GLP2_invertBG).w

.AddY:
	add.w	#1,(v_bgscrposy_dup).w
	moveq	#0,d0
	moveq	#0,d2
	move.w	(v_bgscrposy_dup).w,d0
	lea		(v_hscrolltablebuffer+2).w,a1
	move.w	#223,d1
	move.w 	v_bgscrposy_dup, d2
	
.Loop:
	add.b 	#1, d2

	cmpi.w 	#$40, d2
	bge.s 	.ChangeDirection

	move.w	d0, (a1)
	tst.b	(v_GLP2_invertBG).w
	beq.s	.keepasis
	neg.w	(a1)
	
.keepasis:
	adda.l	#4, a1
	dbf		d1, .Loop
	
	bra.s 	.Die
	
.ChangeDirection:
	moveq	#0, d2
	neg.w	d0

	move.w	d0, (a1)
	tst.b	(v_GLP2_invertBG).w
	beq.s	.keepasis2
	neg.w	(a1)
	
.keepasis2:
	adda.l	#4, a1
	dbf		d1, .Loop

.Die:
	rts

; ===============================================================
; GLP2 Splash Screen assets
; ===============================================================
Map_GLP2:
		incbin		"tilemaps\GLP2 Title.bin"
Map_MainMenu:
		incbin		"tilemaps\Main Menu.bin"
Pal_MainMenu:
		incbin		"palette\Main Menu.bin"
Text_GLP2: 
				dc.b	"TEST                                "
				dc.b	"                                    "
	even