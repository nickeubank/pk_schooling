clear
set more off


use $pk/constructed_data/school_segregation, clear


*********
* Intra-versus-Inter-School herf
*********
egen mtag = tag(mauzaid)

foreach type in priv govt {

		if ("`type'"=="all"){
			local propertype="All Schools"
			local ytitle="School"
		}
		if ("`type'"=="priv"){
			local propertype="Private Schools"
			local ytitle="Private School"
		}
		if ("`type'"=="govt"){
			local propertype="Government Schools"
			local ytitle="Government School"
		}



		twoway (scatter intraschool_frac mauza_frac_all [fw=number_students] if `type'==1, msymbol(circle_hollow)) ///
		(lpoly intraschool_frac mauza_frac_all if `type'==1 [fw=number_students] , lstyle(bold) lwidth(thick) deg(1)) ///
		(lfit mauza_frac_all mauza_frac_all if mtag==1, lpattern(dash)), ///
		aspectratio(1) ///
		legend(label(3 "45 Degree") label(2 "Intra-School Fractionalization" "Weighted by Number of Students") label(1 "Individual Schools" "Scaled to # Primary Students") cols(1)) ///
		xtitle("Village Fractionalization (For Enrolled Students)") ytitle("Intra-`ytitle' Fractionalization") title(School Segregation) subtitle(`propertype')
	tempfile type_`type'
	graph save `type_`type''.gph, replace
	graph export $pk/docs/results/intra_versus_intervillage_frac_`type'.pdf, replace

}


	graph combine `type_govt'.gph `type_priv'.gph, note("Fractionalization is probability two randomly chosen students will be from different castes.")
	graph export $pk/docs/results/intra_versus_intervillage_frac_combined.pdf, replace
