
* **************
* Now let's bring in school fractionalization
* **************

	* Get fees
		use $datadir/school/generalschool1/generalschool1, clear
		
		keep mauzaid schoolid gs1_s14q1 gs1_s13q1_1to3 gs1_s13q2_1to3 gs1_s0q5_type
		recode gs1_s13q1_1to3 gs1_s13q2_1to3 (.=0)
		gen fees=gs1_s13q1_1to3+gs1_s13q2_1to3
		table gs1_s0q5_type, c(m fees)
		keep fees mauzaid schoolid
		rename schoolid1 schoolid
		sort mauzaid schoolid
		tempfile genschool
		save `genschool'
		

	use $datadir/constructed/school_panel/school_panel_long, clear

	keep schoolid mauzaid school_private school_herf school_zaat* round reportcard mauza_numschools_gov mauza_numschools_private child_* mauza_wealth_std mauza_gini_expend school_enrollment
	
	
	
	keep if round==1
	
	gen mauza_numschools=mauza_numschools_gov+mauza_numschools_private

	gen pct_private=mauza_numschools_private/mauza_numschools
	
	bysort mauzaid: egen temp=sum(school_enrollment) if school_private==1
	bysort mauzaid: egen penrollment=max(temp)
	drop temp

	bysort mauzaid: egen enrollment=sum(school_enrollment)
	
	gen enroll_pct_private=penrollment/enrollment
	

	* Bring in fees
	sort mauzaid schoolid
	merge 1:1 mauzaid schoolid using `genschool'
	assert _m~=2
	keep if _m==3
	drop _m



	* Bring in mauza vars
	sort mauzaid
	merge mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
	keep if _m==3
	
	* THIS I SHOULD FIX!!!!!
	duplicates drop mauzaid schoolid round, force

	egen mtag=tag(mauzaid)

	table zfrac4, c(m enroll_pct_private m pct_private)
	reg pct_private mauza_zaat_frac if mtag==1
	
	
	* twoway(lowess school_herf mauza_zaat_frac if school_private==0)(scatter school_herf mauza_zaat_frac if school_private==0)(lfit mauza_zaat_frac  mauza_zaat_frac)
	


egen id=group(mauzaid schoolid)
gen lnfee=ln(fees)

* yay!
* kdensity fees if school_private==1

sum fees if school_private==1, d
replace fees=r(p95) if fees>r(p95)
sum fees if school_private==1, d

sum fees 
drop _m

sort mauzaid schoolid 
merge 1:1 mauzaid schoolid using $datadir/constructed/ethnic_info/raw/school_segregation
tab _m
drop if _m~=3

	* Bigger when windsorized, smaller when log it. 
gen dist2=(district==2)
gen dist3=(district==3)

capture eststo clear
label var mauza_zaat_frac "Biraderi Fractionalization"
label var mauza_wealth "Village: Median Expenditures"

eststo: xi: reg fee mauza_zaat_frac  i.district if school_private==1, cluster(mauzaid) 
eststo: xi: reg fee mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1, cluster(mauzaid) 
eststo: xi: reg fee mauza_zaat_frac mauza_wealth mauza_gini_expend i.district if school_private==1 [pw=number_students], cluster(mauzaid) 


esttab  using $datadir/constructed/ethnic_info/docs/regressions/fees.tex, b(a2) replace nogaps compress label booktabs noconstant ///
 title(Annual Private School Fees\label{fees}) ///
	mtitle("Weighted by School" "Weighted by School" "Weighted by Primary Students") ///
	indicate(District Fixed Effects =_Id*) wrap ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 



/*
twoway(kdensity fee if zfrac3==1 & school_private==1)(kdensity fee if zfrac3==2 & school_private==1)(kdensity fee if zfrac3==3 & school_private==1), title(Distribution of Fees) subtitle(By Fractionalization) legend(label(1 "Private Schools in 1/3 Least Fractionalized Villages") label(2 "Private Schools in Middle Third of Villages") label(3 "Private Schools in 1/3 Most Fractionalized Villages") rows(3))


