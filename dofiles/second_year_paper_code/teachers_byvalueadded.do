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
	
	gen ln_numhh=ln(M_numhh)
	gen size_priv=ln_numhh*school_private

	set more off
	capture eststo clear
	foreach x in  english math urdu{
		local subject=upper("`x'")
		xi: reg valueadded_`x'  i.school_private*mauza_zaat_frac  Mwealth dist2 dist3 M_literacy  M_numhh M_gini_land, cluster(mauzaid) 
		interact_scores mauza_zaat_frac "d" "`subject'"
		graph save $pk/docs/graphs/valueadded_`x'.gph, replace

		}

qqq

		graph combine ///
			$pk/docs/graphs/valueadded_english.gph  $pk/docs/graphs/valueadded_math.gph ///
			  $pk/docs/graphs/valueadded_urdu.gph, rows(1) ///
			title(Teacher Fixed Effects) ///
			subtitle(By Village Fractionalization) ///
			note("Basic controls include village fixed effects, gender, age, and age squared." "Extensive controls include child wealth and parental education")
		graph export $pk/docs/graphs/valueadded.pdf, replace

gen ln_hh=ln(M_numhh)

		* So is govt school improvment from the top or bottom?
		qreg valueadded_english  mauza_zaat_frac  dist2 dist3 M_wealth M_literacy ln_hh if school_private==1, q(10) 
		qreg valueadded_english  mauza_zaat_frac  dist2 dist3 M_wealth M_literacy ln_hh if school_private==1, q(50) 
		qreg valueadded_english  mauza_zaat_frac  dist2 dist3 M_wealth M_literacy ln_hh  if school_private==1, q(90) 
			* MASSIVE improvements at the bottom!


		xi:	bsqreg valueadded_english  i.school_private*mauza_zaat_frac dist2 dist3 M_wealth M_literacy ln_hh, q(10) reps(50)
		interact_scores mauza_zaat_frac "name" "name"
		
		xi:	bsqreg valueadded_english  i.school_private*mauza_zaat_frac dist2 dist3 M_wealth M_literacy ln_hh, q(90) reps(50)
		interact_scores mauza_zaat_frac "name" "name"
		
		
		