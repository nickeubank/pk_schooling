clear

use $datadir/constructed/ethnic_info/raw/mauza_gap, clear
sort mauzaid 
merge 1:1 mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
assert _m~=1
keep if _m==3
drop _m

sort mauzaid
merge 1:1 mauzaid using $datadir/constructed/xvars/mauza_xvars
assert _m~=1
keep if _m==3

gen ln_hh=ln(M_numhh)
label var ln_hh "Log Village Size"
label var M_wealth "Median Village Wealth"
label var M_literacy "Pct of Adults Literate"
eststo clear

eststo: xi:reg gap_english mauza_zaat_frac i.district  M_wealth ln_hh M_literacy M_gini_land
eststo: xi:reg gap_urdu mauza_zaat_frac i.district  M_wealth ln_hh M_literacy M_gini_land 
eststo: xi:reg gap_math mauza_zaat_frac i.district  M_wealth ln_hh M_literacy M_gini_land 


esttab  using $datadir/constructed/ethnic_info/docs/regressions/villagegap.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mtitle( "English" "Urdu" "Math") title(Village Level Government-Private Gap\label{villagegap}) ///
	indicate(District Fixed Effects=_Id*) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) 



