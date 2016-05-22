clear
set more off

use $datadir/constructed/teacher_panel/teacher_panel_long, clear
rename roster_mauzaid mauzaid
drop if school_private==.|mauzaid==.
duplicates drop teachercode, force
sort teachercode
merge 1:1 teachercode using $datadir/constructed/ethnic_info/raw/valueadded_teacher
tab _m
drop _m



sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

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

* drop if roster_absent==30

gen ln_num=ln(num_students)
bysort teachercode: egen avg_absent=mean(roster_absent)
gen ln_salary=log(roster_salary)
bysort teachercode: egen avg_salary=mean(ln_salary)


* First regress salary on education, training, performance (avg value added) and 

egen avg_valueadded=rowmean(valueadded_*)
gen va_interact=avg_valueadded*mauza_zaat_frac


gen ab_interact=avg_absent*mauza_zaat_frac
label var ab_interact "Days Absent * Fractionalization"
tab roster_absent
drop if avg_absent==30

label var avg_salary "Month Salary"
label var avg_absent "Days Absent Last Month"

tab roster_experience, gen(exp_)
label var exp_2 "1-3 Years Teaching"
label var exp_3 "More than 3 Years Teaching"

tab roster_education, gen(educ_)

label var educ_2 "Matriculated"
label var educ_3 "Secondary School"
label var educ_4 "Bachelors"
label var educ_5 "Masters Degree or Better"

label var va_interact "Value-Added * Fractionalization"
label var avg_valueadded "Average Value Added Score"

eststo clear

eststo: xi: reg avg_salary avg_absent mauza_zaat_frac ab_interact roster_gender roster_age exp_2 exp_3 educ_2 educ_3 educ_4 educ_5  i.district if school_private==1 & round==1 [pw=num_students], cluster(mauzaid) 

eststo: xi: reg avg_salary  avg_valueadded mauza_zaat_frac va_interact avg_absent roster_gender roster_age  exp_2 exp_3 educ_2 educ_3 educ_4 educ_5  i.district if school_private==1 & round==1 [pw=num_students], cluster(mauzaid) 


eststo: xi: reg avg_salary avg_absent mauza_zaat_frac ab_interact roster_gender roster_age  exp_2 exp_3 educ_2 educ_3 educ_4 educ_5  i.district if school_private==0 & round==1 [pw=num_students], cluster(mauzaid) 

eststo: xi: reg avg_salary  avg_valueadded mauza_zaat_frac va_interact avg_absent roster_gender roster_age  exp_2 exp_3 educ_2 educ_3 educ_4 educ_5  i.district if school_private==0 & round==1 [pw=num_students], cluster(mauzaid) 



esttab  using $pk/docs/regressions/teachercompensation.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("Private Teachers" "Government Teachers" , pattern( 0 0   1 0     ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "Log Salary" "Log Salary" "Log Salary" "Log Salary" ) title(Village Fractionalization and Teacher Compensation\label{teachercompensation}) ///
		indicate( "District Fixed Effects=_Id*") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) drop("o.*" "exp*" "educ*") ///
	note(\specialcell{Controls for Experience and Teacher Education excluded from table.\\Robust t-statistics clustered at the village level in parenthesis})

qqq




/*
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
		
		
