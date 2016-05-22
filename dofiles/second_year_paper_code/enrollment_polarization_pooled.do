clear
set more off

*******************
* School type by caste
*******************
use $datadir/school/generalschool2/generalschool2, clear

sort mauzaid
merge mauzaid using $datadir/constructed/ethnic_info/raw/mauza_zaat_vars
tab _m
keep if _m==3
drop _m

sort mauzaid
merge mauzaid using $datadir/constructed/xvars/mauza_xvars
tab _m
keep if _m==3
drop _m


keep if  gs2_s0q5_type==1|gs2_s0q5_type==2

gen school_private=(gs2_s0q5_type==1)	
order gs2_s4*
order school_private gs2_s4q2_zaat1 gs2_s4q2_pcent1 gs2_s4q2_zaat2 gs2_s4q2_pcent2 gs2_s4q2_zaat3 gs2_s4q2_pcent3 gs2_s4q2_zaat4 gs2_s4q2_pcent4

forvalues x=1/6 {
	replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==5
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==1
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==9
	replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==13
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==17
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==2
	replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==15
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==6
	replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==18
	replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==22
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==7
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==19
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==8
	replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==16
	replace gs2_s4q2_zaat`x'=. if  gs2_s4q2_zaat`x'~=-99 &  gs2_s4q2_zaat`x'~=-50
}

recode gs2_s4q2_zaat* (-99=1) (-50=2)


* Intraschool
forvalues x=1/6 {	
	gen inschoolshare_`x'=(gs2_s4q2_pcent`x'/100)
	gen inschoolsharesq_`x'=(gs2_s4q2_pcent`x'/100)^2
}

* Interschool
egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)

	* School Numbers
	forvalues zaat=1/2 {
		gen number_of_caste`zaat'=0
				forvalues groupcounter=1/6{
					replace number_of_caste`zaat'= number_of_caste`zaat'+(number_students_15 * gs2_s4q2_pcent`groupcounter'/100) if gs2_s4q2_zaat`groupcounter'==`zaat'								 
				} 
			bysort school_private mauzaid: egen type_number_of_caste`zaat'=sum(number_of_caste`zaat')
			}
			

			
keep mauzaid school_private type_number_of_caste* mauza_zaat_frac district  M_*


egen id=group(mauzaid school_private)
duplicates drop id, force

reshape long type_number_of_caste@, i(id) j(zaat)


bysort mauzaid zaat: egen total=sum(type_number_of_caste)
bysort mauzaid: egen mtotal=sum(type_number_of_caste)
bysort mauzaid school_private: egen mtotal_type=sum(type_number_of_caste)


replace total=0 if total==.
keep if school_private==1
drop school_private
gen pct_private= type_number_of_caste/total
gen mpct_private= mtotal_type/mtotal

gen high=1 if zaat==2
replace high=0 if zaat==1

twoway(scatter pct_private mauza_zaat_frac [pw=total] if high==1)(lfit pct_private mauza_zaat_frac [pw=total] if high==1)


* High castes concentrating in private schools
reg pct_private mauza_zaat_frac i.district [pw=total] if high==1, cluster(mauzaid)

* Low castes moving concentrating in govt schools -- one obs per caste group/village, weighted by number in that group
reg pct_private mauza_zaat_frac i.district [pw=total] if high==0, cluster(mauzaid)


gen ln_hh=ln(M_numhh)

xi:reg pct_private i.high*mauza_zaat_frac i.district M_wealth M_literacy ln_hh [pw=total], cluster(mauzaid)
interact_scores mauza_zaat_frac "df" "Dfd"
qqq




svyset high [pw=total]


gen variance=.
gen variance_unweighted=.

levelsof mauzaid, local(mzs)

foreach x in `mzs' {
	svy:mean pct_private if mauzaid==`x'
	estat sd 
	matrix TEMP=r(sd)
	replace variance=(TEMP[1,1])^2 if mauzaid==`x'
	
	sum pct_private if mauzaid==`x',d
	replace variance_unweighted=r(sd)^2 if mauzaid==`x'
}



egen tag=tag(mauzaid)
keep if tag==1
keep mauzaid variance variance_unweighted


sort mauzaid
tempfile share
save `share'

use $datadir/constructed/ethnic_info/raw/mauza_zaat_vars, clear
sort mauzaid
merge mauzaid using `share'
tab _m
keep if _m==3
reg variance mauza_zaat_frac i.district 
reg variance_unweighted mauza_zaat_frac i.district 

table high zfrac3, c(m variance)




