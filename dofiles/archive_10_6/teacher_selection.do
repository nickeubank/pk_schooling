clear


use $datadir/constructed/teacher_panel/teacher_panel_long, clear
rename roster_mauzaid mauzaid
drop if mauzaid==.
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
tab _m
keep if _m==3
drop _m

keep if round==3 & school_private==0

foreach x in local contract absent training education {
	tab roster_`x' zfrac3, col 	
}


* Some lower absenteeism. 
replace roster_absent=7 if roster_absent>7
reg roster_absent mauza_zaat_frac i.district , cluster(mauzaid)

gen temp_contract=(roster_contract~=1) if roster_contract~=.
reg temp_contract mauza_zaat_frac i.district , cluster(mauzaid)

gen female=(roster_gender==2) if roster_gender~=. & roster_gender~=99
reg female mauza_zaat_frac i.district , cluster(mauzaid)

reg roster_education mauza_zaat_frac i.district , cluster(mauzaid)

gen matric_or_less=(roster_education<=2) if roster_education~=.

reg matric_or_less mauza_zaat_frac i.district , cluster(mauzaid)

reg roster_local mauza_zaat_frac i.district , cluster(mauzaid)

reg roster_age mauza_zaat_frac i.district , cluster(mauzaid)
