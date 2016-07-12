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
* The LEAPS survey has 25 hard-coded biraderis / zaats, so 
* I'm going to assume those are the most common and the ones I want to bin into. 
* 
* This file's primary purpose is to consolidate various transliterations of 
* each zaat into the same group, with the priority groups being the 25 in 
* the leaps file. 
*
* I then use these to create a fragmentation measure. 
*********************


set more off
use $datadir/household/hhcensus1/hhcensus_short.dta, clear


rename s1q3 district
rename s1q11 zaat



************
* 
* 
* Zaat code consolidation
*
*
************


*********
* First general trimming
*********

* Drop weird characters. Some redundancy I know so syntax editor still works. :)

foreach x in "," "." "]" "'" "'" "`" "'" ";" "\" {
	replace zaat = subinstr(zaat, "`x'", "", .)
}

replace zaat=trim(zaat)
replace zaat=upper(zaat)

forvalues x = 1/5 {
	replace zaat= subinstr(zaat, "  ", " ", .)	
}

drop if zaat==""

* Write consolidation function. Takes list of strings, where first
* is "target" string -- one we want all to converge to. 
* Note that has to match with START but not full string, so if 
* listed first will match. 
* 

capture program drop consolidate
program define consolidate

	foreach x in `0' {
		replace zaat = "`1'" if regex(zaat, "^`x'") == 1
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

******
* Consolidate top 25 
* (found in general school 2 file, which I will use for school fragmentation)
* Note naich twice. In data, mostly on grouped category, so keep that. 
******
	* Abbasi
	* Ansari
	* Arain
	* Awan
	* Baloch
	* Butt
	* Chachar
	* Dhobi/Lohar/Mochi/Nai
	* Gujjar
	* Hashmi/Qureshi
	* Jat
	* Kharar
	* Lar
	* Mohana
	* Mughal
	* Muslim Shiekh
	* Naich
	* Non muslim
	* Pathan
	* Rajput/Bhatti
	* Rehmani
	* Samejha
	* Shiekh
	* Solangi
	* Syed



* ABBASI
consolidate ABBASI  ABBASSI ABBAS ABASO ABAS

* ANSARI
consolidate ANSARI ASNARI ANASRI ANARI ANSAI ANSARY ANSRI ANSSRI ANSSARY ANSAARI 

* ARAIN
consolidate ARAIN AARAIN ARRAIN ARAAIN ARIANE ARIANN ARIE ARIEA ARIEANH ARIEN ARIENA ARIENE ARIHAN ARIIAN ARIINE ARIN ///
			ARINA ARIYAN ARIYN ARAINA ARAINE ARAINJ ARAIYEIN ARANIE ARAQIN ARARIN ARAUIN ARAUN ARAYAN ARAYEEN ARAYEN ///
			ARAYIN ARAYN AREEA AREEN AREIAN AREIEN ARIAINE ARIAN AROR ARRAEEN ARRAEIN ARRAEN ARRAHIN ARRAI ARRAIEN ///
			ARRAINE ARRAIRE ARRAIYEIN ARRAIYEN ARRAN ARRAOM ARRAQIN ARREEN ARREIN ARRIAN ARRIANE ARRIEN ARRIN ARRSAIN ///
			ARYAN ARYIN AARAIN ARAYEEN ARAYEN ARAYIN ARAIAN ARAIEN ARAIEND ARAIEND ARAIN ARAINE ARAIYEIN ARANIE ARIN ///
			ARIYN ARAAI ARAI ANSAREE "MALIK AARAIN" "MALIK ARRAIN" "ARAIN PUNJABI" ARAEIN

* AWAN
consolidate AWAN AWAAN AAWAN AWAAB AWAAM AWAAN AWAB AWAIN AWAM AWAMEE AWAN AWANB AWAN AWN AWWAN 


* BALOCH
consolidate BALOCH BALOUCH BALAOCH BALCOH BALO0CH BALOACH BALOCH BALOOCH TALOOCH BALOSH ///
 			BALOUCH BLAOCH BLOCH BLOOCH BLOACH BULOCH BOLOCH "BALOCH CHANDIA" "KORAI BALOCH" "GOPANG BALOCH" "JAMLI BLOCH" ///
 			"BLOCH CHANDIA" "SHAIR BALOCH" "JATOI BALOCH" "KORAI BALOCH" "JAMLI BALOACH" "JAMALI BOLOUCH" "JAMALI BALOCH" ///
 			"SHER BALOCH" "KOREA BLOACH" "KORAI BLOCH"

* BUTT
consolidate BUTT 


* BHATTI
consolidate BHATTI BAHHATI BAHHIT BAHHTI BAHITT BAHTA BAHTE BAHTEE BAT BATHA BATHI BATI BATT BATTA BATTHA BATTI ///
			BATYARA BHATT BHATTA BHATTE BHATTI BHTA BHTI BUHTAY BUHTTI  BUTHA BUTHI BHTTI BHUTI BAHTTI BHALLI GHATTI 



* CHACHAR
consolidate CHACHAR CHACAHR CHACAR CHACHAAR CHACHAER CHACHAN CHACHAR CHACHER CHACHR CHACHRA CHACHRE CHACHURE CHADHAR ///
			CHADHYER CHAHCHAN CHANDIYAH CHANGAR CHANGHAR CHANGHARR CHARCHAR CHARCHER CHARCHR CHARHARAR CHAUDHARI ///
			CHAUDHARY CHAUDHRY CHAUHAN CHAWARA CHAWARD CHIDDHAR CHIDDHRA CHIDHAR KHATTAR KHOKHAR KHAKHAR KAAKAR ///
			"KOH KAR" KAHAR "CHA CHAR" KACHAR 



* DHOBI
consolidate DHOBI DOBI DOHBHI DOUBI DUBI DOBBI DHOBBI  DHUBBI DHOOBI GHOBI BHOBI DHOBHI 



* GUJJAR
consolidate GUJJAR GHUJAR GUAAR GUAJAR GUGAR GUGHAR GUGHJAR GUHGHAR GUHKHER GUJAAR GUJAFR GUJAR GUJER GUJET ///
			GUJHER GUJJAR GUJJR GUJR GUJRAR GYJJAR JUGGAR JUGAR  


* HASHMI
consolidate  HASHMI HASMI


* HAJAM (barber) -- belongs in Lohar, Dhobi, mochi, etc. 
consolidate HAJAM HAJJAM HUJAM HIJAM HAJAAM HAJIAM 

* JAT
consolidate JAT JAAT JUTT GUTT JUT JATT GAT "JATT BHUTTA" "BAJWAH JATT" "KLER JATT" "JATT BAJWAH" ///
			"SINDHU JATT" "JUT KASRA" "SANDHU JUTT" "JUTT KHARA" "DHALOON JUTT" "RANDHAWA JUTT" ///
			"KALHAR JAT" "KAMBOW JAT" "JATT GIL" "GORAYA JUTT" "SINDHU JATT" "CHEEMA JUTT" ///
			"KALER JET" "KULU JATT" 


* KHAHAR
consolidate KHARAR KHOHAR KHARA KHO KHOHAR KHOHER KHOKAHR "KHOKHER NAAI" KHONAHADA KHONAHAR KHONAHARA KHONAR KHONHARA ///
			KHONHARAS KHONIHALA KHONIHARA KHORIGA BOHAR KOKHAR KHUKHAR KHOKER KAKAR KAKER  ///
			KHARAR KHARAAR KHARAL KHARAR KHARKISH KHARL KHAWAJA KAHTAR KATHAR KHETER KHTAR KHORAR KHAROR ///
			KAKHAR

* KHUMYAR  -- potter; belongs in Lohar, Dhobi, mochi, etc. 
consolidate KHUMYAR KAMHAR KUMHAR KUMHYAR 

* LAR
consolidate LAR LAAR  LARR LARE LARA

* LOHAR
consolidate LOHAR LUHAR LOHAR LOHANI LOHARA LOHR LOAR LUDHAR LOHAAR LOOHAR LADAR


* MOCHI 
consolidate MOCHI MACHI MASHKI MASHI MUCHI MOUCHI MASIH MACHA MACHE MACHHI MAACHI MASCHKEE MASHKE 

* MOHANA
consolidate MOHANA MOHAN MOHANDA MOHNA MOHNAH MOLANA MOMAN MUHANA MUHANI "MULAN ALL" MULANA

* MUGHAL
consolidate MUGHAL MUBHAL MUGHAL MUGHL MUGHUL MUGJAL MUGUL MUHAL MUHGAL MUHGHAL MUIGHAL MOGHAL 


* MUSLIM SHEIKH -- MUST COME BEFORE REGULAR SHEIKH!!!
consolidate "MUSLIM SHEIKH" "MUSALIM SHAIK" "MUSIM SHIKH" "MUSLAM SHAIK" "MUSLAM SHAIQ" "MUSLAM SHEIK" "MUSLAM SHIK" ///
			"MUSLIM  SHIEKH" "MUSLIM SEIKH" "MUSLIM SHAGUFTA" "MUSLIM SHAIK" "MUSLIM SHAIKH" "MUSLIM SHAKH" ///
			"MUSLIM SHEKH" "MUSLIM SHIEKH" "MUSLSM SHEIK" "MUSLIM SHEIKH" "MUSLIM SAIKH" "MUSALM SHIK" "MUSLIM SHEIK" ///
			 "MUSALM SHAIK" "MUSLEM SHAIK"



* NAICH
consolidate NAICH NACH NACHEJ NAI  NAIECH NAIEJ NAIEJH NALICH NIACH NICH 


* NON-MUSLIM
consolidate NON-MUSLIM HINDU HINDO HINDKO 


* PATHAN
consolidate PATHAN PETHTTAN PETHAN PHTTHAN PETTHAN PATAHN PATHAN PATHHAN PATTHAN PAYHAN PAYTHAN  PTHAAN PEHTHAN ///
			PUTHAN PATAHAN PATHAN PHATAN




* QURESHI
consolidate QURESHI "QAARESHI" "QAARISHE" "QAARISHI" "QAREESHI" "QARESHI" "QARSHI" "QRASHI" "QREESHI" "QRUESHI" ///
			"QUERSHI" "QUERSHIQ" "QUESHI" "QURAESHI" "QURAISH" "QURAISHI" "QURAISHI GHORI" "QURASH HASHMI" ///
			"QURASH HASMI" "QURASHA HASMI" "QURASHAI HASHMI" "QURASHI" "QURASHI HASHMI" "QURASHI HASMI" ///
			"QURASHY" "QURASHYI HASHMI" "QURASI" "QUREEHI" "QUREESHI" "QUREHI HASHMI" "QUREHSI" "QUREHSI HASHMI" ///
			"QUREISH" "QURESH" "QURISHI" "QURSHI" "QURSHI HASHIMI" "HASHMI QURASHI" "QURESHI HASHMI"





* RAJPUT -- CHOHAN . 
consolidate RAJPUT "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" ///
					 "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" ///
				 	 "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" ///
					 "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" "RAJPUT BHATTI" ///
					 "RAJPOOT BHATTI" "CHOHAN RAJPOOT" "RAJPOOT BHAKIRYAL" "KOREA BLOACH" ///
					 "COHAN" CHOHAN CHOHAAN CHOHAN CHUHAN CHOCHAN CHOOHAN CHOAN 





* REHMANI
consolidate REHMANI REEMA REHAN REHANI REHMAN REHMANI REHMANOI RHMANI RAHMINI RAHMANI RAHAMNI 


* SAMEJHA
consolidate SAMEJHA SAMIJA SAMBIJA SAMEEJA SAMEJA SAMI SAMIBA SAMIGA SAMIJA SAMINA SAMITA SAMUJA SANJRA


* SHEIKH
consolidate SHEIKH SHEEK SHEIH  SHEKH SHIEKH SHIKH SHKEIKH SHAEKH 


* SOLANGI
consolidate SOLANGI SLOLANGHI SOLAGI SOLANGHI SOLANGI SOLANHI SOLANI SOLNAGHI SOLNAGI SOLNGHI SOLNGI SULANGI ///
			SOLANTI SOLONGI  SOHARI SOHANA 


* SYED
consolidate SYED SYAD SAED SAEED SAID SAYAD SAYEED SAYID SAYYAD SAYYED SEAD SEEYID SEYAD SEYID SYEED ///
			SYYED SAYD SAYED SYEE SYEEAD



* TARKHAN (carpenter) -- belongs in Lohar, Dhobi, mochi, etc. 
consolidate TARKHAN TARKAN TRAKHAN TRKHAN TERKHAN TERKHAAN TARHAN TURKHAN


* Now code. Don't match other files, but not necessary for this. 
capture drop zaat_code
gen zaat_code=.
replace zaat_code= 1 if zaat=="ABBASI"
replace zaat_code= 2 if zaat=="ANSARI"
replace zaat_code= 3 if zaat=="ARAIN"
replace zaat_code= 4 if zaat=="AWAN"
replace zaat_code= 5 if zaat=="BALOCH"
replace zaat_code= 6 if zaat=="BUTT"
replace zaat_code= 7 if zaat=="CHACHAR"
replace zaat_code= 8 if inlist(zaat, "NAICH", "MOCHI", "LOHAR", "DHOBI", "TARKHAN", "KHUMYAR", "HAJAM")
replace zaat_code= 9 if zaat=="GUJJAR"
replace zaat_code= 10 if zaat=="QURESHI" | zaat == "HASHMI"
replace zaat_code= 11 if zaat=="JAT"
replace zaat_code= 12 if zaat == "KHARAR"
replace zaat_code= 13 if zaat == "LAR"
replace zaat_code= 14 if zaat == "MOHANA"
replace zaat_code= 15 if zaat == "MUGHAL"
replace zaat_code= 16 if zaat == "MUSLIM SHEIKH"
replace zaat_code= 17 if zaat == "NON-MUSLIM"
replace zaat_code= 18 if zaat == "PATHAN"
replace zaat_code= 19 if zaat == "RAJPUT" | zaat == "BHATTI"
replace zaat_code= 20 if zaat == "REHMANI"
replace zaat_code= 21 if zaat == "SAMEJHA"
replace zaat_code= 22 if zaat == "SHEIKH"
replace zaat_code= 23 if zaat == "SOLANGI"
replace zaat_code= 24 if zaat == "SYED"



********
* TOP 25 MORE AGGRESSIVE REGULAR EXPRESSIONS
********
* Jaat
replace zaat = "JAT" if (regex(zaat, "JAT") | regex(zaat, "JUT") ) & zaat_code == .
replace zaat_code = 11 if zaat == "JAT"

* Rajput
foreach x in RAJPUT "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" ///
					 "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" ///
				 	 "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" ///
					 "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" {

	replace zaat = "RAJPUT" if regex(zaat, "`x'") & zaat_code == .
}
replace zaat_code = 19 if zaat == "RAJPUT"


* Baloch
foreach x in BALOCH BALOUCH BALAOCH BALCOH BALO0CH BALOACH BALOCH BALOOCH TALOOCH BALOSH ///
			 BALOUCH BLAOCH BLOCH BLOOCH BLOACH BULOCH BOLOCH {

	replace zaat = "BALOCH" if regex(zaat, "`x'") & zaat_code == .	
}
replace zaat_code = 5 if zaat == "BALOCH"

* SYED
foreach x in SYED SYAD SAED SAEED SAID SAYAD SAYEED SAYID SAYYAD SAYYED SEAD SEEYID SEYAD SEYID SYEED ///
			SYYED SAYD SAYED SYEE SYEEAD {

	replace zaat = "SYED" if regex(zaat, "`x'") & zaat_code == .
}
replace zaat_code = 24 if zaat == "SYED"


***
* Couple tests
***

* All these should be populated
* Check missing Categories

set more off

sum zaat_code
forvalues x = 1 / `r(max)' {
	display "`x'"
	count if zaat_code == `x'
	assert `r(N)' > 0
}


* Should have less than 26% without code
count if zaat_code == .
local missing = `r(N)'
count
display `missing' / `r(N)'
assert `missing' / `r(N)' < 0.26




************************
*
* Group others  into either "other" or "can't classify string"
*
*************************


* ADAL
consolidate ADAL "ADAL KHAIL" "ADA KHAIL" "ADAL KHAN" "ADIL KHEL" 


* AFGHANI
consolidate AFGHANI AFGHAN AFGHANI AFGANI 


* ATRAAL
consolidate ATRAAL AMRAAL ATHWAL ATHRAAN 



*ALWI
consolidate ALWI ALRYI 

* BABO
consolidate BABO BABU 

* BHATYARA
consolidate BHATYARA BHUTYARA  

* BHADER
consolidate BHADER 

* BEHAL
consolidate BEHAL BEHEAL BHEL BHAIL BHAYAL BHAYAL BAHAL BAKHAL BAHAEL BAHEAL BAHALE BAHIL BEHAEAL BEHAEL ///
			BAHIL BEAHEAL BEAHEL 

* BHATA
consolidate BHATA BHATOO BHOTHA BHUTA BHUTTA

* BHAYA
consolidate BHAYA 

* CHANDYA
consolidate CHANDYA CHNDIYA CAHNDYA CAMBHO CHANDAI CHANDEU CHANDIA "CHANDIA NAAI" CHANDIO CHANGAD CHANGID CHANDIYO CHANDIYA 

* CHEENY
consolidate CHEENY CHEENA  


* COBLER
consolidate COBLER COBBLER COBLER 

* CHANAR
consolidate CHANAR CHINAR CHNAR CHENEAR 

* DAHAR
consolidate DAHAR DAHA DAHAR DAHER DAHRJA DAAR DAR 

* DHALOON
consolidate DHALOON DHALON 

* DAOD
consolidate DAOD DAD DADOO DAYOO ODD "DAD POTRA" "DADOO KHAIL"

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

* GUNIAL
consolidate GUNIAL 


* INSARI
consolidate INSARI INASARI INSARI INSAREE INSARE 

* JAWALA
consolidate JAWALA JAWAHA     

*JATOI
consolidate JATOI JATOIE JATOOI 

* JANGAL
consolidate JANGAL JANGALA JANGALLA 

* JABHIL
consolidate JABHIL JHBAIL JHABAL JHABEL JHAIL  JHAMBHEEL JHABAIL JHABEEL JAHBEEL

* JAKHAR
consolidate JAKHAR 

* JALAL
consolidate JALAL "JALAL KHEL" JILAH "JALAL KHAIL" JALAL JANGAL JANGLLA 

* JAMALI
consolidate JAMALI 

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

* KALER
consolidate  KALER KAMHAAR KAMHRA KALHAR KALHORA "KALR MAHAR" KAMANGHAR 

* KAMBO
consolidate KAMBO KAMBAHWA "KAMBH WA" KAMBHEWA KAMBOO KAMBOW  KAMBWA KOMBOH KAMBOH 

* KANJO
consolidate KANJO KANJU 

*KASHMIRI
consolidate KASHMIRI KSHMERI KASHMERI KASHMIRI KASHMIRY KASHMIRE KASHMIREE KASHMEERAY KASHMEERAY KASHMAIRA ///
			KASHMARY KASHIMIRY KASHMIRA KASHMIRE KASMIRY 

* KATHIYA
consolidate KATHIYA KATHIA KATHIYA 

* KHANAN
consolidate KHANAN KHAMAN 

* KHAN
consolidate KHAN 


* KLASAN
consolidate KLASAN KLASEEN KALSAN 

* KORI
consolidate KORI KORY KORI KORAI KURI KUORI 

* KOMJATOE
consolidate KOMJATOE "KOM " "KOM JATOE" "KOM JATOL" "KOM JATONI" "KOM PANJABI" 

* KUNDAL
consolidate KUNDAL KUNDAIL KUDAIL 

* LEHNGA
consolidate LEHNGA LAHNGA LANGA LANGHA 

* LONA
consolidate LONA LOONAY LONE LUNAY 

* MATA
consolidate MATA MAYA 

* MHAR
consolidate MHAR MAHR MEHAR MAHAR MEHER MEER 

* MALIK
consolidate MALIK MALAK MANIK MULIK MULIK MALK MAILK  

* MAAMANPURI
consolidate MAAMANPURI "MAAMAN PURI" "MOMIN POURI" "MUMAN PURI" "MAMAN PURI" "MUMIN PURI" "MAMAAN PURI" ///
			"MOMIN PORI" "MOUMIN POURI" 

* MASHE
consolidate MASHE MASEH 

* MALYAR
consolidate MALYAR MALIAR MALYAAR MILYAR MALYAR MULHAAR MALHAR MILHAR MALIYAR MALIYAAR MALYA MALYAR 

* MALAH
consolidate MALAH MALLAH 

* MARKI
consolidate MARKI "MARKI KHEL" "MARKI KHAL" "MERKI KHAIL" "MARKI KHAIL" "MARKI KHIAL" "MARKI KHEL" "MARKI HEAL" ///
			"MIRKA KHEL" "MAR KAKHEL"  

* MITHA
consolidate MITHA "MITHA KHAIL" MILHA 

* MENGWAL
consolidate MENGWAL MANGHOWAL MANGWAL MANGWAL MENGOOL MANGOOL MAINGWAL MANGOOLAN MENGHOOL MEENGWAL MEEENGHWAL ///
			JEHNGWAL MENGOL   

*MERALAM
consolidate MERALAM "MER ALAM" "MEER ALAM" "MIR ALAM" "MEER AZAM" 

* MINHAS

* NANGI
consolidate NANGI NAGI NANGY 

* NANDAN

* NOON
consolidate NOON 

* NIDU
consolidate NIDU "NIDU KHAIL"   


* PATHOR
consolidate PATHOR PHORE PATHOOR PHAOOR PAHORA PAHOOR

* PERHAR
consolidate PERHAR PARHAR "PARYAR" PARHAAR

* QAZI
consolidate QAZI QASAI "QAZI KHAIL" KAZI

* RANDHAWA 
consolidate RANDHAWA RANDAWA RANDAHWA RANDHANA RENDHAWA RENDAWAH RENDAWHA RENDWAHA RENEAHAWA RANDHAR RENDAHAWA

* RAJAR
consolidate RAJAR 

* RATHOR
consolidate RATHOR RATHOOR RATHOR RATHORE RATHAN 

* REMA
consolidate REMA REHMNI 

* RONGA
consolidate RONGA RONGHA RONGAA RANGRAZ RANGSAZ RANJA RANJHA RANJHAY RANGRAZ RANGA RANA 

* SARKI
consolidate SARKI SANGI SIRKI SANGHI SANGEE 

* SARAA
consolidate SARAA SAQA 

* SADIQUEI
consolidate SADIQUEI SIDDIQUE SADDIQUE SADIQIE SAIKEE

* SADHAN
consolidate SADHAN SDHAN SIDHAN 

* SAKAY

* SIYAL
consolidate SIYAL SAYAL SAYAAL SIAL SYAL "SARDANA SIAL"

* SOMRO
consolidate SOMRO SOMORO  SOMROO SUMRO SOMERO SOMERA SOMRA SOMRAH SOMRU SOMUROO SOMARA SOMADA SOMARO 

*SALMANKHEL
consolidate SALMANKHEL SALMAN 

* SAHU
consolidate SAHU SAHO SAHOO

* SHAH
consolidate SHAH

* SINDHU
consolidate SINDHU SINDU SINDHOW SINDHO SINDHA 

* SOTRAQ

* TANOORI
consolidate TANOORI TANORI TANORY THORI "TANOORI ULMAROOF MEER HEECH" "TANOORI ULMAOOF MEER HEECH"

* TANVI
consolidate TANVI  TANVLI " TANVI AL MAROF MARIACH" "TANVI AL MAROF MURAICH" "TANVI AL MAROF MUTAICH" ///
			"TANVI ALMAROF MURACH" "TANVI AL MROF MURAICH"

* TARHALI
consolidate TARHALI "TAR HAILI" TARHAILI TARHALI TARHEELI TARHELI TARHELLI TEHWAR TERAHLI TERBALI ///
			TERBILI TERHAILI TERHALAI TERHALI TERHIL TERHILA TERHILI TERSILI 

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

set more off
local i = 100
foreach x in "ADAL" "AFGHANI" "ALWI" "ATRAAL" "BABO" "BEHAL" "BHADER" "BHATA" ///
			"BHATYARA" "BHAYA" "CHANAR" "CHANDYA" "CHEENY" "CHRISTIAN"  ///
			"CHUNGER" "CLASS" "COBLER" "DAB" "DAHAR" "DALU" "DAOD" "DAYA" "DERICHA" "DHALOON"  ///
			"DOGAR" "DOSEE" "DURANI" "FARQEER" "GHAFARI" "GHAKER FERZALI" "GHALLO" "GILL"  ///
			"GOPANG" "GORI" "GUNIAL" "INSARI" "JABHIL" "JAKHAR"  ///
			"JAMALI" "JAMBEEL" "JANGLA" "JAWALA" "JHALO" "JHANEG" "JHEEL" "JHUMBAIL"  ///
			"JODRA" "JOPU" "JUNJOWA" "KACHI" "KAHITA" "KALER" "KAMBO" "KANJO" "KASHMIRI"  ///
			"KATHIYA" "KATWAL" "KHAN" "KHER"   ///
			"KLASAN" "KORI" "KUMBO" "KUNDAL" "KUNIAL" "LEHNGA" "LONA" "MAAMANPURI"  ///
			"MADHOL" "MAKOOL" "MALAH" "MALIK" "MALYAR" "MARKI" "MARWAI" "MASHE" "MASTOIE" "MATA"  ///
			"MENGWAL" "MERALAM" "MHAR" "MINHAS" "MISSAN" "MITHA" "MUHEEL" "NANDAN" "NANGI" "NIDU"  ///
			"NIHAYA" "NOON" "OKHAROND"  "PATHOR" "PERHAR" "PHOR" "QALYAAR"  ///
			"QAZI" "RAJA" "RAJAR" "RANDHAWA" "RAO" "RATHOR" "REMA" "RONGA" "SADHAN" "SADIQUEI" "SAHU"  ///
			"SAKAY" "SALMANKHEL" "SARAA" "SARKI" "SHAH" "SHTAAL" "SINDHU" "SIYAL" "SOMRO" "SOTRAQ"  ///
			"TANOORI" "TANVI" "TARHALI" "TEELI" "THAHEEM" "TOOR" "WAHIA" "WALOOT" "WARAH"  ///
			"WARDAG" "WARICH" "WATTU" "WILLERA" "WIRK" "ZARGAR" {

	display "`x'"
	count if zaat == "`x'"
	assert `r(N)' != 0
	replace zaat_code = 98 if zaat == "`x'" & zaat_code == .
	local i = `i'+1
}

replace zaat_code=99 if zaat_code==.

label define zaat_code 98"Other" 99"Invalid string?", modify
label values zaat_code zaat_code


* * Check residuals
* bysort zaat: gen size = _N 
* egen t = tag(zaat)
* sort size 
* br zaat size if t == 1 & zaat_code == 99





************
*
* Make fragmentation measures
*
************

***
* Make with all categories
***

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
	gen mauza_zaat_frac_all = 1-tmp2
	assert mauza_zaat_frac_all >= 0 & mauza_zaat_frac_all <=1 & mauza_zaat_frac_all !=.
	drop tmp* M_* hhtag mztag

	label var mauza_zaat_frac_all "Mauza Biraderi Fractionalization"

***
* Make based on grouped
***

	keep if zaat_code != 99

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
	gen mauza_zaat_frac_others = 1-tmp2
	assert mauza_zaat_frac_others >= 0 & mauza_zaat_frac_others <=1 & mauza_zaat_frac_others !=.
	drop tmp* M_* hhtag mztag

	label var mauza_zaat_frac_others "Mauza Biraderi Fractionalization"


***
* Only top 24
***

	keep if zaat_code < 98

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
	gen mauza_zaat_frac = 1-tmp2
	assert mauza_zaat_frac >= 0 & mauza_zaat_frac_others <=1 & mauza_zaat_frac_others !=.
	drop tmp*  hhtag mztag

	label var mauza_zaat_frac "Mauza Biraderi Fractionalization (from top 24 codes)"

corr mauza_zaat_frac mauza_zaat_frac_others 
assert `r(rho)' > 0.95

corr mauza_zaat_frac mauza_zaat_frac_all
assert `r(rho)' > 0.95

* Keep only top 24. Others are all very small groups, so keeping "other" aggregate
* creates artificially homogenous appearance. But clearly doesn't matter much -- corr > 0.95.

drop mauza_zaat_frac_others mauza_zaat_frac_all

***
* 
* Make share of village that is top two castes
*
**

* Look only at top 24 categories so can compare with later data directly. 

sum zaat_code
local num_zaats = `r(max)'


forvalues z = 1 / `num_zaats' {
	gen temp_`z' = M_zaat_numhh / M_numhh if zaat_code == `z'
	bysort mauzaid: egen mauza_share_zaat_`z' = max(temp_`z')
	drop temp_`z'
	replace mauza_share_zaat_`z' = 0 if mauza_share_zaat_`z' == .
	label var mauza_share_zaat_`z' "Share of total village that's Zaat `z' "
}

duplicates drop mauzaid, force

* Get share in top two. Stupid convoluted because of troubles with row-ops in Stata.  

sum zaat_code
local num_zaats = `r(max)'

egen t_1 = rowmax(mauza_share_zaat_*)

gen to_drop = .
forvalues x = 1 / `num_zaats' {
	replace to_drop = `x' if (mauza_share_zaat_`x' == t_1) & (to_drop == .)
}

forvalues x = 1 / `num_zaats' {
	replace mauza_share_zaat_`x' = . if (to_drop == `x')
}

egen t_2 = rowmax(mauza_share_zaat_*)

assert t_1 >= t_2

gen share_in_toptwo = t_1 + t_2
drop to_drop t_1 t_2 mauza_share_zaat_*

**********
* Clean up a little
**********


rename share_in_toptwo mauza_share_in_toptwo
label var mauza_share_in_toptwo "Share of Mauza in two larges Biraderis (only looking at top `num_zaats' codes)"

keep mauzaid mauza_zaat_frac mauza_share_in_toptwo district
sort mauzaid

save $pk/prepublic_data/from_hhcensus.dta, replace
