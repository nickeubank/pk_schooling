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




			eststo: xi: reg child_`x'_theta school_private filler interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)


				interact mauza_zaat_frac " " "`upper_x'"
				graph save $pk/docs/results/kids_`x'.gph, replace




				eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac interact_zaat_private  ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

					interact_scores mauza_zaat_frac "`x'" "`upper_x'"
					graph save $pk/docs/results/kids_`x'_district.gph, replace



}


		esttab  using $pk/docs/results/children.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores\label{kids}) ///
			 drop(  "child_age" "child_age2" "child_female" "class_*" "filler") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01)

		* note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)

graph combine ///
	$pk/docs/results/kids_english.gph ///
	 $pk/docs/results/kids_urdu.gph ///
	  $pk/docs/results/kids_math.gph, row(1) ///
	title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals)
graph export $pk/docs/results/kids_combined.pdf, replace

	* 	note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")


graph combine ///
	$pk/docs/results/kids_english_district.gph ///
	 $pk/docs/results/kids_urdu_district.gph ///
	  $pk/docs/results/kids_math_district.gph, row(1) ///
	title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals)
graph export $pk/docs/results/kids_combined_district.pdf, replace

	* 	note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")



* **********
* Drop coefficients on mauza
* *********

	eststo clear
	set more off
	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample

			eststo:	xi: reg child_`x'_theta school_private  mauza_zaat_frac ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


			eststo: xi: reg child_`x'_theta school_private mauza_zaat_frac  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)

				xi: reg child_`x'_theta filler filler2 mauza_zaat_frac school_private ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


				interact mauza_zaat_frac " " "`upper_x'"
				graph save $pk/docs/results/nointeract_`x'.gph, replace
}


		esttab  using $pk/docs/results/children_nointeract.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0   1  0  1   0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Test Scores and Fractionalization \label{kidsnointeract}) ///
			 drop( "child_age" "child_age2" "child_female" "class_*" ) ///
			 substitute({table} {sidewaystable})  ///
			indicate( "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01)


			* note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)

			graph combine ///
				$pk/docs/results/nointeract_english.gph ///
				 $pk/docs/results/nointeract_urdu.gph ///
				  $pk/docs/results/nointeract_math.gph, row(1) ///
				title(Caste Fractionalization and Value Added Scores) subtitle(With 90 Percent Confidence Intervals)

			graph export $pk/docs/results/nointeraction_combined.pdf, replace

			* note("Controls include village fixed effects, gender, age, age squared, child wealth and parental education")
