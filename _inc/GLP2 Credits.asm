; ================================================================
; "GLP2'S LEVEL PACK 2" Title Screen
; Code by giovanni.gen
; Logo by Cinossu
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================
ArtTile_ArtNem_CreditText_CredScr = $0001

CreditsScreenIndex = $FF1000

GLP2Credits:
EndgameCredits:
	bsr.w	PaletteFadeOut
	lea	(vdp_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200+(vram_fg>>10),(a6)	; PNT A base: $C000
	move.w	#$8400+(vram_bg>>13),(a6)	; PNT B base: $E000
	move.w	#$9001,(a6)		; Scroll table size: 64x32
	move.w	#$9200,(a6)		; Disable window
	move.w	#$8B03,(a6)		; EXT-INT disabled, V scroll by screen, H scroll by line
	move.w	#$8700,(a6)		; Background palette/color: 0/0
	clr.b	(f_wtr_state).w
	move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
	jsr		ClearScreen
	
	clr.w	(v_pal_dry_dup).w
	move.w	#$EEE,(v_pal_dry_dup+$C).w
	move.w	#$EE,(v_pal_dry_dup+$2C).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_CreditText_CredScr),VRAM,WRITE),(vdp_control_port).l
	lea	(ArtNem_CreditText).l,a0
	jsr		NemDec
	clr.w	(CreditsScreenIndex).l

.newpage:

	jsr		ClearScreen
	bsr.w	ShowCreditsScreen
	bsr.w	PaletteFadeIn

	; Here's how to calculate new duration values for the below instructions.
	; Each slide of the credits is displayed for $18E frames at 60 FPS, or $144 frames at 50 FPS.
	; We also need to take into account how many frames the fade-in/fade-out take: which is $16 each.
	; Also, there are 21 slides to display.
	; That said, by doing '($18E+$16+$16)*21', we get the total number of frames it takes until
	; the credits reach the Sonic 2 splash (which is technically not an actual slide in the credits).
	; Dividing this by 60 will give us how many seconds it takes. The result being 154.7.
	; Doing the same for 50 FPS, by dividing the result of '($144+$16+$16)*21' by 50, will give us 154.56.
	; Now that we have the time it should take for the credits to end, we can adjust the calculation to account
	; for any slides we may have added. For example, if you added a slide, bringing the total to 22,
	; performing '((154.7*60)/22)-($16+$16)' will give you the new value to put in the 'move.w' instruction below.
	move.w	#$18E,d0
	btst	#6,(v_megadrive).w
	beq.s	.NTSC
	move.w	#$144,d0

.NTSC:
	move.b	#6,(v_vbla_routine).w
	bsr.w	WaitForVBla
	moveq	#0,d1
    move.b  (v_jpadpress1).w,d1        	
	andi.b	#btnStart+btnB,d1
    bne.s   .skipcredits   ; if so, branch
	dbf	d0,.NTSC

	bsr.w	PaletteFadeOut
	lea	(off_B2CA).l,a1
	addq.w	#1,(CreditsScreenIndex).l
	move.w	(CreditsScreenIndex).l,d0
	lsl.w	#2,d0
	move.l	(a1,d0.w),d0
	bpl.s	.newpage
	
.skipcredits:	
	bsr.w	PaletteFadeOut

	move.b	#id_Sega,(v_gamemode).w ; => SegaScreen
	rts
; End of function EndgameCredits	

; ================================================================

;sub_B262
ShowCreditsScreen:
	lea	off_B2CA(pc),a1
	move.w	(CreditsScreenIndex).l,d0
	lsl.w	#2,d0
	move.l	(a1,d0.w),d0
	movea.l	d0,a1

loc_B272:
	move	#$2700,sr
	lea	(vdp_data_port).l,a6
.minus2
	move.l	(a1)+,d0
	bmi.s	.plus2
	movea.l	d0,a2
	move.w	(a1)+,d0
	bsr.s	sub_B29E
	move.l	d0,4(a6)
	move.b	(a2)+,d0
	lsl.w	#8,d0
.minus1
	move.b	(a2)+,d0
	bmi.s	.plus1
	move.w	d0,(a6)
	bra.s	.minus1
; ===========================================================================
.plus1:
	bra.s	.minus2
; ===========================================================================
.plus2:
	move	#$2300,sr
	rts
	
sub_B29E:
	andi.l	#$FFFF,d0
	lsl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d0
	swap	d0
	rts
; End of function sub_B29E	
; End of function ShowCreditsScreen

; ===========================================================================

; ===========================================================================

; macro for declaring pointer/position structures for intro/credit text
vram_pnt := vram_fg
creditsPtrs macro addr,pos
	if "addr"<>""
		dc.l addr
		dc.w vram_pnt + pos
		shift
		shift
		creditsPtrs ALLARGS
	else
		dc.w -1
	endif
    endm

textLoc function col,line,(($80 * line) + (2 * col))

; credits screen pointer table
off_B2CA:
	dc.l CreditsScreen_0, CreditsScreen_1
	dc.l CreditsScreen_2, CreditsScreen_3	
	dc.l CreditsScreen_4, CreditsScreen_5, CreditsScreen_6
	dc.l CreditsScreen_7, CreditsScreen_8, CreditsScreen_9
	dc.l CreditsScreen_10, off_B548, ThanksForPlaying, -1				

; credits text pointers for each screen of credits
vram_pnt := vram_fg
CreditsScreen_0:	creditsPtrs CreditText_GLP2_1,textLoc($0B,$0A), CreditText_GLP2_2,textLoc($09,$0C), CreditText_StaffCredits,textLoc($08,$10)
CreditsScreen_1:	creditsPtrs CreditText_ProjectLead,textLoc($02,$0B), CreditText_Giovanni,textLoc($02,$0F)
CreditsScreen_2:	creditsPtrs CreditText_LevelLayouts,textLoc($02,$0B), CreditText_Giovanni,textLoc($02,$0F)
CreditsScreen_3:	creditsPtrs CreditText_Programming,textLoc($02,$0A), CreditText_Giovanni,textLoc($02,$0E), CreditText_fuzzybit,textLoc($02,$10)
CreditsScreen_4: 	creditsPtrs	CreditText_Playtesting,textLoc($02,$08), CreditText_fuzzybit,textLoc($02,$0C), CreditText_HazelSpooder,textLoc($02,$0E), CreditText_MDTravis,textLoc($02,$10), CreditText_ScrapSorra,textLoc($02,$12)
CreditsScreen_5:	creditsPtrs CreditText_AdditionalFeedback,textLoc($02,$0A), CreditText_DAGarden,textLoc($02,$0E),	CreditText_djohe,textLoc($02,$10)
CreditsScreen_6: 	creditsPtrs	CreditText_AdditionalArtwork,textLoc($02,$06), CreditText_Cinossu,textLoc($02,$0A), CreditText_Giovanni,textLoc($02,$0C), CreditText_MDTravis,textLoc($02,$0E), CreditText_Rosie,textLoc($02,$10), CreditText_Speems,textLoc($02,$12), CreditText_Tomatowave,textLoc($02,$14)
CreditsScreen_7: 	creditsPtrs	CreditText_AdditionalCode,textLoc($02,$06), CreditText_Cinossu,textLoc($02,$0A), CreditText_Clownacy,textLoc($02,$0C), CreditText_DeltaW,textLoc($02,$0E), CreditText_devon,textLoc($02,$10), CreditText_djohe,textLoc($02,$12), CreditText_FraGag,textLoc($02,$14)
CreditsScreen_8: 	creditsPtrs	CreditText_AdditionalCode,textLoc($02,$06), CreditText_Hixatas,textLoc($02,$0A), CreditText_Lightning,textLoc($02,$0C), CreditText_Kilo,textLoc($02,$0E), CreditText_kram1024,textLoc($02,$10), CreditText_MarkeyJester,textLoc($02,$12), CreditText_Mercury,textLoc($02,$14)
CreditsScreen_9: 	creditsPtrs	CreditText_AdditionalCode,textLoc($02,$06), CreditText_ProjectFM,textLoc($02,$0A), CreditText_Puto,textLoc($02,$0C), CreditText_Raendom,textLoc($02,$0E), CreditText_RHS,textLoc($02,$10), CreditText_Shobiz,textLoc($02,$12), CreditText_Tweaker,textLoc($02,$14)
CreditsScreen_10:	creditsPtrs CreditText_OriginalGame,textLoc($02,$0A), CreditText_SEGA,textLoc($02,$0E), CreditText_SonicTeam,textLoc($02,$10)
off_B548: creditsPtrs	byte_BC7B,textLoc($0B,$09), byte_BC8F,textLoc($12,$0D), CreditText_Giovanni,textLoc($09,$11)
ThanksForPlaying:	creditsPtrs CreditText_ThanksFor,textLoc($0A,$0B), CreditText_Playing,textLoc($0D,$0E)	; and for checking out my hack's source code, too!

 ; temporarily remap characters to credit text format
 ; let's encode 2-wide characters like Aa, Bb, Cc, etc. and hide it with a macro
 charset '@',"\x3B\2\4\6\8\xA\xC\xE\x10\x12\x13\x15\x17\x19\x1B\x1D\x1F\x21\x23\x25\x27\x29\x2B\x2D\x2F\x31\x33"
 charset 'a',"\3\5\7\9\xB\xD\xF\x11\x12\x14\x16\x18\x1A\x1C\x1E\x20\x22\x24\x26\x28\x2A\x2C\x2E\x30\x32\x34"
 charset '!',"\x3D\x39\x3F\x36"
 charset '\H',"\x39\x37\x38"
 charset '9',"\x3E\x40\x41"
 charset '1',"\x3C\x35"
 charset '.',"\x3A"
 charset ' ',0

 ; macro for defining credit text in conjunction with the remapped character set
vram_src := ArtTile_ArtNem_CreditText_CredScr
creditText macro pal,ss
	if ((vram_src & $FF) <> $0) && ((vram_src & $FF) <> $1)
		fatal "The low byte of vram_src was $\{vram_src & $FF}, but it must be $00 or $01."
	endif
	dc.b (make_art_tile(vram_src,pal,0) & $FF00) >> 8
	irpc char,ss
	dc.b "char"
	switch "char"
	case "I"
	case "1"
		dc.b "!"
	case "2"
		dc.b "$"
	case "9"
		dc.b "#"
	elsecase
l := lowstring("char")
		if l<>"char"
			dc.b l
		endif
	endcase
	endm
	dc.b -1
	even
    endm

; credits text data (palette index followed by a string)
vram_src := ArtTile_ArtNem_CreditText_CredScr
CreditText_GLP2_1:	creditText 1,"GIOVANNI'S"
CreditText_GLP2_2:  creditText 1,"LEVEL PACK 2"
CreditText_StaffCredits:	creditText 0,"STAFF CREDITS"
CreditText_ProjectLead:	creditText 1,"PROJECT LEAD"
CreditText_Giovanni:	creditText 0,"GIOVANNI.GEN"
CreditText_LevelLayouts:	creditText 1,"LEVEL LAYOUTS"
CreditText_Programming:	creditText 1,"PROGRAMMING"
CreditText_fuzzybit:	creditText 0,"FUZZYBIT"
CreditText_Playtesting:	creditText 1,"PLAYTESTING"
CreditText_HazelSpooder:	creditText 0,"HAZELSPOODER"
CreditText_MDTravis:	creditText 0,"MDTRAVIS"
CreditText_ScrapSorra:	creditText 0,"SCRAP SORRA"
CreditText_AdditionalFeedback:	creditText 1,"ADDITIONAL FEEDBACK"
CreditText_DAGarden: creditText 0,"D.A. GARDEN"
CreditText_AdditionalArtwork:	creditText 1,"ADDITIONAL ARTWORK"
CreditText_Cinossu: creditText 0,"CINOSSU"
CreditText_Rosie: creditText 0,"ROSIE ECLAIRS"
CreditText_Speems: creditText 0,"SPEEMS"
CreditText_Tomatowave: creditText 0,"TOMATOWAVE"
CreditText_AdditionalCode: creditText 1,"ADDITIONAL CODE"
CreditText_Clownacy: creditText 0,"CLOWNACY"
CreditText_DeltaW: creditText 0,"DELTAW"
CreditText_devon: creditText 0,"DEVON"
CreditText_djohe: creditText 0,"DJOHE"
CreditText_FraGag: creditText 0,"FRAGAG"
CreditText_Hixatas: creditText 0,"HIXATAS"
CreditText_Lightning: creditText 0,"LIGHTNING"
CreditText_Kilo: creditText 0,"KILO"
CreditText_kram1024: creditText 0,"KRAM"
CreditText_MarkeyJester: creditText 0,"MARKEYJESTER"
CreditText_Mercury: creditText 0,"MERCURY"
CreditText_ProjectFM: creditText 0,"PROJECTFM"
CreditText_Puto: creditText 0,"PUTO"
CreditText_Raendom: creditText 0,"RAENDOM"
CreditText_RHS: creditText 0,"REDHOTSONIC"
CreditText_Shobiz: creditText 0,"SHOBIZ"
CreditText_Tweaker: creditText 0,"TWEAKER"
CreditText_OriginalGame: creditText 1,"ORIGINAL GAME"
CreditText_SEGA:	creditText 0,"SEGA"
CreditText_SonicTeam:	creditText 0,"SONIC TEAM"
byte_BC7B:	creditText 0,"PRESENTED"
byte_BC8F:	creditText 0,"BY"
byte_BC95:	creditText 0,"SEGA"
CreditText_ThanksFor:	creditText 1,"THANKS FOR"
CreditText_Playing:		creditText 1,"PLAYING"

 charset ; have to revert character set before changing again

	even

; -------------------------------------------------------------------------------
; Nemesis compressed art
; 64 blocks
; Standard font used in credits
; -------------------------------------------------------------------------------
; ArtNem_BD26:
ArtNem_CreditText:	BINCLUDE	"artnem/Credit Text.bin"
	even
; ===========================================================================