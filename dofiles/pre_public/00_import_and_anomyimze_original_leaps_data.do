* Load data from (original) LEAPS directory
* Drop identifying data and variables not fit for public release
* save to project folder in `leaps_data`

* Note "Anonymization" is quite basic -- dropping names and GPS coordinates.
* This falls short of "true" anonymization, and should only be released with
* permission of LEAPS project leaders.

* Test for security -- make sure no names or coordinates slip through!


capture program drop check_no_identifying
program define check_no_identifying

   foreach i in "name" "GPS" "coordinates"{
      lookfor `i'
      assert  missing("`r(varlist)'")
   }

end



* Import household census with caste information
use $datadir/household/hhcensus1/hhcensus_short, clear

   drop  s2q2 s3q2  s3q5 school_name
   check_no_identifying

save $pk/prepublic_data/hhcensus.dta, replace

* Constructed Village Variables
use $datadir/constructed/xvars/mauza_xvars, clear

   check_no_identifying

save $pk/prepublic_data/xvars.dta, replace


* Import child panel
use $datadir/constructed/child_panel/child_panel_long, clear
   drop child_name mauza_name school_gps_north school_gps_east ///
		household_gps_north household_gps_east household_gps_problem ///
		household_gps_problem_comment household_childname1
   check_no_identifying
save $pk/public_leaps_data/public_child_panel_long.dta, replace

* School panel
use $datadir/constructed/school_panel/school_panel_long, clear

   drop school_gps_north school_gps_east school_gps_problem school_gps_problem_comment
   label var district "district string"
   check_no_identifying
   label var district "district name"

save $pk/public_leaps_data/public_school_panel_long.dta, replace

* Household panel
use $datadir/constructed/hh_panel/hh_panel_long, clear

   drop hh_gps_north hh_gps_east hh_gps_problem hh_gps_problem_comment mem_name
   check_no_identifying

save $pk/public_leaps_data/public_hh_panel_long, replace





