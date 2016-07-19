
use $pk/constructed_data/school_descriptives_withfees.dta, clear


* Eye ball a few things
egen id=group(mauzaid schoolid)

gen fee_pre_windsor = fee

sum fees if school_private==1, d
replace fees=r(p95) if fees>r(p95)
capture file close myfile
file open myfile using "$pk/docs/results/fee_windsor.tex", write replace
file write myfile %7.0f (r(p95))
file close myfile


capture eststo clear
label var mauza_zaat_frac "Biraderi Fractionalization"
label var mauza_wealth "Village: Median Expenditures"

eststo: xi: reg fees mauza_zaat_frac  i.district if school_private==1, cluster(mauzaid)
local avg_value = _b[mauza_zaat_frac]

eststo: xi: reg fees mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1, cluster(mauzaid)
local avg_value = _b[mauza_zaat_frac] + `avg_value'

eststo: xi: reg fees mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1 [pw=school_enrollment], cluster(mauzaid)
local avg_value = _b[mauza_zaat_frac] + `avg_value'

esttab  using $pk/docs/results/fees.tex, b(a2) se replace nogaps compress label booktabs noconstant ///
 title(Annual Private School Fees\label{fees}) ///
	mtitle("Weighted by School" "Weighted by School" "Weighted by Primary Students") ///
	indicate(District Fixed Effects =_Id*) wrap ///
	star(* 0.10 ** 0.05 *** 0.01)


local avg_value = `avg_value' / 3
capture file close myfile
file open myfile using "$pk/docs/results/fee_avg_effect.tex", write replace
file write myfile %7.0f (`avg_value')
file close myfile


sum fees if school_private == 1, d

capture file close myfile
file open myfile using "$pk/docs/results/fee_median_fee.tex", write replace
file write myfile %7.0f (r(p50))
file close myfile

* Make sure smaller with adjustment
eststo: xi: reg fees mauza_zaat_frac  i.district if school_private==1, cluster(mauzaid)
local pre = _b[mauza_zaat_frac]
eststo: xi: reg fee_pre_windsor mauza_zaat_frac  i.district if school_private==1, cluster(mauzaid)
local post = _b[mauza_zaat_frac]

assert `pre' < `post'
