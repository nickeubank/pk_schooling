clear
* *********
*replace zaat_code= 1 if zaat=="AARAIN"
*replace zaat_code= 2 if zaat=="ABBASI"
*replace zaat_code= 3 if zaat=="ANSARI"
*replace zaat_code= 4 if zaat=="AWAAN"
*replace zaat_code= 5 if zaat=="BALOCH"
*replace zaat_code= 6 if zaat=="BUTT"
*replace zaat_code= 7 if zaat=="CHACHAR"
*replace zaat_code= 8 if zaat=="GUJJAR"
*replace zaat_code= 9 if zaat=="JAT"
*replace zaat_code= 10 if zaat=="LAAR"
*replace zaat_code= 11 if zaat=="MOHANA"
*replace zaat_code= 12 if zaat=="MUGHAL"
*replace zaat_code= 13 if zaat=="MUSLIM SHEIKH"
*replace zaat_code= 14 if zaat=="NAICH"
*replace zaat_code= 15 if zaat=="PATHAN"
*replace zaat_code= 16 if zaat=="QURESHI"
*replace zaat_code= 17 if zaat=="RAJPUT"
*replace zaat_code= 18 if zaat=="REHMANI"
*replace zaat_code= 19 if zaat=="SAMIJA"
*replace zaat_code= 20 if zaat=="SHEIKH"
*replace zaat_code= 21 if zaat=="SOLANGI"
*replace zaat_code= 22 if zaat=="SYED"

set more off
use $datadir/constructed/ethnic_info/raw/mauza_zaat_vars, clear

* scatter mauzaid mauza_zaat_frac, mlabel(mauzaid)


	*br if mauzaid==19
		* 88% #4 (Awan), 5% #20(Sheikh), 3% #15(Pathan)

	*br if mauzaid==120
			* 80% #1 (Arain), 5% #5(Baloch), and scattering of 17/18 (rajput and rehmani)

	* br if mauzaid==7
					* 80% #4 (Awan), others scattered. 

use $datadir/school/generalschool2/generalschool2, clear
	keep if mauzaid==5
	gen school_private=(gs2_s0q5_type==1)	
	keep school_private gs2_s4*	
	order gs2_s4*
	order school_private gs2_s4q2_zaat1 gs2_s4q2_pcent1 gs2_s4q2_zaat2 gs2_s4q2_pcent2 gs2_s4q2_zaat3 gs2_s4q2_pcent3 gs2_s4q2_zaat4 gs2_s4q2_pcent4
	sort school_private
	* br

	
	* In 19:
	* Privates are all Awan, Mughal, and Shiekh. 
	* Govt schools have dhobi/lohar/mochi/naich, kharar, and pathan. 
	
	* In 120
	* All have arain
	* Privates have lar, solangi, Rajput, chachar, dhobis...
	
	* In 7: 
	* One private has dhobi as #1! then syed!
	* Another awan, Syed, Kharar.
	* In govt, awan/syed, then dhobi, kharar...
	
	* in 59: 
	* Hard to say... maybe one dhobi-centric school? private somewhat more segregated? but not a ton...
	* But clearly arain's mostly in private. 
	
	
*******************
* School type by caste
*******************
use $datadir/school/generalschool2/generalschool2, clear


gen school_private=(gs2_s0q5_type==1)	
order gs2_s4*
order school_private gs2_s4q2_zaat1 gs2_s4q2_pcent1 gs2_s4q2_zaat2 gs2_s4q2_pcent2 gs2_s4q2_zaat3 gs2_s4q2_pcent3 gs2_s4q2_zaat4 gs2_s4q2_pcent4


	
* Intraschool
forvalues x=1/6 {	
	gen inschoolshare_`x'=(gs2_s4q2_pcent`x'/100)
	gen inschoolsharesq_`x'=(gs2_s4q2_pcent`x'/100)^2
}

* Interschool
egen number_students_15=rowtotal(gs2_s2q3_girls gs2_s2q4_girls gs2_s2q5_girls gs2_s2q6_girls gs2_s2q7_girls gs2_s2q3_boys gs2_s2q4_boys gs2_s2q5_boys gs2_s2q6_boys gs2_s2q7_boys)

	* School Numbers
	forvalues zaat=1/26 {
		gen number_of_caste`zaat'=0
				forvalues groupcounter=1/6{
					replace number_of_caste`zaat'= number_of_caste`zaat'+(number_students_15 * gs2_s4q2_pcent`groupcounter'/100) if gs2_s4q2_zaat`groupcounter'==`zaat'								 
				} 
			bysort school_private mauzaid: egen type_number_of_caste`zaat'=sum(number_of_caste`zaat')
			}
			

			
keep mauzaid school_private type_number_of_caste*

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


table zaat if mauzaid==92, c(m pct_private m total m mpct_private) row col scol

svyset zaat [pw=total]


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





	