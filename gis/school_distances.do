clear

use $datadir/master/schools, clear
keep mauzaid schoolid school_gps* school_private  school_open1
keep if school_gps_problem==0
keep if school_open1==1

keep mauzaid schoolid school_private school_gps_north school_gps_east 
egen id=group(mauzaid schoolid)
sort mauzaid schoolid
tempfile schools
save `schools'

renvars  schoolid school_private school_gps_*, prefix(a_) 
joinby mauzaid using `schools'





gen phi1 = 90-school_gps_north
gen phi2 = 90-a_school_gps_north
gen theta1 = school_gps_east
gen theta2 = a_school_gps_east
gen c = sin(phi1)*sin(phi2)*cos(theta1-theta2) + cos(phi1)*cos(phi2)

* 3963 is circum of earth in miles
* 1.609 is conversio to kilometers
gen distance = 1.609*(3963.1676*acos(c)*_pi/180)
drop phi* theta* c
label var distance "Distance from school to School (km)"

drop if schoolid==a_schoolid

bysort mauzaid schoolid: egen temp=min(distance) if a_school_private==0
bysort mauzaid schoolid: egen dist_to_nearest_govt=max(temp)

bysort mauzaid schoolid: egen temp2=min(distance) if a_school_private==1
bysort mauzaid schoolid: egen dist_to_nearest_priv=max(temp2)

egen tag=tag(mauzaid schoolid)
keep if tag==1
keep mauzaid schoolid dist_*

save $datadir/constructed/ethnic_info/gis/school_distances, replace

