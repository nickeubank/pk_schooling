clear
set more off

* *********
* Now do children level...
* *********

clear
set more off

* ********************
* Want to look at year 1 to year 4 shifts to get full effects.
* First, let's just look at:
* 	- Change in test scores -- village level effects and split by ethnic fractionalization
* 	- Change of schools
* 	- change in accuracy of parental perceptions
* 	- increased class diversity!
* ********************



use $pk/constructed_data/custom_child_panel, replace

* ********
* Enrollment by Frac
* *********

keep if round==1 & child_enrolled==1
bysort mauzaid: egen private_share=mean(school_private) 
label var private_share "Share Students in Private School"

capture eststo clear
egen matag=tag(mauzaid)

gen ln_hh = log(M_numhh)
label var ln_hh "Log Num HHs"

eststo: xi:reg private_share mauza_zaat_frac i.district if matag==1, cluster(district)
eststo: xi:reg private_share mauza_zaat_frac i.district mauza_wealth mauza_gini_land mauza_literacy ln_hh if matag==1, cluster(district)


esttab  using $pk/docs/results/private_share.tex, b(a2) se replace nogaps compress label booktabs noconstant ///
 title("Share of Enrolled Students in Private Schools"\label{privateshare}) ///
indicate( "District Fixed Effects=_Id*") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnote("Results clustered at district level.")

