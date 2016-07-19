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



*********
*
*
* Make Herfandahls 
*
*
*********


gen priv=(gs2_s0q5_type==1)
label var priv "Private"
gen govt=(gs2_s0q5_type==2)
label var govt "Government"
gen all=1
label var all "All Schools"


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
*
* Inter-school, intra-village
*
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
egen number_students=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls ///
								 gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)

* Extrapolated number of students in each caste.
forvalues zaat = 1/`num_zaats' {
	
	gen number_of_caste`zaat'=0

	forvalues variable_suffix = 1/6 {
		replace number_of_caste`zaat' = number_of_caste`zaat'+(number_students * pcent`variable_suffix') if zaat`variable_suffix'==`zaat'
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
* Population Share of two largest castes 
* At Village Level
*
* And at school level
***********


***
* School level
***


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

replace t_1 = t_1 / 100
replace t_2 = t_2 / 100

gen school_share_toptwo_full = t_1 + t_2  if full == 1
gen school_share_toptwo_safer = t_1 + t_2 if safer == 1

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

* Range
assert (0 < t_1) & (t_1 <= 1) if t_1 != .
assert 0 <= (t_1 + t_2) if t_1 != .
assert 1.01 >= (t_1 + t_2) if t_1 != . // small floating precision issue. 

drop to_drop t_1 t_2

********
* Now for village level
********

foreach sample in full safer {

	egen t_1 = rowmax(mauza_caste_all_*_`sample')

	gen to_drop = .
	forvalues x = 1 / `num_zaats_minus_other' {
		replace to_drop = `x' if (mauza_caste_all_`x'_`sample' == t_1) & (to_drop == .)
	}

	forvalues x = 1 / `num_zaats_minus_other' {
		gen temp_caste_count`x' = mauza_caste_all_`x'_`sample'
		replace temp_caste_count`x' = . if (to_drop == `x')
	}

	egen t_2 = rowmax(temp_caste_count*)
	replace t_2 = 0 if t_2 == .  
		// In theory, should only exist if t_1 == 100, but 
		// because I drop "other" and because respondent-reported
		// not calculated,
		// doesn't actually hold.
		// sometimes report totals of less than 100.



	gen village_share_toptwo_`sample' = (t_1 + t_2) / mauza_students_all_`sample'
	label var village_share_toptwo_`sample' "Share of students in village in two largest zaats, `sample' sample"

	***
	* Tests
	***

	* Order
	assert t_1 >= t_2

	* Range
	assert (0 < (t_1 / mauza_students_all_`sample')) ///
		     & ((t_1 / mauza_students_all_`sample') < 1) ///
		     if t_1 !=. & mauza_students_all_`sample'!=.

	assert (0 < (t_2 / mauza_students_all_`sample')) ///
			 & ((t_2 / mauza_students_all_`sample') < 1) ///
			 if t_2 !=. & mauza_students_all_`sample' != .

	assert (0 < village_share_toptwo_`sample') ///
			& (village_share_toptwo_`sample' <= 1) ///
			if village_share_toptwo_`sample' != .

	* Not all same
	count if t_1 == t_2
	local matching = `r(N)'
	count
	assert `matching' < `r(N)' / 2

	drop t_1 t_2 temp_caste_count* to_drop

	corr village_share_toptwo_`sample' school_share_toptwo_`sample'
	assert `r(rho)' > 0
		
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
	// Really doesn't matter. 

label var mtag "Mauza Tag"


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

************
* Look at composition by status
************

forvalues x = 1/6 {
	decode zaat`x', gen(zaat_string)
	replace zaat_string = upper(zaat_string)

		* Need to harmonize a few
		replace zaat_string="AARAIN" if zaat_string == "ARAIN"
		replace zaat_string="AWAAN" if zaat_string == "AWAN"
		replace zaat_string="QURESHI" if zaat_string == "HASHMI/QURESHI"
		replace zaat_string="MUGHAL" if zaat_string == "MUGHAL"
		replace zaat_string="MUSLIM SHEIKH" if zaat_string == "MUSLIM SHIEKH"
		replace zaat_string="RAJPUT" if zaat_string == "RAJPUT/BHATTI"
		replace zaat_string="SHEIKH" if zaat_string == "SHIEKH"
		replace zaat_string="SOLANGI" if zaat_string == "SOLANGI"



	do $pk/dofiles/10_build_datasets_for_analysis/encode_zaat_status.do  zaat_string 
    // takes a string and gives back "zaat_high_status var. "
    // I do a lot so put in one file so changes always propogate everywhere. 
    rename zaat_high_status zaat_high_status`x' 
    drop zaat_string
}


* Number by Status in each school
foreach high_status in 0 1   {
	gen num_status_`high_status'=0
	
	forvalues groupcounter = 1/6 {
		replace num_status_`high_status' = num_status_`high_status' + ///
											 (number_students * pcent`groupcounter'/100) ///
											if zaat_high_status`groupcounter' == `high_status'
	}
	duplicates report schoolid mauzaid
}


bysort mauzaid: egen tempnum=sum(num_status_1)
bysort mauzaid: egen tempdenom=sum(num_status_0)
gen mauza_pct_high = tempnum / (tempnum+tempdenom)
label var mauza_pct_high "Share of students in village of high status"
drop tempnum tempdenom

gen school_pct_high= num_status_1 /( num_status_1 + num_status_0)
label var school_pct_high "Share of students high status"


gen school_private = (gs2_s0q5_type == 1) if gs2_s0q5_type == 1 | gs2_s0q5_type == 2


***********
* Mauza level terciles
***********
drop mtag
egen mtag = tag(mauzaid)
xtile t_zfrac = mauza_zaat_frac if mtag == 1, n(3)
bysort mauzaid: egen zfrac3 = max(t_zfrac)
drop t_zfrac

***********
* Organize vars
***********


keep mauzaid schoolid mauza_frac_* intraschool_frac_* school_segregation_* number_students priv govt all ///
	 school_pct_high mauza_pct_high school_private M_numhh M_literacy mauza_zaat_frac M_wealth district ///
	 zfrac3 *_share_toptwo* 


renvars *_full, postdrop(5)
rename schoolid2 schoolid

sort mauzaid schoolid
save $pk/constructed_data/school_segregation, replace

