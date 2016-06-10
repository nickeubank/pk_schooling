clear
set more off
use $datadir/constructed/hh_panel/hh_panel_long, clear

keep if round==1

egen htag=tag(hhid)
egen mtag=tag(mauzaid)


* Bring in fractionalization


sort mauzaid
merge m:1 mauzaid using $pk/public_leaps_data/public_mauza

tab _m
keep if _m==3

drop _m


gen enrolled=child_in_school==1
bysort hhid: egen enrolledkid=max(enrolled)
keep if enrolledkid==1


gen private=(child_school_type==3) if child_school_type~=2 & child_school_type~=.

bysort hhid: egen temp=mean(private)
gen split=(temp~=1 & temp~=0)

tab split enrolledkid

svyset [pw=hh_weight]
svy:mean split if htag==1 

reg split mauza_zaat_frac i.district  if htag==1 [pw=hh_weight], cluster(mauzaid)

qqq

*keep if split==1

gen inter=mauza_zaat_frac*child_intelligent
areg private child_intelligent inter, a(mauzaid) cluster(mauzaid)



