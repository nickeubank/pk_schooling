clear
set more off

*****
* Load
*****

use $pk/constructed_data/custom_teacher_dataset, clear


gen school_government=(school_private==0) if school_private~=.


foreach x in government private {
	eststo clear
	
	foreach indicator in avg_absent female avg_local avg_teacher_english_theta has_matricplus {

		eststo : xi:reg `indicator' mauza_zaat_frac i.district M_wealth ln_numhh ///
				if school_`x'==0 [pw=avg_students_peryear], cluster(mauzaid)		

	}


	preserve
		use $pk/constructed_data/school_descriptives_withfees.dta, clear

		label var school_facilities_basic "\specialcellc{Basic School \\\\ Facility Index}"
		gen school_government=(school_private==0) if school_private~=.


		eststo : xi:reg school_facilities_basic mauza_zaat_frac i.district M_wealth ln_numhh ///
					if school_`x'==0 , cluster(mauzaid)		

	restore

	local upper=proper("`x'")
	esttab  using $pk/docs/results/`x'_teachers.tex, b(a2)  se  replace nogaps compress label noconstant booktabs ///
		title(`upper' Teacher Characteristics and Village Fractionalization\label{`x'teachers}) ///
		indicate(District Fixed Effects=_Id*) ///
		 substitute({table} {sidewaystable})  ///
		star(* 0.10 ** 0.05 *** 0.01) 
		
		* note("\specialcell{All results clustered at the village level.\\All regressions weighted by number of students.\\Robust t-statistics presented in parenthesis.}")
	
}


