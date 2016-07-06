clear
set more off

* *********
* Now do children level...
* *********

clear
set more off

use $pk/public_leaps_data/panels/public_child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/public_leaps_data/public_mauza
assert _m~=1
tab _m
keep if _m==3
drop _m

* Get students' intra-school segregation
preserve
	use $pk/constructed_data/school_segregation, clear
	keep mauzaid schoolid intraschool_frac intraschool_frac_safer
	gen round = 2
	rename schoolid child_schoolid
	sort mauzaid child_schoolid round
	tempfile seg 
	save `seg'
restore

sort mauzaid child_schoolid round
merge m:1 mauzaid child_schoolid round using `seg'

* Two students without schools and 21 schools without students.
* later befuddling. Schools that refused testing??
* assert _m == 3 if round == 2 & child_schoolid != .
drop if _m == 2
drop _m 

*******
* make variables
*******

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






save $pk/constructed_data/custom_child_panel, replace

