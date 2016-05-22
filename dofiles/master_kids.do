clear
set more off

* *********
* Now do children level...
* *********

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

	tab mauzaid, gen(_ma)
	tab child_class, gen(class_)
	forvalues x=1/8 {
		label var class_`x' "Class `x' Dummy"
	}

	label var mauza_gini_land "Village Land Gini"
	label var mauza_literacy "Village: Pct Adults Literate"
	label var school_private "Private School"
	label var mauza_wealth "Median Village Expenditure"
	

gen filler=1

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
				graph save $datadir/constructed/ethnic_info/docs/graphs/kids_`x'.gph, replace




				eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private  ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

					interact_scores mauza_zaat_frac "`x'" "`upper_x'"
					graph save $datadir/constructed/ethnic_info/docs/graphs/kids_`x'_district.gph, replace



}


		esttab  using $datadir/constructed/ethnic_info/docs/regressions/children.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores\label{kids}) ///
			 drop( "o.*" "child_age" "child_age2" "child_female" "class_*") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01) ///
			note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)

graph combine ///
	$datadir/constructed/ethnic_info/docs/graphs/kids_english.gph ///
	 $datadir/constructed/ethnic_info/docs/graphs/kids_urdu.gph ///
	  $datadir/constructed/ethnic_info/docs/graphs/kids_math.gph, row(1) ///
	title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals) ///
	note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")
graph export $datadir/constructed/ethnic_info/docs/graphs/kids_combined.pdf, replace

graph combine ///
	$datadir/constructed/ethnic_info/docs/graphs/kids_english_district.gph ///
	 $datadir/constructed/ethnic_info/docs/graphs/kids_urdu_district.gph ///
	  $datadir/constructed/ethnic_info/docs/graphs/kids_math_district.gph, row(1) ///
	title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals) ///
	note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")
graph export $datadir/constructed/ethnic_info/docs/graphs/kids_combined_district.pdf, replace



* **********
* Drop coefficients on mauza
* *********

	eststo clear
	set more off
	gen filler2=1
	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample	

			eststo:	xi: reg child_`x'_theta school_private  mauza_zaat_frac ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid) 
			

			eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

				xi: reg child_`x'_theta filler filler2 mauza_zaat_frac school_private ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


				interact mauza_zaat_frac " " "`upper_x'"
				graph save $datadir/constructed/ethnic_info/docs/graphs/nointeract_`x'.gph, replace
}


		esttab  using $datadir/constructed/ethnic_info/docs/regressions/children_nointeract.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0   1  0  1   0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores and Fractionalization \label{kidsnointeract}) ///
			 drop( "o.*" "child_age" "child_age2" "child_female" "class_*") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01) ///
			note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)

			graph combine ///
				$datadir/constructed/ethnic_info/docs/graphs/nointeract_english.gph ///
				 $datadir/constructed/ethnic_info/docs/graphs/nointeract_urdu.gph ///
				  $datadir/constructed/ethnic_info/docs/graphs/nointeract_math.gph, row(1) ///
				title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals) ///
				note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")
			graph export $datadir/constructed/ethnic_info/docs/graphs/nointeraction_combined.pdf, replace






* ***********
* Quantiles
************

set more off
foreach x in english  {
	eststo clear

foreach z in 0 {

eststo:xi:	qreg child_`x'_theta   i.school_private*mauza_zaat_frac child_age child_age2 child_female child_pca child_parentedu i.child_class i.district mauza_wealth mauza_literacy ln_numhh lagged_english lagged_math lagged_urdu , q(10) 
eststo:xi:	qreg child_`x'_theta  i.school_private*mauza_zaat_frac child_age child_age2 child_female child_pca child_parentedu i.child_class i.district mauza_wealth mauza_literacy ln_numhh lagged_english lagged_math lagged_urdu , q(50) 
eststo:xi:	qreg child_`x'_theta i.school_private*mauza_zaat_frac child_age child_age2 child_female child_pca child_parentedu i.child_class i.district mauza_wealth mauza_literacy ln_numhh lagged_english lagged_math lagged_urdu , q(90) 

}


local proper=proper("`x'")


esttab  using $datadir/constructed/ethnic_info/docs/regressions/children_quantile_`x'.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("Government" "Private" , pattern(0 0 0   1 0  0   ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "10 Pct" "50 Pct" "90 Pct" "10 Pct" "50 Pct" "90 Pct" ) title(Child `proper' Test Score Quantile Regressions\label{kidsquants`x'}) ///
	 drop( "child_age" "child_age2" "child_female" "_Ic*") ///
	 substitute({table} {sidewaystable})  ///
	indicate( "District Fixed Effects=_Id*") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)

}



