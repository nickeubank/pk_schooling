clear

use $datadir/constructed/teacher_panel/teacher_panel_long, clear
rename roster_mauzaid mauzaid
keep teachercode school_private mauzaid
drop if school_private==.|mauzaid==.
duplicates drop teachercode, force
sort teachercode
merge 1:1 teachercode using $datadir/constructed/ethnic_info/raw/valueadded
tab _m
keep if _m==3
drop _m

codebook mauzaid


sort mauzaid
merge m:1 mauzaid using $pk/public_leaps_data/public_mauza

tab _m
keep if _m==3

drop _m


sort mauzaid
merge m:1 mauzaid using $datadir/constructed/xvars/mauza_xvars

tab _m
keep if _m==3
drop _m

* Get report card
sort mauzaid 
merge m:1 mauzaid using $datadir/master/mauzas
assert _m~=1
tab _m

keep if _m==3
drop _m

* drop if reportcard==1

capture drop num_students

* Fix district

* Get number of kids
preserve
	use $datadir/constructed/child_panel/child_panel_long, clear


	egen oneobstag1=tag(childcode child_teachercode)
	bysort child_teachercode round: egen num_students1=sum(oneobstag1)


	egen oneobstag=tag(childcode child_teachercode round)
	bysort child_teachercode round: egen temp=sum(oneobstag)
	replace temp=. if temp==0
	
	egen tag=tag(child_teachercode round)
	keep if tag==1
	bysort child_teachercode: egen num_students=median(temp)
	egen tag2=tag(child_teachercode)
	keep if tag2==1
	
	drop num_students1


	
	keep child_teachercode num_students
	rename child_teachercode teachercode

	tempfile numkids
	sort teachercode
	save `numkids'
restore

sort teachercode 
merge 1:1 teachercode using `numkids'
tab _m
keep if _m==3
drop _m


gen ln_num=ln(num_students)

* replace mauza_zaat_frac=-ln(1-mauza_zaat_frac)

* preserve 
	gen schoolprivate=school_private
	gen mauzazaatfrac= mauza_zaat_frac 
	gen Mwealth=M_wealth 
	gen numstudents=num_students

	gen dist2=(district==2) if district~=.
	gen dist3=(district==3) if district~=.

	gen interactprivfrac=schoolprivate*mauzazaatfrac
	label var interactprivfrac "Private School * Village Fractionalization"
	label var mauzazaatfrac "Village Fractionalization"

	set more off
	capture eststo clear
	foreach x in  english math urdu{
		xi: reg valueadded_`x'  mauzazaatfrac schoolprivate interactprivfrac  Mwealth dist2 dist3 i.M_litcat M_wealth_alt M_frac_land M_numhh [pw=numstudents], cluster(mauzaid) 
		predict pvalue_`x'
		interact_scores mauzazaatfrac "Private Premium" "Lagged Scores, Basic Controls"

		}
qqq

/*
	esttab  using $pk/docs/regressions/valueadded_frac.tex, b(a2) replace nogaps compress label booktabs noconstant ///
		mgroups("English" "Math" "Urdu" , pattern(0 0 1 0 1 0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
		mtitle("District FEs" "Village FEs" "District FEs" "Village FEs" "District FEs" "Village FEs")  note("Weighted by Number of Students") ///
		title("Valued-Added and Village Characteristics\label{valueadded}") ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		nonumber substitute({table} {sidewaystable})
restore
	 */

gen ln_numhh=ln(M_numhh)

		foreach x in  english math urdu{
			forvalues z=1/3{

				twoway(lfit pvalue_`x' mauza_zaat_frac if school_private==1 & district==`z' [pw=num_students] ) ///
					(lfit pvalue_`x' mauza_zaat_frac if school_private==0 & district==`z'  [pw=num_students]) ///
					(kdensity mauza_zaat_frac if district==`z' , yaxis(2)) ///
					, legend(label(1 "Priv") label(2 "Gov") label(3 "all") rows(1)) ///
					ytitle("Value Added Score") xtitle(ELF) title("`x', District `z'") ///
					yscale(range(-0.5(0.5)1)) xscale(range(0(0.2)1)) scheme(s2color)

					tempfile dist_`z'_`x'
					graph save  `dist_`z'_`x''.gph, replace

				}

				xi:reg valueadded_`x' i.district i.M_litcat M_wealth_alt M_frac_land ln_numhh [pw=num_students]

				predict residuals, resid
				twoway(lfit pvalue_`x' mauza_zaat_frac if school_private==1 [pw=num_students] ) ///
					(lfit pvalue_`x' mauza_zaat_frac if school_private==0 [pw=num_students]) ///
					, legend(label(1 "Priv") label(2 "Gov") label(3 "all") rows(1)) ///
					ytitle("Value Added Score") xtitle(ELF) title("`x', All") ///
					yscale(range(-0.5(0.5)1)) xscale(range(0(0.2)1)) scheme(s2color)

					tempfile dist_all_`x'
					graph save  `dist_all_`x''.gph, replace

				capture drop residuals
		}





		graph combine `dist_1_english'.gph `dist_2_english'.gph `dist_3_english'.gph  `dist_all_english'.gph  ///
					`dist_1_urdu'.gph `dist_2_urdu'.gph `dist_3_urdu'.gph `dist_all_urdu'.gph ///
					`dist_1_math'.gph `dist_2_math'.gph `dist_3_math'.gph `dist_all_math'.gph ///
					,rows(3) cols(4)
		graph export  $pk/docs/graphs/valueadded_all_pweighted.pdf, replace


qqq

* Control for Levels, across all
foreach x in  english math urdu{

		xi:reg valueadded_`x' i.district M_wealth [pw=num_students]
		predict residuals, resid
		twoway(lfitci residuals mauza_zaat_frac if school_private==1) ///
			(lfitci residuals mauza_zaat_frac if school_private==0 ) ///
			, legend(label(1 "Priv") label(2 "Gov") label(3 "all") rows(1)) ///
			ytitle("Value Added Score") xtitle(ELF) title("`x', All") ///
			yscale(range(-0.5(0.5)1)) xscale(range(0(0.2)1)) scheme(s2color)

			tempfile dist_all_`x'
			graph save  `dist_all_`x''.gph, replace

		capture drop residuals
}




/*

graph combine `dist_all_english'.gph  ///
			`dist_all_urdu'.gph ///
			`dist_all_math'.gph ///
			,rows(3) cols(4)
graph export  $pk/docs/graphs/valueadded_all_lfit.pdf, replace
