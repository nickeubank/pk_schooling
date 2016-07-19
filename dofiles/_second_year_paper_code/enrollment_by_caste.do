clear
set more off


use $pk/public_leaps_data/school/school2/generalschool2, clear


* Get village caste

sort mauzaid
merge mauzaid using $pk/public_leaps_data/public_mauza

keep if _m==3


	* ****************
	* Number from first two groups:
	* ****************


	gen share_toptwo=gs2_s4q2_pcent1+gs2_s4q2_pcent2
	tab share_toptwo
	
	egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)
	
	* School top two
 	twoway(kdensity share_toptwo if zfrac3==1)(kdensity share_toptwo if zfrac3==2)(kdensity share_toptwo if zfrac3==3), ///
	title(School Caste Concentration) subtitle(By Village Fractionalization Terciles) ///
	ytitle("Density") xtitle(Percentage of Students in Largest Two Castes) ///
	legend(label(1 "Schools in Least Fractionalized 1/3 of Villages") label(2 "Schools in Middle 1/3 of Villages") label(3 "Schools in Most Fractionalized 1/3 of Villages") rows(3) size(vsmall))
	tempfile toptwo
	graph save `toptwo'.gph, replace

	graph export $pk/docs/graphs/school_toptwo.pdf, replace


	* Village
	egen mtag=tag(mauzaid)
	replace mauza_share_in_toptwo=mauza_share_in_toptwo
 	twoway(kdensity mauza_share_in_toptwo if zfrac3==1 & mtag==1)(kdensity mauza_share_in_toptwo if zfrac3==2 & mtag==1)(kdensity mauza_share_in_toptwo if zfrac3==3 & mtag==1), ///
	title(Village Caste Concentration) subtitle(By Village Fractionalization Terciles) ///
	ytitle("Density") xtitle(Percentage of Village in Largest Two Castes) ///
	legend(label(1 "Least Fractionalized 1/3 of Villages") label(2 "Middle 1/3 of Villages") label(3 "Most Fractionalized 1/3 of Villages") rows(3) size(vsmall))

	tempfile village_toptwo
	graph save `village_toptwo'.gph, replace

	graph export $pk/docs/graphs/village_toptwo.pdf, replace

	
	
	twoway(kdensity gs2_s4q1 if zfrac3==1)(kdensity gs2_s4q1 if zfrac3==2)(kdensity gs2_s4q1 if zfrac3==3), ///
	title(Total Castes Present) subtitle(By Village Fractionalization Terciles) ///
	ytitle("Density") xtitle(Total Number of Castes Represented in Preschool and Classes 1-5) ///
	legend(label(1 "Schools in Least Fractionalized 1/3 of Villages") label(2 "Schools in Middle 1/3 of Villages") label(3 "Schools in Most Fractionalized 1/3 of Villages") rows(3))

	tempfile total
	graph save `total'.gph, replace

	graph export $pk/docs/graphs/totalpresent.pdf, replace

	graph combine `village_toptwo'.gph `toptwo'.gph , title(Top Two Caste Shares) rows(1)
	graph export $pk/docs/graphs/toptwo_combined.pdf, replace
 	
qqq
* Want to do intra- versus inter-school herf.
	* Have to work off top six... :(
	
	
	gen priv=(gs2_s0q5_type==1)
	gen govt=(gs2_s0q5_type==2)
	gen all=1	

	
		
	* Intraschool
	forvalues x=1/6 {	
		gen inschoolshare_`x'=(gs2_s4q2_pcent`x'/100)
		gen inschoolsharesq_`x'=(gs2_s4q2_pcent`x'/100)^2
	}

	egen test=rowtotal(inschoolshare_*)
	sum test, d
	egen intraschool_frac=rowtotal(inschoolsharesq_*)
	replace  intraschool_frac=1- intraschool_frac
	label var intraschool_frac "Intra-school fractionalization"

	* Interschool
	* egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)
	
		* School Numbers
		forvalues zaat=1/26 {
			gen number_of_caste`zaat'=0
					forvalues groupcounter=1/6{
						replace number_of_caste`zaat'= number_of_caste`zaat'+(number_students_15 * gs2_s4q2_pcent`groupcounter') if gs2_s4q2_zaat`groupcounter'==`zaat'								 
					} 
				}


		* Add up to village by type
		
			foreach type in priv govt all {			
					forvalues zaat=1/26 {	
						bysort mauzaid: egen temp=sum(number_of_caste`zaat') if `type'==1
						bysort mauzaid: egen mauza_caste_`type'_`zaat'=max(temp)
						drop temp
					}
		
			egen mauza_students_`type'=rowtotal(mauza_caste_`type'_*)

			forvalues zaat=1/26 {
				gen mauza_share_`zaat'_`type'=mauza_caste_`type'_`zaat'/mauza_students_`type'
				gen mauza_sharesq_`zaat'_`type'=(mauza_caste_`type'_`zaat'/mauza_students_`type')^2
			}

				egen mauza_frac_`type'= rowtotal(mauza_sharesq_*_`type') if `type'==1
				replace mauza_frac_`type'=1-mauza_frac_`type'
				sum mauza_frac_`type', d
		}


	
	egen mtag=tag(mauzaid)
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
	graph export $pk/docs/graphs/intra_versus_intervillage_frac_`type'.pdf, replace

}


	graph combine `type_govt'.gph `type_priv'.gph, note("Fractionalization is probability two randomly chosen students will be from different castes.")
	graph export $pk/docs/graphs/intra_versus_intervillage_frac_combined.pdf, replace

* gen ln_num=ln(number_students)


	twoway(scatter intraschool_frac mauza_frac_all [fw=number_students], msymbol(circle_hollow))(lpoly intraschool_frac mauza_frac_all [fw=number_students], lstyle(bold) lwidth(thick) deg(1) )(lfit mauza_frac_all mauza_frac_all if mtag==1, lpattern(dash)), ///
		aspectratio(1) ///
		legend(label(3 "45 Degree") label(2 "Intra-School Fractionalization" "Weighted by Number of Students") label(1 "Individual Schools" "Scaled to # Primary Students") cols(1)) ///
		xtitle("Village Fractionalization (For Enrolled Students)") ytitle("Intra-School Fractionalization") title(School Segregation) ///
		note("Fractionalization is probability two randomly chosen students will be from different castes.")
	graph export $pk/docs/graphs/intra_versus_intervillage_frac.pdf, replace






reg intraschool_frac mauza_frac_all, cluster(mauzaid)
predict expected_score
gen school_segregation=expected_score-intraschool_frac
label var school_segregation "School Segregation"

rename schoolid2 schoolid

rename mauza_frac_all mauza_schoolkid_frac




keep mauzaid schoolid school_segregation number_students mauza_schoolkid_frac intraschool_frac
sort mauzaid schoolid
save $datadir/constructed/ethnic_info/raw/school_segregation, replace






