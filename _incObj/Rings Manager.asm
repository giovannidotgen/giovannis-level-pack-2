RingsManager:
	moveq	#0,d0
	move.b	(Rings_manager_routine).w,d0
	move.w	RingsManager_States(pc,d0.w),d0
	jmp	RingsManager_States(pc,d0.w)
; ===========================================================================
; off_16F96:
RingsManager_States:
	dc.w RingsManager_Init-RingsManager_States
	dc.w RingsManager_Main-RingsManager_States
; ===========================================================================
; loc_16F9A:
RingsManager_Init:
	addq.b	#2,(Rings_manager_routine).w ; => RingsManager_Main
	bsr.w	RingsManager_Setup
	movea.l	(Ring_start_addr_ROM).w,a1
	lea	(Ring_Positions).w,a2
	move.w	($FFFFF700).w,d4
	subq.w	#8,d4
	bhi.s	loc_16FB6
	moveq	#1,d4
	bra.s	loc_16FB6
; ===========================================================================

loc_16FB2:
	addq.w	#4,a1
	addq.w	#2,a2

loc_16FB6:
	cmp.w	(a1),d4
	bhi.s	loc_16FB2
	move.l	a1,(Ring_start_addr_ROM).w
	move.w	a2,(Ring_start_addr_RAM).w
	addi.w	#$150,d4
	bra.s	loc_16FCE
; ===========================================================================

loc_16FCA:
	addq.w	#4,a1

loc_16FCE:
	cmp.w	(a1),d4
	bhi.s	loc_16FCA
	move.l	a1,(Ring_end_addr_ROM).w
	rts
; ===========================================================================
; loc_16FDE:
RingsManager_Main:
	lea	(Ring_consumption_table).w,a2
	move.w	(a2)+,d1
	subq.w	#1,d1
	bcs.s	loc_17014

loc_16FE8:
	move.w	(a2)+,d0
	beq.s	loc_16FE8
	movea.w	d0,a1
	subq.b	#1,(a1)
	bne.s	loc_17010
	move.b	#6,(a1)
	addq.b	#1,1(a1)
	cmpi.b	#8,1(a1)
	bne.s	loc_17010
	move.w	#-1,(a1)
	move.w	#0,-2(a2)
	subq.w	#1,(Ring_consumption_table).w

loc_17010:
	dbf	d1,loc_16FE8

loc_17014:
	movea.l	(Ring_start_addr_ROM).w,a1
	movea.w	(Ring_start_addr_RAM).w,a2
	move.w	($FFFFF700).w,d4
	subq.w	#8,d4
	bhi.s	loc_17028
	moveq	#1,d4
	bra.s	loc_17028
; ===========================================================================

loc_17024:
	addq.w	#4,a1
	addq.w	#2,a2

loc_17028:
	cmp.w	(a1),d4
	bhi.s	loc_17024
	bra.s	loc_17032
; ===========================================================================

loc_17030:
	subq.w	#4,a1
	subq.w	#2,a2

loc_17032:
	cmp.w	-4(a1),d4
	bls.s	loc_17030
	move.l	a1,(Ring_start_addr_ROM).w
	move.w	a2,(Ring_start_addr_RAM).w
	movea.l	(Ring_end_addr_ROM).w,a2
	addi.w	#$150,d4
	bra.s	loc_1704A
; ===========================================================================

loc_17046:
	addq.w	#4,a2

loc_1704A:
	cmp.w	(a2),d4
	bhi.s	loc_17046
	bra.s	loc_17054
; ===========================================================================

loc_17052:
	subq.w	#4,a2

loc_17054:
	cmp.w	-4(a2),d4
	bls.s	loc_17052
	move.l	a2,(Ring_end_addr_ROM).w
	rts

; ===========================================================================

Touch_Rings:
	movea.l	(Ring_start_addr_ROM).w,a1
	movea.l	(Ring_end_addr_ROM).w,a2

loc_170D0:
	cmpa.l	a1,a2
	beq.w	return_17166
	movea.w	(Ring_start_addr_RAM).w,a4
	cmpi.w	#$5A,$30(a0)
	bcc.w	return_17166
	tst.b	($FFFFFE2C).w	; does Sonic have a lightning shield?
	beq.s	Touch_Rings_NoAttraction	; if not, branch
	move.w	8(a0),d2
	move.w	$C(a0),d3
	subi.w	#$40,d2
	subi.w	#$40,d3
	move.w	#6,d1
	move.w	#$C,d6
	move.w	#$80,d4
	move.w	#$80,d5
	bra.s	loc_17112
; ===========================================================================
	
Touch_Rings_NoAttraction:
	move.w	8(a0),d2
	move.w	$C(a0),d3
	subi.w	#8,d2
	moveq	#0,d5
	move.b	$16(a0),d5
	subq.b	#3,d5
	sub.w	d5,d3
	cmpi.b	#$4D,4(a0)
	bne.s	RM1
	addi.w	#$C,d3
	moveq	#$A,d5
RM1:
	move.w	#6,d1
	move.w	#$C,d6
	move.w	#$10,d4
	add.w	d5,d5

loc_17112:
	tst.w	(a4)
	bne.w	loc_1715C
	move.w	(a1),d0
	sub.w	d1,d0
	sub.w	d2,d0
	bcc.s	loc_1712A
	add.w	d6,d0
	bcs.s	loc_17130
	bra.w	loc_1715C
; ===========================================================================

loc_1712A:
	cmp.w	d4,d0
	bhi.w	loc_1715C

loc_17130:
	move.w	2(a1),d0
	sub.w	d1,d0
	sub.w	d3,d0
	bcc.s	loc_17142
	add.w	d6,d0
	bcs.s	loc_17148
	bra.w	loc_1715C
; ===========================================================================

loc_17142:
	cmp.w	d5,d0
	bhi.w	loc_1715C

loc_17148:
	tst.b	($FFFFFE2C).w
	bne.s	AttractRing
	
loc_17148_cont:
	move.w	#$604,(a4)
	bsr.s	loc_17168
	lea	(Ring_consumption_table+2).w,a3

loc_17152:
	tst.w	(a3)+
	bne.s	loc_17152
	move.w	a4,-(a3)
	addq.w	#1,(Ring_consumption_table).w

loc_1715C:
	addq.w	#4,a1
	addq.w	#2,a4
	cmpa.l	a1,a2
	bne.w	loc_17112

return_17166:
	rts
; ===========================================================================

loc_17168:
	subq.w	#1,(Perfect_rings_left).w
	bra.w	CollectRing
; ===========================================================================

AttractRing:
	movea.l	a1,a3
	jsr	FindFreeObj
	bne.w	AttractRing_NoFreeSlot
	move.b	#7,(a1)
	move.w	(a3),8(a1)
	move.w	2(a3),$C(a1)
	move.w	a0,$34(a1)
	move.w	#-1,(a4)
	rts	
; ===========================================================================
	
AttractRing_NoFreeSlot:
	movea.l	a3,a1
	bra.s	loc_17148_cont
; ===========================================================================

BuildRings:
	movea.l	(Ring_start_addr_ROM).w,a0
	move.l	(Ring_end_addr_ROM).w,d7
	sub.l	a0,d7
	bne.s	loc_17186
	rts
; ===========================================================================

loc_17186:
	movea.w	(Ring_start_addr_RAM).w,a4
	lea	($FFFFF700).w,a3

loc_1718A:
	tst.w	(a4)+
	bmi.w	loc_171EC
	move.w	(a0),d3
	sub.w	(a3),d3
	addi.w	#$80,d3
	move.w	2(a0),d2
	sub.w	4(a3),d2
	andi.w	#$7FF,d2
	addi.w	#8,d2
	bmi.s	loc_171EC
	cmpi.w	#$F0,d2
	bge.s	loc_171EC
	addi.w	#$78,d2
	lea	(Map_Ring).l,a1
	moveq	#0,d1
	move.b	-1(a4),d1
	bne.s	loc_171C8
	move.b	($FFFFFEC3).w,d1

loc_171C8:
	add.w	d1,d1
	adda.w	(a1,d1.w),a1
	moveq	#$00,d1
	move.b	(a1)+,d1
	subq.b	#1,d1
	bmi.s	loc_171EC
	move.b	(a1)+,d0
	ext.w	d0
	add.w	d2,d0
	move.w	d0,(a2)+
	move.b	(a1)+,(a2)+
	addq.b	#1,d5
	move.b	d5,(a2)+
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	addi.w	#$27B2,d0
	move.w	d0,(a2)+
	move.b	(a1)+,d0
	ext.w	d0
	add.w	d3,d0
	move.w	d0,(a2)+

loc_171EC:
	addq.w	#4,a0
	subq.w	#4,d7
	bne.w	loc_1718A
	rts
; ===========================================================================

RingsManager_Setup:
	lea	(Ring_Positions).w,a1
	moveq	#0,d0
	move.w	#Rings_Space/4-1,d1

loc_172AE:				; CODE XREF: h+33Cj
	move.l	d0,(a1)+
	dbf	d1,loc_172AE

	; d0 = 0
	lea	(Ring_consumption_table).w,a1
	move.w	#$1F,d1
RMBack1:
	move.l	d0,(a1)+
	dbf	d1,RMBack1

	moveq	#0,d5
	moveq	#0,d0
	move.w	($FFFFFE10).w,d0
	lsl.b	#6,d0
	lsr.w	#4,d0
	lea	(RingPos_Index).l,a1
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1
	move.l	a1,(Ring_start_addr_ROM).w
	addq.w	#4,a1
	moveq	#0,d5
	move.w	#(Max_Rings-1),d0	
	
RMBack2:
	tst.l	(a1)+
	bmi.s	RM2
	addq.w	#1,d5
	dbf	d0,RMBack2
RM2:
	move.w	d5,(Perfect_rings_left).w
	rts