; ---------------------------------------------------------------------------
; Animation script - shield and invincibility stars
; ---------------------------------------------------------------------------
Ani_Shield:	dc.w .shield-Ani_Shield
		dc.w .stars1-Ani_Shield
		dc.w .stars2-Ani_Shield
		dc.w .stars3-Ani_Shield
		dc.w .stars4-Ani_Shield
.shield:	dc.b 1,	1, 0, 2, 0, 3, 0, afEnd
.stars1:	dc.b 5,	1, 2, 3, 4, afEnd
.stars2:	dc.b 0,	1, 1, 0, 1, 1, 0, 2, 2,	0, 2, 2, 0, 3, 3, 0, 3
		dc.b 3,	0, 4, 4, 0, 4, 4, 0, afEnd
.stars3:	dc.b 0,	1, 1, 0, 1, 0, 0, 2, 2,	0, 2, 0, 0, 3, 3, 0, 3
		dc.b 0,	0, 4, 4, 0, 4, 0, 0, afEnd
.stars4:	dc.b 0,	1, 0, 0, 1, 0, 0, 2, 0,	0, 2, 0, 0, 3, 0, 0, 3
		dc.b 0,	0, 4, 0, 0, 4, 0, 0, afEnd
		even