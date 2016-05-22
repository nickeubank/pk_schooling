clear
set more off

use $datadir/constructed/school_panel/school_panel_long, clear

sort mauzaid

merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

keep if _m==3
drop _m

keep if round==1

gen st_ratio=school_enrollment/teacher_number

foreach x in st_ratio school_enrollment school_facilities_basic school_facilities_extra teacher_absenteeism teacher_number  mauza_numhh {
	xi:reg `x' i.school_private*mauza_zaat_frac i.district , cluster(mauzaid)
	* interact mauza_zaat_frac "`x'" ""
}


