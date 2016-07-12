gen zaat_high_status = .


* Called in:
	* 15_make_hh_child_cross_section.do
	* 25_make_school_composition.do



* High
foreach x in AARAIN ABBASI AWAAN BUTT GUJJAR JAT PATHAN RAJPUT SHEIKH SYED {
	replace zaat_high_status = 1 if `1' == "`x'"	

}

* Low
foreach x in ANSARI BALOCH MUGHAL "MUSLIM SHEIKH" QURESHI REHMANI SOLANGI {
	replace zaat_high_status = 0 if `1' == "`x'"	
}

count if `1' != ""
local total = `r(N)'
count if zaat_high_status == . & `1' != ""
assert `r(N)' / `total' < 0.4


label define zaat_high_status 1"High Status" 0"Low Status", modify
label values zaat_high_status zaat_high_status
label var zaat_high_status "High Status Zaat"


