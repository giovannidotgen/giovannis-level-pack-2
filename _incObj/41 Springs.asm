; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------

Springs:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spring_Index(pc,d0.w),d1
		jsr	Spring_Index(pc,d1.w)
		bsr.w	DisplaySprite
		out_of_range_S3.w	DeleteObject
		rts	
; ===========================================================================
Spring_Index:	
		dc.w Spring_Init-Spring_Index
        dc.w Spring_Up-Spring_Index
        dc.w Spring_Horizontal-Spring_Index
        dc.w Spring_Down-Spring_Index
        dc.w Spring_DiagonallyUp-Spring_Index
        dc.w Spring_DiagonallyDown-Spring_Index

; ===========================================================================

Spring_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spring_Red,obMap(a0)
		move.w	#$52F,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obPriority(a0)
		move.b	obSubtype(a0),d0
		lsr.w   #3,d0   ; divide it to 6
		andi.w  #$E,d0  ; and it by $E
		move.w  Spring_Init_Subtypes(pc,d0.w),d0
		jmp Spring_Init_Subtypes(pc,d0.w)    ; Jump to different initialization subroutines depending on subtype
		
		
; ===========================================================================

Spring_Init_Subtypes:
    dc.w Spring_Init_Up-Spring_Init_Subtypes        ; 0
    dc.w Spring_Init_Horizontal-Spring_Init_Subtypes    ; 2
    dc.w Spring_Init_Down-Spring_Init_Subtypes      ; 4
    dc.w Spring_Init_DiagonallyUp-Spring_Init_Subtypes  ; 6
    dc.w Spring_Init_DiagonallyDown-Spring_Init_Subtypes    ; 8		
		
; ===========================================================================
; loc_188E8:
Spring_Init_Horizontal:
    move.b  #4,obRoutine(a0)
    move.b  #2,obAnim(a0)
    move.b  #3,obFrame(a0)
    move.w  #$523,obGfx(a0)
    move.b  #8,obActWid(a0)
    bra.s   Spring_Init_Common

; ===========================================================================

; loc_18908:
Spring_Init_Down:
    move.b  #6,obRoutine(a0)
    move.b  #6,obFrame(a0)
    bset    #1,obStatus(a0)
    bra.s   Spring_Init_Common

; ===========================================================================

; loc_1891C:
Spring_Init_DiagonallyUp:
    move.b  #8,obRoutine(a0)
    move.b  #4,obAnim(a0)
    move.b  #7,obFrame(a0)
    move.w  #($ABA0/$20),obGfx(a0)	
    bra.s   Spring_Init_Common

; ===========================================================================

; loc_18936:
Spring_Init_DiagonallyDown:
    move.b  #$A,obRoutine(a0)
    move.b  #4,obAnim(a0)
    move.b  #$A,obFrame(a0)
    move.w  #($ABA0/$20),obGfx(a0)	
    bset    #1,obStatus(a0)
; ===========================================================================

Spring_Init_Up:
Spring_Init_Common:
    ; checks color of spring
    move.b  obSubtype(a0),d0
    andi.w  #2,d0
    move.w  Spring_Powers(pc,d0.w),spring_pow(a0)
    btst    #1,d0
    beq.s   Spring_Init_Common_Red
    move.l  #Map_Spring_Green,obMap(a0)
Spring_Init_Common_Red:
    rts

; ===========================================================================

spring_pow:	equ $30			; power of current spring

Spring_Powers:	dc.w -$1000		; power	of red spring
		dc.w -$A00		; power	of yellow spring    
	
; ===========================================================================


Spring_Up:	; Routine 2
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		tst.b	obSolid(a0)	; is Sonic on top of the spring?
		beq.s	Spring_AniUp	; if not, branch
		
; ===========================================================================

Spring_BounceUp:
		move.w	#$100,obAnim(a0)
		addq.w	#8,obY(a1)
		move.w	spring_pow(a0),obVelY(a1) ; move Sonic upwards
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1) ; use "bouncing" animation
		tst.b   obSubtype(a0) ; is bit 7 of subtype is set?
		bpl.s   Spring_UpNoClr   ; if not, branch
		clr.w   obVelX(a1) ; clear Sonic's X velocity
	Spring_UpNoClr:		
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	obSolid(a0)
		move.w	#sfx_Spring,d0
		jsr	(PlaySound_Special).l	; play spring sound

Spring_AniUp:	; Routine 4
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
		
; ===========================================================================

;byte_18FAA:

Spring_SlopeData_DiagUp:
    dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10, $E, $C, $A,  8
    dc.b   6,  4,  2,  0,$FE,$FC,$FC,$FC,$FC,$FC,$FC,$FC; 16

; ===========================================================================

Spring_DiagonallyUp:
        move.w  #$1B,d1
        move.w  #$10,d2
        move.w  $8(a0),d4
        lea Spring_SlopeData_DiagUp(pc),a2
        jsr     (SolidObject2F).l
        btst    #3,$22(a0)
        beq.w   Spring_AniDiagUp
;       btst    #0,$22(a0)
;       bne.s   Spring_DiagFlipped
        subq.w  #4,d0
        cmp.w   8(a1),d0
        blo.s   Spring_BounceDiagUp
        bra.s   Spring_AniDiagUp
;Spring_DiagFlipped:
;        addq.w  #4,d0
;        cmp.w   8(a1),d0
;        blo.s   Spring_AniDiagUp

; ===========================================================================

Spring_BounceDiagUp:
        move.w  #$500,obAnim(a0)
        move.w  spring_pow(a0),obVelX(a1)
        move.w  spring_pow(a0),obVelY(a1)
        addq.w  #6,obX(a1)
        addq.w  #6,obY(a1)
        bset    #0,obStatus(a1)
        btst    #0,obStatus(a0)
        bne.s   Spring_BDUFlipped
        bclr    #0,obStatus(a1)
        subi.w  #6*2,obX(a1)
        neg.w   obVelX(a1)
    Spring_BDUFlipped:
        bset    #1,obStatus(a1)
        bclr    #3,obStatus(a1)
;        bset    #4,$22(a1)
;        clr.w   $3A(a1)
;		clr.b   $2B(a1)
;		clr.w   $2C(a1)		
        move.b  #2,obRoutine(a1)
        bclr    #3,obStatus(a0)
        move.b	#$10,obAnim(a1)
        clr.b   obSolid(a0)
        move.w  #sfx_Spring,d0
        jsr (PlaySound_Special).l ; play spring sound
Spring_AniDiagUp:
        lea (Ani_Spring).l,a1
        bra.w   AnimateSprite
		
; ===========================================================================		

Spring_SlopeData_DiagDwn:
    dc.b -$C,-$10,-$10,-$10,-$10,-$10,-$10,-$10,-$10,-$10,-$10,-$10,-$E,-$C,-$A,-8
    dc.b -6,-4,-2,  0,  2,  4,  4,  4,  4,  4,  4,  4; 16
		
; ===========================================================================

Spring_DiagonallyDown:    ;  Routine $A
        move.w  #$1B,d1
        move.w  #$10,d2
        move.w  obX(a0),d4
        lea     Spring_SlopeData_DiagDwn(pc),a2
        jsr     (SolidObject2F).l
        cmpi.w  #-2,d4
        bne.s   Spring_AniDiagDwn

; ===========================================================================

Spring_BounceDiagDwn:
        move.w  #$500,obAnim(a0)
        move.w  $30(a0),obVelX(a1)
        move.w  $30(a0),obVelY(a1)
        neg.w   obVelY(a1)
        subq.w  #6,obY(a1)
        addq.w  #6,obX(a1)
        bset    #0,obStatus(a1)
        btst    #0,obStatus(a0)
        bne.s   Spring_BDDFlipped
        bclr    #0,obStatus(a1)
        subi.w  #6*2,obX(a1)
        neg.w   obVelX(a1)
    Spring_BDDFlipped:
        bset    #1,obStatus(a1)
        bclr    #3,obStatus(a1)
;        bset    #4,$22(a1)
;        clr.w   $3A(a1)
;		clr.b   $2B(a1)
;		clr.w   $2C(a1)		
        move.b  #2,obRoutine(a1)
        bclr    #3,obStatus(a0)
        move.b	#$10,obAnim(a1)
        clr.b   obSolid(a0)
        move.w  #sfx_Spring,d0
        jsr (PlaySound_Special).l ; play spring sound

Spring_AniDiagDwn:
        lea (Ani_Spring).l,a1
        bra.w   AnimateSprite

; ===========================================================================
		
Spring_Horizontal:	; Routine 8
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
;		cmpi.b	#2,obRoutine(a0)
;		bne.s	loc_DC0C
;		move.b	#8,obRoutine(a0)

loc_DC0C:
		btst	#5,obStatus(a0)
		beq.s Spring_AniLR
		move.b  obStatus(a0),d1
		move.w  obX(a0),d0
		sub.w   obX(a1),d0
		bcs.s   loc_18AD8
		eori.b  #1,d1

loc_18AD8:
		andi.b  #1,d1
		bne.s   Spring_AniLR
; ===========================================================================

Spring_BounceLR:
		move.w	#$300,obAnim(a0)
		move.w	spring_pow(a0),obVelX(a1) ; move Sonic to the left
		addq.w	#8,obX(a1)
		btst	#0,obStatus(a0)	; is object flipped?
		bne.s	Spring_Flipped	; if yes, branch
		subi.w	#$10,obX(a1)
		neg.w	obVelX(a1)	; move Sonic to	the right

	Spring_Flipped:
		move.w	#$F,$3E(a1)
		move.w	obVelX(a1),obInertia(a1)
		bchg	#0,obStatus(a1)
		btst	#2,obStatus(a1)
		bne.s	loc_DC56
		move.b	#id_Walk,obAnim(a1)	; use walking animation

loc_DC56:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
		move.w	#sfx_Spring,d0
		jsr	(PlaySound_Special).l	; play spring sound

Spring_AniLR:	; Routine $A
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Spring_ResetLR:	; Routine $C
		move.b	#2,obNextAni(a0) ; reset animation
		subq.b	#4,obRoutine(a0) ; goto "Spring_LR" routine
		rts	
; ===========================================================================

Spring_Down:	; Routine $E
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject

loc_DCA4:
		cmpi.w	#-2,d4
		bne.s	Spring_AniDwn

; ===========================================================================

Spring_BounceDwn:
		move.w	#$100,$1C(a0)
		subq.w	#8,obY(a1)
		move.w	spring_pow(a0),obVelY(a1)
		neg.w	obVelY(a1)	; move Sonic downwards
		tst.b   $28(a0) ; is bit 7 of subtype is set?
		bpl.s   Spring_DnNoClr   ; if not, branch
		clr.w   $10(a1) ; clear Sonic's X velocity
	Spring_DnNoClr:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	obSolid(a0)
		move.w	#sfx_Spring,d0
		jsr	(PlaySound_Special).l	; play spring sound

Spring_AniDwn:	; Routine $10
		lea	(Ani_Spring).l,a1
		bra.w	AnimateSprite
; ===========================================================================
