clear

	* Get settlement id

	use $datadir/household/hhcensus1/hhcensus_short.dta, clear
	duplicates drop hhid, force
	keep hhid setid
	tempfile setid
	sort hhid
	save `setid'



* Now into panel
use $datadir/constructed/hh_panel/hh_panel_long, clear

keep if round==1

keep mauzaid hhid hh_gps_*

	* get settlements
	sort hhid
	merge m:1 hhid using `setid'
	tab _m
	keep if _m==3
	drop _m



sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

tab _m
keep if _m==3
drop _m

egen stag=tag(mauzaid setid)

bysort mauzaid: egen num=sum(stag)

egen htag=tag(hhid)
egen mtag=tag(mauzaid)
tab num if mtag==1

reg num mauza_zaat_frac i.district if mtag==1
qqq

outsheet using $datadir/constructed/ethnic_info/gis/hhgps.csv, replace
