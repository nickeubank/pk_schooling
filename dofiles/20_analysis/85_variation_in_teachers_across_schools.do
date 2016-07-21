clear
set more off

*****
* Load
*****

use $pk/constructed_data/custom_teacher_dataset, clear

duplicates report teachercode 
display `r(N)'


gen school_government=(school_private==0) if school_private~=.
label var school_facilities_basic "\specialcellc{Basic School \\ Facility Index}"
label var ln_numhh "\specialcell{Log Number \\ of Households}"
label var M_wealth "\specialcell{Median Village \\ Expenditures}"



foreach x in government private {
	eststo clear
	
	foreach indicator in avg_absent female avg_local has_matricplus avg_teacher_english_theta {

		eststo : xi:reg `indicator' mauza_zaat_frac i.district M_wealth ln_numhh ///
				if school_`x' == 1, cluster(mauzaid)		

		if "`x'" == "government" {

			if "`indicator'" == "avg_teacher_english_theta" {
				assert `e(N)' > 1000
			}
			else{
				assert `e(N)' > 3500
			}

		}
		else {
			if "`indicator'" == "avg_teacher_english_theta" {
				assert `e(N)' > 1000
			}
			else{
				assert `e(N)' > 4600
			}
		}

	}


	preserve
		use $pk/constructed_data/school_descriptives_withfees.dta, clear

		label var school_facilities_basic "\specialcellc{Basic School \\ Facility Index}"
		label var ln_numhh "\specialcell{Log Number \\ of Households}"
		label var M_wealth "\specialcell{Median Village \\ Expenditures}"

		gen school_government=(school_private==0) if school_private~=.


		eststo : xi:reg school_facilities_basic mauza_zaat_frac i.district M_wealth ln_numhh ///
					if school_`x' == 1 , cluster(mauzaid)		


		if "`x'" == "government" {
			assert `e(N)' > 490
		}
		else {
			assert `e(N)' > 290
		}

	restore

	local upper=proper("`x'")
	esttab  using $pk/docs/results/`x'_teachers.tex, b(a2)  se  replace nogaps compress label noconstant booktabs ///
		title(`upper' Teacher Characteristics and Village Fractionalization\label{`x'teachers}) ///
		indicate(District Fixed Effects=_Id*) ///
		 substitute({table} {sidewaystable})  ///
		mtitle("\specialcellc{Days Absent \\ Last Month}" "Female" "\specialcellc{Local \\ Teacher}" ///
			   "\specialcellc{More than Grade \\ School Educ}" "\specialcellc{Teacher's \\ English Score}" ///
			   "\specialcellc{Basic School \\ Facility Index}") ///
		star(* 0.10 ** 0.05 *** 0.01)  ///
		addnote("All results clustered at the village level.")	
}



