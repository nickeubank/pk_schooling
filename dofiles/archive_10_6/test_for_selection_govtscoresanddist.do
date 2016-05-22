clear

clear
set more off
use $datadir/constructed/hh_panel/hh_panel_long, clear


drop if childcode==.


tsset childcode round

egen htag=tag(hhid)
egen mtag=tag(mauzaid)




* Bring in fractionalization

sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

tab _m
keep if _m==3
drop _m

* Now bring in "parent educ" from child panel
	preserve
	use $datadir/constructed/child_panel/child_panel_long, clear
	keep childcode round child_panel child_female child_class child_momfulledu child_dadfulledu child_momedu child_dadedu child_bmi school_private child_age
	sort childcode round 
	tempfile child
	save `child'
	restore
	
sort childcode 
merge 1:1 childcode round using `child'
tab _m
assert _m~=1
drop if _m==2
drop _m



*replace close_pri_primary=3 if close_pri_primary>3 & close_pri_primary~=.


sort childcode round


gen added_distance=close_pri_primary-close_govt_primary

sum added_distance, d
replace added_distance=. if added_distance>r(p90)|added_distance<r(p10)
* replace added_distance=added_distance^2

* Valid instrument?
sort childcode round
areg school_private added_distance ///
	i.district hh_pca_4years child_age  i.child_class /// 
	if school_private==0, cluster(mauzaid) a(mauzaid)


foreach x in english urdu math {
	sort childcode round
		areg child_`x'_theta added_distance ///
			i.district hh_pca_4years child_age  i.child_class /// 
			L.child_english_theta L.child_urdu_theta L.child_math_theta ///
			if school_private==0, cluster(mauzaid) a(mauzaid)
}

* Plot resids:
foreach x in english urdu math {
	sort childcode round

	reg child_`x'_theta ///
		 hh_pca_4years child_age  i.child_class /// 
		L.child_english_theta L.child_urdu_theta L.child_math_theta i.mauzaid ///
		if school_private==0, cluster(mauzaid) 
	
	
	predict newvar_`x' if e(sample), resid

	lowess newvar_`x' added_distance
	qqq

	
}







