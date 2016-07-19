clear


use $pk/leaps_data/child_panel_long.dta, clear

clear
set more off

* ********************
* Want to look at year 1 to year 4 shifts to get full effects.
* First, let's just look at:
* ********************


* ************
* Now look at child changes from 1 to 4.
* ************



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/leaps_data/hhcensus_clean
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
	label var interact_zaat_private "Fractionalization * Private"
	label var mauza_wealth "Median Village Expenditure"
	gen ln_numhh=ln(mauza_numhh)
	label var ln_numhh "Log Village Size"

	foreach x in math urdu english {
		local name=proper("`x'")
		gen lagged_`x'=L.child_`x'_theta
		label var lagged_`x' "Lagged `name' Scores"
	}

	label var school_private "Private School"

	tab mauzaid, gen(_ma)
	tab child_class, gen(class_)
	forvalues x=1/8 {
		label var class_`x' "Class `x' Dummy"
	}

	label var mauza_gini_land "Village Land Gini"
	label var mauza_literacy "Village: Pct Adults Literate"
	label var school_private "Private School"
	label var mauza_wealth "Median Village Expenditure"
