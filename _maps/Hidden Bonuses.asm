; ---------------------------------------------------------------------------
; Sprite mappings - hidden points at the end of	a level
; ---------------------------------------------------------------------------
Map_Bonus_internal:
		dc.w .blank-Map_Bonus_internal
		dc.w .Type10000-Map_Bonus_internal
		dc.w .Type1000-Map_Bonus_internal
		dc.w .Type100-Map_Bonus_internal
.blank:		dc.b 0
.Type10000:		dc.b 1
		dc.b $F4, $E, 0, 0, $F0
.Type1000:		dc.b 1
		dc.b $F4, $E, 0, $C, $F0
.Type100:		dc.b 1
		dc.b $F4, $E, 0, $18, $F0
		even