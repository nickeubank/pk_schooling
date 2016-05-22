
use $datadir/household/hhsurvey1/hhsurvey1_school.dta, clear





/*
* ************
* Get herf and school scores
* ************

	use $datadir/constructed/school_panel/school_panel_long, clear

	keep mauzaid schoolid id round strata district reportcard school_* child_*theta mauza*

	keep if round==1
	rename schoolid schoolid1
	tempfile school
	save `school'


* ************
* Get perceptions
* ************

	use $datadir/household/hhsurvey1/hhsurvey1_school.dta, clear
	keep hhid mauzaid schoolid1 hf1_s14q8_english hf1_s14q8_math hf1_s14q8_religious hf1_s14q8_overall hm1_s8q8_english hm1_s8q8_math hm1_s8q8_religious hm1_s8q8_overall

	sort mauzaid schoolid1
	merge mauzaid schoolid1 using `school'
	tab _m
	
	keep if _m==3
	
* *********
* Analyze
* ********* 
label define gender -1"Below Average" 0"Average" 1"Average", modify

drop id
egen id=group(mauzaid schoolid1)

foreach z in english math overall {
		gen gender_f_`z'=hf1_s14q8_`z'
		gen gender_m_`z'=hm1_s8q8_`z'
	foreach x in f m {
		recode gender_`x'_`z' (0=.)
		label values gender_`x'_`z' gender
	}
}	


/*
foreach z in english math {
	gen child_`z'=.
	forvalues x=1/154 {
		capture xtile child_`z'_`x'=child_`z'_theta if mauzaid==`x', n(5)
		capture replace child_`z'=child_`z'_`x' if mauzaid==`x'
	}
	drop child_`z'_*
}
*/




foreach z in english math {
	xi: reg child_`z'_theta i.gender_f_`z' , cluster(mauzaid)
	xi: reg child_`z'_theta i.gender_f_`z'*mauza_polarity_zaat, cluster(mauzaid)

corr child_`z'_theta gender_f_`z'
corr child_`z'_theta gender_f_`z' if mauza_polarity>0.3
corr child_`z'_theta gender_f_`z' if mauza_polarity<0.3


}



