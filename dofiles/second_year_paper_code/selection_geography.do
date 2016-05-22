clear
set matsize 500
clear
set more off
use $datadir/constructed/hh_panel/hh_panel_long, clear
drop if childcode==.
tsset childcode round
egen htag=tag(hhid)
egen mtag=tag(mauzaid)



* Get expenditure
preserve
use $datadir/household/hhsurvey1/hhsurvey1_household, clear
keep hhid total_expend
sort hhid
tempfile expend
save `expend'
restore
sort hhid
merge m:1 hhid using `expend'
tab _m
keep if _m==3
drop _m

* Bring in fractionalization
sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

tab _m
keep if _m==3
drop _m

* Mauza vars
sort mauzaid
merge m:1 mauzaid using $datadir/constructed/xvars/mauza_xvars
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

sort childcode round


* Make some new variables

	* Expand distances to all household observations:
	bysort hhid: egen new_pri_dist=mean(close_pri_primary)
	bysort hhid: egen new_govt_dist=mean(close_govt_primary)

	bysort hhid: egen new_pri_dist_middle=mean(close_pri_middle)
	bysort hhid: egen new_govt_dist_middle=mean(close_govt_middle)


	replace new_pri_dist=new_pri_dist_middle if round==4 & child_class==6
	replace new_govt_dist=new_govt_dist_middle if round==4 & child_class==6
	
	gen added_distance=new_pri_dist-new_govt_dist
	sum added_distance, d
	
sort childcode round
* br child_english_theta childcode  round child_class close_* new_* added_distance if  close_govt_middle~= close_govt_primary & close_govt_middle~=. & child_english_theta~=.


	
* Get favorite sample:
gen year1=(child_english_theta~=.) if child_panel==1 & round==1
replace year1=(child_english_theta~=.) if child_panel==2 & round==3

bysort childcode: egen good=max(year1)
keep if good==1
drop if round==4 & child_panel==1

	
	* replace added_distance=. if added_distance>r(p90)|added_distance<r(p10)
	gen ln_expend=ln(total_expend)
	gen dist_frac_interact=mauza_zaat_frac*added_dist


* Valid instrument?


sort childcode round

gen lagged=L.child_english_theta

egen tag=tag(childcode) if lagged~=.
gen child_age2=child_age^2

	
drop if hh_gps_problem==1 & 	good_hh_match==1
sort childcode round





	* Make "change"
	label var child_age2 "Age Squared"
	
	foreach x in math urdu english {
		local name=proper("`x'")
		gen lagged_`x'=L.child_`x'_theta
		label var lagged_`x' "Lagged `name' Scores"
	}

	label var school_private "Private School"

	label var child_momedu "Mom Educated"
	label var child_dadedu "Dad Educated"

	label var new_pri_dist "Km to Nearest Private Sch"
	label var added_dist "Additional Km to Nearest Private"

* Test on english
sort childcode round

eststo clear
	
sort childcode round
eststo: xi: reg school_private added_distance new_pri_dist ln_expend child_age child_age2 child_momedu child_dadedu child_female i.mauzaid [pw=hh_weight] if round==1, cluster(mauzaid) 
	





* drop if round==4 & child_panel==1

gen interact=added_dist*mauza_zaat_frac

	label var ln_expend "Log HH Expenditures"
foreach x in english math urdu {

	eststo:	xi:reg child_`x'_theta added_dist interact mauza_zaat_frac new_pri_dist ///
			ln_expend child_age child_age2 child_momedu child_dadedu child_female i.child_class /// 
			 i.mauzaid lagged_* ///
			  [pw=hh_weight] if school_private==0 , cluster(mauzaid)  
}
qqq


foreach x in english math urdu {

	eststo:xi:reg child_`x'_theta added_dist    new_pri_dist ///
		ln_expend child_age child_age2 child_momedu child_dadedu   child_female i.child_class /// 
		lagged_*  i.mauzaid ///
		if school_private==1  [pw=hh_weight], cluster(mauzaid) 
}

esttab  using $pk/docs/regressions/distance_scores.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("Selection" "Government School" "Private School" , pattern(0 1 0 0 1 0 0 1    ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	 substitute({table} {sidewaystable})  ///
	mtitle( "Private School" "English" "Math" "Urdu" "English" "Math" "Urdu" ) title(Test Scores and Relative Distance of Schools\label{distancescores}) ///
	indicate(Village Fixed Effects=_Ima*) drop(_Ic* _Ich* o.*) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 

qqq

added_distance

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








