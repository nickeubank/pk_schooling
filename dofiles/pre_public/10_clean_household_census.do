*********************
* 
* This dofile reads in the household listing census conducted
* prior to the LEAPS survey that includes data on zaat of 
* ALL households in each village. 
*
* cleans, converts to codes using code-zaat mapping from LEAPS data
* and passes to later dataset for collapse to (releasable) 
* mauza-level vars.
* 
* Where multiples listed, the rule is:
* 	- If one in top 22 we hard-code later, use that
* 	- If both not in that list, use first. 
*********************


set more off
use $datadir/household/hhcensus1/hhcensus_short.dta, clear


rename s1q3 district
rename s1q11 zaat

************
* Clean and organize zaats
* All strings, and very dirty.
************


* Drop weird characters. Some redundancy I know so syntax editor still works. :)

foreach x in "," "." "]" "'" "'" "`" "'" ";" {
	replace zaat = subinstr(zaat, "`x'", "", .)
}

replace zaat=trim(zaat)
replace zaat=upper(zaat)
drop if zaat==""

* Write consolidation function. Takes list of strings, where first
* is "target" string -- one we want all to converge to. 
capture program drop consolidate
program define consolidate

	foreach x in `0' {
		replace zaat = "`1'" if regex(zaat, "^`x'$") == 1
	}

end

* Check works
preserve
	clear
	set obs 10
	gen zaat = "a"
	replace zaat = "b c" if _n==2
	replace zaat = "d" if _n==3

	consolidate a "b c" d 
	assert zaat == "a"
restore


* AARAIN
consolidate AARAIN ARRAIN ARAAIN ARIANE ARIANN ARIE ARIEA ARIEANH ARIEN ARIENA ARIENE ARIHAN ARIIAN ARIINE ARIN ARINA ARIYAN ARIYN ARAINA ARAINE ARAINJ ARAIYEIN ARANIE ARAQIN ARARIN ARAUIN ARAUN ARAYAN ARAYEEN ARAYEN ARAYIN ARAYN AREEA AREEN AREIAN AREIEN ARIAINE ARIAN AROR ARRAEEN ARRAEIN ARRAEN ARRAHIN ARRAI ARRAIEN ARRAINE ARRAIRE ARRAIYEIN ARRAIYEN ARRAN ARRAOM ARRAQIN ARREEN ARREIN ARRIAN ARRIANE ARRIEN ARRIN ARRSAIN ARYAN ARYIN AARAIN ARAYEEN ARAYEN ARAYIN ARAIAN ARAIEN ARAIEND ARAIEND ARAIN ARAINE ARAIYEIN ARANIE ARIN ARIYN ARAAI ARAI ANSAREE 


* ABBASI
consolidate ABBASI  ABBASSI ABBAS ABASO ABAS

* ADAL
consolidate ADAL "ADAL KHAIL" "ADA KHAIL" "ADAL KHAN" "ADIL KHEL" 


* AFGHANI
consolidate AFGHANI AFGHAN AFGHANI AFGANI 


* ATRAAL
consolidate ATRAAL AMRAAL ATHWAL ATHRAAN 


* ANSARI
consolidate ANSARI ASNARI ANASRI ANARI ANSAI ANSARY ANSRI ANSSRI ANSSARY ANSAARI 


* AWAAN
consolidate AWAAN AAWAN AWAAB AWAAM AWAAN AWAB AWAIN AWAM AWAMEE AWAN AWANB AWAN AWN AWWAN 


*ALWI
consolidate ALWI ALRYI 

* BALOCH
consolidate  BALOCH BALOUCH BALAOCH BALCOH BALO0CH BALOACH BALOCH BALOOCH TALOOCH BALOSH ///
 BALOUCH BLAOCH BLOCH BLOOCH BLOACH BULOCH BOLOCH "BALOCH CHANDIA" "KORAI BALOCH" "GOPANG BALOCH" "JAMLI BLOCH" ///
 "BLOCH CHANDIA" "SHAIR BALOCH"


* BABO
consolidate BABO BABU 


* BEHAL
consolidate BEHAL BEHEAL BHEL BHAIL BHAYAL BHAYAL BAHAL BAKHAL BAHAEL BAHEAL BAHALE BAHIL BEHAEAL BEHAEL BAHIL BEAHEAL BEAHEL 

* BHATA
consolidate BHATA BHATOO BHOTHA BHUTA BHUTTA  {

* BHAYA
consolidate BHAYA 

* BUTT
consolidate BUTT 

* BHATYARA
consolidate BHATYARA BHUTYARA  


* BHATTI
consolidate BHATTI BAHHATI BAHHIT BAHHTI BAHITT BAHTA BAHTE BAHTEE BAT BATHA BATHI BATI BATT BATTA BATTHA BATTI BATYARA BHATT BHATTA BHATTE BHATTI BHTA BHTI BUHTAY BUHTTI  BUTHA BUTHI BHTTI BHUTI BAHTTI BHALLI GHATTI 


* BHADER
consolidate BHADER 


* CHACHAR
consolidate CHACHAR CHACAHR CHACAR CHACHAAR CHACHAER CHACHAN CHACHAR CHACHER CHACHR CHACHRA CHACHRE CHACHURE CHADHAR CHADHYER CHAHCHAN CHANDIYAH CHANGAR CHANGHAR CHANGHARR CHARCHAR CHARCHER CHARCHR CHARHARAR CHAUDHARI CHAUDHARY CHAUDHRY CHAUHAN CHAWARA CHAWARD CHIDDHAR CHIDDHRA CHIDHAR KHATTAR KHOKHAR KHAKHAR KAAKAR "KOH KAR" KAHAR "CHA CHAR" KACHAR 


* CHEENY
consolidate CHEENY CHEENA  


* CHOHAN
consolidate CHOHAN CHOHAAN CHOHAN CHUHAN CHOCHAN CHOOHAN CHOAN 


* COBLER
consolidate COBLER COBBLER COBLER 

* CHUNGER

* CHANAR
consolidate CHANAR CHINAR CHNAR CHENEAR 


* CHANDYA
consolidate CHANDYA CHNDIYA CAHNDYA CAMBHO CHANDAI CHANDEU "CHANDIA NAAI" CHANDIO CHANDYA CHANGAD CHANGID CHANDIYO CHANDIYA 


* DAHAR
consolidate DAHAR DAHA DAHAR DAHER DAHRJA DAAR DAR 


* DHALOON
consolidate DHALOON DHALON 


* DOBI
consolidate DOBI DHOBI DOHBHI DOUBI DUBI DOBBI DHOBBI  DHUBBI DHOOBI GHOBI BHOBI DHOBHI 


* DAOD
consolidate DAOD DAD DADOO DAYOO ODD "DAD POTRA"


* DERICHA
consolidate DERICHA DHREECH DHRECH 


* DURANI

* DOGAR
consolidate DOGAR DOGHAR DOGGAR 


* FARQEER
consolidate FARQEER FAQEER FAQIR FAQER FQEER 


* GILL
consolidate  GILL GIL


* GOPANG
consolidate GOPANG GOOPANG GOPANG GOYANG


* GORI -- white people! :)
consolidate GORI GHORI GOURI GAOURI GAORI GORI GORIA GAORE ANGRAIZ 


* GUJJAR
consolidate GUJJAR GHUJAR GUAAR GUAJAR GUGAR GUGHAR GUGHJAR GUHGHAR GUHKHER GUJAAR GUJAFR GUJAR GUJER GUJET GUJHER GUJJAR GUJJR GUJR GUJRAR GYJJAR JUGGAR JUGAR  


* GUNIAL
consolidate GUNIAL 


* HAJAM
consolidate HAJAM HAJJAM HUJAM HIJAM HAJAAM HAJIAM 


* HASMI
consolidate HASMI HASHMI 


*HINDU
consolidate HINDU HINDO HINDKO 


* INSARI
consolidate INSARI INASARI INSARI INSAREE INSARE 


* JAT
consolidate JAT JAAT JUTT GUTT JUT JATT GAT "JATT BHUTTA" "BAJWAH JATT" "KLER JATT" "JATT BAJWAH"


* JAWALA
consolidate JAWALA JAWAHA     


*JATOI
consolidate JATOI JATOIE JATOOI 


* JANGAL
consolidate JANGAL JANGALA JANGALLA 


* JABHIL
consolidate JABHIL JHBAIL JHABAL JHABEL JHAIL  JHAMBHEEL JHABAIL JHABEEL JAHBEEL{



* JAKHAR
consolidate JAKHAR 


* JALAL
consolidate JALAL "JALAL KHEL" JILAH "JALAL KHAIL" JALAL JANGAL JANGLLA 


* Jamali
consolidate JAMALI "JAMALI BOLOUCH" "JAMALI BALOCH"

* JHANEG
consolidate JHANEG JAHNG JHAENG JHNAG GHANJ JHANG  


* JHEEL
consolidate JHEEL JHIL  GHELO JHAIL 


*JODRA
consolidate JODRA JORDA JOODRA JUDRA JODAH  JODHOO JODHRA JODRAH JODHAH JWDRA JORDA JORDRA JORDHA  


*JOPU
consolidate JOPU JUPO 


* JUNJOWA
consolidate JUNJOWA JANJOWA JANJUA JUNJOWA 

* KACHI
consolidate KACHI KHACHI KACHII 

* KAKAR
consolidate KAKAR KAKER 

* KALER
consolidate  KALER KAMHAAR KAMHRA KALHAR "KALHAR JAT" KALHORA "KALR MAHAR" KAMANGHAR 

* KAMBO
consolidate KAMBO KAMBAHWA "KAMBH WA" KAMBHEWA KAMBOO KAMBOW "KAMBOW JAT" KAMBWA KOMBOH KAMBOH 

* KANJO
consolidate KANJO KANJU 

*KASHMIRI
consolidate KASHMIRI KSHMERI KASHMERI KASHMIRI KASHMIRY KASHMIRE KASHMIREE KASHMEERAY KASHMEERAY KASHMAIRA KASHMARY KASHIMIRY KASHMIRA KASHMIRE KASMIRY 


* KATHIYA
consolidate KATHIYA KATHIA KATHIYA 

* KHARAR
consolidate KHARAR KHARAAR KHARAL KHARAR KHARKISH KHARL KHAWAJA KAHTAR KATHAR KHETER KHTAR KHORAR{


* KHANAN
consolidate KHANAN KHAMAN 


* KHAN
consolidate KHAN "KHAN " 


* KHOHAR
consolidate KHOHAR KHARA KHO KHOHAR KHOHER KHOKAHR "KHOKHER NAAI" KHONAHADA KHONAHAR KHONAHARA KHONAR KHONHARA KHONHARAS KHONIHALA KHONIHARA KHORIGA BOHAR KOKHAR KHUKHAR 


* KHUMYAR
consolidate KHUMYAR KAMHAR KUMHAR KUMHYAR 


* KLASAN
consolidate KLASAN KLASEEN KALSAN 


* KORI
consolidate KORI KORY KORI KORAI KURI KUORI 


* KOMJATOE
consolidate KOMJATOE "KOM " "KOM JATOE" "KOM JATOL" "KOM JATONI" "KOM PANJABI" 


* KUNDAL
consolidate KUNDAL KUNDAIL KUDAIL 


* LAAR
consolidate LAAR LAR LARR LARE LARA 


* LEHNGA
consolidate LEHNGA LAHNGA LANGA LANGHA 


* LONA
consolidate LONA LOONAY LONE LUNAY 


* LOHAR
consolidate LOHAR LUHAR LOHAR LOHANI LOHARA LOHR LOAR LUDHAR LOHAAR LOOHAR 

* MATA
consolidate MATA MAYA 

* MHAR
consolidate MHAR MAHR MEHAR MAHAR MEHER MEER 


* MALIK
consolidate MALIK MALAK MANIK MULIK MULIK MALK MAILK  


* MACHI -- NOT IN LATER CODOES, BUT REALLY BIG!
consolidate MACHI MOCHI MASHKI MASHI MUCHI MOUCHI MASIH MACHA MACHE MACHHI MAACHI MASCHKEE MASHKE 


* MAAMANPURI
consolidate MAAMANPURI "MAAMAN PURI" "MOMIN POURI" "MUMAN PURI" "MAMAN PURI" "MUMIN PURI" "MAMAAN PURI" "MOMIN PORI" "MOUMIN POURI" 


* MASHE
consolidate MASHE MASEH 


* MALYAR
consolidate MALYAR MALIAR MALYAAR MILYAR MALYAR MULHAAR MALHAR MILHAR MALIYAR MALIYAAR MALYA MALYAR 


* MALAH
consolidate MALAH MALLAH 


* MARKI
consolidate MARKI "MARKI KHEL" "MARKI KHAL" "MERKI KHAIL" "MARKI KHAIL" "MARKI KHIAL" "MARKI KHEL" "MARKI HEAL" "MIRKA KHEL" "MAR KAKHEL"  

* MITHA
consolidate MITHA "MITHA KHAIL" MILHA 


* MENGWAL
consolidate MENGWAL MANGHOWAL MANGWAL MANGWAL MENGOOL MANGOOL MAINGWAL MANGOOLAN MENGHOOL MEENGWAL MEEENGHWAL JEHNGWAL MENGOL   


*MERALAM
consolidate MERALAM "MER ALAM" "MEER ALAM" "MIR ALAM" "MEER AZAM" 


* MINHAS

* MOHANA
consolidate MOHANA MOHAN MOHANDA MOHNA MOHNAH MOLANA MOMAN MUHANA MUHANI "MULAN ALL" MULANA{

* MUGHAL
consolidate MUGHAL MUBHAL MUGHAL MUGHL MUGHUL MUGJAL MUGUL MUHAL MUHGAL MUHGHAL MUIGHAL MOGHAL 


* MUSLIM SHEIKH -- MUST COME BEFORE REGULAR SHEIKH!!!
consolidate "MUSLIM SHEIKH" "MUSALIM SHAIK" "MUSIM SHIKH" "MUSLAM SHAIK" "MUSLAM SHAIQ" "MUSLAM SHEIK" "MUSLAM SHIK" "MUSLIM  SHIEKH" "MUSLIM SEIKH" "MUSLIM SHAGUFTA" "MUSLIM SHAIK" "MUSLIM SHAIKH" "MUSLIM SHAKH" "MUSLIM SHEKH" "MUSLIM SHIEKH" "MUSLSM SHEIK" "MUSLIM SHEIKH" "MUSLIM SAIKH" "MUSALM SHIK" "MUSLIM SHEIK" "MUSALM SHAIK" "MUSLEM SHAIK"{


* NAICH
consolidate NAICH NACH NACHEJ NAI  NAIECH NAIEJ NAIEJH NALICH NIACH NICH 


* NANGI
consolidate NANGI NAGI NANGY 


* NANDAN

* NOON
consolidate NOON 


* NIDU
consolidate NIDU "NIDU KHAIL"  


* PANWAR
consolidate  PANWAR PANWAAR PAHOOR PANORA PUNWAR 


* PATHAN
consolidate PATHAN PETHTTAN PETHAN PHTTHAN PETTHAN PATAHN PATHAN PATHHAN PATTHAN PAYHAN PAYTHAN  PTHAAN PEHTHAN PUTHAN PATAHAN PATHAN 


* PATHOR
consolidate PATHOR PHORE PATHOOR PHAOOR PAHORA 


* PERHAR

consolidate PERHAR PARHAR 




* QAZI
consolidate QAZI QASAI "QAZI KHAIL" KAZI



* QURESHI
consolidate QURESHI "QAARESHI" "QAARISHE" "QAARISHI" "QAREESHI" "QARESHI" "QARSHI" "QRASHI" "QREESHI" "QRUESHI" "QUERSHI" "QUERSHIQ" "QUESHI" "QURAESHI" "QURAISH" "QURAISHI" "QURAISHI GHORI" "QURASH HASHMI" "QURASH HASMI" "QURASHA HASMI" "QURASHAI HASHMI" "QURASHI" "QURASHI HASHMI" "QURASHI HASMI" "QURASHY" "QURASHYI HASHMI" "QURASI" "QUREEHI" "QUREESHI" "QUREHI HASHMI" "QUREHSI" "QUREHSI HASHMI" "QUREISH" "QURESH" "QURESHI" "QURISHI" "QURSHI" "QURSHI HASHIMI"





* RAJPUT
consolidate RAJPUT "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" ///
					 "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" ///
				 	 "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" ///
					 "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" "RAJPUT BHATTI" ///
					 "RAJPOOT BHATTI"


* RANDHAWA
consolidate RANDHAWA RANDAWA RANDAHWA RANDHANA RENDHAWA RENDAWAH RENDAWHA RENDWAHA RENEAHAWA RANDHAR 


* RAJAR
consolidate RAJAR 

* RATHOR
consolidate RATHOR RATHOOR RATHOR RATHORE RATHAN 


* REMA
consolidate REMA REHMNI 


* REHMANI
consolidate REHMANI REEMA REHAN REHANI REHMAN REHMANI REHMANOI RHMANI RAHMINI RAHMANI RAHAMNI 



* RONGA
consolidate RONGA RONGHA RONGAA RANGRAZ RANGSAZ RANJA RANJHA RANJHAY RANGRAZ RANGA RANA 


* SAMIJA
consolidate SAMIJA SAMBIJA SAMEEJA SAMEJA SAMI SAMIBA SAMIGA SAMIJA SAMINA SAMITA SAMUJA SANJRA


* SHEIKH -- MUST FOLLOW MUSLIM SHEIKH
consolidate SHEIKH SHEEK SHEIH SHEIKH SHEKH SHIEKH SHIKH SHKEIKH SHAEKH 

* SARKI
consolidate SARKI SANGI SIRKI SANGHI SANGEE 


* SARAA
consolidate SARAA SAQA 


* SADIQUEI
consolidate SADIQUEI SIDDIQUE SADDIQUE SADIQIE SAIKEE SADIQUEI 


* SADHAN
consolidate SADHAN SDHAN SIDHAN 


* SAKAY

* SIYAL
consolidate SIYAL SAYAL SAYAAL SIAL SYAL "SARDANA SIAL"


* SOLANGI
consolidate  SOLANGI SLOLANGHI SOLAGI SOLANGHI SOLANGI SOLANHI SOLANI SOLNAGHI SOLNAGI SOLNGHI SOLNGI SULANGI SOLANTI SOLONGI  SOHARI SOHANA 


* SOMRO
consolidate SOMRO SOMORO  SOMROO SUMRO SOMERO SOMERA SOMRA SOMRAH SOMRU SOMUROO SOMARA SOMADA SOMARO 


*SALMANKHEL
consolidate SALMANKHEL SALMAN 

* SAHU
consolidate SAHU SAHO SAHOO

* SINDHU
consolidate SINDHU SINDU SINDHOW SINDHO SINDHA 


* SOTRAQ


* SYED
consolidate SYED SYAD SAED SAEED SAID SAYAD SAYEED SAYID SAYYAD SAYYED SEAD SEEYID SEYAD SEYID SYEED ///
			SYYED SAYD SAYED SYEE SYEEAD "SYED BUKHARI"


* TARKHAN
consolidate TARKHAN TARKAN TRAKHAN TRKHAN TERKHAN TERKHAAN TARHAN TURKHAN


* TANOORI
consolidate TANOORI TANORI TANORY THORI "TANOORI ULMAROOF MEER HEECH" "TANOORI ULMAOOF MEER HEECH"


* TANVI
consolidate TANVI  TANVLI " TANVI AL MAROF MARIACH" "TANVI AL MAROF MURAICH" "TANVI AL MAROF MUTAICH" "TANVI ALMAROF MURACH" "TANVI AL MROF MURAICH"


* TARHALI
consolidate TARHALI "TAR HAILI" TARHAILI TARHALI TARHEELI TARHELI TARHELLI TEHWAR TERAHLI TERBALI TERBILI TERHAILI TERHALAI TERHALI TERHIL TERHILA TERHILI TERSILI 



* THAHEEM
consolidate THAHEEM THAHSIM THASEEM THAYAM THEHSAIM THEHSEEM THAEEM TAHEEM 


* TEELI
consolidate TEELI TELI TEALE TAELI TELO 



* TOOR
consolidate TOOR TAILE TAILI TALI 


* WATTU
consolidate WATTU WATTO WATO WATOO 



* WARICH
consolidate WARICH  WARIACH WARHICH  WART WARRIACH  


* WARDAG
consolidate WARDAG WARDIG 


* WARAH
consolidate WARAH WARAHA WARAHO WARAECH WARACH WARA WAHRA  


* WAHIA
consolidate WAHIA WAHYA WAEHYA WAEEYA WAYAA WAI WIA  


* WIRK
consolidate WIRK WARK WARQ 


* WILLERA
consolidate WILLERA WILERA 


* ZARGAR
consolidate  ZARGAR ZARGHAR ZARGUR ZERGER ZAJGAR ZAGHAR ZAFAR ZAEGER 




* Now code it up like in the other data:
capture drop zaat_code
gen zaat_code=.
replace zaat_code= 1 if zaat=="AARAIN"
replace zaat_code= 2 if zaat=="ABBASI"
replace zaat_code= 3 if zaat=="ANSARI"
replace zaat_code= 4 if zaat=="AWAAN"
replace zaat_code= 5 if zaat=="BALOCH"
replace zaat_code= 6 if zaat=="BUTT"
replace zaat_code= 7 if zaat=="CHACHAR"
replace zaat_code= 8 if zaat=="GUJJAR"
replace zaat_code= 9 if zaat=="JAT"
replace zaat_code= 10 if zaat=="LAAR"
replace zaat_code= 11 if zaat=="MOHANA" 
replace zaat_code= 12 if zaat=="MUGHAL"
replace zaat_code= 13 if zaat=="MUSLIM SHEIKH"
replace zaat_code= 14 if zaat=="NAICH"
replace zaat_code= 15 if zaat=="PATHAN"
replace zaat_code= 16 if zaat=="QURESHI"
replace zaat_code= 17 if zaat=="RAJPUT"
replace zaat_code= 18 if zaat=="REHMANI"
replace zaat_code= 19 if zaat=="SAMIJA"
replace zaat_code= 20 if zaat=="SHEIKH"
replace zaat_code= 21 if zaat=="SOLANGI"
replace zaat_code= 22 if zaat=="SYED"

set more off
local i = 99
foreach x in "MALIK" "MACHI" "CHANDIA" "MALYAR" "KHUMYAR" "CHOHAN" "LOHAR" "GILL" "HAJAM" "LONA" "MATA" ///
			 "JHEEL" "OKHAROND" "FARQEER" "PERHAR" "TARKHAN" "KORI" "CHRISTIAN" "SARKI" "WILLERA" "KASHMIRI" ///
			 "PANWAR" "JAMALI" "JHUMBAIL" "BEHAL" "DAHAR" "GOPANG" "JATOI" "KHARAR" "SOMRO" "TANOORI" "TANVI" ///
			 "THAHEEM" "SALMANKHEL" "KHOHAR" "KAMBO" "KALER" "DAOD" "BHATA" "KUMBO" "MISSAN" "JHALO" ///
			 "TARHALI" "JABHIL" "DERICHA" "LEHNGA" "WATTU" "JAMBEEL" "MASTOIE" "RANDHAWA" "ALWI" "NIHAYA" ///
			 "GHAKER FERZALI" "ZARGAR" "WARICH" "WARAH" "WAHIA" "SIYAL" "TOOR" "SINDHU" "SARAA" "REMA" "RATHOR" ///
			 "RONGA" "JAKHAR" "KATHIYA" "BHAYA" "GUNIAL" "SAHU" "MADHOL" "QAZI" "DALU" "KUNIAL" "CLASS" "INSARI" ///
			 "KAHITA" "KLASAN" "JOPU" "MARWAI" "MENGWAL" "SHTAAL" "DAB" "JANGLA" "ATRAAL" "GHAFARI" "PHATAN" ///
			 "PARYAR" "DOSEE" "KHAN" "BABO" "MAAMANPURI" "KAKAR" "DOBI" "NIDU" "RAJAR" "NOON" "WIRK" ///
			 "WARDAG" "JHANEG" "MASHE" "PHOR" "GORI" "PATHOR" "WALOOT"  "MHAR" "DHALOON" ///
			 "RAJA" "QALYAAR" "MUHEEL" "GHALLO" "KACHI" "JODRA" "SADHAN"  "DOGAR" "COBLER" ///
			 "SAKAY" "HASMI" "DAYA" "KANJO" "MAKOOL" "SOTRAQ" "NANDAN" "MARKI" "AFGHANI" "HINDU" ///
			 "MINHAS" "CHEENY" "NANGI" "JUNJOWA" "KATWAL" "MERALAM" "BHATTI" "MITHA" "DURANI" "ADAL" "CHUNGER" ///
			 "BHADER" "CHANAR" "RAO" "MALAH" "KHANAN" "BHATYARA" "KUNDAL" "JAWALA" "KHER" "KHOSA" "CHANDYA" {
	replace zaat_code = `i' if zaat == "`x'"
	local i = `i'+1
}



replace zaat_code=23 if zaat_code==.

* Should have less than 7% without code
count if zaat_code == 23
local missing = `r(N)'
count
display `missing' / `r(N)'
assert `missing' / `r(N)' < 0.15

qqq
* Check missing Categories
set more off

forvalues x = 1/22 {
	display "`x'"
	count if zaat_code == `x'
	assert `r(N)' > 0
}

sum zaat_code
forvalues x = 99/`r(max)' {
	display "`x'"
	tab zaat if zaat_code==`x'
	count if zaat_code == `x'
	assert `r(N)' > 0
}

egen ztag = tag(zaat)
bysort zaat: gen size=_N 

sort size
br zaat  size if ztag==1 & zaat_code==23

qqq



* Only 7% have no assignment

drop if zaat_code==23





* Make fractionalization based on new codes
egen hhtag=tag(hhid)
bysort mauzaid zaat_code: egen MZ_numhh=sum(hhtag)
bysort mauzaid: egen M_numhh=sum(hhtag)




	* Stop real quick to make variables for share per code per village:
	gen zaat_matching=zaat_code
	recode zaat_matching (98=23) (99=23)
	forvalues z=1/23 {
		gen temp_`z'=MZ_numhh/M_numhh if zaat_code==`z'
		bysort mauzaid: egen mauza_zaat_share`z'=max(temp_`z')
		drop temp_`z'
		replace mauza_zaat_share`z'=0 if mauza_zaat_share`z'==.
		label var mauza_zaat_share`z' "Share of total village that's Zaat `z'"
		}

*square stuff
gen MZ_numhh2 = MZ_numhh*MZ_numhh
gen M_numhh2 = M_numhh * M_numhh
gen MZ_frac = MZ_numhh2/M_numhh2



egen mztag=tag(mauzaid zaat_code)
bysort mauzaid: egen tmp= sum(MZ_frac) if mztag==1
bysort mauzaid: egen tmp2 = max(tmp)
gen mauza_zaat_frac=1-tmp2
drop tmp*


* Make Reynal-Querol polarization
gen temp_polarity_term=MZ_frac*(1-(MZ_numhh/M_numhh))

bysort mauzaid: egen temp=sum(temp_polarity_term) if mztag==1
bysort mauzaid: egen temp2=max(temp)
gen mauza_zaat_polarity=1-temp2
drop temp*
label var mauza_zaat_polarity "Village Polarity"





egen mtag=tag(mauzaid)
keep if mtag==1
label var mauza_zaat_frac "Nick's Fractionalization"
gen num_greater_than_10=0
forvalues x=1/23 {
	replace num_greater_than_10=num_greater_than_10+1 if mauza_zaat_share`x'>0.10
}

label var num_greater_than_10 "Number of castes with more than 10% of village"



* Make share of village that is top two castes
egen temp_max=rowmax(mauza_zaat_share*)

forvalues x=1/23 {
	gen mauza_zaat_share`x'_temp=mauza_zaat_share`x'
	replace mauza_zaat_share`x'_temp=. if mauza_zaat_share`x'==temp_max
}

egen temp_second=rowmax(mauza_zaat_share*_temp)

gen share_in_toptwo=temp_max+temp_second
drop temp_* *_temp



* Make some terciles
xtile zfrac3=mauza_zaat_frac, n(3)
xtile zfrac4=mauza_zaat_frac, n(4)


table zfrac3, c(min mauza_zaat_frac max mauza_zaat_frac)
table zfrac3, c(min M_numhh max M_numhh median M_numhh mean M_numhh)

twoway(kdensity mauza_zaat_frac if district==1)(kdensity mauza_zaat_frac if district==2)(kdensity mauza_zaat_frac if district==3)

label var mauza_zaat_frac "Biraderi Fractionalization"

rename share_in_toptwo mauza_share_in_toptwo


keep mauzaid mauza_zaat_frac mauza_zaat_polar mauza_zaat_share* zfrac*  num_greater mauza_share_in_toptwo district
sort mauzaid

save $pk/prepublic_data/from_hhcensus.dta, replace
