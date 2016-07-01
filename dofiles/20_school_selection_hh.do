* *********
* Look at school choice from the household side
**********
set more off
use $pk/constructed_data/hh_child_cross_section.dta, clear


eststo clear
eststo: xi:areg school_private above_avg_intell mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above_avg_intell mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(hhid)

esttab  using $pk/docs/results/hhselection.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselection}) ///
	mtitle("Village FE" "HH FE")  ///
	starlevels(* 0.10 ** 0.05 *** 0.01)

**********
* Does premium on intelligence change?
**********
gen above_frac_interact=above*mauza_zaat_frac
label var above_frac_interact "Child Above Avg * Fractionalization"
label var above_avg_intell "Mom: Child Above Avg Intelligence"


	count if school_private ~= . & above_avg_intell ~= .

eststo clear

local controls above_avg_intell mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female
eststo: xi:areg school_private `controls' [pw=hh_weight], cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private `controls' [pw=hh_weight], cluster(mauzaid) a(hhid)

eststo: xi:areg school_private `controls' [pw=hh_weight] if zaat_high_status==1, cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private `controls' [pw=hh_weight] if zaat_high_status==1, cluster(mauzaid) a(hhid)

eststo: xi:areg school_private `controls' [pw=hh_weight] if zaat_high_status==0, cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private `controls' [pw=hh_weight] if zaat_high_status==0, cluster(mauzaid)  a(hhid)


esttab  using $pk/docs/results/hhselection_interaction.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselectioninteraction}) ///
mgroups("All" "High Status" "Low Status" , pattern(0 0 1  0 1 0    ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle("Village FE" "HH FE" "Village FE" "HH FE" "Village FE" "HH FE") ///
	starlevels(* 0.10 ** 0.05 *** 0.01)
