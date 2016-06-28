set more off
clear
set matsize 800

*********
* Create component files to merge below
*********



* HH vars
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_household, clear
keep hhid mauzaid  hm1_s0q8_zaatcode
sort hhid
tempfile hh
save `hh', replace

use $pk/public_leaps_data/panels/public_hh_panel_long, clear
keep if round == 1

   * Check looks right
   duplicates report hhid if mid==1
   assert `r(N)' == `r(unique_value)'


duplicates drop hhid, force
keep hhid hh_weight hh_pca_4years
sort hhid
tempfile hhweight
save `hhweight', replace


* Member vars
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_member, clear
keep hhid mid h1_s1q6 h1_s1q5 h1_s2q7 h1_s2q6

rename h1_s1q5 female
recode female (2=1) (1=0)
rename h1_s1q6 age
rename h1_s2q7 class
rename h1_s2q6 haseduc
recode haseduc (1=0) (2=1) (3=1) (4=.)
sort hhid mid
tempfile member
save `member', replace


* Make parental education vars

preserve
   rename mid momid
   rename haseduc mom_haseduc
   keep if female == 1
   keep hhid momid mom_haseduc
   sort hhid momid

   tempfile momeduc
   save `momeduc', replace
restore

preserve
   rename mid dadid
   rename haseduc dad_haseduc
   keep if female == 0
   keep hhid dadid dad_haseduc
   sort hhid dadid

   tempfile dadeduc
   save `dadeduc', replace
restore


* get distance to nearest
use $pk/public_leaps_data/panels/public_hh_panel_long, clear
keep if round==1
egen tag=tag(hhid) if close_govt_primary~=.
keep if tag==1
keep hhid close_govt_primary close_pri_primary
sort hhid

tempfile distance
save `distance', replace




* Get kids
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_child, clear
keep hhid mid hf1_s8q2 hf1_s8q3 hf1_s8q4 hf1_s5q3a1_type hf1_s5q2 hf1_s4q2 hf1_s4q4

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

* Get parental education
rename hf1_s4q2 momid
sort hhid momid
merge m:1 hhid momid using `momeduc'
keep if _m != 2
drop _m
replace mom_haseduc = . if momid == 99 | momid == -99

rename hf1_s4q4 dadid
sort hhid dadid
merge m:1 hhid dadid using `dadeduc'
keep if _m != 2
drop _m
replace dad_haseduc = . if dadid == 99 | dadid == -99


save $pk/constructed_data/hh_cross_section.dta, replace
