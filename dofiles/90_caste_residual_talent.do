
* ********************
* Want to look at year 1 to year 4 shifts to get full effects.
* First, let's just look at:
* ********************


* ************
* Now look at child changes from 1 to 4.
* ************
use $pk/constructed_data/custom_child_panel, replace



* Get caste
preserve
	use  $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_household, clear
	keep hhid hm1_s0q8_zaat
	sort hhid
	tempfile caste
	save `caste'
restore


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


		esttab  using $pk/docs/results/status.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Social Status and Residual Talent\label{castesarentdumb}) ///
			 drop(  "child_age" "child_age2" "child_female" "class_*") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01)


			*note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)
