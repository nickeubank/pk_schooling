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
* 	- Change in test scores -- village level effects and split by ethnic fractionalization
* 	- Change of schools
* 	- change in accuracy of parental perceptions
* 	- increased class diversity!
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


	* keep if child_panel==1 
	
	tsset childcode round




	* Make "change"
	rename child_pca_4years child_pca
	gen child_age2=child_age^2 
	label var child_age2 "Age Squared"
	label var child_pca "Child's Wealth Index"
	label var child_parentedu "Educated Parent"
	
	
	* ********
	* Enrollment by Frac
	* *********

	preserve
	keep if round==1
	bysort mauzaid: egen private_share=mean(school_private) if child_enrolled==1

	capture eststo clear
	label var mauza_zaat_frac "Village Fractionalization"
	egen matag=tag(mauzaid)
	eststo: xi:reg private_share mauza_zaat_frac i.district if matag==1
	esttab  using $pk/docs/regressions/private_share.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	 title("Share of Enrolled Students in Private Schools"\label{privateshare}) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) 
	restore


		* ********
		* Wealth and Enrollment Decision
		* *********

		preserve

		twoway(kdensity child_pca if school_private==1)(kdensity child_pca if school_private==0), ///
			title(Child Wealth Distributions) subtitle(By School Type) ///
			legend(label(1 "Private School Students") label(2 "Government School Students")) ///
			ytitle(Density) xtitle(Wealth PCA Scores (sd=1))

		graph export $pk/docs/graphs/wealth_and_type.pdf, replace
	
		restore



* ********
* Private Premium
* ********
	gen interact_zaat_private=school_private*mauza_zaat_frac
	label var interact_zaat_private "Zaat-Private Interaction"	
	label var mauza_zaat_frac "Village Fractionalization"
	label var school_private "Private School"


preserve
	keep if (round==1 & child_panel==1)|(round==3 & child_panel==2 & reportcard==0)




bysort mauzaid: egen temp_p=mean(child_english_theta) if school_private==1
bysort mauzaid: egen private=max(temp_p) 

bysort mauzaid: egen temp_g=mean(child_english_theta) if school_private==0
bysort mauzaid: egen gov=max(temp_g) 

gen gap=private-gov

twoway(scatter gap mauza_zaat_frac)(lfit gap mauza_zaat_frac )



xi: reg child_english_theta  i.mauza_wealthcat mauza_literacy mauza_numhh mauza_penrolled  i.district 
predict residuals, resid

xi: reg child_english_theta child_age child_age2 child_parentedu child_pca i.mauza_wealthcat mauza_literacy mauza_numhh mauza_penrolled  i.district if school_private==0
predict residuals_g, resid


twoway(lpoly residuals mauza_zaat_frac if school_private==1, deg(1))(lpoly residuals mauza_zaat_frac if school_private==0, deg(1))

capture drop residuals 

restore

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
	eststo:	xi: reg child_`x'_theta school_private  interact_zaat_private ///
		child_female child_age child_age2  i.mauzaid ///
		, cluster(mauzaid) 

		xi: areg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
			child_female child_age child_age2   ///
			, cluster(mauzaid)  a(mauzaid)
			

		interact_scores mauza_zaat_frac "Private Premium" "Basic Controls"
		graph save $pk/docs/graphs/privatepremium_g3_bigsample_`x'.gph, replace

		* Do twice -- once for interact
	eststo:	xi: reg child_`x'_theta school_private interact_zaat_private ///
		child_female child_age child_age2 child_pca child_parentedu i.mauzaid ///
		, cluster(mauzaid) 

	xi: areg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
			child_female child_age child_age2 child_pca child_parentedu  ///
			, cluster(mauzaid)  a(mauzaid)

		interact_scores mauza_zaat_frac "Private Premium" "Extensive Controls"
		graph save $pk/docs/graphs/privatepremium_g3_smallsample_`x'.gph, replace

		graph combine ///
			$pk/docs/graphs/privatepremium_g3_bigsample_`x'.gph $pk/docs/graphs/privatepremium_g3_smallsample_`x'.gph , ///
			title(Class 3 Private School Premium in `upper_x') subtitle(By Village Fractionalization) note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/privatepremium_`x'_crosssection.pdf, replace


	}

restore


esttab  using $pk/docs/regressions/privatepremium_crossection.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("English" "Urdu" "Math" , pattern(0 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle("" "" "" "" "" "" ) indicate(Village Fixed Effects=_Im*) ///
	title("Class 3 Cross-Sectional Private School Premium\label{crosssection}") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 

	

	* ***********
	* Now in class 4 with lagged scores
	* ***********

	preserve


		* Only year 2 panel 1 and year 4 panel 2, reportcard==0. 
		keep if  child_surveypanel==1  &( (child_panel==1 & round<=2)|child_panel==2)

		capture eststo clear 

	foreach x in english urdu math {

local upper_x=proper("`x'")

		* Do twice with no lag (for control) -- one for interact, one for outreg. 
		eststo:	xi: reg child_`x'_theta L.school_private L.interact_zaat_private ///
			child_female  child_age child_age2 i.mauzaid  ///
		if L.child_`x'_theta~=., cluster(mauzaid)		

		xi: areg child_`x'_theta L.school_private L.mauza_zaat_frac L.interact_zaat_private ///
				child_female  child_age child_age2  child_pca child_parentedu ///
				if L.child_`x'_theta~=., cluster(mauzaid) a(mauzaid)

				interact_scores mauza_zaat_frac "Private Premium" "No Lagged Scores"
			graph save $pk/docs/graphs/twoyear_nolag_`x'.gph, replace


		* Do twice with lag, big sample. Once for interact, one for outreg. 
		eststo:	xi: reg child_`x'_theta L.school_private L.interact_zaat_private ///
			child_female  child_age child_age2 i.mauzaid ///
			L.child_`x'_theta , cluster(mauzaid) 

		xi: areg child_`x'_theta L.school_private L.mauza_zaat_frac L.interact_zaat_private ///
			child_female  child_age child_age2  ///
			L.child_`x'_theta , cluster(mauzaid) a(mauzaid)

			interact_scores mauza_zaat_frac "Private Premium" "Lagged Scores, Basic Controls"
			graph save $pk/docs/graphs/twoyear_big_`x'.gph, replace

			* Do twice with lag, small sample. Once for interact, one for outreg. 

		eststo:	xi: reg child_`x'_theta L.school_private L.interact_zaat_private ///
			child_female  child_age child_age2  child_pca child_parentedu i.mauzaid ///
			L.child_`x'_theta , cluster(mauzaid)


		xi: areg child_`x'_theta L.school_private L.mauza_zaat_frac L.interact_zaat_private ///
		child_female  child_age child_age2  child_pca child_parentedu  ///
		L.child_`x'_theta , cluster(mauzaid) a(mauzaid)

		interact_scores mauza_zaat_frac "Private Premium" "Lagged Scores, Extensive Controls"
		graph save $pk/docs/graphs/twoyear_small_`x'.gph, replace



		graph combine ///
			$pk/docs/graphs/twoyear_nolag_`x'.gph  $pk/docs/graphs/twoyear_big_`x'.gph ///
			  $pk/docs/graphs/twoyear_small_`x'.gph, row(1) ///
			title(Class 4 Private School Premium in `upper_x') ///
			subtitle(By Village Fractionalization) ///
			note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/twoyear_`x'.pdf, replace


	}

		esttab  using $pk/docs/regressions/twoyear.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0 1 0 0 1 0 0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Scores at Class 4\label{wlags}) ///
			nonumber substitute({table} {sidewaystable})  ///
			indicate(Village Fixed Effects=_Ima*) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) 



restore


	* ***********
	* Now in class 4 with lagged scores, report card interaction
	* ***********

	preserve


		* Only year 2 panel 1 and year 4 panel 2, reportcard==0. 
		keep if child_surveypanel==1  &( (child_panel==1 & round<=2)|child_panel==2)

		capture eststo clear 

		gen interact=reportcard*mauza_zaat_frac
		

	foreach x in english urdu math {

local upper_x=proper("`x'")

sort childcode round

		xi: areg child_`x'_theta L.school_private reportcard mauza_zaat_frac  interact ///
				child_female  child_age child_age2  child_pca child_parentedu ///
				if L.child_`x'_theta~=., cluster(mauzaid) a(district)

			*	interact_scores mauza_zaat_frac "Private Premium" "No Lagged Scores"
			* graph save $pk/docs/graphs/twoyear_nolag_`x'.gph, replace


		* Do twice with lag, big sample. Once for interact, one for outreg. 

		xi: areg child_`x'_theta L.school_private reportcard mauza_zaat_frac interact ///
			child_female  child_age child_age2  ///
			L.child_`x'_theta , cluster(mauzaid) a(district)

			* interact_scores mauza_zaat_frac "Private Premium" "Lagged Scores, Basic Controls"
			* graph save $pk/docs/graphs/twoyear_big_`x'.gph, replace

			* Do twice with lag, small sample. Once for interact, one for outreg. 



		xi: areg child_`x'_theta L.school_private reportcard mauza_zaat_frac  interact ///
		child_female  child_age child_age2  child_pca child_parentedu  ///
		L.child_`x'_theta , cluster(mauzaid) a(district)





	}

restore




/*
* What's driving?!
preserve
keep if (round==1 & child_panel==1)|(round==3 & child_panel==2 & reportcard==0)

capture eststo clear
foreach x in urdu english math {
eststo:	xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
	child_female child_age child_age2 mauza_wealth mauza_literacy mauza_gini_expend i.district ///
	, cluster(mauzaid) 
}

restore




preserve
keep if reportcard==0  & child_surveypanel==1  &( (child_panel==1 & round<=2)|child_panel==2)

capture eststo clear
foreach x in urdu english math {
eststo:	xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
	child_female child_age child_age2 mauza_wealth mauza_literacy mauza_gini_expend i.district L.child_`x'_theta ///
	, cluster(mauzaid) 
}


restore

esttab  using $pk/docs/regressions/separate_drivers.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	indicate(District Dummies=_Idis*) title("Separating Drivers") ///
	mtitle("Urdu" "English" "Math") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 
restore
*/









* *******
* Wealth and school choice?
* *******
gen frac_wealth=child_pca*mauza_zaat_frac
gen zfrac=(mauza_zaat_frac>0.6)
xi: reg school_private frac_wealth child_pca child_parentedu i.district, cluster(mauzaid)
interact_scores child_pca school_private "Results"

rename child_schoolid schoolid
drop _m
sort mauzaid schoolid
merge m:1 mauzaid schoolid using $datadir/constructed/ethnic_info/raw/school_segregation
tab _m
keep if _m==3

* Now do with segregation -- is there a segregation-score tradeoff?

foreach x in english math urdu {
	xi: areg child_`x'_theta intraschool_frac ///
		if child_class==4 & round==2 & school_private==1 ///
		, cluster(mauzaid) a(mauzaid)

xi: areg child_`x'_theta child_female child_age child_age2 child_pca child_parentedu intraschool_frac ///
		if child_class==4 & round==2 & school_private==1 ///
		, cluster(mauzaid) a(mauzaid)
}



keep if reportcard==0  & child_surveypanel==1 
keep if (child_panel==1 & (round==1|round==2))| (child_panel==2 & (round==3|round==4))

xi: areg child_math_theta school_private interact_zaat_private child_female  child_age child_age2  child_pca child_parentedu if L.child_math_theta~=., cluster(mauzaid) a(mauzaid)


*/


	* Get best cross-sectional panel: panel 1 round 1, and panel 2 year 3 not report card. 
discard
preserve
	keep if (round==1 & child_panel==1)|(round==3 & child_panel==2)
	

	capture eststo clear

		foreach x in   english  urdu math    {
	
			local upper_x=proper("`x'")
	
	
	* Do twice
	eststo:	xi: reg child_`x'_theta school_private  interact_zaat_private ///
		child_female child_age child_age2  i.mauzaid ///
		, cluster(mauzaid) 

		xi: areg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
			child_female child_age child_age2   ///
			, cluster(mauzaid)  a(mauzaid)
			

		interact_scores mauza_zaat_frac "Private Premium" "Basic Controls"
		graph save $pk/docs/graphs/privatepremium_g3_bigsample_`x'.gph, replace

		* Do twice -- once for interact
	eststo:	xi: reg child_`x'_theta school_private interact_zaat_private ///
		child_female child_age child_age2 child_pca child_parentedu i.mauzaid ///
		, cluster(mauzaid) 

	xi: areg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private ///
			child_female child_age child_age2 child_pca child_parentedu  ///
			, cluster(mauzaid)  a(mauzaid)

		interact_scores mauza_zaat_frac "Private Premium" "Extensive Controls"
		graph save $pk/docs/graphs/privatepremium_g3_smallsample_`x'.gph, replace

		graph combine ///
			$pk/docs/graphs/privatepremium_g3_bigsample_`x'.gph $pk/docs/graphs/privatepremium_g3_smallsample_`x'.gph , ///
			title(Class 3 Private School Premium in `upper_x') subtitle(By Village Fractionalization) note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/privatepremium_`x'_crosssection.pdf, replace


	}



