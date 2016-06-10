clear
set more off

use $datadir/constructed/xvars/mauza_xvars, clear
drop M_frac_zaat

gen schools_perhh=(M_numschools_gov+M_numschools_private)/M_numhh
gen schools_perhh_g=(M_numschools_gov)/M_numhh
gen schools_perhh_p=(M_numschools_private)/M_numhh


sort mauzaid
merge mauzaid using $pk/public_leaps_data/public_mauza
tab _m
keep if _m==3

label var M_wealth "Median Montly Expenditures"
label var M_literacy "Adult Literacy Rate"
label var M_penrolled "Percent of Children Enrolled"
label var schools_perhh "Schools per Household"
label var M_numhh "Number of Households"



* Show fractionalization distribution

twoway(kdensity mauza_zaat_frac if district==1 ) ///
	(kdensity mauza_zaat_frac if district==2 ) ///
	(kdensity mauza_zaat_frac if district==3 ), ///
	title("Village Fractionalization") subtitle("By District") ///
	legend(label(1 "Attock") label(2 "Faisalabad") label(3 "Rahim Yar Khan")) ///
	xtitle(Village Fractionalization) ytitle(Density)
	
	graph export $pk/docs/graphs/village_frac_by_district.pdf, replace

qqq
tabstat  M_wealth M_literacy M_penrolled schools_perhh M_numhh, by(zfrac3) save format(%9.2g)

matrix define results=r(Stat3)\r(Stat2)\r(Stat1)\r(StatTotal)
matrix rownames results= "Highest_Frac" "Moderate_Frac" "Lowest_Fract" "All"
matrix colnames results="Median_Expend" "Adult_Lit_Rate" "Pct_Enrollment" "Schools_per_HH"  "Num_Households" 

outtable using $pk/docs/tables/village_summary, mat(results)  replace clabel(vsummary) format(%9.2g) caption(Village Summary Statistics) 

* Now demean
foreach x in M_wealth M_literacy M_penrolled schools_perhh M_numhh {
	gen `x'_de=.
	forvalues z=1/3 {
		sum `x' if district==`z'
		replace `x'_de=`x'-r(mean) if district==`z'
	}
}

tabstat  M_wealth_de M_literacy_de M_penrolled_de schools_perhh_de M_numhh_de, by(zfrac3) save format(%9.2g)
matrix define results=r(Stat3)\r(Stat2)\r(Stat1)\r(StatTotal)
matrix rownames results= "Highest_Frac" "Moderate_Frac" "Lowest_Fract" "All"
matrix colnames results="Median_Expend" "Adult_Lit_Rate" "Pct_Enrollment" "Schools_per_HH"  "Num_Households" 

outtable using $pk/docs/tables/village_summary_demeaned, mat(results) caption("Summary Statistics, After Subracting District Averages") replace clabel(vsummarydemeaned) format(%9.2g) 


	qqq
	/*

tabout south race collgrad [iw=wt] using table2.txt,, ///
cells(freq row col) format(0c 1p 1p) clab(_ _ _) ///
layout(rb) h3(nil) ///
replace ///
style(tex) bt font(bold) cl1(2-4) ///
topf(top.tex) botf(bot.tex) topstr(11cm) botstr(nlsw88.dta)


qqq
table zfrac3, c( m M_wealth_census m M_literacy m M_penrolled m schools_perhh m M_numhh)
 	* No trends in wealth or literacy. 
	* More enrollment in low frac 
	* More schools  per cap in fractionalized
	* Higher frac=bigger.
	
qqq
	
table zfrac3, c( m schools_perhh m schools_perhh_g m schools_perhh_p)
	* Most of difference is in number of private schools in fractionalized villages.
	* No actual difference once ignore four outliers. 
	
	
	
xi:reg schools_perhh mauza_zaat_frac i.district
xi:reg schools_perhh mauza_zaat_frac 
xi:reg schools_perhh_g mauza_zaat_frac i.district
xi:reg schools_perhh_p mauza_zaat_frac 
xi:reg schools_perhh_p mauza_zaat_frac i.district
 
twoway(lowess schools_perhh_p mauza_zaat_frac if schools_perhh_p<0.04 )(scatter  schools_perhh_p mauza_zaat_frac if schools_perhh_p<0.04 )
	
	