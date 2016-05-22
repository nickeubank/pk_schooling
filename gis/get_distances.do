use $datadir/master/households, clear

keep hhid household_gps* mauzaid
sort mauzaid
tempfile hh
save `hh'

use $datadir/master/schools, clear
keep mauzaid schoolid school_private school_gps*
qqq

sort mauzaid hhid
merge mauzaid hhid using `panel'
tab _m
keep if _m==3
drop _m

keep hhid mauzaid setid s1q3 panel_settlement hh_gps_* 
rename s1q3 district

sort mauzaid setid
br mauzaid setid panel_settlement
replace setid=99 if setid==.

outsheet hhid mauzaid setid panel_settlement hh_gps_north hh_gps_east district using $datadir/constructed/ethnic_info/gis/hhgps.txt, replace 





