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
		replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==11
		replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==5
		replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==1
		replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==9
		replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==13
		replace gs2_s4q2_zaat`x'=-50 if gs2_s4q2_zaat`x'==17
		replace gs2_s4q2_zaat`x'=-99 if gs2_s4q2_zaat`x'==23
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

recode gs2_s4q2_zaat* (-99=0) (-50=1)

egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)


	* School Numbers
	foreach zaat in 0 1  {
		gen number_of_caste`zaat'=0
				forvalues groupcounter=1/6{
					replace number_of_caste`zaat'= number_of_caste`zaat'+(number_students_15 * gs2_s4q2_pcent`groupcounter'/100) if gs2_s4q2_zaat`groupcounter'==`zaat'								 
				} 
			bysort school_private mauzaid: egen type_number_of_caste`zaat'=sum(number_of_caste`zaat')
			}

bysort mauzaid: egen tempnum=sum(type_number_of_caste1)
bysort mauzaid: egen tempdenom=sum(type_number_of_caste0)
gen mauza_pct_high=tempnum/(tempnum+tempdenom)
drop tempnum tempdenom

gen pct_high=type_number_of_caste1/(type_number_of_caste1+type_number_of_caste0)

			
keep mauzaid school_private pct_high mauza_zaat_frac district  M_* number_students_15 mauza_pct_high

gen ln_hh=ln(M_numhh)

gen interact_zaat_private=mauza_zaat_frac*school_private
label var interact_zaat_private "Fractionalization * Private"
label var ln_hh "Log Village Size"
label var mauza_pct_high "Village: Pct High Status"
label var M_literacy "Village: Pct Adults Literate"
label var school_private "Private School"
label var M_wealth "Median Village Expenditure"


eststo clear
eststo: xi:reg pct_high school_private mauza_zaat_frac interact_zaat_private M_wealth M_literacy ln_hh mauza_pct_high  i.district [pw=number_students_15], cluster(mauzaid)


eststo: xi:reg pct_high school_private mauza_zaat_frac interact_zaat_private i.mauzaid [pw=number_students_15], cluster(mauzaid)

esttab  using $datadir/constructed/ethnic_info/docs/regressions/high_pooling.tex, b(a2) replace nogaps compress label booktabs noconstant ///
	mtitle( "Pct of Students High Status" "Pct of Students High Status" ) title(Student Body Social Composition\label{highpooling}) ///
	indicate( "District Fixed Effects=_Id*" "Village Fixed Effects=_Ima*")  ///
	drop(o.*) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	



