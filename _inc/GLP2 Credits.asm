; ================================================================
; "GLP2'S LEVEL PACK 2" Title Screen
; Code by giovanni.gen
; Logo by Cinossu
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================


GLP2Credits:
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
	
    ; lea     ($FF0000).l,a1				; load dump location
    ; lea     (Tilemap_MenuBox).l,a0				; load compressed mappings address
    ; move.w  #$2060,d0	             		; prepare pattern index value to patch to mappings
    ; jsr     EniDec						; decompress and dump
    ; lea     ($FF0000).l,a1				; load dump location
    ; move.l  #$41040003,d0				; VRAM location
    ; moveq   #36,d1						; width - 1
    ; moveq   #24,d2						; height - 1
    ; bsr.w   TilemapToVRAM	         	; flush mappings to VRAM			
	
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
Credits_InitRender:
	bsr.w	Credits_Headings
	bsr.w	Credits_Body
	
; Fade in	
Credits_TextFadeIn:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank
	bsr.w	DynPaletteTransition
	tst.b	(v_palflags).w				; check if the palette is fully loaded
	bne.s	Credits_TextFadeIn
	
; Main loop	
Credits_MainLoop:
    move.b  #6,(v_vbla_routine).w			; set V-blank routine to run
    jsr 	WaitForVBla					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (v_jpadpress1).w           	; has player 1 pressed start button?
    bmi.s   Credits_StartPressed    ; if so, branch
	bsr.w	Credits_Controls
	bsr.w	GLP2_Camera
	bra.s	Credits_MainLoop
 
; Quit Menu
Credits_StartPressed:
    move.b  #id_GLP2Title,(v_gamemode).w      	; set the screen mode to Title Screen
    rts									; return

; ===============================================================
; Controls routine
; ===============================================================
Credits_Controls:

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
		bra.w	Credits_Body
;		move.w	#SndID_Blip,d0
;		jmp	(PlaySound).l			

; ===============================================================
; Foreground Plane Graphics Rendering Routines
; ===============================================================

Credits_Headings:
	; lea	($C00000).l,a6
	; lea	(Credits_Heading1).l,a1 ; where to fetch the lines from	
	; move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	; move.l	#$428C0003,4(a6)
	; moveq	#12,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender
	
	; ; MOST RINGS
	; move.l	#$46080003,4(a6)
	; moveq	#10,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender

	; ; BEST TIME
	; move.l	#$47080003,4(a6)
	; moveq	#9,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender	

	; ; EXITS
	; move.l	#$4A080003,4(a6)
	; moveq	#4,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender
	
	; ; RED STAR RINGS
	; move.l	#$4A2C0003,4(a6)
	; moveq	#13,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender
	
	; move.l	#$47220003,4(a6)
	; move.w	#$A680+":"-$21,(a6)
	
	; move.l	#$47280003,4(a6)
	; move.w	#$A680+":"-$21,(a6)

	; rts
	

; ===============================================================

Credits_Body:
	; lea	($C00000).l,a6
	; lea	(Credits_LevelNames).l,a1 ; where to fetch the lines from
	; move.w	(v_levselitem).w,d1
	; mulu.w	#11,d1
	; adda.l	d1,a1	
	; move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	; move.l	#$42A80003,4(a6)
	; moveq	#10,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender

	
	; lea		(v_level_savedata).w,a3
	; moveq	#0,d0
	; move.w	(v_levselitem).w,d0
	; add.w	d0,d0
	; adda.l	d0,a0
	; lsl.w	#2,d0	; save data size is 8
	; adda.l	d0,a3	

; Credits_Time:

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
	
; Credits_Rings:
	; move.l	#$46200003,4(a6)

	; movem.l	d0-d6,-(sp)
	; lea	(Hud_100).l,a2 			; get the number of digits
	; moveq	#2,d0             			; repeat X-1 times
	; moveq	#0,d1
	; move.w	LSD_Rings(a3),d1			; get value to render
	; move.w	#$A68F,d3					; get 0 from font
	; bsr.w	DecimalNumberRender
	; movem.l	(sp)+,d0-d6	


; Credits_RedStarRings:
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
	
; Credits_Exits:
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