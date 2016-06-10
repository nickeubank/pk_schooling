
* **************
* Now let's bring in school fractionalization
* **************

	use $datadir/constructed/school_panel/school_panel_long, clear
	keep schoolid mauzaid school_herf school_zaat* round reportcard mauza_numschools_gov mauza_numschools_private
	keep if round==1|round==4
	replace round=2 if round==4

	gen mauza_numschools=mauza_numschools_gov+mauza_numschools_private

	* Bring in mauza vars
	sort mauzaid
	merge mauzaid using $pk/public_leaps_data/public_mauza
	keep if _m==3
	
	* THIS I SHOULD FIX!!!!!
	duplicates drop mauzaid schoolid round, force

egen id=group(mauzaid schoolid)

tsset id round

xi:reg `x' reportcard , cluster(mauzaid)

egen mtag=tag(mauzaid)
sum mauza_zaat_frac if mtag==1, d

gen zaat_low=(mauza_zaat_frac<r(p50))

	* By second measure, we seem to get concentration of dominant class declining in treatment villages, albeit
	* not quite significant effect. 
	
	* No gain from interaction -- all insignficant... :(

foreach x in school_herf school_zaat_one_pct{
	
	display "All"
	xi:reg D.`x' reportcard, cluster(mauzaid)

	display "Low Frac"
	xi:reg D.`x' reportcard if zaat_low==1, cluster(mauzaid)

	display "High Frac"
	xi:reg D.`x' reportcard if zaat_low==0, cluster(mauzaid)


	display "All, with num"
	xi:reg D.`x' i.reportcard*mauza_numschools, cluster(mauzaid)
	test _Ireportcar_1+_IrepXmauza_1=0

	display "Low Frac, with num"
	xi:reg D.`x' i.reportcard*mauza_numschools if zaat_low==1, cluster(mauzaid)
	test _Ireportcar_1+_IrepXmauza_1=0


	display "High Frac, with num"
	xi:reg D.`x' i.reportcard*mauza_numschools if zaat_low==0, cluster(mauzaid)
	test _Ireportcar_1+_IrepXmauza_1=0

}
