* *********
* Look at school choice from the household side
**********
set more off
set matsize 10000
use $pk/constructed_data/hh_cross_section.dta, clear


	* Make some variables
	keep if hf1_s5q2==1
	gen school_private=(hf1_s5q3a1_type==2) if hf1_s5q3a1_type~=3
	gen age2=age^2
	gen intelligent=hf1_s8q2
	gen frac_intelligent_interact=mauza_zaat_frac*intelligent
 	gen above=(intelligent>=4) if intelligent~=.
	gen hardworking=(hf1_s8q3>=4) if hf1_s8q3~=.


	gen wealth_frac=hh_pca_4years*mauza_zaat_frac
	gen gap=close_pri_primary-close_govt_primary


* *******
* Now throw in caste
* ********

tab hm1_s0q8_zaat
tab hm1_s0q8_zaat, nol



gen status=""
replace status="High" if hm1_s0q8_zaat==1
replace status="High" if hm1_s0q8_zaat==2
replace status="Low" if hm1_s0q8_zaat==3
replace status="High" if hm1_s0q8_zaat==4
replace status="Low" if hm1_s0q8_zaat==5
replace status="High" if hm1_s0q8_zaat==6
replace status="High" if hm1_s0q8_zaat==8
replace status="High" if hm1_s0q8_zaat==9
replace status="Low" if hm1_s0q8_zaat==12
replace status="Low" if hm1_s0q8_zaat==13
replace status="High" if hm1_s0q8_zaat==15
replace status="Low" if hm1_s0q8_zaat==16
replace status="High" if hm1_s0q8_zaat==17
replace status="Low" if hm1_s0q8_zaat==18
replace status="High" if hm1_s0q8_zaat==20
replace status="High" if hm1_s0q8_zaat==22
replace status="Low" if hm1_s0q8_zaat==21


gen status2=.
replace status2=0 if status=="Low"
replace status2=1 if status=="High"

gen status_b=""
replace status_b="Medium" if hm1_s0q8_zaat==2
replace status_b="Low" if hm1_s0q8_zaat==3
replace status_b="Medium" if hm1_s0q8_zaat==1
replace status_b="High" if hm1_s0q8_zaat==4
replace status_b="Low" if hm1_s0q8_zaat==5
replace status_b="Medium" if hm1_s0q8_zaat==6
replace status_b="Medium" if hm1_s0q8_zaat==8
replace status_b="Medium" if hm1_s0q8_zaat==16
replace status_b="High" if hm1_s0q8_zaat==9
replace status_b="Low" if hm1_s0q8_zaat==11
replace status_b="Low" if hm1_s0q8_zaat==12
replace status_b="Low" if hm1_s0q8_zaat==13
replace status_b="High" if hm1_s0q8_zaat==14
replace status_b="Low" if hm1_s0q8_zaat==15
replace status_b="High" if hm1_s0q8_zaat==17
replace status_b="Low" if hm1_s0q8_zaat==20
replace status_b="Low" if hm1_s0q8_zaat==21
replace status_b="High" if hm1_s0q8_zaat==22


gen ln_hh=ln(M_numhh)

* First intelligence

label var above "Mom Reports Child Above Average Intelligence"
label var mom_haseduc "Mom Has Some Schooling"
label var dad_haseduc "Mom Has Some Schooling"
label var hh_pca_4years "Log Month Expenditure"
label var age "Age"
label var age2 "Age Squared"
label var female "Female"

label var school_private "Private School"
eststo clear
eststo: xi:areg school_private above mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(hhid)

esttab  using $pk/docs/results/hhselection.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselection}) ///
	mtitle("Village FE" "HH FE")  ///
	starlevels(* 0.10 ** 0.05 *** 0.01)

**********
* Does premium on intelligence change?
**********
gen above_frac_interact=above*mauza_zaat_frac
label var above_frac_interact "Child Above Avg * Fractionalization"
label var above "Mom: Child Above Avg Intelligence"


	count if school_private~=. & above~=.

eststo clear
eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female  [pw=hh_weight], cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight], cluster(mauzaid) a(hhid)

eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight] if status2==1, cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight] if status2==1, cluster(mauzaid) a(hhid)

eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female [pw=hh_weight] if status2==0, cluster(mauzaid) a(mauzaid)
eststo: xi:areg school_private above mauza_zaat_frac above_frac_interact mom_haseduc dad_haseduc hh_pca_4years age age2 female  [pw=hh_weight] if status2==0, cluster(mauzaid)  a(hhid)


esttab  using $pk/docs/results/hhselection_interaction.tex, b(a2) replace nogaps compress label noconstant 	title(School Choice and Child Intelligence\label{hhselectioninteraction}) ///
mgroups("All" "High Status" "Low Status" , pattern(0 0 1  0 1 0    ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
	mtitle("Village FE" "HH FE" "Village FE" "HH FE" "Village FE" "HH FE") ///
	starlevels(* 0.10 ** 0.05 *** 0.01)
