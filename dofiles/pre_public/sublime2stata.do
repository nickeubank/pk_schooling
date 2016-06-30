
* Share in top 22 should be a lot. 
count if zaat_code < 23
local main_group = `r(N)'
count
display `main_group' / `r(N)'
assert `main_group' / `r(N)' > 0.7

* Code for checking un-grouped groups. 

* capture drop ztag size
* egen ztag = tag(zaat)
* bysort zaat: gen size=_N 

* sort size

* br zaat  size if ztag==1 & zaat_code==23

drop if zaat_code==23



************
*
* Make fragmentation measures
*
************


* Make fractionalization based on new codes
egen hhtag=tag(hhid)
bysort mauzaid zaat_code: egen M_zaat_numhh=sum(hhtag)
bysort mauzaid: egen M_numhh=sum(hhtag)

*square shares
gen M_zaat_numhh2 = M_zaat_numhh * M_zaat_numhh
gen M_numhh2 = M_numhh * M_numhh
gen M_zaat_sq_shares = M_zaat_numhh2/M_numhh2

egen mztag=tag(mauzaid zaat_code)
bysort mauzaid: egen tmp= sum(M_zaat_sq_shares) if mztag==1
bysort mauzaid: egen tmp2 = max(tmp)
assert tmp2 != .
gen mauza_zaat_frac=1-tmp2
assert mauza_zaat_frac >= 0 & mauza_zaat_frac <=1 & mauza_zaat_frac !=.
drop tmp*



label var mauza_zaat_frac "Mauza Biraderi Fractionalization"


***
* Make share of village that is top two castes
***

* Look only at top 22 categories so can compare with later data directly. 

forvalues z=1/22 {
	gen temp_`z' = M_zaat_numhh / M_numhh if zaat_code == `z'
	bysort mauzaid: egen mauza_share_zaat_`z' = max(temp_`z')
	drop temp_`z'
	replace mauza_share_zaat_`z' = 0 if mauza_share_zaat_`z' == .
	label var mauza_share_zaat_`z' "Share of total village that's Zaat `z'"
}

duplicates drop mauzaid, force

egen temp_max=rowmax(mauza_share_zaat_*)

forvalues x=1/22 {
	gen mauza_zaat_share`x'_temp = mauza_share_zaat_`x'
	replace mauza_zaat_share`x'_temp = . if mauza_share_zaat_`x' == temp_max
}

egen temp_second=rowmax(mauza_zaat_share*_temp)

gen share_in_toptwo=temp_max+temp_second
drop temp_* *_temp


**********
* Clean up a little
**********


rename share_in_toptwo mauza_share_in_toptwo
label var mauza_share_in_toptwo "Share of Mauza in two larges Biraderis (only looking at top 22 codes)"

keep mauzaid mauza_zaat_frac mauza_share_in_toptwo
sort mauzaid

save $pk/prepublic_data/from_hhcensus.dta, replace

