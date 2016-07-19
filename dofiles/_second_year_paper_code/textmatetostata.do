	* Village
	egen mtag=tag(mauzaid)
	replace mauza_share_in_toptwo=mauza_share_in_toptwo
 	twoway(kdensity mauza_share_in_toptwo if zfrac3==1 & mtag==1)(kdensity mauza_share_in_toptwo if zfrac3==2 & mtag==1)(kdensity mauza_share_in_toptwo if zfrac3==3 & mtag==1), ///
	title(Village Caste Concentration) subtitle(By Village Fractionalization Terciles) ///
	ytitle("Density") xtitle(Percentage of Village in Largest Two Castes) ///
	legend(label(1 "Least Fractionalized 1/3 of Villages") label(2 "Middle 1/3 of Villages") label(3 "Most Fractionalized 1/3 of Villages") rows(3) size(vsmall))

	tempfile village_toptwo
	graph save `village_toptwo'.gph, replace

	graph export $pk/docs/graphs/village_toptwo.pdf, replace

