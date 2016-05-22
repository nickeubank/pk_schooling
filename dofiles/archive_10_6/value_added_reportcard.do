clear
clear matrix 
clear mata 

set maxvar 20000


use $datadir/constructed/child_panel/child_panel_long, clear

set more off

tsset childcode round

drop if child_math_theta==. &  child_urdu_theta==. &  child_english_theta==.  


keep if ///
	(round==2 & child_class==4) | ///
	(round==3 & child_class==5 & child_panel==1) | ///
	(round==4 & child_class==6  & child_panel==1) | ///
	(round==3 & child_class==3 & child_panel==2) | ///
	(round==4 & child_class==4  & child_panel==2)


* Drop teachers with less than 10 kids
	bysort round child_teachercode: egen num=count(child_math_theta)
	drop if num<=10
	
	drop if child_english_theta==.


	sort childcode round

* ********************
* Make a few vars
* ********************

* Make teacher dummies
levelsof child_teachercode , local(codes)
foreach x in `codes' {
	gen t_`x'=(child_teachercode==`x')
}

* Make age squared
gen child_age2=child_age^2


* **************
* Run regression
* **************

set matsize 5000


foreach x in english math urdu {
	xi: reg child_`x'_theta L.child_`x'_theta child_parentedu child_pca child_age child_age2 t_* i.district, cluster(childcode)
	
	foreach teacher in `codes' {
		gen valueadded_`x'_`teacher'= _b[t_`teacher']
		replace valueadded_`x'_`teacher'= . if valueadded_`x'_`teacher'==0
	}
}




keep valueadded_*

keep if _n==_N
gen id=1


reshape long valueadded_math_ valueadded_english_ valueadded_urdu_ , i(id) j(teachercode)

renvars valueadded_*_, postdrop(1)
drop id

sort teachercode 
save $datadir/constructed/ethnic_info/raw/valueadded_reportcard, replace


