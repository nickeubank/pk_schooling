*********
* Master dofile for PK sorting project
*********

* All code uses $pk as global for this project folder
* Note I assume throughout that there are no spaces in the folder path!

global pk "/users/nick/projects/pk_schooling/"
global datadir "/users/nick/projects/leaps/data"
set scheme s2mono, permanently

******
* Import and anonymize original LEAPS data
* -- no processing except removing variables not allowed in a public release.
******

do $pk/dofiles/00_pre_public/00_import_and_anomyimze_original_leaps_data.do
do $pk/dofiles/00_pre_public/10_clean_household_census.do
do $pk/dofiles/00_pre_public/20_add_xvars.do


*********
* Make analysis datasets
*********

do $pk/dofiles/10_build_datasets_for_analysis/15_make_hh_child_cross_section.do
do $pk/dofiles/10_build_datasets_for_analysis/25_make_school_caste_measures.do
do $pk/dofiles/10_build_datasets_for_analysis/30_general_school_descriptives.do
do $pk/dofiles/10_build_datasets_for_analysis/40_make_custom_child_panel.do 
do $pk/dofiles/10_build_datasets_for_analysis/50_calculate_teacher_valueadded.do
do $pk/dofiles/10_build_datasets_for_analysis/55_make_custom_teacher_dataset.do

*********
* Run Analyses
*********

do $pk/dofiles/20_analysis/10_village_descriptive_figures.do
do $pk/dofiles/20_analysis/20_school_selection_hh.do
do $pk/dofiles/20_analysis/30_enrollment_by_caste.do
do $pk/dofiles/20_analysis/40_enrollment_pctprivate_pooled.do
do $pk/dofiles/20_analysis/50_crosssection_school_descriptives.do
do $pk/dofiles/20_analysis/60_crosssection_child_descriptives.do
do $pk/dofiles/20_analysis/70_master_kids.do
do $pk/dofiles/20_analysis/75_caste_residual_talent.do
do $pk/dofiles/20_analysis/80_teachers_compensation.do
do $pk/dofiles/20_analysis/85_variation_in_teachers_across_schools.do


