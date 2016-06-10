clear
set more off


* Get average school scores
use $datadir/constructed/school_panel/school_panel_long, clear

keep if round==1|round==4
drop if child_math_theta==. & child_english_theta==.
renvars child_*_theta, presub("child_" "schoolavg_")
keep mauzaid round schoolid schoolavg* reportcard mauza_numschools_pri mauza_numschools_gov
drop if mauzaid>200
egen id=group(round mauzaid)

* kdensity schoolavg_math if round==1

foreach x in math urdu english  {
	xtile2 squal_`x'_overall=schoolavg_`x', n(5) by(round)
	label var squal_`x'_overall "5-fold ranking across all mauzas, own round"
	xtile2 squal_`x'=schoolavg_`x', n(5) by(id)
	label var squal_`x' "5-fold ranking across own mauza and round"
}


drop if mauza_numschools_gov+mauza_numschools_private<=3

tempfile school
duplicates report mauzaid schoolid round

sort mauzaid schoolid round 
save `school'

* Get household perceptions
	
	* Year 1
	use $datadir/household/hhsurvey1/hhsurvey1_school, clear
	keep hf1_s14q8_*  hm1_s8q8_* mauzaid schoolid1 hhid
	renvars hf1_s14q8_*, presub("hf1_s14q8_" "female_")
	renvars hm1_s8q8_*, presub("hm1_s8q8_" "male_")
	renvars male_*, postfix(1)
	renvars female_*, postfix(1)
	rename schoolid1 schoolid
	sort hhid mauzaid schoolid
	tempfile year1
	save `year1'
	
	* Year 4
	use $datadir/household/hhsurvey4/hhsurvey4_school, clear
	keep hf4_s14q10_*  hm4_s8q10_* mauzaid schoolid4 hhid
	renvars hf4_s14q10_*, presub("hf4_s14q10_" "female_")
	renvars hm4_s8q10_*, presub("hm4_s8q10_" "male_")
	renvars male_*, postfix(4)
	renvars female_*, postfix(4)
	renvars *islamyat*, subst("islamyat" "religious")
	renvars *, subst("maths" "math")
	rename schoolid4 schoolid
	sort hhid mauzaid schoolid
	tempfile year4
	save `year4'

	merge hhid mauzaid schoolid using `year1'
	tab _m
	keep if _m==3
	drop _m
	egen id=group(hhid mauzaid schoolid)
	duplicates drop id, force 
		*  COME BACK AND FIX IF THINGS WORK!!!!!!!! **********************************
	reshape long female_english female_math female_religious female_overall male_english male_math male_religious male_overall, i(id) j(round)
	drop id
	
* 	recode female_* male_* (2=1) (3=2) (4=3) (5=3)
	
	sort mauzaid schoolid round
	merge m:1 mauzaid schoolid round using `school'

	tab reportcard
	
* 	recode squal* (2=1) (3=2) (4=3) (5=3)

	
	tab _m
	* **** FIX LATER ***********************************************	
	keep if _m==3  

	drop _m
	
	* Get mauza frac
	sort mauzaid
	merge m:1 mauzaid using $pk/public_leaps_data/public_mauza
	assert _m~=1
	drop if _m==2
	drop _m

	renvars *_religious, postsub("_religious" "_urdu")


qqq

	foreach x in math english urdu {
		gen accuracy_male_`x'=.
		gen accuracy_female_`x'=.
		gen accuracy_male_`x'_overall=.
		gen accuracy_female_`x'_overall=.

		gen male_dontknow_`x'=(male_`x'==0) if male_`x'~=.
		gen female_dontknow_`x'=(male_`x'==0) if male_`x'~=.
	
		bysort hhid round: egen male_pct_dontknow_`x'=mean(male_dontknow_`x')
		bysort hhid round: egen female_pct_dontknow_`x'=mean(female_dontknow_`x')
	
	}
	
	egen male_pct_dontknow=rowmean(male_pct_dontknow_*)
	label var male_pct_dontknow "Pct of responses were dont know in round"
	egen female_pct_dontknow=rowmean(female_pct_dontknow_*)
	label var female_pct_dontknow "Pct of responses were dont know in round"
	
foreach x in math english urdu {

	levelsof hhid, local(houses)

	foreach round in 1 4 {
	foreach hh in  `houses' {
		foreach gender in female male {
			* Don't handicap if say don't know?
			replace `gender'_`x'=. if `gender'_`x'==0 
			capture corr `gender'_`x' squal_`x' if hhid==`hh' & round==`round'
				if("r(rho)"~=""){
					replace accuracy_`gender'_`x'=r(rho) if hhid==`hh' & round==`round'
				}

			replace `gender'_`x'=. if `gender'_`x'==0
			capture corr `gender'_`x' squal_`x'_overall if hhid==`hh' & round==`round'
				if("r(rho)"~=""){
					replace accuracy_`gender'_`x'_overall=r(rho) if hhid==`hh' & round==`round'
				}
				}
			}
		}
	
	}

egen hhtag=tag(hhid round)
keep if hhtag==1
tsset hhid round

rename mauza_zaat_frac mauzazaatfrac

renvars accuracy_* *dontknow_*, subst("_" "")


label var mauzazaatfrac "Village Fractionalization"

capture eststo clear
foreach x in english math urdu {
	eststo: xi:reg accuracyfemale`x' mauzazaatfrac i.district if round==1, cluster(mauzaid)
}

foreach x in english math urdu {
	eststo: xi:reg accuracymale`x' mauzazaatfrac i.district if round==1, cluster(mauzaid)
}

foreach x in english math urdu {
	eststo: xi:reg femalepctdontknow`x' mauzazaatfrac i.district if round==1, cluster(mauzaid)
}
foreach x in english math urdu {
	eststo: xi:reg malepctdontknow`x' mauzazaatfrac i.district if round==1, cluster(mauzaid)
}


esttab  using $pk/docs/regressions/perception_accuracy.tex, b(a2) replace nogaps compress label booktabs noconstant ///
 title(Parental Knowledge of School Quality\label{knowledge}) ///
	mgroups("Accuracy, Women" "Accuracy, Men" "Share of Schools Don't Know, Women" "Share of Schools Don't Know, Men" , pattern(0 0 0 1 0 0 1 0 0 1 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle("English" "Math" "Urdu" "English" "Math" "Urdu" "English" "Math" "Urdu" "English" "Math" "Urdu") ///
	indicate(District Fixed Effects =_I*) wrap ///
	substitute({table} {sidewaystable}) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	note("Accuracy is measured as correlation between 5-fold parental rating of schools and actual school ratings by average score.")


/*
foreach x in math urdu english {
	twoway(lpolyci  )(lpolyci accuracy_`x' mauza_zaat_frac if round==2 & mauza_zaat_frac>0.2 & report==0) , ///
	title("Control Group") xtitle("Mauza Zaat Fractionalization") ytitle("Correlation in 5 item") legend(label(2 "Round 1") label(3 "Round 2"))
	tempfile temp1
	graph save `temp1'.gph, replace
	
	twoway(lpolyci accuracy_`x' mauza_zaat_frac if round==1 & mauza_zaat_frac>0.2 & report==1)(lpolyci accuracy_`x' mauza_zaat_frac if round==2 & mauza_zaat_frac>0.2 & report==1) , ///
 title("Treatment Group") xtitle("Mauza Zaat Fractionalization") ytitle("Correlation in 5 item") legend(label(2 "Round 1") label(3 "Round 2"))
	tempfile temp2
	graph save `temp2'.gph, replace

	graph combine `temp1'.gph `temp2'.gph, 	title(Pre- and Post- Treatment School Quality Perception Accuracy) subtitle("In `x'") 


	graph export $datadir/constructed/ethnic_info/graphs/perceptions_`x'.pdf, replace
}


sum accuracy_math_o

gen change_math=D.accuracy_math
gen change_english=D.accuracy_english

gen change_math_o=D.accuracy_math_over
gen change_english_o=D.accuracy_english_over


sum change_math
sum change_english

ttest change_math, by(reportcard)
ttest change_math_o, by(reportcard)



