clear
clear matrix 
clear mata 

set maxvar 20000


use $datadir/constructed/child_panel/child_panel_long, clear

set more off

tsset childcode round

drop if child_math_theta==. &  child_urdu_theta==. &  child_english_theta==.  


keep if ///
	(round==1 & child_class==3) | ///
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

* Make age squared
gen child_age2=child_age^2


* **************
* Run regression
* **************

set matsize 5000
gen reffgroup=( child_english_theta~=. & L.child_english_theta~=.)

tab district, gen(dist)

foreach x in math urdu english {
	gen lag_`x'= L.child_`x'_theta
}

tab child_class, gen(class_)

foreach x in english  {

	felsdvregdm child_`x'_theta lag_english lag_math lag_urdu child_parentedu child_pca_4years child_age child_age2 dist2 dist3, ivar(childcode) jvar(child_teachercode) reff(reffgroup) feff(valueadded) mover(mover) mnum(mnum) group(newgroup) pobs(pobs) peff(peff) xb(xb) res(res) grouponly
	
}
qqq



keep valueadded_*

keep if _n==_N
gen id=1


reshape long valueadded_math_ valueadded_english_ valueadded_urdu_ , i(id) j(teachercode)

renvars valueadded_*_, postdrop(1)
drop id

sort teachercode 
save $datadir/constructed/ethnic_info/raw/valueadded_reportcard, replace


