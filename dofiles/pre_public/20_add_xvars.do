clear
set more off

use $pk/prepublic_data/xvars, clear
drop M_frac_zaat

gen schools_perhh=(M_numschools_gov+M_numschools_private)/M_numhh
gen schools_perhh_g=(M_numschools_gov)/M_numhh
gen schools_perhh_p=(M_numschools_private)/M_numhh


sort mauzaid
merge 1:m mauzaid using $pk/prepublic_data/from_hhcensus.dta
tab _m
keep if _m==3

label var M_wealth "Median Montly Expenditures"
label var M_literacy "Adult Literacy Rate"
label var M_penrolled "Percent of Children Enrolled"
label var schools_perhh "Schools per Household"
label var M_numhh "Number of Households"

gen ln_numhh =ln(M_numhh)
label var ln_numhh "Log Number of Households"


duplicates report mauzaid
assert `r(N)' == `r(unique_value)'
save $pk/public_leaps_data/public_mauza.dta, replace


