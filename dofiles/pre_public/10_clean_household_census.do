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
consolidate AARAIN ARRAIN ARAAIN ARIANE ARIANN ARIE ARIEA ARIEANH ARIEN ARIENA ARIENE ARIHAN ARIIAN ARIINE ARIN ///
			ARINA ARIYAN ARIYN ARAINA ARAINE ARAINJ ARAIYEIN ARANIE ARAQIN ARARIN ARAUIN ARAUN ARAYAN ARAYEEN ARAYEN ///
			ARAYIN ARAYN AREEA AREEN AREIAN AREIEN ARIAINE ARIAN AROR ARRAEEN ARRAEIN ARRAEN ARRAHIN ARRAI ARRAIEN ///
			ARRAINE ARRAIRE ARRAIYEIN ARRAIYEN ARRAN ARRAOM ARRAQIN ARREEN ARREIN ARRIAN ARRIANE ARRIEN ARRIN ARRSAIN ///
			ARYAN ARYIN AARAIN ARAYEEN ARAYEN ARAYIN ARAIAN ARAIEN ARAIEND ARAIEND ARAIN ARAINE ARAIYEIN ARANIE ARIN ///
			ARIYN ARAAI ARAI ANSAREE "MALIK AARAIN" "MALIK ARRAIN" "ARAIN PUNJABI"


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
 "BLOCH CHANDIA" "SHAIR BALOCH" "JATOI BALOCH" "KORAI BALOCH" "JAMLI BALOACH" "JAMALI BOLOUCH" "JAMALI BALOCH" ///
 "SHER BALOCH" "KOREA BLOACH" "KORAI BLOCH"


* BABO
consolidate BABO BABU 


* BEHAL
consolidate BEHAL BEHEAL BHEL BHAIL BHAYAL BHAYAL BAHAL BAKHAL BAHAEL BAHEAL BAHALE BAHIL BEHAEAL BEHAEL ///
			BAHIL BEAHEAL BEAHEL 

* BHATA
consolidate BHATA BHATOO BHOTHA BHUTA BHUTTA

* BHAYA
consolidate BHAYA 

* BUTT
consolidate BUTT 

* BHATYARA
consolidate BHATYARA BHUTYARA  


* BHATTI
consolidate BHATTI BAHHATI BAHHIT BAHHTI BAHITT BAHTA BAHTE BAHTEE BAT BATHA BATHI BATI BATT BATTA BATTHA BATTI ///
			BATYARA BHATT BHATTA BHATTE BHATTI BHTA BHTI BUHTAY BUHTTI  BUTHA BUTHI BHTTI BHUTI BAHTTI BHALLI GHATTI 


* BHADER
consolidate BHADER 


* CHACHAR
consolidate CHACHAR CHACAHR CHACAR CHACHAAR CHACHAER CHACHAN CHACHAR CHACHER CHACHR CHACHRA CHACHRE CHACHURE CHADHAR ///
			CHADHYER CHAHCHAN CHANDIYAH CHANGAR CHANGHAR CHANGHARR CHARCHAR CHARCHER CHARCHR CHARHARAR CHAUDHARI ///
			CHAUDHARY CHAUDHRY CHAUHAN CHAWARA CHAWARD CHIDDHAR CHIDDHRA CHIDHAR KHATTAR KHOKHAR KHAKHAR KAAKAR ///
			"KOH KAR" KAHAR "CHA CHAR" KACHAR 

* CHANDYA
consolidate CHANDYA CHNDIYA CAHNDYA CAMBHO CHANDAI CHANDEU CHANDIA "CHANDIA NAAI" CHANDIO CHANGAD CHANGID CHANDIYO CHANDIYA 

* CHEENY
consolidate CHEENY CHEENA  


* CHOHAN
consolidate CHOHAN CHOHAAN CHOHAN CHUHAN CHOCHAN CHOOHAN CHOAN 


* COBLER
consolidate COBLER COBBLER COBLER 

* CHUNGER

* CHANAR
consolidate CHANAR CHINAR CHNAR CHENEAR 


* DAHAR
consolidate DAHAR DAHA DAHAR DAHER DAHRJA DAAR DAR 


* DHALOON
consolidate DHALOON DHALON 


* DOBI
consolidate DOBI DHOBI DOHBHI DOUBI DUBI DOBBI DHOBBI  DHUBBI DHOOBI GHOBI BHOBI DHOBHI 


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


* GUJJAR
consolidate GUJJAR GHUJAR GUAAR GUAJAR GUGAR GUGHAR GUGHJAR GUHGHAR GUHKHER GUJAAR GUJAFR GUJAR GUJER GUJET ///
			GUJHER GUJJAR GUJJR GUJR GUJRAR GYJJAR JUGGAR JUGAR  


* GUNIAL
consolidate GUNIAL 


* HAJAM
consolidate HAJAM HAJJAM HUJAM HIJAM HAJAAM HAJIAM 


* HASHMI
consolidate  HASHMI HASMI


*HINDU
consolidate HINDU HINDO HINDKO 


* INSARI
consolidate INSARI INASARI INSARI INSAREE INSARE 


* JAT
consolidate JAT JAAT JUTT GUTT JUT JATT GAT "JATT BHUTTA" "BAJWAH JATT" "KLER JATT" "JATT BAJWAH" ///
			"SINDHU JATT" "JUT KASRA" "SANDHU JUTT" "JUTT KHARA" "DHALOON JUTT" "RANDHAWA JUTT" ///
			"KALHAR JAT" "KAMBOW JAT" "JATT GIL" "GORAYA JUTT" "SINDHU JATT" "CHEEMA JUTT" ///
			"KALER JET" "KULU JATT" 


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


* Jamali
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


* KHOHAR
consolidate KHOHAR KHARA KHO KHOHAR KHOHER KHOKAHR "KHOKHER NAAI" KHONAHADA KHONAHAR KHONAHARA KHONAR KHONHARA ///
			KHONHARAS KHONIHALA KHONIHARA KHORIGA BOHAR KOKHAR KHUKHAR KHOKER KAKAR KAKER  ///
			KHARAR KHARAAR KHARAL KHARAR KHARKISH KHARL KHAWAJA KAHTAR KATHAR KHETER KHTAR KHORAR KHAROR



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

* LOHAR
consolidate LOHAR LUHAR LOHAR LOHANI LOHARA LOHR LOAR LUDHAR LOHAAR LOOHAR LADAR


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


* MACHI 
consolidate MOCHI MACHI MASHKI MASHI MUCHI MOUCHI MASIH MACHA MACHE MACHHI MAACHI MASCHKEE MASHKE 


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
consolidate PATHAN PETHTTAN PETHAN PHTTHAN PETTHAN PATAHN PATHAN PATHHAN PATTHAN PAYHAN PAYTHAN  PTHAAN PEHTHAN ///
			PUTHAN PATAHAN PATHAN PHATAN


* PATHOR
consolidate PATHOR PHORE PATHOOR PHAOOR PAHORA 


* PERHAR
consolidate PERHAR PARHAR "PARYAR" PARHAAR

 


* QAZI
consolidate QAZI QASAI "QAZI KHAIL" KAZI



* QURESHI
consolidate QURESHI "QAARESHI" "QAARISHE" "QAARISHI" "QAREESHI" "QARESHI" "QARSHI" "QRASHI" "QREESHI" "QRUESHI" ///
			"QUERSHI" "QUERSHIQ" "QUESHI" "QURAESHI" "QURAISH" "QURAISHI" "QURAISHI GHORI" "QURASH HASHMI" ///
			"QURASH HASMI" "QURASHA HASMI" "QURASHAI HASHMI" "QURASHI" "QURASHI HASHMI" "QURASHI HASMI" ///
			"QURASHY" "QURASHYI HASHMI" "QURASI" "QUREEHI" "QUREESHI" "QUREHI HASHMI" "QUREHSI" "QUREHSI HASHMI" ///
			"QUREISH" "QURESH" "QURISHI" "QURSHI" "QURSHI HASHIMI" "HASHMI QURASHI" "QURESHI HASHMI"





* RAJPUT
consolidate RAJPUT "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" ///
					 "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" ///
				 	 "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" ///
					 "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" "RAJPUT BHATTI" ///
					 "RAJPOOT BHATTI" "CHOHAN RAJPOOT" "RAJPOOT BHAKIRYAL" "KOREA BLOACH"


* RANDHAWA 
consolidate RANDHAWA RANDAWA RANDAHWA RANDHANA RENDHAWA RENDAWAH RENDAWHA RENDWAHA RENEAHAWA RANDHAR RENDAHAWA


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
consolidate SADIQUEI SIDDIQUE SADDIQUE SADIQIE SAIKEE


* SADHAN
consolidate SADHAN SDHAN SIDHAN 


* SAKAY

* SIYAL
consolidate SIYAL SAYAL SAYAAL SIAL SYAL "SARDANA SIAL"


* SOLANGI
consolidate SOLANGI SLOLANGHI SOLAGI SOLANGHI SOLANGI SOLANHI SOLANI SOLNAGHI SOLNAGI SOLNGHI SOLNGI SULANGI ///
			SOLANTI SOLONGI  SOHARI SOHANA 


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
replace zaat_code= 14 if zaat == "NAICH" | zaat == "MOCHI" | zaat == "LOHAR" | zaat == "DOBI"
replace zaat_code= 15 if zaat=="PATHAN"
replace zaat_code= 16 if zaat=="QURESHI" | zaat == "HASHMI"
replace zaat_code= 17 if zaat=="RAJPUT" | zaat == "BHATTI"
replace zaat_code= 18 if zaat=="REHMANI"
replace zaat_code= 19 if zaat=="SAMIJA"
replace zaat_code= 20 if zaat=="SHEIKH"
replace zaat_code= 21 if zaat=="SOLANGI"
replace zaat_code= 22 if zaat=="SYED"



set more off
local i = 99
foreach x in "ADAL" "AFGHANI" "ALWI" "ATRAAL" "BABO" "BEHAL" "BHADER" "BHATA" ///
			"BHATYARA" "BHAYA" "CHANAR" "CHANDYA" "CHEENY" "CHOHAN" "CHRISTIAN"  ///
			"CHUNGER" "CLASS" "COBLER" "DAB" "DARKHAN" "DAHAR" "DALU" "DAOD" "DAYA" "DERICHA" "DHALOON"  ///
			"DOGAR" "DOSEE" "DURANI" "FARQEER" "GHAFARI" "GHAKER FERZALI" "GHALLO" "GILL"  ///
			"GOPANG" "GORI" "GUNIAL" "HAJAM" "HINDU" "INSARI" "JABHIL" "JAKHAR"  ///
			"JAMALI" "JAMBEEL" "JANGLA" "JATOI" "JAWALA" "JHALO" "JHANEG" "JHEEL" "JHUMBAIL"  ///
			"JODRA" "JOPU" "JUNJOWA" "KACHI" "KAHITA" "KALER" "KAMBO" "KANJO" "KASHMIRI"  ///
			"KATHIYA" "KATWAL" "KHAN" "KHANAN" "KHER" "KHOHAR" "KHOSA" "KHUMYAR"  ///
			"KLASAN" "KORI" "KUMBO" "KUNDAL" "KUNIAL" "LEHNGA" "LONA" "MAAMANPURI"  ///
			"MADHOL" "MAKOOL" "MALAH" "MALIK" "MALYAR" "MARKI" "MARWAI" "MASHE" "MASTOIE" "MATA"  ///
			"MENGWAL" "MERALAM" "MHAR" "MINHAS" "MISSAN" "MITHA" "MUHEEL" "NANDAN" "NANGI" "NIDU"  ///
			"NIHAYA" "NOON" "OKHAROND" "PANWAR" "PATHOR" "PERHAR" "PHOR" "QALYAAR"  ///
			"QAZI" "RAJA" "RAJAR" "RANDHAWA" "RAO" "RATHOR" "REMA" "RONGA" "SADHAN" "SADIQUEI" "SAHU"  ///
			"SAKAY" "SALMANKHEL" "SARAA" "SARKI" "SHTAAL" "SINDHU" "SIYAL" "SOMRO" "SOTRAQ"  ///
			"TANOORI" "TANVI" "TARHALI" "TARKHAN" "TEELI" "THAHEEM" "TOOR" "WAHIA" "WALOOT" "WARAH"  ///
			"WARDAG" "WARICH" "WATTU" "WILLERA" "WIRK" "ZARGAR" {
	replace zaat_code = `i' if zaat == "`x'"
	local i = `i'+1
}

replace zaat_code=23 if zaat_code==.


*******
* Lots of mixed jaats, mixed Rajputs, and mixed Baloch. If unassigned and have that in name, use them.
*******

* Jaat
replace zaat = "JAT" if (regex(zaat, "JAT") | regex(zaat, "JUT") ) & zaat_code == 23
replace zaat_code = 9 if zaat == "JAT"

* Rajput
foreach x in RAJPUT "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" ///
					 "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" ///
				 	 "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" ///
					 "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" {

	replace zaat = "RAJPUT" if regex(zaat, "`x'") & zaat_code == 23
}
replace zaat_code = 17 if zaat == "RAJPUT"


* Baloch
foreach x in BALOCH BALOUCH BALAOCH BALCOH BALO0CH BALOACH BALOCH BALOOCH TALOOCH BALOSH ///
			 BALOUCH BLAOCH BLOCH BLOOCH BLOACH BULOCH BOLOCH {

	replace zaat = "BALOCH" if regex(zaat, "`x'") & zaat_code == 23 	
}
replace zaat_code = 5 if zaat == "BALOCH"







*******
* TESTS FOR INTEGRITY
*******

* Should have less than 10% without code
count if zaat_code == 23
local missing = `r(N)'
count
display `missing' / `r(N)'
assert `missing' / `r(N)' < 0.1

* Check missing Categories
set more off

forvalues x = 1/22 {
	display "`x'"
	count if zaat_code == `x'
	assert `r(N)' > 0
}

sum zaat_code
forvalues x = 99/`r(max)' {
	tab zaat if zaat_code == `x'
	count if zaat_code == `x'
	assert `r(N)' > 0
}

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
