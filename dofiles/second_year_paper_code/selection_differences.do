clear

use $datadir/constructed/child_panel/child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/public_leaps_data/public_mauza
assert _m~=1
tab _m
keep if _m==3
count


keep if (round==1 & child_panel==1)|(round==3 & child_panel==2 & reportcard==0)
	
	tsset childcode round

	* Make "change"
	rename child_pca_4years child_pca
	gen child_age2=child_age^2 
	label var child_age2 "Age Squared"
	label var child_pca "Child's Wealth Index"
	label var child_parentedu "Educated Parent"

twoway(kdensity child_pca if zfrac3==1 & school_private==0)	(kdensity child_pca if zfrac3==1 & school_private==1), ///
legend(label(1 "Govt Students") label(2 "Private Students")) title(Low Fractionalization Village) ytitle(Density)
tempfile z1
graph save `z1'.gph, replace

twoway(kdensity child_pca if zfrac3==2 & school_private==0)	(kdensity child_pca if zfrac3==2 & school_private==1), ///
legend(label(1 "Govt Students") label(2 "Private Students")) title(Moderate Fractionalization Village) ytitle(Density)
tempfile z2
graph save `z2'.gph, replace

twoway(kdensity child_pca if zfrac3==2 & school_private==0)	(kdensity child_pca if zfrac3==2 & school_private==1), ///
legend(label(1 "Govt Students") label(2 "Private Students")) title(High Fractionalization Village) ytitle(Density)
tempfile z3
graph save `z3'.gph, replace



graph combine `z1'.gph `z2'.gph `z3'.gph, title(Student Wealth Distributions) subtitle(by Village Fractionalization) ///
	note("Weath comes from a standardized PCA wealth index of mean 0, standard deviation 1")
graph export $pk/docs/graphs/wealth_by_frac.pdf, replace

/*
twoway(kdensity child_pca if zfrac==2 & school_private==0)	(kdensity child_pca if zfrac==2 & school_private==1)
twoway(kdensity child_pca if zfrac==3 & school_private==0)	(kdensity child_pca if zfrac==3 & school_private==1)

