use $datadir/constructed/child_panel/child_panel_long, clear

keep if (round==1 & child_panel==1)|(round==3 & child_panel==2)



* Get mauza vars
sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
tab _m
keep if _m==3
drop _m


qqq
