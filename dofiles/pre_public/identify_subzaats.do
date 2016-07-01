********
* HH Census has a lot of people reporting zaats not in main list. 
*
* HH survey has "subzaats" which will allow me to figure out which in census
* are subcategories of a coded dominant zaat. 
******

use $pk/public_leaps_data/household/hhsurvey1/public_hhsurvey1_household, clear
keep hm1_s0q8_zaatcode hm1_s0q8_subzaat
decode hm1_s0q8_zaatcode, gen(zaat)
rename hm1_s0q8_subzaat subzaat

replace subzaat = trim(subzaat)

keep if zaat != subzaat

bysort zaat subzaat: gen size = _N
duplicates drop zaat subzaat, force
sort size zaat subzaat
br zaat subzaat size

