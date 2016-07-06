******************
* This dofile creates a cross-sectional dataset at the level of household children
* for examining school choice. 
* 
* To do so, it first gathers a number of needed variables from various sources, 
* then pulls them all together with public_hhsurvey1_children for use in other files. 
*******************


set more off
clear
set matsize 800

*********
* Create component files to merge below
*********

* HH-level caste var
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_household, clear
keep hhid mauzaid  hm1_s0q8_zaatcode
   * Zaat codes 94% the same, so just use male. 

sort hhid
tempfile hh
save `hh', replace

* More hh level vars -- survey weight and pca index. 
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


* Member vars -- gender, age, educ. 
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_member, clear
keep hhid mid h1_s1q6 h1_s1q5 h1_s2q7 h1_s2q6

rename h1_s1q5 female
recode female (2=1) (1=0)
rename h1_s1q6 age
rename h1_s2q7 class
rename h1_s2q6 haseduc
recode haseduc (1=0) (2=1) (3=1) (4=.)
label drop educode
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


* get distance to nearest school. 
use $pk/public_leaps_data/panels/public_hh_panel_long, clear
keep if round==1
egen tag=tag(hhid) if close_govt_primary~=.
keep if tag==1
keep hhid close_govt_primary close_pri_primary
sort hhid

tempfile distance
save `distance', replace


****************
* Build up child-level dataset
****************


* Get kids
use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_child, clear
keep hhid mid hf1_s8q2 hf1_s8q3 hf1_s8q4 hf1_s5q3a1_type hf1_s5q2 hf1_s4q2 hf1_s4q4

* Merge in hh
sort hhid
merge m:1 hhid using `hh'
tab _m
assert _m~=1 // No kids without homes.
keep if _m==3
drop _m

* Merge in member
sort hhid mid
merge 1:1 hhid mid using `member'
assert _m ~= 1 // No kids not in roster
keep if _m == 3
drop _m

* Get mauza vars
sort mauzaid
merge m:1 mauzaid using $pk/public_leaps_data/public_mauza
tab _m
assert _m == 3  // no one without a mauza!
drop _m

* Get distance
sort hhid
merge m:1 hhid using `distance'
keep if _m == 3 // Some kids have bad GPS; some homes don't have kids in this data. 
drop _m

* Get weights
sort hhid
merge m:1 hhid using `hhweight'
tab _m
assert _m != 1 // no kids without weights
keep if _m != 2
drop _m

* Get parental education
rename hf1_s4q2 momid
sort hhid momid
merge m:1 hhid momid using `momeduc'
tab _m
keep if _m != 2 // Some may be missing moms keep anyway; women not moms we drop.  
drop _m
replace mom_haseduc = . if momid == 99 | momid == -99


rename hf1_s4q4 dadid
sort hhid dadid
merge m:1 hhid dadid using `dadeduc'
tab _m
keep if _m != 2  // Some may be missing moms keep anyway; women not moms we drop.  
drop _m
replace dad_haseduc = . if dadid == 99 | dadid == -99


**********
* Make additional variables and Sample restrictions
**********

* Enrolled children only
keep if hf1_s5q2==1


* Other vars   
   gen school_private=(hf1_s5q3a1_type==2) if hf1_s5q3a1_type~=3
   gen age2=age^2
   gen intelligent=hf1_s8q2
   gen above_avg_intell = (intelligent>=4) if intelligent~=.
   gen abov_avg_hardworking = (hf1_s8q3>=4) if hf1_s8q3~=.
   gen ln_hh=ln(M_numhh)

   gen wealth_frac_interact = hh_pca_4years*mauza_zaat_frac

   gen school_dist_gap_pri_minus_govt = close_pri_primary - close_govt_primary

   label var above "Mom Reports Child Above Average Intelligence"
   label var mom_haseduc "Mom Has Some Schooling"
   label var dad_haseduc "Dad Has Some Schooling"
   label var hh_pca_4years "PCA Wealth Index"
   label var age "Age"
   label var age2 "Age Squared"
   label var female "Female"

   label var school_private "Private School"


* *******
* Now Code zaat social status. 
* ********

tab hm1_s0q8_zaat
tab hm1_s0q8_zaat, nol
decode hm1_s0q8_zaat, gen(caste_string)


do $pk/dofiles/encode_zaat_status.do  caste_string 
   // takes a string and gives back "zaat_high_status var. "
   // I do a lot so put in one file so changes always propogate everywhere. 





save $pk/constructed_data/hh_child_cross_section.dta, replace
