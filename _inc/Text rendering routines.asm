; ===========================================================================
; Subroutine that renders one line of text.
; Input:
; a6: VDP data
; d3: Character in VRAM
; d2: Characters in line
; ===========================================================================	
	
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

SingleLineRender:
		moveq	#0,d0				; Init d0
		move.b	(a1)+,d0			; Get character
		bpl.s	LineRender_NotBlank	; If not blank, render the character
		move.w	#0,(a6)				; Render a null tile
		dbf	d2,SingleLineRender		; Repeat
		rts	
; ===========================================================================

LineRender_NotBlank:				; XREF: SingleLineRender
        sub.w    #$21,d0        ; Subtract #$21 (replace with #$33 if you're using Sonic 2's font
        add.w    d3,d0        	; combine char with VRAM setting
        move.w   d0,(a6)        ; send to VRAM
        dbf      d2,SingleLineRender  
        rts
; End of function SingleLineRender

Art_S2Text:	incbin "artunc\Sonic 2 ASCII Text.bin"
	even