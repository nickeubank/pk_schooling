clear
set more off

* *********
* Now do children level...
* *********

use $pk/constructed_data/custom_child_panel, clear

	gen filler = 1
	gen filler2 = 1



		capture eststo clear

	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample

			eststo:	xi: reg child_`x'_theta school_private  interact_zaat_private ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)

			* All children with test scores, & lagged test scores
			assert `e(N)' > 37000

			eststo: xi: reg child_`x'_theta school_private filler interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)


				interact mauza_zaat_frac " " "`upper_x'"
				graph save $pk/docs/results/kids_`x'.gph, replace


			* All children with test scores, lagged test scores, and longer survey questionnaire
			assert `e(N)' > 26000


			eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

			* All children with test scores, lagged test scores, and longer survey questionnaire
			assert `e(N)' > 26000


}


		esttab  using $pk/docs/results/children.tex, b(a2)  se  replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores\label{kids}) ///
			 drop(  "child_age" "child_age2" "child_female" "class_*" "filler") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			addnote("Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.")

graph combine ///
	$pk/docs/results/kids_english.gph ///
	 $pk/docs/results/kids_urdu.gph ///
	  $pk/docs/results/kids_math.gph, row(1) ///
	title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals)
graph export $pk/docs/results/kids_combined.pdf, replace



* **********
* Use only district fixed effects so can include fractionalization as separate control. 
* *********

	eststo clear
	set more off
	foreach x in english urdu math {

		local upper_x=proper("`x'")


			eststo:	xi: reg child_`x'_theta school_private  mauza_zaat_frac ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

			* All children with test scores, & lagged test scores
			assert `e(N)' > 37000


			eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

			* All children with test scores, lagged test scores, and longer survey questionnaire
			assert `e(N)' > 26000


	}


		esttab  using $pk/docs/results/children_nointeract.tex, b(a2) se replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0   1  0  1   0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores and Fractionalization \label{kidsnointeract}) ///
			 drop( "child_age" "child_age2" "child_female" "class_*" ) ///
			 substitute({table} {sidewaystable})  ///
			indicate( "District Fixed Effects=_Id*") ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			addnote("Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.")


