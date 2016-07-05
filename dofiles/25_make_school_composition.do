clear
set more off


use $pk/public_leaps_data/school/school2/public_generalschool2, clear


* Get village caste

sort mauzaid
merge mauzaid using $pk/public_leaps_data/public_mauza

keep if _m==3

***********
* Check how well reported percentages add up
***********
renvars gs2_s4q2_*, predrop(9)
order zaat* pcent*


egen test=rowtotal(pcent*)
sum test, d
	* Not perfect.  12% report less than 90 percent... 
	* Do with and without them. 
gen safer_school_sample = (test >= 90)





* ****************
* Number from first two groups:
* ****************



* Drop percentages of "other"

forvalues x = 1/6 {
	gen pcent_noother`x' = pcent`x'
	gen temp_`x' = (zaat`x' == 26)
	replace pcent_noother`x' = . if temp_`x' == 1
	drop temp_`x'
}


***
* Get total in top two groups
***

egen t_1 = rowmax(pcent_noother*)

gen to_drop = .
forvalues x = 1 / 6 {
	replace to_drop = `x' if (pcent_noother`x' == t_1) & (to_drop == .)
}


forvalues x = 1 / 6 {
	gen temp_pcent_noother`x' = pcent_noother`x'
	replace temp_pcent_noother`x' = . if (to_drop == `x')
}

egen t_2 = rowmax(temp_pcent_noother*)
replace t_2 = 0 if t_2 == .  
		// In theory, should only exist if t_1 == 100, but 
		// because I drop "other" and because respondent-reported
		// not calculated,
		// doesn't actually hold.
		// sometimes report totals of less than 100.

gen share_toptwo = t_1 + t_2

***
* Tests
***

* Order
assert t_1 >= t_2

* Not all same
count if t_1 == t_2
local matching = `r(N)'
count
assert `matching' < `r(N)' / 2

drop to_drop t_1 t_2



*********
*
*
* Make Herfandahls 
*
*
*********


gen priv=(gs2_s0q5_type==1)
gen govt=(gs2_s0q5_type==2)
gen all=1


*****
* Intraschool
*****
forvalues x = 1/6 {
	gen inschoolshare_`x' = (pcent`x' / 100)
	gen inschoolsharesq_`x' = (pcent`x' / 100) ^ 2
}


egen intraschool_frac_full = rowtotal(inschoolsharesq_*)
replace  intraschool_frac_full = 1 - intraschool_frac
label var intraschool_frac_full "Intra-school fractionalization"

gen intraschool_frac_safer = intraschool_frac if safer_school_sample == 1
label var intraschool_frac_safer "Intra-school fractionalization (sample with at least 90% reported)"

**
* Couple tests.
**
assert intraschool_frac_full <= 1 & intraschool_frac_full >= 0 if intraschool_frac_full != .
count if intraschool_frac_full == .
assert `r(N)' < 8

* Check sign
egen max = rowmax(pcent*)
corr max intraschool_frac_full
assert `r(rho)' < 0

*****
* Inter-school, intra-village
*****


* Get number of zaats codes(look at a couple to be safe)
local num_zaats = 0
forvalues x = 1/6 { 
	sum zaat`x'
	if (`r(max)' > `num_zaats') {
		local num_zaats = `r(max)'
	}
}

**
* Calculate actual number of students in each caste in each school
**

* School population
egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls ///
								 gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)

* Extrapolated number of students in each caste.
forvalues zaat = 1/`num_zaats' {
	
	gen number_of_caste`zaat'=0

	forvalues variable_suffix = 1/6 {
		replace number_of_caste`zaat' = number_of_caste`zaat'+(number_students_15 * pcent`variable_suffix') if zaat`variable_suffix'==`zaat'
	}
}


* do twice -- once full once "safer" sample
gen full = 1
gen safer = (safer_school_sample==1)

* Add up to village by type
foreach sample in full safer {
	foreach school_type in priv govt all {
			forvalues zaat = 1 / `num_zaats' {
				bysort mauzaid: egen temp = sum(number_of_caste`zaat') if `school_type' == 1 & `sample' == 1
				bysort mauzaid: egen mauza_caste_`school_type'_`zaat'_`sample'=max(temp)
				drop temp
			}

	* Drop "other", change num_zaat counter (after making sure runs to 26, which we drop!)
	drop mauza_caste_`school_type'_26_`sample'
	assert `num_zaats' == 26
	local num_zaats_minus_other = 25


	egen mauza_students_`school_type'_`sample' = rowtotal(mauza_caste_`school_type'_*_`sample') if `sample' == 1


	forvalues zaat = 1/`num_zaats_minus_other' {
		gen mauza_share_`zaat'_`school_type'_`sample' = mauza_caste_`school_type'_`zaat'_`sample' ///
														/ mauza_students_`school_type'_`sample' ///
														if `sample' == 1

		gen mauza_sharesq_`zaat'_`school_type'_`sample'=(mauza_share_`zaat'_`school_type'_`sample')^2  ///
														if `sample' == 1

	}

	* make village level fragmentation!
	egen temp = rowtotal(mauza_sharesq_*_`school_type'_`sample') if `school_type' == 1
	tab temp if `school_type' == 1, m
	bysort mauzaid: egen mauza_frac_`school_type'_`sample' = max(temp)
	* drop temp
	replace mauza_frac_`school_type'_`sample' = 1 - mauza_frac_`school_type'_`sample'
	drop temp

	label var mauza_frac_`school_type'_`sample' "cross-school intra-village herf, `school_type' schools, `sample' sample"

	***
	* Tests
	***

	* valid ranges. Note ~6 villages had private schools close by year 2 (5 without sample restriction, 6 with)
	bysort mauzaid: egen has_`school_type' = max(`school_type') if `sample' == 1
	egen mtag = tag(mauzaid)
	count if has_`school_type' == 0 & mtag == 1
	assert `r(N)' < 7
	assert mauza_frac_`school_type'_`sample' >= 0 & mauza_frac_`school_type'_`sample' < 1 if has_`school_type' ==1
	drop has_`school_type' mtag
	
	* Make sure signed correctly. 
	egen largest_share = rowmax(mauza_share_*_`school_type'_`sample')
	corr largest_share mauza_frac_`school_type'_`sample'
	assert `r(rho)' < 1
	drop largest_share

	}
}

**********
* Check sample restriction importance
**********

* Check significance of sample restriction on inter-school. 
egen mtag = tag(mauzaid)
foreach school_type in govt priv all {
	corr mauza_frac_`school_type'_full mauza_frac_`school_type'_safer if mtag==1
	assert `r(rho)' > 0.85
}
drop mtag 
	// matters somewhat!

	

* Check on intra school
egen mtag = tag(mauzaid)
foreach school_type in govt priv all {
	bysort mauzaid: egen temp_all = mean(intraschool_frac_full) if `school_type' == 1
	bysort mauzaid: egen temp_safer = mean(intraschool_frac_safer)  if `school_type' == 1

	corr temp_all temp_safer if mtag==1
	assert `r(rho)' > 0.95
	drop temp_all temp_safer
}
drop mtag 
	// Really doesn't matter. 



*********
* Generate segregation index:
**********

foreach sample in safer full {
	reg intraschool_frac_`sample' mauza_frac_all_`sample', cluster(mauzaid)
	predict expected_score
	gen school_segregation_`sample'=expected_score-intraschool_frac_`sample'
	label var school_segregation_`sample' "School Segregation, `sample' sample"
	drop expected_score
}

***********
* Organize vars
***********

keep mauzaid schoolid mauza_frac_* intraschool_frac_* school_segregation_*
renvars *_full, postdrop(5)
rename schoolid2 schoolid

sort mauzaid schoolid
save $pk/constructed_data/school_segregation, replace