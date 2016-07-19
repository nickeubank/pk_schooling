clear
set more off

******
* Load
******

use $pk/constructed_data/custom_teacher_dataset.dta, clear

*******
* Sample restrictions
*******

eststo clear

local standard_controls "i.district"

gen ln_avg_absent = log(avg_absent)
gen ln_ab_frac_interact = ln_avg_absent * mauza_zaat_frac


foreach private_type in 0 1 {

	eststo: xi: reg ln_salary ///
					avg_absent ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	eststo: xi: reg ln_salary ///
					avg_absent mauza_zaat_frac ab_frac_interact ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	eststo: xi: reg ln_salary ///
					avg_valueadded ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	eststo: xi: reg ln_salary ///
					avg_valueadded mauza_zaat_frac va_frac_interact ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

}

esttab  using $pk/docs/results/teachercompensation.tex, b(a2)  se  replace nogaps compress label booktabs noconstant ///
	mgroups("Private Teachers" "Government Teachers" , pattern( 0 0   1 0     ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "Log Salary" "Log Salary" "Log Salary" "Log Salary" ) title(Village Fractionalization and Teacher Compensation\label{teachercompensation}) ///
		indicate( "Mauza Fixed Effects=_Id*") ///
	star(* 0.10 ** 0.05 *** 0.01)

