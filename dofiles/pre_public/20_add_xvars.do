clear
set more off

use $pk/prepublic_data/xvars, clear

* Var in the original dataset was created with first cleaning strings. 
* Mine is much better. 
drop M_frac_zaat M_polarity_zaat

gen M_schools_perhh=(M_numschools_gov+M_numschools_private)/M_numhh
gen M_schools_perhh_gov=(M_numschools_gov)/M_numhh
gen M_schools_perhh_priv=(M_numschools_private)/M_numhh


sort mauzaid
merge 1:m mauzaid using $pk/prepublic_data/from_hhcensus.dta
tab _m
assert _m != 1
keep if _m == 3
drop _m

label var M_wealth "Median Monthly Expenditures"
label var M_literacy "Adult Literacy Rate"
label var M_penrolled "Percent of Children Enrolled"
label var M_schools_perhh "Schools per Household"
label var M_schools_perhh_gov "Govt Schools per Household"
label var M_schools_perhh_priv "Priv Schools per Household"
label var M_numhh "Number of Households"

gen ln_numhh =ln(M_numhh)
label var ln_numhh "Log Number of Households"


duplicates report mauzaid
assert `r(N)' == `r(unique_value)'
assert `r(N)' == 112
sort mauzaid
save $pk/public_leaps_data/public_mauza.dta, replace


