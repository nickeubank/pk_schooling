
use $pk/constructed_data/school_descriptives_withfees.dta, clear


* Eye ball a few things
egen id=group(mauzaid schoolid)
gen lnfee=ln(fees)

* yay!
* kdensity fees if school_private==1

sum fees if school_private==1, d
replace fees=r(p95) if fees>r(p95)
sum fees if school_private==1, d

sum fees


	* Bigger when windsorized, smaller when log it.
gen dist2=(district==2)
gen dist3=(district==3)


* Actual regressions
capture eststo clear
label var mauza_zaat_frac "Biraderi Fractionalization"
label var mauza_wealth "Village: Median Expenditures"

eststo: xi: reg fee mauza_zaat_frac  i.district if school_private==1, cluster(mauzaid)
eststo: xi: reg fee mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1, cluster(mauzaid)
eststo: xi: reg fee mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1 [pw=school_enrollment], cluster(mauzaid)

esttab  using $pk/docs/results/fees.tex, b(a2) replace nogaps compress label booktabs noconstant ///
 title(Annual Private School Fees\label{fees}) ///
	mtitle("Weighted by School" "Weighted by School" "Weighted by Primary Students") ///
	indicate(District Fixed Effects =_Id*) wrap ///
	starlevels(* 0.10 ** 0.05 *** 0.01)
