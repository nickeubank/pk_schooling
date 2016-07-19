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

qqq

drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/public_leaps_data/public_mauza
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
	
	* **************
	* Cross-sectionally
	* **************


	* Get best cross-sectional panel: panel 1 round 1, and panel 2 year 3 not report card. 
discard
preserve
	keep if (round==1 & child_panel==1)|(round==3 & child_panel==2)
	

	capture eststo clear

	foreach x in   english  urdu math    {
	
			local upper_x=proper("`x'")
	
	
	* Do twice
	eststo:	xi: reg child_`x'_theta i.school_private*mauza_zaat_frac ///
		child_female child_age child_age2  i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land  ///
		, cluster(mauzaid) 
		interact_scores mauza_zaat_frac "`x'" "Basic Controls"
	graph save $pk/docs/graphs/g3_bigsample_`x'.gph, replace

		* Do twice -- once for interact
	eststo:	xi: reg child_`x'_theta i.school_private*mauza_zaat_frac ///
		child_female child_age child_age2 child_pca child_parentedu ///
		, cluster(mauzaid) 

	interact_scores mauza_zaat_frac "`x'" "Extensive Controls"
	graph save $pk/docs/graphs/g3_smallsample_`x'.gph, replace



		graph combine ///
			$pk/docs/graphs/g3_bigsample_`x'.gph $pk/docs/graphs/g3_smallsample_`x'.gph , ///
			title(Class 3 Private School Premium in `upper_x') subtitle(By Village Fractionalization) note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/crosssection_`x'.pdf, replace
	}

restore

/*
 esttab  using $pk/docs/regressions/privatepremium_crossection.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("English" "Urdu" "Math" , pattern(0 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle("" "" "" "" "" "" ) indicate(Village Fixed Effects=_Im*) ///
	title("Class 3 Cross-Sectional Private School Premium\label{crosssection}") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 
*/

	

	* ***********
	* Now in good panel with lagged scores
	* ***********

	preserve


		capture eststo clear 

	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample	
		eststo:	xi: reg child_`x'_theta school_private interact_zaat_private ///
			child_female  child_age child_age2  mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
			L.child_math_theta L.child_urdu_theta L.child_english_theta i.district, cluster(mauzaid) 

			interact_scores mauza_zaat_frac "`x'" "Lagged Scores, Basic Controls"
			graph save $pk/docs/graphs/twoyear_big_`x'.gph, replace
			
			* Do twice with lag, small sample. Once for interact, one for outreg. 

		xi: reg child_`x'_theta L.school_private mauza_zaat_frac L.interact_zaat_private  ///
		child_female  child_age child_age2  child_pca child_parentedu  ///
		i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
		L.child_math_theta L.child_urdu_theta L.child_english_theta , cluster(mauzaid)

		interact_scores mauza_zaat_frac "`x'" "Lagged Scores, Extensive Controls"
		graph save $pk/docs/graphs/twoyear_small_`x'.gph, replace



		graph combine ///
			$pk/docs/graphs/twoyear_nolag_`x'.gph  $pk/docs/graphs/twoyear_big_`x'.gph ///
			  $pk/docs/graphs/twoyear_small_`x'.gph, row(1) ///
			title(Class 4 Private School Premium in `upper_x') ///
			subtitle(By Village Fractionalization) ///
			note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/twoyear_`x'.pdf, replace


	}

/*
		esttab  using $pk/docs/regressions/twoyear.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0 1 0 0 1 0 0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Scores at Class 4\label{wlags}) ///
			nonumber substitute({table} {sidewaystable})  ///
			indicate(Village Fixed Effects=_Ima*) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) 
*/


restore


* ***************
* And now Overall scores -- improving weakly overall. 
* **************
preserve
keep if ///
	(round==1 & child_class==3) | ///
	(round==2 & child_class==4) | ///
	(round==3 & child_class==5 & child_panel==1) | ///
	(round==4 & child_class==6  & child_panel==1) | ///
	(round==3 & child_class==3 & child_panel==2) | ///
	(round==4 & child_class==4  & child_panel==2)

foreach x in english math urdu {

xi: reg child_`x'_theta mauza_zaat_frac i.school_private ///
	child_female  child_age child_age2 i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
	L.child_math_theta L.child_urdu_theta L.child_english_theta , cluster(mauzaid) 


* Do twice with lag, big sample. Once for interact, one for outreg. 
xi: reg child_`x'_theta mauza_zaat_frac  i.school_private ///
	child_female  child_age child_age2 i.district mauza_wealth mauza_numhh mauza_litcat mauza_gini_land ///
	L.child_math_theta L.child_urdu_theta L.child_english_theta , cluster(mauzaid) 
}
restore


