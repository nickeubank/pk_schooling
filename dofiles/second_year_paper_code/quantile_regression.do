
clear
set more off


use $datadir/constructed/child_panel/child_panel_long, clear



drop mauza_frac_zaat
sort mauzaid
count
merge mauzaid using $pk/public_leaps_data/public_mauza
assert _m~=1
tab _m
keep if _m==3
count

* *************
* Only want class 3 cross section
* *************


gen child_age2=child_age^2
tab district, gen(dist)

gen 

gen ln_hh=ln(mauza_numhh)

* So is govt school improvment from the top or bottom?
xi:	qreg child_english_theta  i.school_private*mauza_zaat_frac child_age child_age2 dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(10) 
xi:	qreg child_english_theta  i.school_private*mauza_zaat_frac child_age child_age2  dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(50) 
xi:	qreg child_english_theta i.school_private*mauza_zaat_frac child_age child_age2 dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(90) 
	* MASSIVE improvements at the bottom!

qqq
qqq
	xi:	bsqreg child_english_theta  i.school_private*mauza_zaat_frac child_age child_age2 child_pca child_parentedu dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(10) reps(150)
	xi:	bsqreg child_english_theta  i.school_private*mauza_zaat_frac child_age child_age2 child_pca child_parentedu dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(50) reps(150)
	xi:	bsqreg child_english_theta i.school_private*mauza_zaat_frac child_age child_age2 child_pca child_parentedu dist2 dist3 mauza_wealth mauza_literacy ln_hh, q(90) reps(150)
		* MASSIVE improvements at the bottom!


