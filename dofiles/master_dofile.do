*********
* Master dofile for PK sorting project
*********

* All code uses $pk as global for this project folder
* Note I assume throughout that there are no spaces in the folder path!

global pk "/users/nick/projects/pk_schooling/"
global datadir "/users/nick/projects/leaps/data"

******
* Import and anonymize original LEAPS data
* -- no processing except removing variables not allowed in a public release.
******

do $pk/dofiles/pre_public/00_import_and_anomyimze_original_leaps_data.do
do $pk/dofiles/pre_public/10_clean_household_census.do
do $pk/dofiles/pre_public/20_add_xvars.do

*********
* Village descriptives
*********

do $pk/dofiles/10_village_descriptive_figures.do




********
* Basic cleaning
********

* Clean caste names and make village fragmentation.
do dofiles/clean_household_census.do



*************
* Create Paper Result!
*************

* Section 1: Village Caste Descriptives
do dofiles/village_descriptives.do
