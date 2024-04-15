; ---------------------------------------------------------------------------
; Sprite mappings - lamp (SYZ)
; ---------------------------------------------------------------------------
Map_Light_internal:
		dc.w .Type0-Map_Light_internal
		dc.w .Type1-Map_Light_internal
		dc.w .Type2-Map_Light_internal
		dc.w .Type3-Map_Light_internal
		dc.w .Type4-Map_Light_internal
		dc.w .Type5-Map_Light_internal
.Type0:		dc.b 2
		dc.b $F8, $C, 0, $31, $F0
		dc.b 0,	$C, $10, $31, $F0
.Type1:		dc.b 2
		dc.b $F8, $C, 0, $35, $F0
		dc.b 0,	$C, $10, $35, $F0
.Type2:		dc.b 2
		dc.b $F8, $C, 0, $39, $F0
		dc.b 0,	$C, $10, $39, $F0
.Type3:		dc.b 2
		dc.b $F8, $C, 0, $3D, $F0
		dc.b 0,	$C, $10, $3D, $F0
.Type4:		dc.b 2
		dc.b $F8, $C, 0, $41, $F0
		dc.b 0,	$C, $10, $41, $F0
.Type5:		dc.b 2
		dc.b $F8, $C, 0, $45, $F0
		dc.b 0,	$C, $10, $45, $F0
		even