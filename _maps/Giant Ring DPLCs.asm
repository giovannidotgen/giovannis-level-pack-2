DPLC_e6e0: mappingsTable
	mappingsTableEntry.w	DPLC_e6e0_0
	mappingsTableEntry.w	DPLC_e6e0_1
	mappingsTableEntry.w	DPLC_e6e0_2
	mappingsTableEntry.w	DPLC_e6e0_3

DPLC_e6e0_0:	dplcHeader
 dplcEntry $10, 0
 dplcEntry $10, $10
 dplcEntry $C, $20
DPLC_e6e0_0_End

DPLC_e6e0_1:	dplcHeader
 dplcEntry $10, $2C
 dplcEntry $10, $3C
 dplcEntry 6, $4C
DPLC_e6e0_1_End

DPLC_e6e0_2:	dplcHeader
 dplcEntry $10, $52
DPLC_e6e0_2_End

DPLC_e6e0_3:	dplcHeader
 dplcEntry $10, $2C
 dplcEntry $10, $3C
 dplcEntry 6, $4C
DPLC_e6e0_3_End

	even