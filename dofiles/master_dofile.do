*********
* Master dofile for PK sorting project
*********

* All code uses $pk as global for this project folder
* Note I assume throughout that there are no spaces in the folder path!

global pk "/users/nick/projects/pk_schooling/"

******
* Import and anonymize original LEAPS data
* -- no processing except removing variables not allowed in a public release.
******


global datadir "/users/nick/projects/leaps/data"

* Import village census
do $pk/dofiles/import_and_anomyimze_original_leaps_data.do
<<<<<<< 013791f19bbdc5b75e08fe191a9003ac483577b2
=======
qqq
>>>>>>> update master_do

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
