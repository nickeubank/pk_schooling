* *********
* Look at school choice from the household side
**********
set more off
clear 
set matsize 800


* HH vars
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_household, clear
keep hhid mauzaid  hm1_s0q8_zaatcode
sort hhid 
tempfile hh
save `hh', replace

use $pk/public_leaps_data/public_hh_panel_long, clear
keep hhid hh_weight
egen htag=tag(hhid) if hh_weight~=.
keep if htag==1
drop htag
sort hhid
tempfile hhweight
save `hhweight', replace


* Member vars
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_member, clear
keep hhid mid h1_s1q6 h1_s1q5 h1_s2q7
rename h1_s1q5 female
recode female (2=1) (1=0)
rename h1_s1q6 age
rename h1_s2q7 class
sort hhid mid
tempfile member
save `member', replace

* get distance to nearest 
use $pk/public_leaps_data/public_hh_panel_long, clear
keep if round==1
egen tag=tag(hhid) if close_govt_primary~=.
keep if tag==1
keep hhid close_govt_primary close_pri_primary 
sort hhid

tempfile distance
save `distance', replace


* Get kids
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_child, clear
keep hhid mid momeduc dadeduc hf1_s8q2 hf1_s8q3 hf1_s8q4 hf1_s5q3a1_type hf1_s5q2

* Merge in hh
sort hhid
merge m:1 hhid using `hh'
tab _m
assert _m~=1
keep if _m==3
drop _m

* Merge in member
sort hhid mid
merge 1:1 hhid mid using `member'
assert _m~=1
keep if _m==3
drop _m

* Get mauza vars
sort mauzaid
merge m:1 mauzaid using $pk/public_leaps_data/public_mauza
tab _m
keep if _m==3
drop _m


* Get distance
sort hhid 
merge m:1 hhid using `distance'
keep if _m==3
drop _m

* Get weights
sort hhid
merge m:1 hhid using `hhweight'
tab _m
keep if _m~=2
drop _m

	* Make some variables
	keep if hf1_s5q2==1
	gen school_private=(hf1_s5q3a1_type==2) if hf1_s5q3a1_type~=3
	gen mom_haseduc=momeduc>0 if momeduc~=.
	gen dad_haseduc=dadeduc>0 if dadeduc~=.
	gen ln_expend=ln(total_expend)
	sum ln_expend, d
	gen age2=age^2
	gen intelligent=hf1_s8q2
	gen frac_intelligent_interact=mauza_zaat_frac*intelligent
 	gen above=(intelligent>=4) if intelligent~=.
	gen hardworking=(hf1_s8q3>=4) if hf1_s8q3~=.


	gen expend_frac=ln_expend*mauza_zaat_frac
	gen gap=close_pri_primary-close_govt_primary


* *******
* Now throw in caste
* ********

tab hm1_s0q8_zaat
tab hm1_s0q8_zaat, nol



gen status=""
replace status="High" if hm1_s0q8_zaat==1
replace status="High" if hm1_s0q8_zaat==2
replace status="Low" if hm1_s0q8_zaat==3
replace status="High" if hm1_s0q8_zaat==4
replace status="Low" if hm1_s0q8_zaat==5
replace status="High" if hm1_s0q8_zaat==6
replace status="High" if hm1_s0q8_zaat==8
replace status="High" if hm1_s0q8_zaat==9
replace status="Low" if hm1_s0q8_zaat==12
replace status="Low" if hm1_s0q8_zaat==13
replace status="High" if hm1_s0q8_zaat==15
replace status="Low" if hm1_s0q8_zaat==16
replace status="High" if hm1_s0q8_zaat==17
replace status="Low" if hm1_s0q8_zaat==18
replace status="High" if hm1_s0q8_zaat==20
replace status="High" if hm1_s0q8_zaat==22
replace status="Low" if hm1_s0q8_zaat==21


gen status2=.
replace status2=0 if status=="Low"
replace status2=1 if status=="High"

gen status_b=""
replace status_b="Medium" if hm1_s0q8_zaat==2
replace status_b="Low" if hm1_s0q8_zaat==3
replace status_b="Medium" if hm1_s0q8_zaat==1
replace status_b="High" if hm1_s0q8_zaat==4
replace status_b="Low" if hm1_s0q8_zaat==5
replace status_b="Medium" if hm1_s0q8_zaat==6
replace status_b="Medium" if hm1_s0q8_zaat==8
replace status_b="Medium" if hm1_s0q8_zaat==16
replace status_b="High" if hm1_s0q8_zaat==9
replace status_b="Low" if hm1_s0q8_zaat==11
replace status_b="Low" if hm1_s0q8_zaat==12
replace status_b="Low" if hm1_s0q8_zaat==13
replace status_b="High" if hm1_s0q8_zaat==14
replace status_b="Low" if hm1_s0q8_zaat==15
replace status_b="High" if hm1_s0q8_zaat==17
replace status_b="Low" if hm1_s0q8_zaat==20
replace status_b="Low" if hm1_s0q8_zaat==21
replace status_b="High" if hm1_s0q8_zaat==22


gen ln_hh=ln(M_numhh)

* First intelligence

label var above "Mom Reports Child Above Average Intelligence"
label var mom_haseduc "Mom Has Some Schooling"
label var dad_haseduc "Mom Has Some Schooling"
label var ln_expend "Log Month Expenditure"
label var age "Age"
label var age2 "Age Squared"
label var female "Female"

label var school_private "Private School"
eststo clear
eststo: xi:reg school_private above mom_haseduc dad_haseduc ln_expend age age2 female i.mauzaid [pw=hh_weight], cluster(mauzaid)
eststo: xi:reg school_private above mom_haseduc dad_haseduc ln_expend age age2 female i.hhid [pw=hh_weight], cluster(mauzaid) 

esttab  using $pk/docs/results/hhselection.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselection}) ///
	indicate("Village Fixed Effects=_Ima*" "Household Fixed Effects=_Ihh*") ///
	mtitle("" "") drop(o.*)
	starlevels(* 0.10 ** 0.05 *** 0.01) drop(o.*)
	
**********
* Does premium on intelligence change?
**********
gen above_frac_interact=above*mauza_zaat_frac
label var above_frac_interact "Child Above Avg * Fractionalization"
label var above "Mom: Child Above Avg Intelligence"
	
	
	count if school_private~=. & above~=.
	
eststo clear
eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.mauzaid [pw=hh_weight], cluster(mauzaid)
eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.hhid [pw=hh_weight], cluster(mauzaid) 

eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.mauzaid [pw=hh_weight] if status2==1, cluster(mauzaid)
eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.hhid [pw=hh_weight] if status2==1, cluster(mauzaid) 

eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.mauzaid [pw=hh_weight] if status2==0, cluster(mauzaid)
eststo: xi:reg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc ln_expend age age2 female i.hhid [pw=hh_weight] if status2==0, cluster(mauzaid) 


esttab  using $pk/docs/results/hhselection_interaction.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselectioninteraction}) ///
mgroups("All" "High Status" "Low Status" , pattern(0 0 1  0 1 0    ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	indicate("Village Fixed Effects=_Ima*" "Household Fixed Effects=_Ihh*") ///
	mtitle("" "" "" "" "" "") drop(o.*) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 
	
	
	/*
	
xi:areg school_private i.above*mauza_zaat_frac mom_haseduc dad_haseduc ln_expend age age2 female  [pw=hh_weight] if status2==1, cluster(mauzaid) a(district)

xi:areg school_private i.above*mauza_zaat_frac mom_haseduc dad_haseduc ln_expend age age2 female  [pw=hh_weight] if status2==0, cluster(mauzaid) a(district)
qqq

eststo: xi:reg school_private above mom_haseduc dad_haseduc ln_expend age age2 female i.hhid [pw=hh_weight], cluster(mauzaid) 
	
	
sort hhid mid
tempfile temp
save `temp'
use $datadir/constructed/child_panel/child_panel_long, clear
keep if hhid~=.
keep if round==1
keep hhid mid child_*_theta
sort hhid mid
merge 1:1 hhid mid using `temp'


xi:areg child_english_theta i.status2 mauza_zaat_frac mom_haseduc dad_haseduc ln_expend age age2 female  [pw=hh_weight] , cluster(mauzaid) a(district)
qqq


