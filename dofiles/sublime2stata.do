clear
set more off


use $pk/public_leaps_data/school/school2/public_generalschool2, clear


* Get village caste

sort mauzaid
merge mauzaid using $pk/public_leaps_data/public_mauza


