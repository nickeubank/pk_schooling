clear

use $datadir/constructed/school_panel/school_panel_long, clear

keep if round==1
sort mauzaid schoolid
merge 1:1 mauzaid schoolid using $datadir/constructed/ethnic_info/gis/school_distances
tab _m

keep if _m==3
drop if dist_to_nearest_priv>2

areg child_english_theta child_wealth child_educ_elem dist_to_nearest_priv if school_private==0, a(mauzaid) cluster(mauzaid)
areg child_english_theta child_wealth child_educ_elem dist_to_nearest_priv if school_private==1, a(mauzaid) cluster(mauzaid)




