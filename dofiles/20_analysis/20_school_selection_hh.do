* *********
* Look at school choice from the household side
**********
set more off
use $pk/constructed_data/hh_child_cross_section.dta, clear


eststo clear
eststo: xi:areg school_private above_avg_intell mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above_avg_intell mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(hhid)

esttab  using $pk/docs/results/hhselection.tex, b(a2) se replace nogaps compress label noconstant ///
	booktabs ///
	title(Probability Enrolled Child Attends Private School\label{hhselection}) ///
	mtitle("Village FE" "HH FE")  ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnotes("Standard errors clustered at village level.")



