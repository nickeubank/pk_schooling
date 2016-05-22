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

tab gs2_s4q2_zaat1


forvalues x=1/6 {
gen zaat_`x'=""
replace zaat_`x'="Medium" if gs2_s4q2_zaat`x'==11
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==5
replace zaat_`x'="Medium" if gs2_s4q2_zaat`x'==1
replace zaat_`x'="High" if gs2_s4q2_zaat`x'==9
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==13
replace zaat_`x'="Medium" if gs2_s4q2_zaat`x'==17
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==23
replace zaat_`x'="Medium" if gs2_s4q2_zaat`x'==2
replace zaat_`x'="Medium" if gs2_s4q2_zaat`x'==15
replace zaat_`x'="High" if gs2_s4q2_zaat`x'==6
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==14
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==18
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==22
replace zaat_`x'="High" if gs2_s4q2_zaat`x'==3
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==7
replace zaat_`x'="High" if gs2_s4q2_zaat`x'==19
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==8
replace zaat_`x'="Low" if gs2_s4q2_zaat`x'==12
replace zaat_`x'="High" if gs2_s4q2_zaat`x'==16

gen zaat_num_`x'=1 if zaat_`x'=="Low"
replace zaat_num_`x'=2 if zaat_`x'=="Medium"
replace zaat_num_`x'=3 if zaat_`x'=="High"
}


egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)


	* School Numbers
	foreach zaat in 1 2 3  {
		gen number_of_caste`zaat'=0
				forvalues groupcounter=1/6{
					replace number_of_caste`zaat'= number_of_caste`zaat'+(number_students_15 * gs2_s4q2_pcent`groupcounter'/100) if zaat_num_`groupcounter'==`zaat'								 
				} 
			bysort school_private mauzaid: egen type_number_of_caste`zaat'=sum(number_of_caste`zaat')
			}

bysort mauzaid: egen tempnum=sum(type_number_of_caste1)
bysort mauzaid: egen tempdenom=sum(type_number_of_caste2)
bysort mauzaid: egen tempdenom2=sum(type_number_of_caste3)
gen mauza_pct_high=tempnum/(tempnum+tempdenom)
drop tempnum tempdenom

gen pct_high=type_number_of_caste3/(type_number_of_caste3+type_number_of_caste2+type_number_of_caste1)

			
keep mauzaid school_private pct_high mauza_zaat_frac district  M_* number_students_15 mauza_pct_high

gen ln_hh=ln(M_numhh)

xi:areg pct_high i.school_private*mauza_zaat_frac M_wealth ln_hh mauza_pct_high [pw=number_students_15], cluster(mauzaid) a(district)
interact_scores mauza_zaat_frac
xi:areg pct_high i.school_private*mauza_zaat_frac M_wealth ln_hh mauza_pct_high [pw=number_students_15], cluster(mauzaid) a(mauzaid)


