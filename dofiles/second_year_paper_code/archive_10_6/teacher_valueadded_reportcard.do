clear

use $datadir/constructed/teacher_panel/teacher_panel_long, clear
rename roster_mauzaid mauzaid
keep teachercode school_private mauzaid
drop if school_private==.|mauzaid==.
duplicates drop teachercode, force
sort teachercode
merge 1:1 teachercode using $datadir/constructed/ethnic_info/raw/valueadded_reportcard
tab _m
keep if _m==3
drop _m

drop if valueadded_english==. & valueadded_urdu==. & valueadded_math==.

codebook mauzaid


sort mauzaid
merge m:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars

tab _m
keep if _m==3

drop _m

count

sort mauzaid
merge m:1 mauzaid using $datadir/constructed/xvars/mauza_xvars

tab _m
keep if _m==3
drop _m

count


* Get report card
sort mauzaid 
merge m:1 mauzaid using $datadir/master/mauzas
assert _m~=1
tab _m

keep if _m==3
drop _m

capture drop num_students

* Get number of kids
preserve
	use $datadir/constructed/child_panel/child_panel_long, clear

	egen oneobstag=tag(childcode child_teachercode round)
	bysort child_teachercode round: egen temp=sum(oneobstag)
	replace temp=. if temp==0
	
	egen tag=tag(child_teachercode round)
	keep if tag==1
	bysort child_teachercode: egen num_students=median(temp)
	egen tag2=tag(child_teachercode)
	keep if tag2==1


	keep child_teachercode num_students
	rename child_teachercode teachercode

	tempfile numkids
	sort teachercode
	save `numkids', replace
restore

sort teachercode 
merge 1:1 teachercode using `numkids'
tab _m
keep if _m==3
drop _m




	capture eststo clear
	foreach x in  english math urdu{
		eststo:	xi: reg valueadded_`x' i.reportcard*mauza_zaat_frac M_wealth i.district [pw=num_students] if school_private==1, cluster(mauzaid) 
		interact mauza_zaat_frac `x' "Title"
		}

qqq

