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

local standard_controls "female avg_age exp_2 exp_3 educ_2 educ_3 educ_4 educ_5  i.district"

eststo: xi: reg avg_salary ///
				avg_absent mauza_zaat_frac ab_frac_interact ///
				`standard_controls' ///
				if school_private==1  [pw=avg_students_peryear], cluster(mauzaid)

eststo: xi: reg avg_salary ///
				avg_valueadded mauza_zaat_frac va_frac_interact ///
				 avg_absent `standard_controls' ///
				if school_private==1 [pw=avg_students_peryear], cluster(mauzaid)


eststo: xi: reg avg_salary ///
				avg_absent mauza_zaat_frac ab_frac_interact ///
				avg_absent `standard_controls' ///
				if school_private==0 [pw=avg_students_peryear], cluster(mauzaid)

eststo: xi: reg avg_salary ///
				avg_valueadded mauza_zaat_frac va_frac_interact ///
				avg_absent `standard_controls' ///
				if school_private==0  [pw=avg_students_peryear], cluster(mauzaid)


esttab  using $pk/docs/results/teachercompensation.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mgroups("Private Teachers" "Government Teachers" , pattern( 0 0   1 0     ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle( "Log Salary" "Log Salary" "Log Salary" "Log Salary" ) title(Village Fractionalization and Teacher Compensation\label{teachercompensation}) ///
		indicate( "District Fixed Effects=_Id*") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) drop( "exp*" "educ*")

