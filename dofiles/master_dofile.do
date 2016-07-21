*********
* Master dofile for PK sorting project
*********

* All code uses $pk as global for this project folder
* Note I assume throughout that there are no spaces in the folder path!

global pk "/users/nick/projects/pk_schooling/"
set scheme s2mono, permanently
version 12

******
* Import and anonymize original LEAPS data
*  - remove variables not allowed in a public release.
*  - Process zaat data which, in listing census, was in free-form strings, 
*	 leading to lots of difficult to interprete and group responses. 
* 	 10_clean_household_census attempts to aggregate transliterations
*	 and different terms that map to the same group, eventually 
* 	 attempting to converge on the groupings hard-coded in later leaps surveys.
*  - add_xvars brings in more variables constructed by the LEAPS team from household 
*    census
*
* Note this is included for completeness and transparency, but as these files operate 
* on non-public data, cannot actually be run by replicators. 
* As such, these files should be commented out here.
******
global datadir "/users/nick/projects/leaps/data"

do $pk/dofiles/00_pre_public/00_import_and_anomyimze_original_leaps_data.do
do $pk/dofiles/00_pre_public/10_clean_household_census.do
do $pk/dofiles/00_pre_public/20_add_xvars.do


*********
* Make analysis datasets
*********

do $pk/dofiles/10_build_datasets_for_analysis/15_make_hh_child_cross_section.do
	* creates cross-sectional dataset at level of children for analysis of school choice. 

do $pk/dofiles/10_build_datasets_for_analysis/25_make_school_caste_measures.do
	* creates measures of caste-composition within schools (and village-level measures
	* based on school data rather than housing census -- school caste reporting 
	* has some structural quirks, so using only these variables when directly comparing 
	* intra-school diversity to intra-village inter-school diversity improves
	* comparability)

do $pk/dofiles/10_build_datasets_for_analysis/30_general_school_descriptives.do
	* Dataset of school variables. Imports and integrates caste measures from file 25.

do $pk/dofiles/10_build_datasets_for_analysis/40_make_custom_child_panel.do 
	* Modifies the standard child panel for the purposes of child-panel analyses 
	* (like lagged-value-added models)

do $pk/dofiles/10_build_datasets_for_analysis/50_calculate_teacher_valueadded.do
	* Calculates value-added estimates for teachers.
	* Note this file places the largest demands on Stata -- 
	* running regressions with dummies for each teacher requires a matsize of > 2000,
	* which cannot be supported by most version of Stata. 
	* Takes a long time to run!

do $pk/dofiles/10_build_datasets_for_analysis/55_make_custom_teacher_dataset.do
	* One-observation per teacher dataset with value-added and such. 
	* Mostly collapsing panel to one obs per teacher. 

*********
* Run Analyses
*********

do $pk/dofiles/20_analysis/10_village_descriptive_figures.do
	* Creates Table 1, Figure 1

do $pk/dofiles/20_analysis/20_school_selection_hh.do
	* Table 2 

do $pk/dofiles/20_analysis/30_enrollment_by_caste.do
	* Figure 2

do $pk/dofiles/20_analysis/40_share_highstatus.do
	* Table 3

do $pk/dofiles/20_analysis/50_fees_and_fractionalization.do
	* Table 4

do $pk/dofiles/20_analysis/60_private_school_enrollment_rate.do
	* Table 5

do $pk/dofiles/20_analysis/70_primary_testscore_regressions.do
	* Table 6, 7 Figure 3

do $pk/dofiles/20_analysis/75_caste_residual_talent.do
	* Table 8

do $pk/dofiles/20_analysis/80_teachers_compensation.do
	* Table 9, Table 10

do $pk/dofiles/20_analysis/85_variation_in_teachers_across_schools.do
	* Table 11, Table 12


