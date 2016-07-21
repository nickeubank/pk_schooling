clear
set more off

*************
*
* Build up dataset
*
**************


****
* Build off Panel, which has full roster
****

use $pk/public_leaps_data/panels/public_teacher_panel_long, clear
rename roster_mauzaid mauzaid
keep if roster_current_teacher == 1
sort teachercode


*****
* Add value added scores
*****

merge m:1 teachercode using $pk/constructed_data/teacher_value_added_scores

* Two non-merge, source unclear. But small enough probably just cleanliness issue. 
tab _m
count if _m == 2
assert `r(N)' < 3
drop if _m == 2
drop _m

****
* Mauza vars
****

drop if mauzaid >= 200 & mauzaid != . // Teachers from outside of village
 									  // found when students who left village
 									  // were followed. 

sort mauzaid
merge m:1 mauzaid using $pk/public_leaps_data/public_mauza
assert _m == 3
drop _m


********************
* Convert to one observation per teacher
*
* Sample restrictions and adding variables. 
********************

// Some NGO teachers -- not relevant.
drop if school_private == .



* Since this is a panel, each teacher has many values for 
* same variable. 
*
* Take average or first (depending)
**********

* School type -- test to make sure stable over time

bysort teachercode: egen min = min(school_private)
bysort teachercode: egen max = max(school_private)
gen dif = ( max != min )
assert dif == 0
drop dif
drop min school_private
rename max school_private
label var school_private "Private School"



* Age
bysort teachercode: egen avg_age = mean(roster_age)
label var avg_age "Age"

* Gender
recode roster_gender (2=1) (1=0)
bysort teachercode: egen female = max(roster_gender)
label var female "Female"

* Absenteeism
bysort teachercode: egen avg_absent=mean(roster_absent)
label var avg_absent "Days Absent Last Month"

gen ab_frac_interact=avg_absent * mauza_zaat_frac
label var ab_frac_interact "Days Absent * Fractionalization"

* Single
bysort teachercode: egen avg_single = max(roster_single)
label var avg_single "Single"

* Local
bysort teachercode: egen avg_local = max(roster_local)
label var avg_local "From Village"

* Avg salary
bysort teachercode: egen avg_salary=mean(roster_salary)
label var avg_salary "Month Salary"
gen ln_salary = log(avg_salary)

* Experience -- take lowest value. 
bysort teachercode: egen temp_exp = max(roster_experience)
tab temp_exp, gen(exp_)
label var exp_2 "1-3 Years Teaching"
label var exp_3 "More than 3 Years Teaching"
drop temp_exp

gen has_more_than3_experience = (exp_3==1)
label var has_more_than3_experience "\specialcellc{More than 3 Years \\\\ Experience}" 

* Education
bysort teachercode: egen temp_educ = max(roster_education)
tab temp_educ, gen(educ_)

label var educ_2 "Matriculated"
label var educ_3 "Secondary School"
label var educ_4 "Bachelors"
label var educ_5 "Masters Degree or Better"

gen has_matricplus= (temp_educ > 2) if temp_educ != .
label var has_matricplus "\specialcellc{More than Grade \\\\ School Education}"

drop temp_educ

* Training
bysort teachercode: egen temp = max(roster_training)	
gen has_training = (temp >= 3) if temp !=.
label var has_training "At Least Secondary School Trained"
drop temp

* Own English score
bysort teachercode: egen avg_teacher_english_theta = mean(teacher_english_theta)
label var avg_teacher_english_theta "\specialcellc{Teacher English \\\\ Exam Score}"

* Value added
egen avg_valueadded = rowmean(valueadded_english valueadded_math valueadded_urdu)
egen avg_valueadded_se = rowmean(valueadded_se_english valueadded_se_math valueadded_se_urdu)
label var avg_valueadded "Average Value Added Score"
label var avg_valueadded_se "Average Value Added Standard Error"

gen va_frac_interact = avg_valueadded * mauza_zaat_frac
label var va_frac_interact "Value-Added * Fractionalization"






bysort teachercode: egen first_round = min(round)
keep if round == first_round
drop first_round


keep avg_* exp_* educ_* female has_* ///
	district mauzaid teachercode school_private mauza_zaat_frac *_frac_interact ///
	school_facilities_basic M_wealth ln_numhh ln_salary



*******
* Get number of students taught by each teacher (for weighting)
*******

* Get avg number of kids per year
preserve
	use $pk/public_leaps_data/panels/public_child_panel_long, clear

	keep child_teachercode round
	gen counter = 1
	bysort child_teachercode round: egen num_in_class=sum(counter)

	duplicates drop child_teachercode round, force
	bysort child_teachercode: egen avg_students_peryear = mean(num_in_class)

	drop num_in_class counter round

	rename child_teachercode teachercode
	drop if teachercode == . 

	duplicates drop teachercode, force

	tempfile numkids
	sort teachercode
	save `numkids'
restore

sort teachercode
merge 1:1 teachercode using `numkids'
tab _m
assert _m != 1 if avg_valueadded != . // no one with value added should not have a value
drop if _m == 2
drop _m


******
* Sample size tests
******
duplicates report teachercode
assert `r(unique_value)' > 8000 & `r(unique_value)' < 8800
assert `r(unique_value)' == `r(N)'

duplicates report teachercode if school_private == 1
assert `r(unique_value)' > 4300 & `r(unique_value)' < 4800

duplicates report teachercode if school_private == 0
assert `r(unique_value)' > 3300 & `r(unique_value)' < 3900

count if avg_valueadded !=.
assert `r(N)' > 1900 & `r(N)' < 2000


save $pk/constructed_data/custom_teacher_dataset.dta, replace

