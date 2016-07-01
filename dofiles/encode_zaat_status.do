gen zaat_high_status = .

* High
foreach x in AARAIN ABBASI AWAAN BUTT GUJJAR JAT PATHAN RAJPUT SHEIKH SYED {
	replace zaat_high_status = 1 if `1' == "`x'"	
}

* Low
foreach x in ANSARI BALOCH MUGHAL "MUSLIM SHEIKH" QURESHI REHMANI SOLANGI {
	replace zaat_high_status = 0 if `1' == "`x'"	
}

foreach x of local zaat_levels {
	display "`x'"
	assert zaat_high_status != . if `1' == "`x'" & `1' != "OTHER"
}

label define zaat_high_status 1"High Status" 0"Low Status", modify
label values zaat_high_status zaat_high_status
label var zaat_high_status "High Status Zaat"


