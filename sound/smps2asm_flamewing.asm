; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================
SonicDriverVer:	equ	4
; PSG conversion to S3/S&K/S3D drivers require a tone shift of 12 semi-tones.
psgdelta	equ 12
; ---------------------------------------------------------------------------------------------
; Standard Octave Pitch equates
smpsPitch10lo	equ $88
smpsPitch09lo	equ $94
smpsPitch08lo	equ $A0
smpsPitch07lo	equ $AC
smpsPitch06lo	equ $B8
smpsPitch05lo	equ $C4
smpsPitch04lo	equ $D0
smpsPitch03lo	equ $DC
smpsPitch02lo	equ $E8
smpsPitch01lo	equ $F4
smpsPitch00		equ $00
smpsPitch01hi	equ $0C
smpsPitch02hi	equ $18
smpsPitch03hi	equ $24
smpsPitch04hi	equ $30
smpsPitch05hi	equ $3C
smpsPitch06hi	equ $48
smpsPitch07hi	equ $54
smpsPitch08hi	equ $60
smpsPitch09hi	equ $6C
smpsPitch10hi	equ $78
; ---------------------------------------------------------------------------------------------
; Note equates
; ---------------------------------------------------------------------------------------------
nRst		EQU	$80
nC0			EQU	$81
nCs0		EQU	$82
nD0			EQU	$83
nEb0		EQU	$84
nE0			EQU	$85
nF0			EQU	$86
nFs0		EQU	$87
nG0			EQU	$88
nAb0		EQU	$89
nA0			EQU	$8A
nBb0		EQU	$8B
nB0			EQU	$8C
nC1			EQU	$8D
nCs1		EQU	$8E
nD1			EQU	$8F
nEb1		EQU	$90
nE1			EQU	$91
nF1			EQU	$92
nFs1		EQU	$93
nG1			EQU	$94
nAb1		EQU	$95
nA1			EQU	$96
nBb1		EQU	$97
nB1			EQU	$98
nC2			EQU	$99
nCs2		EQU	$9A
nD2			EQU	$9B
nEb2		EQU	$9C
nE2			EQU	$9D
nF2			EQU	$9E
nFs2		EQU	$9F
nG2			EQU	$A0
nAb2		EQU	$A1
nA2			EQU	$A2
nBb2		EQU	$A3
nB2			EQU	$A4
nC3			EQU	$A5
nCs3		EQU	$A6
nD3			EQU	$A7
nEb3		EQU	$A8
nE3			EQU	$A9
nF3			EQU	$AA
nFs3		EQU	$AB
nG3			EQU	$AC
nAb3		EQU	$AD
nA3			EQU	$AE
nBb3		EQU	$AF
nB3			EQU	$B0
nC4			EQU	$B1
nCs4		EQU	$B2
nD4			EQU	$B3
nEb4		EQU	$B4
nE4			EQU	$B5
nF4			EQU	$B6
nFs4		EQU	$B7
nG4			EQU	$B8
nAb4		EQU	$B9
nA4			EQU	$BA
nBb4		EQU	$BB
nB4			EQU	$BC
nC5			EQU	$BD
nCs5		EQU	$BE
nD5			EQU	$BF
nEb5		EQU	$C0
nE5			EQU	$C1
nF5			EQU	$C2
nFs5		EQU	$C3
nG5			EQU	$C4
nAb5		EQU	$C5
nA5			EQU	$C6
nBb5		EQU	$C7
nB5			EQU	$C8
nC6			EQU	$C9
nCs6		EQU	$CA
nD6			EQU	$CB
nEb6		EQU	$CC
nE6			EQU	$CD
nF6			EQU	$CE
nFs6		EQU	$CF
nG6			EQU	$D0
nAb6		EQU	$D1
nA6			EQU	$D2
nBb6		EQU	$D3
nB6			EQU	$D4
nC7			EQU	$D5
nCs7		EQU	$D6
nD7			EQU	$D7
nEb7		EQU	$D8
nE7			EQU	$D9
nF7			EQU	$DA
nFs7		EQU	$DB
nG7			EQU	$DC
nAb7		EQU	$DD
nA7			EQU	$DE
nBb7		EQU	$DF
; SMPS2ASM uses nMaxPSG for songs from S1/S2 drivers.
; nMaxPSG1 and nMaxPSG2 are used only for songs from S3/S&K/S3D drivers.
; The use of psgdelta is intended to undo the effects of PSGPitchConvert
; and ensure that the ending note is indeed the maximum PSG frequency.
nMaxPSG				EQU nBb6-psgdelta
nMaxPSG1			EQU nBb6
nMaxPSG2			EQU nB6
; ---------------------------------------------------------------------------------------------
; PSG Flutter equates
fTone_00	equ	$00
fTone_01	equ	$01
fTone_02	equ	$02
fTone_03	equ	$03
fTone_04	equ	$04
fTone_05	equ	$05
fTone_06	equ	$06
fTone_07	equ	$07
fTone_08	equ	$08
fTone_09	equ	$09
fTone_0A	equ	$0A
fTone_0B	equ	$0B
fTone_0C	equ	$0C
fTone_0D	equ	$0D
sTone_01	equ	$0E
sTone_02	equ	$0F
sTone_03	equ	$10
sTone_04	equ	$11
sTone_05	equ	$12
sTone_06	equ	$13
sTone_07	equ	$14	; SFX envelope, probably unused in S3K
sTone_08	equ	$15
sTone_09	equ	$16
sTone_0A	equ	$17
sTone_0B	equ	$18	; For FM volume envelopes
sTone_0C	equ	$19
sTone_0D	equ	$1A	; This time it matches 100%
sTone_0E	equ	sTone_01	; Duplicate of 01
sTone_0F	equ	sTone_02	; Duplicate of 02
sTone_10	equ	$1B
sTone_11	equ	$1C
sTone_12	equ	sTone_05	; Duplicate of 05
sTone_13	equ	sTone_06	; Duplicate of 06
sTone_14	equ	$1D	; SFX envelope, probably unused in S3K
sTone_15	equ	sTone_08	; Duplicate of 08
sTone_16	equ	sTone_09	; Duplicate of 09
sTone_17	equ	sTone_0A	; Duplicate of 0A
sTone_18	equ	$1E	; For FM volume envelopes
sTone_19	equ	sTone_0C	; Duplicate of 0C
sTone_1A	equ	$1F
sTone_1B	equ	sTone_0C	; Duplicate of 0C
sTone_1C	equ	$06
sTone_1D	equ	$07
sTone_1E	equ	$02
sTone_1F	equ	$04
sTone_20	equ	$00	; This time it matches 100%
sTone_21	equ	$09
sTone_22	equ	$04
sTone_23	equ	$07
sTone_24	equ	$02
sTone_25	equ	$09
sTone_26	equ	$07
sTone_27	equ	$03
sTone_DB2_3	equ	$1F
sTone_Ristar_14	equ	$20
sTone_Ristar_15	equ	$21
sTone_Ristar_17	equ	$22
sTone_DB2_D	equ	$23
sTone_DB2_1	equ	$24
; ---------------------------------------------------------------------------------------------
; DAC equates
; ---------------------------------------------------------------------------------------------
dKick equ $81
dSnare equ $82
dClap equ $83
dKCCrash equ $84
dCrashCymbal equ $85
dRideCymbal	equ $86
dKCSnare equ $87
dHiTimpani equ $88
dMidTimpani equ $89
dLowTimpani equ $8A
dVLowTimpani equ $8B
dKickS3	equ $8C
dSnareS3	equ $8D
dElectricHighTom equ $8E
dElectricMidTom equ $8F
dElectricLowTom equ $90
dElectricFloorTom equ $91
dHighTom equ $92
dMidTomS3 equ $93
dLowTomS3 equ $94
dFloorTomS3 equ $95
dLackOfTrack1 equ $96
dLackOfTrack2 equ $97
dLackOfTrack3 equ $98
dLackOfTrack4 equ $99
dLackOfTrack5 equ $9A
dLackOfTrack6 equ $9B
dMuffledSnare equ $9C
dCrayonKick equ $9D
dCrayonSnare equ $9E
dQuickLooseSnare equ $9F
dMidTom equ $A0
dLowTom equ $A1
dFloorTom equ $A2
dLowMetalHit equ $A3
dMetalHit equ $A4
dHighMetalHit equ $A5
dHigherMetalHit equ $A6
dMidMetalHit equ $A7
dTightSnare equ $A8
dMidpitchSnare equ $A9
dLooseSnare equ $AA
dLooserSnare equ $AB
dSegaTheme equ $AC
dScratch equ $AD
dHiTimpaniS3 equ $AE
dLowTimpaniS3 equ $AF
dMidTimpaniS3 equ $B0
dProtoSnare equ $B1
dLackOfTrack7 equ $B2
dLackOfTrack8 equ $B3
dLackOfTrack9 equ $B4
dLackOfTrack10 equ $B5
dLackOfTrack11 equ $B6
dLackOfTrack12 equ $B7
dLackOfTrack13 equ $B8
dLackOfTrack14 equ $B9
dLackOfTrack15 equ $BA
dLackOfTrack16 equ $BB
dLackOfTrack17 equ $BC
dLackOfTrack18 equ $BD
dLackOfTrack19 equ $BE
dLackOfTrack20 equ $BF
dLackOfTrack21 equ $C0
dHiBongo equ $C1
dMidBongo equ $C2
dLowBongo equ $C3
; ---------------------------------------------------------------------------------------------
; Channel IDs for SFX
; ---------------------------------------------------------------------------------------------
cPSG1				EQU $80
cPSG2				EQU $A0
cPSG3				EQU $C0
cNoise				EQU $E0	; Not for use in S3/S&K/S3D
cFM3				EQU $02
cFM4				EQU $04
cFM5				EQU $05
cFM6				EQU $06	; Only in S3/S&K/S3D, overrides DAC
; ---------------------------------------------------------------------------------------------
; Conversion macros and functions

;conv0To256  macro val 
	;if val<$01
		;dc.b (256-val+$FF)&$FF
	;else	
		;dc.b (256-val)&$FF	
	;endc
	;endm
; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver
SourceDriver set ver
songStart set *
	endm

smpsHeaderStartSongConvert macro ver
SourceDriver set ver
songStart set *
	endm

smpsHeaderVoiceNull macro
	if songStart<>*
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dc.w	$0000
	endm

; Header - set up Voice Location
; Common to music and SFX
smpsHeaderVoice macro loc
	if songStart<>*
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dc.w	loc-songStart
	endm

; Header macros for music (not for SFX)
; Header - set up Channel Usage
smpsHeaderChan macro fm,psg
	dc.b	fm,psg
	endm

; Header - set up Tempo
smpsHeaderTempo macro div,mod
	dc.b	div
tempoDivider set div
	dc.b    mod
	endm

; Header - set up DAC Channel
smpsHeaderDAC macro loc,pitch,vol
	dc.w	loc-songStart
	if (narg=2)
		dc.b	pitch
		if (narg=3)
			dc.b	vol
		else
			dc.b	$00
		endif
	else
		dc.w	$00
	endif
	endm

; Header - set up FM Channel
smpsHeaderFM macro loc,pitch,vol
	dc.w	loc-songStart
	dc.b	pitch,vol
	endm

; Header - set up PSG Channel
smpsHeaderPSG macro loc,pitch,vol,mod,voice
	dc.w	loc-songStart
	dc.b	(pitch+psgdelta)&$FF,vol,mod,voice	
	endm

; Header macros for SFX (not for music)
; Header - set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitch,vol
	if (chanid=cNoise)
		fatal "Using channel ID of FM6 ($06) in Sonic 1 or Sonic 2 drivers is unsupported. Change it to another channel."
	endif
	dc.b	$80,chanid
	dc.w	loc-songStart
	if (chanid&$80)<>0
	if SourceDriver>=3
		dc.b	pitch
	else
		dc.b	(pitch+psgdelta)&$FF
	endif
	else
		dc.b	pitch
	endif
	dc.b	vol
	endm
; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone set $00
panRight set $40
panLeft set $80
panCentre set $C0
panCenter set $C0 ; silly Americans :U
	dc.b $E0,direction+amsfms
	endm

; E1xx - set channel frequency displacement to xx
smpsAlterNote macro val
	dc.b	$E1,val
	endm

smpsDetune macro val
	dc.b $E1, val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$E2,val
	endm

; Return (used after smpsCall)
smpsReturn macro val
	dc.b	$E3
	endm

; Fade in previous song (ie. 1-Up)
smpsFade macro val
	dc.b	$E4
	endm

; E5xx - set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$E5,val
	endm

; E6xx - Alter Volume by xx
smpsAlterVol macro val
	dc.b	$E6,val
	endm
sVol	equ $E6

; E7 - Prevent attack of next note
smpsNoAttack	equ $E7
smpsNA	equ smpsNoAttack
sNA	equ smpsNoAttack

; E8xx - set note fill to xx
smpsNoteFill macro val
	if SourceDriver>=3
	dc.b	$FA,val
	else
	dc.b	$E8,val
	endif
	endm

; Add xx to channel pitch
smpsAlterPitch macro val
	dc.b	$E9,val
	endm

smpsChangeTransposition macro val
	dc.b	$E9,val
	endm

; set music tempo modifier to xx
smpsSetTempoMod macro val
	dc.b	$EA
	dc.b    val
	endm

; set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$EB,val
	endm

; ECxx - set Volume to xx
smpsSetVol macro val
	dc.b	$FC,val
	endm

; Works on all drivers
smpsPSGAlterVol macro vol
	dc.b	$EC,vol
	endm
spVol	equ $EC

; Clears pushing sound flag in S1
smpsClearPush macro
	dc.b	$ED
	endm

; Stops special SFX (S1 only) and restarts overridden music track
smpsStopSpecial macro
	dc.b	$EE
	endm

; EFxx[yy] - set Voice of FM channel to xx; xx < 0 means yy present
smpsSetvoice macro voice,songID
	dc.b	$EF,voice
	endm

; EFxx - set Voice of FM channel to xx
smpsFMvoice macro voice
	dc.b	$EF,voice
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
; DeltaWooloo: I modified this to make the modulation accurate based on the sound source chosen for each song/SFX.
smpsModSet macro wait,speed,change,step
		dc.b	$F0	
	if SourceDriver>=3
		dc.b	wait-1,speed,change,(step*speed-1)&$FF
	else
		dc.b	wait,speed,change,step
	endif
	endm

smpsChangeVolZ80 macro val	; DeltaWooloo: The Hybrid Front really needs this
	dc.b	$FB,val	
	endm

; Turn on Modulation
smpsModOn macro
	dc.b	$F1
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F3xx - PSG waveform to xx
smpsPSGform macro form
	dc.b	$F3,form
	endm

; Turn off Modulation
smpsModOff macro
	dc.b	$F4
	endm

; set Modulation
smpsModChange macro val
	dc.b	$F4,val
	endm	

; F5xx - PSG voice to xx
smpsPSGvoice macro voice
	dc.b	$F5,voice
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	loc-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7
	dc.b	index,loops
	dc.w	loc-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	loc-*-1
	endm
	
; FCxxxx - Jump to xxxx
smpsContinuousLoop macro loc
	dc.b	$FB
	dc.w	loc-*-1
	endm	
	
; ---------------------------------------------------------------------------------------------
; Alter Volume
smpsFMAlterVol macro val1,val2
	dc.b	$E6,val1
	endm

; ---------------------------------------------------------------------------------------------
; S1/S2 only coordination flag
;: =s D1L to maximum volume (minimum attenuation) and RR to maximum for operators 3 and 4 of FM1
smpsWeirdD1LRR macro
	dc.b	$F9
	endm
; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set val
	endm

smpsVcUnusedBits macro val
vcUnusedBits set val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set op1
vcDT2 set op2
vcDT3 set op3
vcDT4 set op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set op1
vcCF2 set op2
vcCF3 set op3
vcCF4 set op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set op1
vcRS2 set op2
vcRS3 set op3
vcRS4 set op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set op1
vcAR2 set op2
vcAR3 set op3
vcAR4 set op4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro op1,op2,op3,op4
vcAM1 set op1
vcAM2 set op2
vcAM3 set op3
vcAM4 set op4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set op1
vcD1R2 set op2
vcD1R3 set op3
vcD1R4 set op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set op1
vcD2R2 set op2
vcD2R3 set op3
vcD2R4 set op4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set op1
vcDL2 set op2
vcDL3 set op3
vcDL4 set op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set op1
vcRR2 set op2
vcRR3 set op3
vcRR4 set op4
	endm

; Voices - Total Level
smpsVcTotalLevel macro op1,op2,op3,op4
vcTLMask4 set ((vcAlgorithm=7)<7)
vcTLMask3 set ((vcAlgorithm>=4)<7)
vcTLMask2 set ((vcAlgorithm>=5)<7)
vcTLMask1 set $80
vcTL1 set op1
vcTL2 set op2
vcTL3 set op3
vcTL4 set op4
	dc.b	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
	dc.b	(vcDT4<<4)+vcCF4, (vcDT3<<4)+vcCF3, (vcDT2<<4)+vcCF2, (vcDT1<<4)+vcCF1
	dc.b	(vcRS4<<6)+vcAR4, (vcRS3<<6)+vcAR3, (vcRS2<<6)+vcAR2, (vcRS1<<6)+vcAR1
	dc.b	(vcAM4<<5)+vcD1R4, (vcAM3<<5)+vcD1R3, (vcAM2<<5)+vcD1R2, (vcAM1<<5)+vcD1R1
	dc.b	vcD2R4, vcD2R3, vcD2R2, vcD2R1
	dc.b	(vcDL4<<4)+vcRR4, (vcDL3<<4)+vcRR3, (vcDL2<<4)+vcRR2, (vcDL1<<4)+vcRR1
	;dc.b	vcTL4|vcTLMask4, vcTL3|vcTLMask3, vcTL2|vcTLMask2, vcTL1|vcTLMask1
	if vcAlgorithm=7
		dc.b	op4|$80
	else
		dc.b	op4
	endif

	if vcAlgorithm>=4
		dc.b    op3|$80
	else
		dc.b    op3
	endif

	if vcAlgorithm>=5
		dc.b    op2|$80
	else
		dc.b    op2
	endif
		dc.b    op1|$80
	endm

