
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

	tab mauzaid, gen(_ma)
	tab child_class, gen(class_)
	forvalues x=1/8 {
		label var class_`x' "Class `x' Dummy"
	}

	label var mauza_gini_land "Village Land Gini"
	label var mauza_literacy "Village: Pct Adults Literate"
	label var school_private "Private School"
	label var mauza_wealth "Median Village Expenditure"

* Get caste
preserve
use  $datadir/household/hhsurvey1/hhsurvey1_household, clear
keep hhid hm1_s0q8_zaat
sort hhid
tempfile caste
save `caste'
restore

drop _merge
drop if hhid==.
sort hhid
merge m:1 hhid using `caste'
assert _merge~=1
keep if _merge==3
drop _merge

	*************
	* Caste bins
	*************
	gen status=""
	replace status="High" if hm1_s0q8_zaat==1
	replace status="High" if hm1_s0q8_zaat==2
	replace status="Low" if hm1_s0q8_zaat==3
	replace status="High" if hm1_s0q8_zaat==4
	replace status="Low" if hm1_s0q8_zaat==5
	replace status="High" if hm1_s0q8_zaat==6
	replace status="High" if hm1_s0q8_zaat==8
	replace status="High" if hm1_s0q8_zaat==9
	replace status="Low" if hm1_s0q8_zaat==12
	replace status="Low" if hm1_s0q8_zaat==13
	replace status="High" if hm1_s0q8_zaat==15
	replace status="Low" if hm1_s0q8_zaat==16
	replace status="High" if hm1_s0q8_zaat==17
	replace status="Low" if hm1_s0q8_zaat==18
	replace status="High" if hm1_s0q8_zaat==20
	replace status="High" if hm1_s0q8_zaat==22
	replace status="Low" if hm1_s0q8_zaat==21


	gen status2=.
	replace status2=0 if status=="Low"
	replace status2=1 if status=="High"

	label var status2 "High Status Biraderi"

	
	* Status table
	qqq
	
		capture eststo clear

	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample

			eststo:	xi: reg child_`x'_theta status2 school_private  interact_zaat_private ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)

			eststo: xi: reg child_`x'_theta status2 school_private  interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)


				eststo: xi: reg child_`x'_theta status2 school_private mauza_zaat_frac interact_zaat_private  ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


}


		esttab  using $datadir/constructed/ethnic_info/docs/regressions/status.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Social Status and Residual Talent\label{castesarentdumb}) ///
			 drop( "o.*" "child_age" "child_age2" "child_female" "class_*") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01) ///
			note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)


qqq
