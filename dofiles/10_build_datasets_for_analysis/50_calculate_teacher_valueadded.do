clear
clear matrix
clear mata

set maxvar 30000


use $pk/public_leaps_data/panels/public_child_panel_long, clear

set more off


tsset childcode round


* About 3500 teachers -- recall we follow a class a year at ~700 schools, so only ~800 
* teachers per round. The teacher roster has info on more teachers (those not in classes
* where students were followed), but those don't have child test scores. 
duplicates report child_teachercode
assert `r(unique_value)' > 3200 & `r(unique_value)' < 3300

* Some refuse testing
drop if child_english_theta==.

* Matrix goes singular if keep teachers with too few students
bysort child_teachercode: gen num = _N
replace child_teachercode = . if num < 5




duplicates report child_teachercode
display `r(unique_value)'
assert `r(unique_value)' > 2500 & `r(unique_value)' < 2700

* ********************
* Make a few vars
* ********************

sort childcode round

****
* Make teacher dummies
****

* Drop teachers not in sample villages
drop if child_teachercode > 2000000


duplicates report child_teachercode
assert `r(unique_value)' > 2300

levelsof child_teachercode , local(codes)
foreach x in `codes' {
	gen t_`x'=(child_teachercode==`x')
}

* Make age squared
gen child_age2 = child_age^2


* **************
* Run regression
* **************

set matsize 4000

sort childcode round 
foreach x in english math urdu {
	xi: reg child_`x'_theta L.child_math_theta L.child_urdu_theta L.child_english_theta ///
			child_parentedu child_pca child_age child_age2 t_* i.district i.child_class ///
			, cluster(childcode)

	foreach teacher in `codes' {
		gen valueadded_`x'_`teacher'= _b[t_`teacher']
		replace valueadded_`x'_`teacher'= . if valueadded_`x'_`teacher'==0

		gen valueadded_se_`x'_`teacher' = _se[t_`teacher']
		replace valueadded_se_`x'_`teacher' = . if valueadded_se_`x'_`teacher'==0

	}
}



keep valueadded_*

keep if _n==_N
gen id=1


reshape long valueadded_math_ valueadded_english_ valueadded_urdu_ ///
			 valueadded_se_math_ valueadded_se_english_ valueadded_se_urdu_ , ///
			 i(id) j(teachercode)

renvars valueadded_*_, postdrop(1)
drop id

********
* Check final sample sizes
********
drop if (valueadded_math == .) & (valueadded_urdu == .) & (valueadded_english == .) 


duplicates report teachercode
display `r(N)'
assert `r(N)' > 2000 & `r(N)' < 2100

sort teachercode
save $pk/constructed_data/teacher_value_added_scores, replace

