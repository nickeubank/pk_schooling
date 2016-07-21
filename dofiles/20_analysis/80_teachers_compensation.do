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

local standard_controls " i.district"

gen ln_avg_absent = log(avg_absent)
gen ln_ab_frac_interact = ln_avg_absent * mauza_zaat_frac


*********
* Absenteeism
*********
eststo clear
foreach private_type in 0 1 {
	eststo: xi: reg ln_salary ///
					avg_absent ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	if `private_type' == 0 {
		assert `e(N)' > 3650
	}
	else {
		assert `e(N)' > 4300
	}

	eststo: xi: reg ln_salary ///
					avg_absent mauza_zaat_frac ab_frac_interact ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	if `private_type' == 0 {
		assert `e(N)' > 3650
	}
	else {
		assert `e(N)' > 4300
	}


}
esttab  using $pk/docs/results/teachercompensation_absenteeism.tex, b(a2)  se  replace nogaps compress label booktabs noconstant ///
	mgroups("Government Teachers" "Private Teachers" , pattern( 0 0 1 0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "Log Salary" "Log Salary" "Log Salary" "Log Salary" ) title(Teacher Compensation and Absenteeism\label{absenteeism}) ///
	indicate( "District Fixed Effects=_Id*") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnote("Errors clustered at village-level")

eststo clear
foreach private_type in 0 1 {

	eststo: xi: reg ln_salary ///
					avg_valueadded ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	if `private_type' == 0 {
		assert `e(N)' > 1200
	}
	else {
		assert `e(N)' > 740
	}



	eststo: xi: reg ln_salary ///
					avg_valueadded mauza_zaat_frac va_frac_interact ///
					`standard_controls' ///
					if school_private==`private_type', cluster(mauzaid)

	if `private_type' == 0 {
		assert `e(N)' > 1200
	}
	else {
		assert `e(N)' > 740
	}


}

esttab  using $pk/docs/results/teachercompensation_valueadded.tex, b(a2)  se  replace nogaps compress label booktabs noconstant ///
	mgroups("Government Teachers" "Private Teachers" , pattern( 0 0 1 0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "Log Salary" "Log Salary" "Log Salary" "Log Salary" ) title(Teacher Compensation and Value-Added\label{valueadded}) ///
	indicate( "District Fixed Effects=_Id*") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnote("Teacher value-added estimates control for student age, age squared, wealth index, parental education," ///
			"and class. Teachers with less than 5 students dropped from analysis. Errors clustered at village-level")


