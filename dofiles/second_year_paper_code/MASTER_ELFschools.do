* ************
* This is now the master dofile for all components of my ELF-schools project.
* It calls all relevant files, and explains what they do and what they save.
* ************

***************
* Set up
****************
do $datadir/constructed/ethnic_info/dofiles/clean_zaats.do

* *******************
* Establishing pattern
* *******************
	* Child regressions
	do $datadir/constructed/ethnic_info/dofiles/crosssection_kids.do
		* produces cross-section regressions for class 3, saved as crosssection_[subject].pdf
		* And lagged regressions -- saved as twoyear_[subject].pdf
		* Also shows that some positive aggregate gains with frac, but not much. Basically flat.

	* Teacher Regressions
	do $datadir/constructed/ethnic_info/dofiles/estimate_valueadded.do
	do $datadir/constructed/ethnic_info/dofiles/teachers_byvalueadded.do


* *****************
* Check for reportcard interaction
* *****************
do $datadir/constructed/ethnic_info/dofiles/children_reportcard_interaction.do
do $datadir/constructed/ethnic_info/dofiles/teachers_reportcard_interaction.

	* Nope. Do everything else full sample.

* ************
* Segregation Patterns
* ************
	* Enrollment by Caste
	do $datadir/constructed/ethnic_info/dofiles/enrollment_by_caste.do

	* Now take caste and "pool" it into high and low bins.
	do $datadir/constructed/ethnic_info/dofiles/enrollment_by_caste_pooled.do

	* Now eyeballing some places
	do $datadir/constructed/ethnic_info/dofiles/enrollment_polarization.do
	do $datadir/constructed/ethnic_info/dofiles/enrollment_polarization_pooled.do


* *************
* Let's study second moments!
* *************
	* Check school and village test score variance
	do $datadir/constructed/ethnic_info/dofiles/variance_analysis.do
		* Private schools have lower variance, but rises slowly as frac increases.
		* Government schools have much higher variance, but declines with frac.

		* Also interestingly, little evidence of changes in inter-school variance.


	* Medians
	* Government seems move improvement from the bottom.
	* Privates decline more at the bottom.
	* So worst students are moving into the private schools! YAY!
	do $datadir/constructed/ethnic_info/dofiles/quantile_regression.do


* ***************
* Selection Regressions
* ***************
	* First, households -- NOTHING THERE!
	* OOPS! I lied! Bad interaction with "high status"... hmmm. bad measure? Am I wrong?
	do $datadir/constructed/ethnic_info/dofiles/school_selection_hh.do

	* Selection by Geography -- clearly have government scores rising with added distance to get to a private school,
	* even controlling for distance to a private school. Much more iffy on the interaction -- not significant,
	* point estimate is positive (i.e. in more fractionalized places, MORE evidence of sorting. )
	do $datadir/constructed/ethnic_info/dofiles/selection_geography.do
