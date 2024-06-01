DPLC_cfa1: mappingsTable
	mappingsTableEntry.w	DPLC_cfa1_0
	mappingsTableEntry.w	DPLC_cfa1_1
	mappingsTableEntry.w	DPLC_cfa1_2
	mappingsTableEntry.w	DPLC_cfa1_3

DPLC_cfa1_0:	dplcHeader
 dplcEntry $C, 0
DPLC_cfa1_0_End

DPLC_cfa1_1:	dplcHeader
 dplcEntry $B, $C
DPLC_cfa1_1_End

DPLC_cfa1_2:	dplcHeader
 dplcEntry 8, $17
DPLC_cfa1_2_End

DPLC_cfa1_3:	dplcHeader
 dplcEntry $C, $1F
DPLC_cfa1_3_End

	even