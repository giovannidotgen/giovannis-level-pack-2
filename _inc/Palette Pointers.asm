; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

PalPointers:

	dc.l Pal_SegaBG		; pallet address
	dc.w $FB00		; RAM address
	dc.w $1F		; (pallet length / 2) - 1
	dc.l Pal_Title
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LevelSel
	dc.w $FB00
	dc.w $1F
	dc.l Pal_Sonic
	dc.w $FB00
	dc.w 7
	dc.l Pal_GHZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_MZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SLZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SYZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SBZ1
	dc.w $FB20
	dc.w $17
	dc.l Pal_Special
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LZWater
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ3
	dc.w $FB20
	dc.w $17
	dc.l Pal_SBZ3Water
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ2
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZSonWater
	dc.w $FB00
	dc.w 7
	dc.l Pal_SBZ3SonWat
	dc.w $FB00
	dc.w 7
	dc.l Pal_SSResult
	dc.w $FB00
	dc.w $1F
	dc.l Pal_Continue
	dc.w $FB00
	dc.w $F
	dc.l Pal_Ending
	dc.w $FB00
	dc.w $1F


palid_SegaBG:		equ 0
palid_Title:		equ 1
palid_LevelSel:		equ 2
palid_Sonic:		equ 3
palid_GHZ:		equ 4
palid_LZ:		equ 5
palid_MZ:		equ 6
palid_SLZ:		equ 7
palid_SYZ:		equ 8
palid_SBZ1:		equ 9
palid_Special:		equ $A
palid_LZWater:		equ $B
palid_SBZ3:		equ $C
palid_SBZ3Water:	equ $D
palid_SBZ2:		equ $E
palid_LZSonWater:	equ $F
palid_SBZ3SonWat:	equ $10
palid_SSResult:		equ $11
palid_Continue:		equ $12
palid_Ending:		equ $13
