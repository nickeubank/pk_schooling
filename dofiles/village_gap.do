clear
clear matrix 
clear mata 
setglobals
set maxvar 30000



use $datadir/constructed/child_panel/child_panel_long, clear

sort childcode mauzaid


* drop if reportcard==1
set more off


tsset childcode round


/*
 keep if ///
	(round==1 & child_class==3) | ///
	(round==2 & child_class==4) | ///
	(round==3 & child_class==5 & child_panel==1) | ///
	(round==4 & child_class==6  & child_panel==1) | ///
	(round==3 & child_class==3 & child_panel==2) | ///
	(round==4 & child_class==4  & child_panel==2)
*/

* Only want villages with more than 10 or 15 kids:

drop if child_english_theta==.
egen ctag=tag(childcode) if school_private==1
bysort mauzaid: egen num_privatestudents=sum(ctag)
egen mtag=tag(mauzaid round) 
tab num_privatestudents if mtag==1

drop if num_privatestudents<5



levelsof mauzaid, local(mlist)


foreach x in `mlist' {
	gen m_`x'=(mauzaid==`x')
	gen mp_`x'=m_`x'*school_private
}

drop m_1
tab mauzaid school_private


sort childcode round 
* ********************
* Make a few vars
* ********************

* Make teacher dummies
gen child_age2=child_age^2


drop if child_class==8|child_class==1|child_class==2
tab child_class


* **************
* Run regression
* **************

set matsize 2000



foreach x in english  urdu math {
	xi: areg child_`x'_theta L.child_math_theta L.child_urdu_theta L.child_english_theta child_age child_age2 i.child_class  m_* mp_*, cluster(mauzaid) 	a(district)
	foreach mauza in `mlist' {
		if (`mauza'==1) {
			gen gap_`x'_`mauza'= _b[mp_`mauza']
		}
		else{
			gen gap_`x'_`mauza'= _b[mp_`mauza']-_b[m_`mauza']
		}
	}
}




keep gap_*

keep if _n==_N
gen id=1


reshape long gap_math_ gap_english_ gap_urdu_ , i(id) j(mauzaid)

renvars gap_*_, postdrop(1)
drop id

sort mauzaid 
save $datadir/constructed/ethnic_info/raw/mauza_gap, replace


do $datadir/constructed/ethnic_info/dofiles/village_gap_analysis.do



