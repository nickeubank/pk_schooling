clear
set more off

* ********************
* Want to look at year 1 to year 4 shifts to get full effects. 
* First, let's just look at:
* 	- Change in test scores -- village level effects and split by ethnic fractionalization
* 	- Change of schools
* 	- change in accuracy of parental perceptions
* 	- increased class diversity!
* ********************



* ************
* Now look at child changes from 1 to 4.
* ************

use $datadir/constructed/child_panel/child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/public_leaps_data/public_mauza
assert _m~=1
tab _m
keep if _m==3
count


* Get local share for children who link:
gen own_zaat_share=.
forvalues x=1/23{
	replace own_zaat_share=mauza_zaat_share`x' if household_zaat1==`x'
}	


* Collapse to relevant years
keep if child_panel==1 & child_surveypanel==1
	* Take "ever changed" or "ever held back" vars before collapsing rounds
	drop if round==4
	bysort childcode: egen ever_switched=max(child_switched)
	replace ever_switched=. if round~=3
	replace ever_switched=. if child_english_theta==.

	gen heldback=(child_promotion==2|child_promotion==4)
	bysort childcode: egen ever_heldback=max(heldback)
	replace ever_heldback=. if child_english_theta==. 
	replace ever_heldback=. if round~=3

keep if (round==1|round==3)
replace round=2 if round==3
count
tsset childcode round


bysort childcode: egen first_year=max((child_math_theta~=. & round==1))

keep if first_year==1
drop first_year



* Make school change
gen change=(child_schoolid~=L.child_schoolid) & child_schoolid~=. & L.child_schoolid~=.
replace change=. if round==1
bysort mauzaid: egen avg_change=mean(change)
egen mtag=tag(mauzaid)
tab avg_change if mtag==1

compare ever_switched change

gen temp=school_private if round==1
bysort childcode: egen initial_school_p=max(school_private)



* Look at effects
sort childcode round
gen lag_math=L.child_math_theta
gen lag_english=L.child_english_theta
gen lag_urdu=L.child_urdu_theta


gen c_english=D.child_english_theta
gen c_math=D.child_math_theta
gen c_urdu=D.child_urdu_theta

sum mauza_zaat_frac, d

gen zfracp2=1 if mauza_zaat_frac>0.5
replace zfracp2=0 if mauza_zaat_frac<0.33

* Test Scores
foreach x in  urdu english math   {
	
	display "`x'"
		discard
		xi:reg c_`x' i.reportcard*mauza_zaat_frac  i.district, cluster(mauzaid)	
		predict pred_c_`x'
		interact mauza_zaat_frac 0.1 `x'
		graph export $datadir/constructed/ethnic_info/graphs/reportcardinteractionstudents_`x'.pdf, replace
		qqq
		display "At full frac: " _b[_Ireportc] + _b[_IrepXmauza_1]
		test _Ireportc + _IrepXmauza_1==0
		display "At mean: "_b[_Ireportc] + 0.65*_b[_IrepXmauza_1]
		test _Ireportc + 0.65*_IrepXmauza_1==0
		display "At no frac: " _b[_Ireportc]
		test _Ireportc==0
		twoway(lowess pred_c_`x' mauza_zaat_frac if reportcard==1, lwidth(thick)) ///
		(lowess pred_c_`x' mauza_zaat_frac if reportcard==0,  lwidth(thick)) ///
		(kdensity mauza_zaat_frac if reportcard==1,yaxis(2)  lcolor(g8) lpattern(dash)), ///
			legend(label(1 "Treatment Fitted") label(2 "Control Fitted") label(3 "Density of Observations")) ///
			ytitle("Predicted Change in `x' Test Scores from 1 to 3")  ///
			xtitle("Mauza Zaat Fractionalization") title("Report Card `x' Treatment Effect") subtitle("When Controlling for Zaat Frac Interaction") ///
			note("reg D.`x' i.reportcard*mauza_zaat_frac i.district, cluster(mauzaid)")
		graph export $datadir/constructed/ethnic_info/graphs/nonpara_`x'.pdf, replace
		
}

* Overlay change and gains
twoway(lowess pred_c_math mauza_zaat_frac if reportcard==1)(lowess pred_c_math mauza_zaat_frac if reportcard==0) ///
	(lowess change mauza_zaat_frac, yaxis(2))


* Change Schools?
foreach x in  change ever_switched ever_heldback {
	xi:dprobit `x' i.reportcard*mauza_zaat_frac  i.district lag_math, cluster(mauzaid)
	test _Ireportc + 0.65*_IrepXmauza_1==0
}

* Test Scores by school type

tostring initial_school_p, replace
rename initial_school_p initial_school
replace initial_school="Private" if initial_school=="1"
replace initial_school="Government" if initial_school=="0"


capture drop pred*
drop if child_switched==1
set more off

	foreach x in  urdu english math   {
		foreach type in Private Government {	
	display "`x'"
		xi:reg c_`x' i.reportcard*mauza_zaat_frac  i.district if initial_school=="`type'" , cluster(mauzaid)		
		predict pred_c_`x'_`type'
		display "At full frac: " _b[_Ireportc] + _b[_IrepXmauza_1]
		test _Ireportc + _IrepXmauza_1==0
		display "At mean: "_b[_Ireportc] + 0.65*_b[_IrepXmauza_1]
		test _Ireportc + 0.65*_IrepXmauza_1==0
		display "At no frac: " _b[_Ireportc]
		test _Ireportc==0
		
		twoway(lowess pred_c_`x'_`type' mauza_zaat_frac if reportcard==1 &  initial_school=="`type'" & mauza_zaat_frac>0.3, lwidth(thick)) ///
		(lowess pred_c_`x'_`type' mauza_zaat_frac if reportcard==0 & initial_school=="`type'" & mauza_zaat_frac>0.3, lwidth(thick)) ///
		(kdensity mauza_zaat_frac  if mauza_zaat_frac>0.3,yaxis(2) lcolor(g8) lpattern(dash)), ///
			legend(label(1 "Treatment Fitted") label(2 "Control Fitted") label(3 "Density of Observations") ) ///
			ytitle("Predicted Change from 1 to 3")  ///
			xtitle("Mauza Zaat Fractionalization") title("`type' Students") subtitle("When Controlling for Zaat Frac Interaction") ///
			note("reg D.`x' i.reportcard*mauza_zaat_frac i.district, cluster(mauzaid)")
		tempfile `x'_`type'
		
		graph save ``x'_`type''.gph, replace		
	}

	graph combine ``x'_Government'.gph ``x'_Private'.gph , title("Treatment v. Control for `x'") subtitle("By School Test") ycommon
	graph export $datadir/constructed/ethnic_info/graphs/nonpara_bothtypes_`x'.pdf, replace

}




