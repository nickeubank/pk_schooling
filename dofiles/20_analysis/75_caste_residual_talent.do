


*******
use $pk/constructed_data/custom_child_panel, clear




		capture eststo clear

	foreach x in english urdu math {

		local upper_x=proper("`x'")

		* Big sample

			eststo:	xi: reg child_`x'_theta zaat_high_status school_private  interact_zaat_private ///
				child_female  child_age child_age2 class_* ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)

			eststo: xi: reg child_`x'_theta zaat_high_status school_private  interact_zaat_private  ///
				child_female  child_age child_age2 class_* child_pca child_parentedu  ///
				lagged_english lagged_math lagged_urdu i.mauzaid, cluster(mauzaid)


				eststo: xi: reg child_`x'_theta zaat_high_status school_private mauza_zaat_frac interact_zaat_private  ///
					child_female  child_age child_age2 class_* child_pca child_parentedu  ///
					lagged_english lagged_math lagged_urdu mauza_literacy ln_numhh mauza_gini_land i.district, cluster(mauzaid)


}


		esttab  using $pk/docs/results/status.tex, b(a2) replace nogaps compress label booktabs noconstant ///
			mgroups("English" "Urdu" "Math" , pattern(0 0 0  1 0 0  1 0  0  ) prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span}) )   ///
			mtitle( "" "" "" "" "" "" "" "" "" ) title(Child Social Status and Residual Talent\label{castesarentdumb}) ///
			 drop(  "child_age" "child_age2" "child_female" "class_*") ///
			 substitute({table} {sidewaystable})  ///
			indicate( "Village Fixed Effects=_Ima*" "District Fixed Effects=_Id*") ///
			starlevels(* 0.10 ** 0.05 *** 0.01)


			*note(Controls for age, age squared, gender, and class omitted from table. Standard errors clustered at village level.)
