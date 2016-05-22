clear
set more off

* *********
* Now do children level...
* *********

clear
set more off


* ************
* Now look at child changes from 1 to 4.
* ************

use $datadir/constructed/child_panel/child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
assert _m~=1
tab _m
keep if _m==3
count


	* keep if child_panel==1 
	
	tsset childcode round




	* Make "change"
	rename child_pca_4years child_pca
	gen child_age2=child_age^2 
	label var child_age2 "Age Squared"
	label var child_pca "Child's Wealth Index"
	label var child_parentedu "Educated Parent"
	label var mauza_gini_land "Village Land Gini"
	label var mauza_literacy "Village: Pct Adults Literate"
	label var school_private "Private School"
	label var mauza_wealth "Median Village Expenditure"
	gen ln_hh=ln(mauza_numhh)
	label var ln_hh "Log Village Size"
	* ********
	* Enrollment by Frac
	* *********
	

	keep if round==1
	bysort mauzaid: egen private_share=mean(school_private) if child_enrolled==1
	label var private_share "Pct Class 3 in Private"
	egen mtag=tag(mauzaid) if private_share~=.

	capture eststo clear
	label var mauza_zaat_frac "Biraderi Fractionalization"
	egen matag=tag(mauzaid)
	eststo: xi:reg private_share mauza_zaat_frac i.district if mtag==1
	eststo: xi:reg private_share mauza_zaat_frac i.district mauza_wealth mauza_gini_land mauza_literacy ln_hh if mtag==1
	esttab  using $datadir/constructed/ethnic_info/docs/regressions/private_share.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	 title("Share of Enrolled Students in Private Schools"\label{privateshare}) ///
		indicate( "District Fixed Effects=_Id*") ///
		starlevels(* 0.10 ** 0.05 *** 0.01) 
