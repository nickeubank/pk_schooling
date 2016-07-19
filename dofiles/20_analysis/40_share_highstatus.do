clear
set more off

*******************
* School type by caste
*******************
use $pk/constructed_data/school_segregation, clear




gen ln_hh=ln(M_numhh)
gen interact_zaat_private=mauza_zaat_frac*school_private
label var interact_zaat_private "Fractionalization * Private"
label var ln_hh "Log Village Size"
label var mauza_pct_high "Village: Pct High Status"
label var M_literacy "Village: Pct Adults Literate"
label var school_private "Private School"
label var M_wealth "Median Village Expenditure"


eststo clear
eststo: xi:reg school_pct_high school_private mauza_zaat_frac interact_zaat_private M_wealth M_literacy ln_hh mauza_pct_high ///
			 i.district [pw=number_students], cluster(mauzaid)


eststo: xi:reg school_pct_high school_private mauza_zaat_frac interact_zaat_private i.mauzaid [pw=number_students], cluster(mauzaid)

esttab  using $pk/docs/results/high_pooling.tex, b(a2) se replace nogaps compress label booktabs noconstant ///
	mtitle( "Pct of Students High Status" "Pct of Students High Status" ) title(Student Body Social Composition\label{highpooling}) ///
	indicate( "District Fixed Effects=_Id*" "Village Fixed Effects=_Ima*")  ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnotes("Standard errors clustered at village level. Weighted by number of students.")


