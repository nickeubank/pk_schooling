
* **************
* Now let's bring in school fractionalization
* **************

* Get fees. Use general school 2 for consistency with caste measures. 
use $pk/public_leaps_data/school/school2/public_generalschool2, clear

		keep mauzaid schoolid gs2_s14q1_1to3 gs2_s14q2_1to3 gs2_s0q5_type
		recode gs2_s14q1_1to3 gs2_s14q2_1to3 (.=0)
		gen fees = gs2_s14q1_1to3 + gs2_s14q2_1to3
		table gs2_s0q5_type, c(m fees)
		keep fees mauzaid schoolid
		rename schoolid2 schoolid
		sort mauzaid schoolid
		tempfile genschool
		save `genschool'

	use $pk/public_leaps_data/panels/public_school_panel_long, clear

	keep schoolid mauzaid school_private school_herf school_zaat* round reportcard mauza_numschools_gov mauza_numschools_private child_* mauza_wealth_std mauza_gini_expend school_enrollment

	keep if round==2

	gen mauza_numschools = mauza_numschools_gov + mauza_numschools_private

	gen pct_private = mauza_numschools_private / mauza_numschools

	bysort mauzaid: egen temp = sum(school_enrollment) if school_private==1
	bysort mauzaid: egen priv_enrollment = max(temp)
	drop temp

	bysort mauzaid: egen enrollment = sum(school_enrollment)

	gen enroll_pct_private = priv_enrollment / enrollment

	* Bring in fees
	sort mauzaid schoolid
	merge 1:1 mauzaid schoolid using `genschool'
	assert _m~=2
	keep if _m==3
	drop _m

	* Bring in mauza vars
	sort mauzaid
	merge m:1 mauzaid using $pk/public_leaps_data/public_mauza
	assert _m==3
	drop _m

save $pk/constructed_data/school_descriptives_withfees.dta, replace



