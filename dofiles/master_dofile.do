*********
* Master dofile for PK sorting project
*********

* All code uses $pk as global for this project folder
* Note I assume throughout that there are no spaces in the folder path!

global pk "/users/nick/projects/pk_schooling/"
global datadir "/users/nick/projects/leaps/data"
QQQ
******
* Import and anonymize original LEAPS data
* -- no processing except removing variables not allowed in a public release.
******

do $pk/dofiles/pre_public/00_import_and_anomyimze_original_leaps_data.do
do $pk/dofiles/pre_public/10_clean_household_census.do
do $pk/dofiles/pre_public/20_add_xvars.do

*********
* Part 2: Context / Village descriptives
*********

do $pk/dofiles/10_village_descriptive_figures.do


*********
* Part 3 : Caste Politics and School Sorting
*********

do $pk/dofiles/20_school_selection_hh.do   // HAS PROBLEMS
	* Mom educ not in public dataset
	* Makes hhselection.tex regression table

do $pk/dofiles/30_school_selection_hh.do
	* Makes:
	 	* village_toptwo.pdf and school_toptwo.pdf  (part 3)
	 	* totalpresent.pdf
	 	* toptwo_combined.pdf
	 	* intra_versus_intervillage_frac_combined.pdf (part 3)
	 	* intra_versus_intervillage_frac.pdf


do $pk/dofiles/40_enrollment_pctprivate_pooled.do
	* Makes high_pooling.tex

do $pk/dofiles/50_crosssection_school_descriptives.do
	* Makes fees.tex

do $pk/dofiles/60_crosssection_child_descriptives.do   // HAS PROBLEMS BUT ALSO MANY MANY RESULTS
	* makes private_share.tex
	* makes wealth_and_type.pdf
	* privatepremium_`x'_crosssection
	* privatepremium_crossection.tex
	* twoyear_`x'
	* twoyear.tex
	* privatepremium_`x'_crosssection

	* need to find / make interact_scores command. Built from `interact.do` presumably?


*********
* Part 4 : Scores
*********


do $pk/dofiles/80_master_kids.do   // wants interact


do $pk/dofiles/90_caste_residual_talent.do   
	* Esttab syntax error

