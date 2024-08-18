; ================================================================
; "GLP2'S LEVEL PACK 2" Title Screen
; Code by giovanni.gen
; Logo by Cinossu
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================


GLP2Instructions:
    move.b  #bgm_Stop,d0					; set music ID to "stop music"
    jsr     PlaySound_Special		; play ID
    jsr     PaletteFadeOut			; fade palettes out
	clr.w	(v_bgscreenposy).w
	clr.w	(v_bgscreenposx).w	
	clr.b	(v_GLP2_invertBG).w	
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
    move.w  #$4020,d0	             		; prepare pattern index value to patch to mappings
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$60000003,d0				; VRAM location
    moveq   #63,d1						; width - 1
    moveq   #31,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM	
	
    lea     ($FF0000).l,a1				; load dump location
    lea     (Tilemap_InstructionsBox).l,a0				; load compressed mappings address
    move.w  #$2060,d0	             		; prepare pattern index value to patch to mappings
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$41040003,d0				; VRAM location
    moveq   #36,d1						; width - 1
    moveq   #24,d2						; height - 1
    bsr.w   TilemapToVRAM	         	; flush mappings to VRAM			
	
; Graphics (BG)	
    move.l  #$44000000,($C00004).l		; VRAM location
    lea     (Nem_MainMenu).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display
	
	move.l	#$4C000000,($C00004).l
	lea		(Nem_MenuBox).l,a0
	jsr		NemDec

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
    lea 	Pal_GHZ.l,a0        		; load this palette
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

    lea 	Pal_Sonic.l,a0        	; load this palette
    lea 	(v_pal_dry_dup+$60).l,a1        ; get beginning of palette line
    moveq  	#$3,d0						; number of entries / 4
 
.PalLoop4:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,.PalLoop4				; repeat until done

; Prepare all tilemaps for screen assets


; DynPaletteTransition variable initialization
	move.b	#1,(v_paltime).w
	move.b	#1,(v_paltimecur).w
	move.b	#1,(v_palflags).w
	move.b	#$3F,(v_awcount).w
	move.l	#v_pal_dry_dup,(p_awtarget).w
	move.l	#v_pal_dry,(p_awreplace).w

	move.b	#bgm_Menu,d0
	jsr		PlaySound_Special

; Initialize Menu Structure
Instructions_InitRender:
	bsr.w	Instructions_Headings
	bsr.w	Instructions_Body
	
; Fade in	
Instructions_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	Instructions_TextFadeIn
	
; Main loop	
Instructions_MainLoop:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    move.b  (v_jpadpress1).w,d0        	
	andi.b	#btnStart+btnB,d0	
    bne.s   Instructions_StartPressed    ; if so, branch
	bsr.w	Instructions_Controls
	bsr.w	GLP2_Camera
	bra.s	Instructions_MainLoop
 
; Quit Menu
Instructions_StartPressed:
	clr.w	(v_levselitem).w
    move.b  #id_GLP2Title,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return

; ===============================================================
; Controls routine
; ===============================================================
Instructions_Controls:

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
		move.w  #7,d2     
		
.right:
		btst	#3,d1		; is right pressed?
		beq.s	.refresh	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#7,d2
		ble.s	.refresh
		move.w	#0,d2	
		
.refresh:
		move.w	d2,(v_levselitem).w
		bsr.w	Instructions_Body
		move.w	#sfx_Switch,d0
		jmp	(PlaySound).l		

; ===============================================================
; Foreground Plane Graphics Rendering Routines
; ===============================================================

Instructions_Headings:
	rts
	

; ===============================================================

Instructions_Body:
	lea	($C00000).l,a6
	lea	(Instructions_Titles).l,a1 ; where to fetch the lines from
	move.w	(v_levselitem).w,d1
	mulu.w	#28,d1
	adda.l	d1,a1	
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	move.l	#$428C0003,4(a6)
	moveq	#27,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	
	moveq	#0,d1
	lea	(Instructions_PageBodies).l,a1 ; where to fetch the lines from
	move.w	(v_levselitem).w,d1
	mulu.w	#32*14,d1	
	adda.l	d1,a1
	move.l	#$45080003,d4	; (CHANGE) starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#13,d1		; number of lines of text to be displayed -1

-
	move.l	d4,4(a6)
	moveq	#31,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-	

	
	; lea		(v_level_savedata).w,a3
	; moveq	#0,d0
	; move.w	(v_levselitem).w,d0
	; add.w	d0,d0
	; adda.l	d0,a0
	; lsl.w	#2,d0	; save data size is 8
	; adda.l	d0,a3	

; Instructions_Time:

; ; Centiseconds
	; move.l	#$472A0003,4(a6)

	; movem.l	d0-d6,-(sp)
	; lea	(Hud_10).l,a2 			; get the number of digits
	; moveq	#1,d0             			; repeat X-1 times
	; moveq	#0,d1	
	; move.b	LSD_Time+3(a3),d1			; get value to render
	; lea		(HUD_CsTimesNTSC).l,a4
	; adda.l	d1,a4
	; move.b	(a4),d1						; convert to centiseconds
	; cmpi.l	#(9*$10000)+(59*$100)+59,LSD_Time(a3) ; is the time 9:59:59?
	; bne.w	.rendercenti	; if not, render as is
	; move.b	#99,d1			; force 99
; .rendercenti:	
	; move.w	#$A68F,d3					; get 0 from font
	; bsr.w	DecimalNumberRender
	; movem.l	(sp)+,d0-d6	
	
; ; Seconds
	; move.l	#$47240003,4(a6)

	; movem.l	d0-d6,-(sp)
	; lea	(Hud_10).l,a2 			; get the number of digits
	; moveq	#1,d0             			; repeat X-1 times
	; moveq	#0,d1	
	; move.b	LSD_Time+2(a3),d1			; get value to render
	; move.w	#$A68F,d3					; get 0 from font
	; bsr.w	DecimalNumberRender
	; movem.l	(sp)+,d0-d6		
	
; ; Minutes
	; move.l	#$47200003,4(a6)

	; move.w	#$A68F,d3					; get 0 from font
	; moveq	#0,d0
	; move.b	LSD_Time+1(a3),d0
	; add.w	d0,d3
	; move.w	d3,(a6)
	
; Instructions_Rings:
	; move.l	#$46200003,4(a6)

	; movem.l	d0-d6,-(sp)
	; lea	(Hud_100).l,a2 			; get the number of digits
	; moveq	#2,d0             			; repeat X-1 times
	; moveq	#0,d1
	; move.w	LSD_Rings(a3),d1			; get value to render
	; move.w	#$A68F,d3					; get 0 from font
	; bsr.w	DecimalNumberRender
	; movem.l	(sp)+,d0-d6	


; Instructions_RedStarRings:
	; move.l	#$4B340003,d4
	; moveq	#4,d3

	
; .loop:
	; moveq	#1,d1
	; moveq	#1,d2
	; move.l	d4,d5
	; move.l	d3,d6
	
	; ; multiply by $40000
	; swap	d6
	; lsl.l	#2,d6
	
	; add.l	d6,d5
	; move.l	d5,d0
	; lea		(Tilemap_RedStarRing).l,a1
	; btst	d3,LSD_RedStar(a3)
	; bne.s	.red
	; lea		(Tilemap_GrayStarRing).l,a1
; .red	
	; movem.l	d0-d6,-(sp)	
	; jsr		TilemapToVRAM
	; movem.l	(sp)+,d0-d6
	; dbf		d3,.loop
	
; Instructions_Exits:
	; move.l	#$4B080003,d4
	; moveq	#2,d3
	
; .loop:
	; moveq	#1,d1
	; moveq	#1,d2
	; move.l	d4,d5
	; move.l	d3,d6
	
	; ; multiply by $40000
	; swap	d6
	; lsl.l	#2,d6
	
	; add.l	d6,d5
	; move.l	d5,d0
	; lea		(Tilemap_YellowRing).l,a1
	; btst	d3,LSD_Exits(a3)
	; bne.s	.yellow
	; lea		(Tilemap_GrayRing).l,a1
; .yellow	
	; movem.l	d0-d6,-(sp)	
	; jsr		TilemapToVRAM
	; movem.l	(sp)+,d0-d6
	; dbf		d3,.loop
	
	rts
	
; ===============================================================
; Raw Text Data
; ===============================================================	
	
Instructions_Titles:
	dc.b	"PAGE 1 - WELCOME!           "
	dc.b	"PAGE 2 - WHAT IS THIS?      "	
	dc.b	"PAGE 3 - CONTROLS (1 OF 2)  "		
	dc.b	"PAGE 4 - CONTROLS (2 OF 2)  "			
	dc.b	"PAGE 5 - EXITING LEVELS     "		
	dc.b	"PAGE 6 - RED STAR RINGS     "		
	dc.b	"PAGE 7 - SAVE DATA          "
	dc.b	"PAGE 8 - BUILD INFORMATION  "				
	
Instructions_PageBodies:
	dc.b	"WELCOME TO THE GIOVANNI'S LEVEL "
	dc.b	"PACK 2 USER MANUAL!             "
	dc.b	"TO SWITCH BETWEEN PAGES, PRESS  "
	dc.b	"LEFT OR RIGHT. ONCE YOU ARE     "
	dc.b	"FINISHED READING, PRESS START OR"
	dc.b	"B TO RETURN TO THE TITLE SCREEN."
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "

	dc.b	"GIOVANNI'S LEVEL PACK 2 IS A    "
	dc.b	"MODIFIED VERSION OF THE ORIGINAL"
	dc.b	"SONIC THE HEDGEHOG FOR THE SEGA "
	dc.b	"MEGA DRIVE OR GENESIS, FEATURING"
	dc.b	"2 LEVELS FOR YOU TO PLAY, WITH  "
	dc.b	"MANY FUN OBJECTIVES TO ACHIEVE! "
	dc.b	"                                "
	dc.b	"DO NOT LET THE LOW LEVEL COUNT  "
	dc.b	"DISAPPOINT YOU, FOR THESE TWO   "
	dc.b	"LEVELS ARE PACKED WITH MANY     "
	dc.b	"CHALLENGES, COLLECTIBLES, AND   "
	dc.b	"OTHER THINGS THAT WILL HAVE YOU "
	dc.b	"HOOKED TO THESE LEVELS!         "
	dc.b	"                                "
		
	dc.b	"THE GAME CONTROLS AS YOU WOULD  "
	dc.b	"EXPECT, WITH A FEW CHANGES:     "
	dc.b	"- YOU CAN PERFORM THE SPIN DASH,"
	dc.b	"  FROM SONIC 2;                 "
	dc.b	"- YOU CAN PERFORM THE SUPER     "
	dc.b	"  PEEL-OUT, FROM SONIC CD, WITH "
	dc.b	"  THE ADDED BENEFIT OF BEING    "
	dc.b	"  ABLE TO RELEASE IT WHENEVER;  "
	dc.b	"- YOU CAN PERFORM THE DROP DASH,"
	dc.b	"  FROM SONIC MANIA;             "
	dc.b	"- SONIC 1'S SPEED CAPS, AND THE "
	dc.b	"  ROLLING JUMP LOCK, ARE NO     "
	dc.b	"  LONGER PRESENT                "
	dc.b	"                                "		
		
	dc.b	"IF NECESSARY, YOU CAN QUIT THE  "
	dc.b	"LEVEL AT ANY TIME BY PRESSING A "
	dc.b	"WHILE THE GAME IS PAUSED.       "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "			
	
	dc.b	"YOU WILL NOT FIND A SIGNPOST    "
	dc.b	"WAITING FOR YOU AT THE END OF   "
	dc.b	"THE LEVEL.                      "
	dc.b	"                                "
	dc.b	"INSTEAD, YOU WILL HAVE TO SEEK  "
	dc.b	"OUT ONE OF THREE GIANT RINGS TO "
	dc.b	"CLEAR THE LEVEL. EACH HAS THREE "
	dc.b	"OF THEM. CAN YOU FIND THEM ALL? "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "			

	dc.b	"RED STAR RINGS ARE AN OPTIONAL  "
	dc.b	"COLLECTIBLE.                    "
	dc.b	"                                "
	dc.b	"FIVE RED STAR RINGS ARE FOUND   "
	dc.b	"IN EACH LEVEL. YOU MIGHT HAVE TO"
	dc.b	"GO THROUGH THE LEVELS MULTIPLE  "
	dc.b	"TIMES AND SCAN THEM CAREFULLY   "
	dc.b	"TO FIND ALL OF THEM!            "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "			
	
	dc.b	"EXITING A LEVEL WILL RECORD THE "
	dc.b	"EXIT AS FOUND, AS WELL AS THE   "
	dc.b	"RED STAR RINGS YOU'VE RETRIEVED "
	dc.b	"DURING YOUR RUN, AND MAY EVEN   "
	dc.b	"RESULT IN THE RECORDING OF A FEW"	
	dc.b	"RECORDS!                        "
	dc.b	"                                "
	dc.b	"IF FOR WHATEVER REASON YOUR DATA"
	dc.b	"CAN NOT BE SAVED, YOU WILL BE   "
	dc.b	"WARNED IN THE GIOVANNI.GEN      "
	dc.b	"SPLASH SCREEN. THAT VERY SAME   "
	dc.b	"SCREEN ALLOWS YOU TO RESET YOUR "
	dc.b	"SAVE DATA BY HOLDING A, B, AND  "
	dc.b	"C DURING IT!                    "			
	
	dc.b	"GIOVANNI'S LEVEL PACK 2         "
	dc.b	"VERSION 1.0                     "
	dc.b	"                                "
	dc.b	"THIS IS A MODIFIED VERSION OF   "
	dc.b	"SONIC THE HEDGEHOG, A PROPERTY  "
	dc.b	"OF SEGA. IT WAS NOT DEVELOPED BY"
	dc.b	"THEM, OR PUBLISHED UNDER A      "
	dc.b	"LICENSE, OR WITH AUTHORIZATION. "
	dc.b	"                                "
	dc.b	"THIS MOD WAS MADE FOR           "
	dc.b	"ENTERTAINMENT PURPOSES, AND IS  "
	dc.b	"AVAILABLE FOR FREE ON           "
	dc.b	"DOTGEN.ORG. IF YOU'VE PAID MONEY"
	dc.b	"FOR THIS, YOU'VE BEEN SCAMMED.  "			