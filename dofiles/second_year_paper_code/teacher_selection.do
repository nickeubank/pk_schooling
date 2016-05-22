clear
set more off

use $datadir/constructed/teacher_panel/teacher_panel_long, clear
rename roster_mauzaid mauzaid
drop if mauzaid==.
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
tab _m
keep if _m==3
drop _m
merge m:1 mauzaid using $datadir/constructed/xvars/mauza_xvars
tab _m
assert _m~=1
keep if _m==3
drop _m

keep if round==3


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



gen school_government=(school_private==0) if school_private~=.


	* make some variables:
	gen female=(roster_gender==2) if roster_gender~=. & roster_gender~=99
	label var female "Female"
	
	gen trained=(roster_training>=3) if roster_training~=.
	label var trained "At Least Secondary School Trained"

	* replace roster_absent=7 if roster_absent>7
	label var roster_absent "Days Absent"
	gen single=roster_single==1 if roster_single~=.
	label var single "Single"
	gen more_than3_experience=roster_experience==3 if roster_experience~=.
	label var more_than3_experience "\specialcellc{More than 3 Years\\Experience}" 

	gen has_matricplus=roster_education>2 if roster_education~=.
	label var has_matricplus "\specialcellc{More than Grade\\School Education}"
	gen ln_numhh=ln(M_numhh)
	label var ln_numhh "\specialcell{Log Number\\of Households}"

	label var roster_local "From Village"
	label var M_wealth "\specialcell{Median Village\\Expenditures}"
	
	label var teacher_english_theta "\specialcellc{Teacher English\\Exam Score}"
	label var school_facilities_basic "\specialcellc{Basic School\\Facility Index}"
	label var mauza_zaat_frac "\specialcell{Biraderi\\Fractionalization}"

egen stag=tag(roster_schoolid mauzaid)

foreach x in government private {
	eststo clear
	foreach indicator in roster_absent female roster_local teacher_english_theta has_matricplus {
		eststo : xi:reg `indicator' mauza_zaat_frac i.district M_wealth ln_numhh if school_`x'==0 [pw=num_students], cluster(mauzaid)		
	}

	eststo : xi:reg school_facilities_basic mauza_zaat_frac i.district M_wealth ln_numhh if school_`x'==0 & stag==1 [pw=num_students], cluster(mauzaid)		


	local upper=proper("`x'")
	esttab  using $pk/docs/regressions/`x'_teachers.tex, b(a2) replace nogaps compress label noconstant booktabs ///
		title(`upper' Teacher Characteristics and Village Fractionalization\label{`x'teachers}) ///
		indicate(District Fixed Effects=_Id*) ///
		 substitute({table} {sidewaystable})  ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		note("\specialcell{All results clustered at the village level.\\All regressions weighted by number of students.\\Robust t-statistics presented in parenthesis.}")
	
}


