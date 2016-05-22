
clear
set more off

* ********************
* Want to look at year 1 to year 4 shifts to get full effects. 
* First, let's just look at:
* ********************


* ************
* Now look at child changes from 1 to 4.
* ************

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

	quietly tab mauzaid, gen(_ma)
	quietly tab child_class, gen(class_)
	forvalues x=1/8 {
		label var class_`x' "Class `x' Dummy"
	}

	label var mauza_gini_land "Village Land Gini"
	label var mauza_literacy "Village: Pct Adults Literate"
	label var school_private "Private School"
	label var mauza_wealth "Median Village Expenditure"
	
	
	
keep if child_panel==1
drop if round==4

drop if child_dropout==1
drop if child_leftmauza==1
* keep if child_pca~=.


gen present=(child_english_theta~=.)
bysort childcode: egen always_present=min(present)
keep if always_present==1

gen switching=1 if school_private==1 & L.school_private==0
replace switching=-1 if school_private==0 & L.school_private==1
replace switching=0 if switching==.
egen tag=tag(childcode)
bysort childcode: egen ever=max(abs(switching))
tab ever if tag==1

egen schoolid=group(mauzaid child_schoolid)

mata: mata set matafavor speed
gen constant=1
xtset childcode round
local gmm "L.child_english_theta L.child_math_theta L.child_urdu_theta school_private"

xtabond2 child_english_theta `gmm' ,  iv( `gmm' , eq(diff) )  

gen interact=D.school_private*mauza_zaat_frac

reg D.child_math_theta D.L.child_english_theta D.L.child_math_theta D.L.child_urdu_theta D.school_private D.child_pca i.child_class interact, cluster(schoolid)

qqq
/*
L.child_urdu_theta L.child_math_theta school_private child_pca child_bmizscore child_motherhome child_fatherhome"
local exogenous "   class_*



/*
capture eststo clear 

	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample	

			eststo:	xi: reg child_`x'_theta school_private  interact_zaat_private ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid) 


			
			

			eststo: xi: reg child_`x'_theta school_private filler interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)
				interact mauza_zaat_frac " " "`upper_x'"
				graph save $pk/docs/graphs/kids_`x'.gph, replace


				eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private  ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


}
