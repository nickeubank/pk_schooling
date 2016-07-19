
use $pk/public_leaps_data/public_mauza.dta, replace

assert _N == 112

***
* Show fractionalization distribution
***

twoway (kdensity mauza_zaat_frac if district==1 ) ///
	   (kdensity mauza_zaat_frac if district==2 ) ///
	   (kdensity mauza_zaat_frac if district==3 ), ///
			title("Village Biraderi Fractionalization") subtitle("By District") ///
			legend(label(1 "Attock") label(2 "Faisalabad") label(3 "Rahim Yar Khan")) ///
			xtitle(Village Fractionalization) ytitle(Density)

	graph export $pk/docs/results/village_frac_by_district.pdf, replace

label var mauza_zaat_frac "Fractionalization"

***
* Regression for significance
***


eststo clear
foreach indicator in M_wealth M_literacy M_gini_land M_penrolled M_schools_perhh ln_numhh {
		eststo : xi:reg `indicator' mauza_zaat_frac i.district, cluster(district)
	}

esttab  using $pk/docs/results/village_by_frac.tex, b(a2) replace nogaps compress label noconstant booktabs ///
		title(Village Characteristics and Fractionalization\label{villagebyfrac}) se ///
		indicate(District FE=_Id*) ///
		mtitle("\specialcellc{Median\\Wealth}" "\specialcellc{Adult\\Literacy}" "\specialcellc{Land\\Gini}" "\specialcellc{Enrollment\\Pct}" "\specialcellc{Schools\\per HH}" "Log Num HH") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		addnote("Standard errors clustered by District.")

