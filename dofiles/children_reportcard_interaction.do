clear
set more off

* *********
* Setup
* *********

clear
set more off


use $datadir/constructed/child_panel/child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
assert _m~=1
tab _m
keep if _m==3
count


	
	tsset childcode round


	* Make "change"
	rename child_pca_4years child_pca
	gen child_age2=child_age^2 
	label var child_age2 "Age Squared"
	label var child_pca "Child's Wealth Index"
	label var child_parentedu "Educated Parent"
	gen interact_zaat_private=mauza_zaat_frac*school_private
	





* ***********
* Analysis -- Children
* ***********



foreach x in english urdu math {

	local upper_x=proper("`x'")

	eststo:	xi: reg child_`x'_theta i.reportcard*mauza_zaat_frac i.school_private ///
		child_female  child_age child_age2 i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
	if L.child_`x'_theta~=. & school_private==1, cluster(mauzaid)		

	eststo:	xi: reg child_`x'_theta i.reportcard*mauza_zaat_frac i.school_private ///
		child_female  child_age child_age2 i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
	L.child_math_theta L.child_urdu_theta L.child_english_theta ///
	if school_private==1, cluster(mauzaid)		

	xi: reg child_`x'_theta i.reportcard*mauza_zaat_frac i.school_private ///
	child_female  child_age child_age2  child_pca child_parentedu  ///
	i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
	L.child_math_theta L.child_urdu_theta L.child_english_theta if school_private==1 , cluster(mauzaid)
}


