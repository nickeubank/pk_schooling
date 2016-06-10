
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

keep if (round==1 & child_panel==1)|(round==3 & child_panel==2)
tab child_class


egen mtag=tag(mauzaid)
egen mtagpriv=tag(mauzaid) if school_private==1
egen mtaggov=tag(mauzaid) if school_private==0
egen stag=tag(mauzaid child_schoolid)

	
tsset childcode round

foreach x in math english urdu {
	
	* Generate variance in schools:
	bysort mauzaid child_schoolid: egen school_var_`x'=sd(child_`x'_theta)	


	* Now variance OF schools
	bysort mauzaid child_schoolid: egen smean_`x'=mean(child_`x'_theta)
	
	bysort mauzaid: egen mauza_var_`x'=sd(smean_`x')	if stag==1
	bysort mauzaid: egen mauza_var_govt_`x'=sd(smean_`x')	if school_private==0 & stag==1
	bysort mauzaid: egen mauza_var_priv_`x'=sd(smean_`x')	if school_private==1 & stag==1
}

egen mauza_var_mean=rowmean(mauza_var_math mauza_var_english mauza_var_urdu)
egen mauza_var_govt_mean=rowmean(mauza_var_math mauza_var_english mauza_var_urdu)
egen mauza_var_priv_mean=rowmean(mauza_var_math mauza_var_english mauza_var_urdu)

egen school_var_mean=rowmean(school_var_*)



gen ln_hh=ln(mauza_numhh)

reg mauza_var_english mauza_zaat_frac i.district mauza_literacy mauza_wealth mauza_gini_land ln_hh  if mtag==1
reg mauza_var_govt_english mauza_zaat_frac i.district mauza_literacy mauza_wealth mauza_gini_land ln_hh if mtaggov==1
reg mauza_var_priv_english mauza_zaat_frac i.district mauza_literacy mauza_wealth mauza_gini_land ln_hh  if mtagpriv==1


xi:reg school_var_english i.school_private*mauza_zaat_frac i.district  mauza_literacy mauza_wealth mauza_gini_land ln_hh if stag==1, cluster(mauzaid)
interact_scores mauza_zaat_frac "Name" "name"


reg school_var_english mauza_zaat_frac i.district  mauza_literacy mauza_wealth mauza_gini_land ln_hh if stag==1 & school_private==0, cluster(mauzaid)
reg school_var_english mauza_zaat_frac i.district  mauza_literacy mauza_wealth mauza_gini_land ln_hh  if stag==1 & school_private==1 , cluster(mauzaid)

