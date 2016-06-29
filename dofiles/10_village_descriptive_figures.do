
use $pk/public_leaps_data/public_mauza.dta, replace

* Show fractionalization distribution

twoway(kdensity mauza_zaat_frac if district==1 ) ///
	(kdensity mauza_zaat_frac if district==2 ) ///
	(kdensity mauza_zaat_frac if district==3 ), ///
	title("Village Fractionalization") subtitle("By District") ///
	legend(label(1 "Attock") label(2 "Faisalabad") label(3 "Rahim Yar Khan")) ///
	xtitle(Village Fractionalization) ytitle(Density)

	graph export $pk/docs/results/village_frac_by_district.pdf, replace


label var mauza_zaat_frac "Fractionalization"

eststo clear
foreach indicator in M_wealth M_literacy M_gini_land M_penrolled schools_perhh ln_numhh {
		eststo : xi:reg `indicator' mauza_zaat_frac i.district
	}

esttab  using $pk/docs/results/village_by_frac.tex, b(a2) replace nogaps compress label noconstant booktabs ///
		title(Village Characteristics and Fractionalization\label{villagebyfrac}) ///
		indicate(District FE=_Id*) ///
		mtitle("\specialcellc{Median\\Wealth}" "\specialcellc{Adult\\Literacy}" "\specialcellc{Land\\Gini}" "\specialcellc{Enrollment\\Pct}" "\specialcellc{Schools\\per HH}" "Log Num HH") ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///

tabstat  M_wealth M_literacy M_penrolled schools_perhh M_numhh, by(zfrac3) save format(%9.2g)
matrix define results=r(Stat3)\r(Stat2)\r(Stat1)\r(StatTotal)
matrix rownames results= "Highest_Frac" "Moderate_Frac" "Lowest_Fract" "All"
matrix colnames results="Median_Expend" "Adult_Lit_Rate" "Pct_Enrollment" "Schools_per_HH"  "Num_Households"

outtable using $pk/docs/results/village_summary, mat(results)  replace clabel(vsummary) format(%9.2g) caption(Village Summary Statistics)

