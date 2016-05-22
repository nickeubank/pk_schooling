use $datadir/constructed/hh_panel/hh_panel_long, clear

keep if round==1
egen htag=tag(hhid)
keep if htag==1
keep if hh_gps_problem==0
keep hhid mauzaid hh_settlementid hh_gps_* 

rename hh_settlementid panel_settlement
sort mauzaid hhid
tempfile panel
save `panel'

use $datadir/household/hhcensus1/hhcensus_short, clear
egen htag=tag(hhid)
keep if htag==1
drop htag

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





