
set more off
use $pk/prepublic_data/hhcensus.dta



rename s1q3 district
rename s1q11 zaat
replace zaat=subinstr(zaat, ",", "", .)
replace zaat=subinstr(zaat, ".", "", .)
replace zaat=subinstr(zaat, "]", "", .)

replace zaat=subinstr(zaat, "'", "", .)
replace zaat=subinstr(zaat, "'", "", .)

replace zaat=subinstr(zaat, "`", "", .) 
replace zaat=subinstr(zaat, "'", "", .) 

replace zaat=subinstr(zaat, ";", "", .)
replace zaat=trim(zaat)
replace zaat=upper(zaat)
drop if zaat==""


* AARAIN
foreach x in ARRAIN ARAAIN ARIANE ARIANN ARIE ARIEA ARIEANH ARIEN ARIENA ARIENE ARIHAN ARIIAN ARIINE ARIN ARINA ARIYAN ARIYN ARAINA ARAINE ARAINJ ARAIYEIN ARANIE ARAQIN ARARIN ARAUIN ARAUN ARAYAN ARAYEEN ARAYEN ARAYIN ARAYN AREEA AREEN AREIAN AREIEN ARIAINE ARIAN AROR ARRAEEN ARRAEIN ARRAEN ARRAHIN ARRAI ARRAIEN ARRAINE ARRAIRE ARRAIYEIN ARRAIYEN ARRAN ARRAOM ARRAQIN ARREEN ARREIN ARRIAN ARRIANE ARRIEN ARRIN ARRSAIN ARYAN ARYIN AARAIN ARAYEEN ARAYEN ARAYIN ARAIAN ARAIEN ARAIEND ARAIEND ARAIN ARAINE ARAIYEIN ARANIE ARIN ARIYN ARAAI ARAI ANSAREE {
	replace zaat="AARAIN" if regex(zaat, "`x'")==1
}

* ABBASI
foreach x in ABBASI ABBASSI ABBAS ABASO ABAS {
	replace zaat="ABBASI" if regex(zaat, "`x'")==1
}

* ADAL
foreach x in "ADAL KHAIL" "ADA KHAIL" "ADAL KHAN" "ADIL KHEL" {
	replace zaat="ADAL" if regex(zaat, "`x'")==1
}

* AFGHANI
foreach x in AFGHAN AFGHANI AFGANI {
	replace zaat="AFGHANI" if regex(zaat, "`x'")==1
}

* ATRAAL
foreach x in ATRAAL AMRAAL ATHWAL ATHRAAN  {
	replace zaat="ATRAAL" if regex(zaat, "`x'")==1
}

* ANSARI
foreach x in ANSARI ASNARI ANASRI ANARI ANSAI ANSARY ANSRI ANSSRI ANSSARY ANSAARI {
	replace zaat="ANSARI" if regex(zaat, "`x'")==1
}

* AWAAN
foreach x in AWAAN AAWAN AWAAB AWAAM AWAAN AWAB AWAIN AWAM AWAMEE AWAN AWANB AWAN AWN AWWAN {
	replace zaat="AWAAN" if regex(zaat, "`x'")==1
}

*ALWI
foreach x in ALWI ALRYI {
	replace zaat="ALWI" if regex(zaat, "`x'")==1
}

* BALOCH
foreach x in  BALOCH BALOUCH BALAOCH BALCOH BALO0CH BALOACH BALOCH BALOOCH TALOOCH BALOSH BALOUCH BLAOCH BLOCH BLOOCH BLOACH BULOCH BOLOCH {
	replace zaat="BALOCH" if regex(zaat, "`x'")==1
}

* BABO
foreach x in BABO BABU {
	replace zaat="BABO" if regex(zaat, "`x'")==1
}

* BEHAL
foreach x in BEHAL BEHEAL BHEL BHAIL BHAYAL BHAYAL BAHAL BAKHAL BAHAEL BAHEAL BAHALE BAHIL BEHAEAL BEHAEL BAHIL BEAHEAL BEAHEL {
	replace zaat="BEHAL" if regex(zaat, "`x'")==1
}

* BHATA
foreach  x in BHATA BHATOO BHOTHA BHUTA BHUTTA  {
	replace zaat="BHATA" if regex(zaat, "`x'")==1
}

* BHAYA
foreach x in BHAYA {
	replace zaat="BHAYA" if regex(zaat, "`x'")==1
}

* BUTT
foreach x in BUTT {
	replace zaat="BUTT" if regex(zaat, "`x'")==1
}

* BHATYARA
foreach x in BHUTYARA BHATYARA {
	replace zaat="BHATYARA" if regex(zaat, "`x'")==1
}

* BHATTI
foreach x in BAHHATI BAHHIT BAHHTI BAHITT BAHTA BAHTE BAHTEE BAT BATHA BATHI BATI BATT BATTA BATTHA BATTI BATYARA BHATT BHATTA BHATTE BHATTI BHTA BHTI BUHTAY BUHTTI  BUTHA BUTHI BHTTI BHUTI BAHTTI BHALLI GHATTI {
	replace zaat="BHATTI" if regex(zaat, "`x'")==1
}

* BHADER
foreach x in BHADER {
	replace zaat="BHADER" if regex(zaat, "`x'")==1
}

* CHACHAR
foreach x in CHACAHR CHACAR CHACHAAR CHACHAER CHACHAN CHACHAR CHACHER CHACHR CHACHRA CHACHRE CHACHURE CHADHAR CHADHYER CHAHCHAN CHANDIYAH CHANGAR CHANGHAR CHANGHARR CHARCHAR CHARCHER CHARCHR CHARHARAR CHAUDHARI CHAUDHARY CHAUDHRY CHAUHAN CHAWARA CHAWARD CHIDDHAR CHIDDHRA CHIDHAR KHATTAR KHOKHAR KHAKHAR KAAKAR "KOH KAR" KAHAR "CHA CHAR" KACHAR {
	replace zaat="CHACHAR" if regex(zaat, "`x'")==1
}

* CHEENY
foreach x in CHEENY CHEENA  {
	replace zaat="CHEENY" if regex(zaat, "`x'")==1
}

* CHOHAN
foreach x in CHOHAAN CHOHAN CHUHAN CHOCHAN CHOOHAN CHOAN {
	replace zaat="CHOHAN" if regex(zaat, "`x'")==1
}

* COBLER
foreach x in COBBLER COBLER {
	replace zaat="COBLER" if regex(zaat, "`x'")==1
}

* CHUNGER

* CHANAR
foreach x in CHANAR CHINAR CHNAR CHENEAR {
	replace zaat="CHANAR" if regex(zaat, "`x'")==1
}

* CHANDYA
foreach x in CHNDIYA CAHNDYA CAMBHO CHANDAI CHANDEU "CHANDIA NAAI" CHANDIO CHANDYA CHANGAD CHANGID CHANDIYO CHANDIYA {
	replace zaat="CHANGYA" if regex(zaat, "`x'")==1
}

* DAHAR
foreach x in DAHA DAHAR DAHER DAHRJA DAAR DAR {
	replace zaat="DAHAR" if  regex(zaat, "`x'")==1
}

* DHALOON
foreach x in DHALOON DHALON {
	replace zaat="DHALOON" if regex(zaat, "`x'")==1
}

* DOBI
foreach x in DOBI DHOBI DOHBHI DOUBI DUBI DOBBI DHOBBI  DHUBBI DHOOBI GHOBI BHOBI DHOBHI {
	replace zaat="DOBI" if regex(zaat, "`x'")==1
}

* DAOD
foreach x in DAOD DAD DADOO DAYOO ODD {
	replace zaat="DAOD" if regex(zaat, "`x'")==1
}


* DERICHA
foreach x in DERICHA DHREECH DHRECH {
	replace zaat="DERICHA" if  regex(zaat, "`x'")==1
}

* DURANI

* DOGAR
foreach x in DOGAR DOGHAR DOGGAR {
	replace zaat="DOGAR" if regex(zaat, "`x'")==1
}

* FARQEER
foreach x in FAQIR FAQEER FAQER FQEER {
	replace zaat="FAQEER" if regex(zaat, "`x'")==1
}


* GILL
foreach x in GIL GILL {
	replace zaat="GILL" if regex(zaat, "`x'")==1
}

* GOPANG
foreach x in GOOPANG GOPANG GOYANG{
	replace zaat="GOPANG" if regex(zaat, "`x'")==1
}

* GORI
foreach x in GHORI GOURI GAOURI GAORI GORI GORIA GAORE ANGRAIZ {
	replace zaat="GORI" if regex(zaat, "`x'")==1
}

* GUJJAR
foreach x in GHUJAR GUAAR GUAJAR GUGAR GUGHAR GUGHJAR GUHGHAR GUHKHER GUJAAR GUJAFR GUJAR GUJER GUJET GUJHER GUJJAR GUJJR GUJR GUJRAR GYJJAR JUGGAR JUGAR  {
	replace zaat="GUJJAR" if regex(zaat, "`x'")==1
}

* GUNIAL
foreach x in GUNIAL {
	replace zaat="GUNIAL" if regex(zaat, "`x'")==1
}

* HAJAM
foreach x in HAJAM HAJJAM HUJAM HIJAM HAJAAM HAJIAM {
	replace zaat="HAJAM" if regex(zaat, "`x'")==1
}

* HASMI
foreach x in HASMI HASHMI {
	replace zaat="HASMI" if regex(zaat, "`x'")==1
}

*HINDU
foreach x in HINDU HINDO HINDKO {
	replace zaat="HINDU" if regex(zaat, "`x'")==1
}

* INSARI
foreach x in INASARI INSARI INSAREE INSARE {
	replace zaat="INSARI" if regex(zaat, "`x'")==1
}



* JAT
foreach x in JAAT JUTT GUTT JUT JATT GAT {
	replace zaat="JAT" if regex(zaat, "`x'")==1
}

* JAWALA
foreach x in JAWALA JAWAHA     {
	replace zaat="JAWALA" if regex(zaat, "`x'")==1
}

*JATOI
foreach x in JATOI JATOIE JATOOI {
	replace zaat="JATOI" if regex(zaat, "`x'")==1
}

* JANGAL
foreach x in JANGAL JANGALA JANGALLA {
	replace zaat="JANGAL" if regex(zaat, "`x'")==1
}

* JABHIL
foreach x in JABHIL JHBAIL JHABAL JHABEL JHAIL  JHAMBHEEL JHABAIL JHABEEL JAHBEEL{
	replace zaat="JABHIL" if regex(zaat, "`x'")==1
}

* JALAL
foreach x in "JALAL KHEL" JILAH "JALAL KHAIL" JALAL JANGAL JANGLLA {
	replace zaat="JALAL" if regex(zaat, "`x'")==1
}

* JAKHAR
foreach x in JAKHAR {
	replace zaat="JAKHAR" if regex(zaat, "`x'")==1
}

* JHANEG
foreach x in JHANEG JAHNG JHAENG JHNAG GHANJ {
	replace zaat="JHANEG" if regex(zaat, "`x'")==1
}

* JHEEL
foreach x in JHEEL JHIL  GHELO JHAIL {
	replace zaat="JHEEL" if regex(zaat, "`x'")==1
}

*JODRA
foreach x in JOODRA JUDRA JODAH JODRA JODHOO JODHRA JODRAH JODHAH JWDRA JORDA JORDRA JORDHA  {
	replace zaat="JODRA" if regex(zaat, "`x'")==1
}

* JUNJOWA
foreach x in JUNJOWA JANJOWA JANJUA JUNJOWA {
	replace zaat="JUNJOWA" if regex(zaat, "`x'")==1
}

* KATHIYA
foreach x in KATHIA KATHIYA {
	replace zaat="KATHIYA" if regex(zaat, "`x'")==1
}



* KHARAR
foreach x in KHARAAR KHARAL KHARAR KHARKISH KHARL KHAWAJA KAHTAR KATHAR KHETER KHTAR KHORAR{
	replace zaat="KHARAR" if regex(zaat, "`x'")==1
}

* KHANAN
foreach x in KHANAN KHAMAN {
	replace zaat="KHANAN" if regex(zaat, "`x'")==1
}

* KHAN
foreach x in KHAN "KHAN " {
	replace zaat="KHAN" if regex(zaat, "`x'")==1
}

*KHOHAR
foreach x in KHARA KHO KHOHAR KHOHER KHOKAHR "KHOKHER NAAI" KHONAHADA KHONAHAR KHONAHARA KHONAR KHONHARA KHONHARAS KHONIHALA KHONIHARA KHORIGA BOHAR KOKHAR KHUKHAR {
	replace zaat="KHOHAR" if regex(zaat, "`x'")==1
}

* KAMBO
foreach x in  KAMBAHWA "KAMBH WA" KAMBHEWA KAMBOO KAMBOW "KAMBOW JAT" KAMBWA KOMBOH KAMBOH {
	replace zaat="KAMBO" if regex(zaat, "`x'")==1
}

* KALER
foreach x in  KALER KAMHAAR KAMHRA KALHAR "KALHAR JAT" KALHORA "KALR MAHAR" KAMANGHAR {
	replace zaat="KALER" if regex(zaat, "`x'")==1
}

* KHER

* KANJO

*KASHMIRI
foreach x in KSHMERI KASHMERI KASHMIRI KASHMIRY KASHMIRE KASHMIREE KASHMEERAY KASHMEERAY KASHMAIRA KASHMARY KASHIMIRY KASHMIRA KASHMIRE KASMIRY {
	replace zaat="KASHMIRI" if regex(zaat, "`x'")==1
}

* KHUMYAR
foreach x in KHUMYAR KAMHAR {
	replace zaat="KHUMYAR" if regex(zaat, "`x'")==1
}

* KAKAR
foreach x in KAKAR KAKER {
	replace zaat="KAKAR" if regex(zaat, "`x'")==1
}

* KACHI
foreach x in KACHI KHACHI KACHII {
	replace zaat="KACHI" if regex(zaat, "`x'")==1
}

* KLASAN
foreach x in KLASAN "KUMHAR KLASAN" KLASEEN KALSAN {
	replace zaat="KLASAN" if regex(zaat, "`x'")==1
}

* KATWAL

* KORI
foreach x in KORY KORI KORAI KURI KUORI{
	replace zaat="KORI" if regex(zaat, "`x'")==1
}

* KOMJATOE
foreach x in "KOM " "KOM JATOE" "KOM JATOL" "KOM JATONI" "KOM PANJABI" {
	replace zaat="KHARAR" if regex(zaat, "`x'")==1
}

* KUNDAL
foreach x in KUNDAL KUNDAIL KUDAIL {
	replace zaat="KUNDAL" if regex(zaat, "`x'")==1
}

* LAAR
foreach x in LAR LARR LARE LARA {
	replace zaat="LAAR" if regex(zaat, "`x'")==1
}

* LEHNGA
foreach x in LEHNGA LAHNGA LANGA LANGHA {
	replace zaat="LEHNGA" if regex(zaat, "`x'")==1
}

* LONA
foreach x in LONA LOONAY LONE LUNAY {
	replace zaat="LONA" if regex(zaat, "`x'")==1
}

* LOHAR
foreach x in LUHAR LOHAR LOHANI LOHARA LOHR LOAR LUDHAR LOHAAR LOOHAR {
	replace zaat="LOHAR" if regex(zaat, "`x'")==1
}



* MATA
foreach x in MATA MAYA {
	replace zaat="MATA" if regex(zaat, "`x'")==1
}

* MHAR
foreach x in MHAR MAHR MEHAR MAHAR MEHER MEER {
	replace zaat="MHAR" if regex(zaat, "`x'")==1
}

* MALIK
foreach x in MALIK MALAK MANIK MULIK MULIK MALK MAILK  {
	replace zaat="MALIK" if regex(zaat, "`x'")==1
}

* MACHI -- NOT IN LATER CODOES, BUT REALLY BIG!
foreach x in MACHI MOCHI MASHKI MASHI MUCHI MOUCHI MASIH MACHA MACHE MACHHI MAACHI MASCHKEE MASHKE {
	replace zaat="MACHI" if regex(zaat, "`x'")==1
}

* MAAMANPURI
foreach x in "MAAMAN PURI" "MOMIN POURI" "MUMAN PURI" "MAMAN PURI" "MUMIN PURI" "MAMAAN PURI" "MOMIN PORI" "MOUMIN POURI" {
	replace zaat="MAAMANPURI" if regex(zaat, "`x'")==1
}

* MASHE
foreach x in MASHE {
	replace zaat="MASHE" if regex(zaat, "`x'")==1
}

* MALIYAR
foreach x in MALIYAR MALYAAR MILYAR MALYAR MULHAAR MALHAR MILHAR MALIYAR MALIYAAR MALYA MALIYAR {
	replace zaat="MALIYAR" if regex(zaat, "`x'")==1
}

* MALAH
foreach x in MALAH MALLAH {
	replace zaat="MALAH" if regex(zaat, "`x'")==1
}

* MARKI
foreach x in "MARKI KHEL" "MARKI KHAL" "MERKI KHAIL" "MARKI KHAIL" "MARKI KHIAL" "MARKI KHEL" "MARKI HEAL" "MIRKA KHEL" "MAR KAKHEL"  {
	replace zaat="MARKI" if regex(zaat, "`x'")==1
}

* MITHA
foreach x in "MITHA KHAIL" MILHA {
	replace zaat="MITHA" if regex(zaat, "`x'")==1
}

* MENGWAL
foreach x in MENGWAL MANGHOWAL MANGWAL MANGWAL MENGOOL MANGOOL MAINGWAL MANGOOLAN MENGHOOL MEENGWAL MEEENGHWAL JEHNGWAL MENGOL   {
	replace zaat="MENGWAL" if regex(zaat, "`x'")==1
}

*MERALAM
foreach x in "MER ALAM" "MEER ALAM" "MIR ALAM" "MEER AZAM" {
	replace zaat="MERALAM" if regex(zaat, "`x'")==1
}

* MINHAS

* MOHANA
foreach x in MOHANA MOHAN MOHANDA MOHNA MOHNAH MOLANA MOMAN MUHANA MUHANI "MULAN ALL" MULANA{
	replace zaat="MOHANA" if regex(zaat, "`x'")==1
}


* MUGHAL
foreach x in MUBHAL MUGHAL MUGHL MUGHUL MUGJAL MUGUL MUHAL MUHGAL MUHGHAL MUIGHAL MOGHAL {
	replace zaat="MUGHAL" if regex(zaat, "`x'")==1
}

* MUSLIM SHEIKH -- MUST COME BEFORE REGULAR SHEIKH!!!
foreach x in "MUSALIM SHAIK" "MUSIM SHIKH" "MUSLAM SHAIK" "MUSLAM SHAIQ" "MUSLAM SHEIK" "MUSLAM SHIK" "MUSLIM  SHIEKH" "MUSLIM SEIKH" "MUSLIM SHAGUFTA" "MUSLIM SHAIK" "MUSLIM SHAIKH" "MUSLIM SHAKH" "MUSLIM SHEKH" "MUSLIM SHIEKH" "MUSLSM SHEIK" "MUSLIM SHEIKH" "MUSLIM SAIKH" "MUSALM SHIK" "MUSLIM SHEIK" "MUSALM SHAIK" "MUSLEM SHAIK"{
	replace zaat="MUSLIM SHEIKH" if regex(zaat, "`x'")==1
}

* NAICH
foreach x in NACH NACHEJ NAI NAICH NAIECH NAIEJ NAIEJH NALICH NIACH NICH {
	replace zaat="NAICH" if regex(zaat, "`x'")==1
}

* NANGI
foreach x in NANGI NAGI NANGY {
	replace zaat="NANGI" if regex(zaat, "`x'")==1
}

* NANDAN

* NOON
foreach x in NOON {
	replace zaat="NOON" if regex(zaat, "`x'")==1
}

* NIDU
foreach x in "NIDU KHAIL"  {
	replace zaat="NIDU" if regex(zaat, "`x'")==1
}



* PANWAR
foreach x in  PANWAR PANWAAR PAHOOR PANORA PUNWAR {
	replace zaat="PANWAR" if regex(zaat, "`x'")==1
}

* PATHAN
foreach x in PETHTTAN PETHAN PHTTHAN PETTHAN PATAHN PATHAN PATHHAN PATTHAN PAYHAN PAYTHAN  PTHAAN PEHTHAN PUTHAN PATAHAN PATHAN {
	replace zaat="PATHAN" if regex(zaat, "`x'")==1
}

* PATHOR
foreach x in PATHOR PHORE PATHOOR PHAOOR PAHORA {
	replace zaat="PATHOR" if regex(zaat, "`x'")==1
}

* RAO

* RONGA
foreach x in RONGA RONGHA RONGAA RANGRAZ RANGSAZ RANJA RANJHA RANJHAY RANGRAZ RANGA RANA {
	replace zaat="RONGA" if regex(zaat, "`x'")==1
}



* QAZI
foreach x in QAZI QASAI "QAZI KHAIL" KAZI{
	replace zaat="QAZI" if regex(zaat, "`x'")==1
}


* QURESHI
foreach x in"QAARESHI" "QAARISHE" "QAARISHI" "QAREESHI" "QARESHI" "QARSHI" "QRASHI" "QREESHI" "QRUESHI" "QUERSHI" "QUERSHIQ" "QUESHI" "QURAESHI" "QURAISH" "QURAISHI" "QURAISHI GHORI" "QURASH HASHMI" "QURASH HASMI" "QURASHA HASMI" "QURASHAI HASHMI" "QURASHI" "QURASHI HASHMI" "QURASHI HASMI" "QURASHY" "QURASHYI HASHMI" "QURASI" "QUREEHI" "QUREESHI" "QUREHI HASHMI" "QUREHSI" "QUREHSI HASHMI" "QUREISH" "QURESH" "QURESHI" "QURISHI" "QURSHI" "QURSHI HASHIMI"{
	replace zaat="QURESHI" if regex(zaat, "`x'")==1
}



* RAJPUT
foreach x in "TAJPUT" "RAJPOOT" "TAJPOOT" "RAAJ POOT" "RAAJPOOT" "RAAJPOT" "RAATJPUT" "RAFPOOT" "RAFPOUT" "RAGPOOT" "RAGPOOT CHOHAN" "RAHPOOT" "RAJ POOT" "RAJ POTE" "RAJ POUT" "RAJ PUT" "RAJ PUTE" "RAJOOT" "RAJPIT" "RAJPOOOT" "RAJPOT" "RAJPOTE" "RAJPOUT" "RAJPPOT" "RAJPUT" "RAJUT" "RALPOOT" "RALPUT" "RAPOOT" "RASJPOOT" "RATPOOT" "ROOJPOOT" "RJPOOT" "RAJPUOOT" "FAJPOOT" {
	replace zaat="RAJPUT" if regex(zaat, "`x'")==1
}

* RANDHAWA
foreach x in RANDHAWA RANDAWA RANDAHWA RANDHANA RENDHAWA RENDAWAH RENDAWHA RENDWAHA RENEAHAWA RANDHAR {
	replace zaat="RANDHAWA" if regex(zaat, "`x'")==1
}

* RAJAR
foreach x in RAJAR {
	replace zaat="RAJAR" if regex(zaat, "`x'")==1
}

* REMA
foreach x in REMA REHMNI {
	replace zaat="REMA" if regex(zaat, "`x'")==1
}

* REHMANI
foreach x in REEMA REHAN REHANI REHMAN REHMANI REHMANOI RHMANI RAHMINI RAHMANI RAHAMNI {
	replace zaat="REHMANI" if regex(zaat, "`x'")==1
}

* RATHOR
foreach x in RATHOOR RATHOR RATHORE RATHAN {
	replace zaat="RATHOOR" if regex(zaat, "`x'")==1
}

* SAMIJA
foreach x in SAMBIJA SAMEEJA SAMEJA SAMI SAMIBA SAMIGA SAMIJA SAMINA SAMITA SAMUJA SANJRA{
	replace zaat="SAMIJA" if regex(zaat, "`x'")==1
}

* SHEIKH -- MUST FOLLOW MUSLIM SHEIKH
foreach x in SHEEK SHEIH SHEIKH SHEKH SHIEKH SHIKH SHKEIKH{
	replace zaat="SHEIKH" if regex(zaat, "`x'")==1 & zaat~="MUSLIM SHEIKH"
}


* SARKI
foreach x in SARKI SANGI SIRKI SANGHI SANGEE {
	replace zaat="SARKI" if regex(zaat, "`x'")==1
}

* SARAA
foreach x in SARAA SAQA {
	replace zaat="SARAA" if regex(zaat, "`x'")==1
}

* SADIQUEI
foreach x in SADIQUEI SIDDIQUE SADDIQUE SADIQIE SAIKEE {
	replace zaat="SADIQUEI" if regex(zaat, "`x'")==1
}

* SADHAN
foreach x in SADHAN SDHAN SIDHAN {
	replace zaat="SADHAN" if regex(zaat, "`x'")==1
}

* SAKAY

* SIYAL
foreach x in SAYAL SIYAL SAYAAL SIAL SYAL "SARDANA SIAL"{
	replace zaat="SIYAL" if regex(zaat, "`x'")==1
}

* SOLANGI
foreach x in  SOLANGI SLOLANGHI SOLAGI SOLANGHI SOLANGI SOLANHI SOLANI SOLNAGHI SOLNAGI SOLNGHI SOLNGI SULANGI SOLANTI SOLONGI  SOHARI SOHANA {
	replace zaat="SOLANGI" if regex(zaat, "`x'")==1
}

* SOMRO
foreach x in SOMORO SOMRO SOMROO SUMRO SOMERO SOMERA SOMRA SOMRAH SOMRU SOMUROO SOMARA SOMADA SOMARO {
	replace zaat="SOMRO" if regex(zaat, "`x'")==1
}


*SALMANKHEL
foreach x in SALMAN {
		replace zaat="SALMANKHEL" if regex(zaat, "`x'")==1
	}

* SAHU
foreach x in SAHO SAHOO SAHU{
	replace zaat="SAHU" if regex(zaat, "`x'")==1
}



* SINDHU
foreach x in SINDHU SINDU SINDHOW SINDHO SINDHA {
	replace zaat="SINDHU" if regex(zaat, "`x'")==1
}

* SOTRAQ


* SYED
foreach x in SYED SYAD SAED SAEED SAID SAYAD SAYEED SAYID SAYYAD SAYYED SEAD SEEYID SEYAD SEYID SYEED SYYED SAYD SAYED SYEE SYEEAD{
	replace zaat="SYED" if regex(zaat, "`x'")==1
}

* TARKHAN
foreach x in TARKAN TARKHAN TRAKHAN TRKHAN TERKHAN TERKHAAN TARHAN {
	replace zaat="TARKHAN" if regex(zaat, "`x'")==1
}

* TANOORI
foreach x in TANOORI TANORI TANORY THORI {
	replace zaat="TANOORI" if regex(zaat, "`x'")==1
}

* TANVI
foreach x in TANVI {
	replace zaat="TANVI" if regex(zaat, "`x'")==1
}

* TARHALI
foreach x in TARHALI "TAR HAILI" TARHAILI TARHALI TARHEELI TARHELI TARHELLI TEHWAR TERAHLI TERBALI TERBILI TERHAILI TERHALAI TERHALI TERHIL TERHILA TERHILI TERSILI {
	replace zaat="TARHALI" if regex(zaat, "`x'")==1
}


* THAHEEM
foreach x in THAHEEM THAHSIM THASEEM THAYAM THEHSAIM THEHSEEM THAEEM TAHEEM {
	replace zaat="THAHEEM" if regex(zaat, "`x'")==1
}

* TEELI
foreach x in TEELI TELI TEALE TAELI TELO {
	replace zaat="TOOR" if regex(zaat, "`x'")==1
}


* TOOR
foreach x in TOOR TAILE TAILI TALI {
	replace zaat="TOOR" if regex(zaat, "`x'")==1
}

* TURKHAN
foreach x in TURKHAN {
	replace zaat="TURKHAN" if regex(zaat, "`x'")==1
}

* WATTU
foreach x in WATTU WATTO WATO WATOO {
	replace zaat="WATTU" if regex(zaat, "`x'")==1
}


* WARICH
foreach x in WARICH  WARIACH WARHICH  WART WARRIACH  {
	replace zaat="WARICH" if regex(zaat, "`x'")==1
}

* WARDAG
foreach x in WARDIG WARDAG {
	replace zaat="WARDAG" if regex(zaat, "`x'")==1
}

* WARAH
foreach x in WARAH WARAHA WARAHO WARAECH WARACH WARA WAHRA  {
	replace zaat="WARAH" if regex(zaat, "`x'")==1
}

* WAHIA
foreach x in WAHIA WAHYA WAEHYA WAEEYA WAYAA WAI WIA  {
	replace zaat="WAHIA" if regex(zaat, "`x'")==1
}

* WIRK
foreach x in WARK WIRK WARQ {
	replace zaat="WIRK" if regex(zaat, "`x'")==1
}

* WILLERA
foreach x in WILLERA WILERA {
	replace zaat="WILLERA" if regex(zaat, "`x'")==1
}

* ZARGAR
foreach x in ZARGHAR ZARGAR ZARGUR ZERGER ZAJGAR ZAGHAR ZAFAR ZAEGER {
	replace zaat="ZARGAR" if regex(zaat, "`x'")==1
}

* Now code it up like in the other data:
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
replace zaat_code=98 if zaat=="MALIK"
replace zaat_code=99 if zaat=="MACHI"
replace zaat_code=100 if zaat=="CHANDIA"
replace zaat_code=101 if zaat=="MALYAR"
replace zaat_code=102 if zaat=="KUMHAR"
replace zaat_code=103 if zaat=="CHOHAN"
replace zaat_code=104 if zaat=="LOHAR"
replace zaat_code=105 if zaat=="GILL"
replace zaat_code=106 if zaat=="HAJAM"
replace zaat_code=108 if zaat=="MATA"
replace zaat_code=109 if zaat=="JHEEL"
replace zaat_code=110 if zaat=="OKHAROND"
replace zaat_code=111 if zaat=="FAQEER"
replace zaat_code=112 if zaat=="PERHAR"
replace zaat_code=113 if zaat=="TARKHAN"
replace zaat_code=114 if zaat=="KORI"
replace zaat_code=115 if zaat=="CHRISTIAN"
replace zaat_code=116 if zaat=="SARKI"
replace zaat_code=117 if zaat=="KHOSA"
replace zaat_code=118 if zaat=="KASHMIRI"
replace zaat_code=119 if zaat=="PANWAR"
replace zaat_code=120 if zaat=="JAMALI"
replace zaat_code=121 if zaat=="JHUMBAIL"
replace zaat_code=122 if zaat=="BEHAL"
replace zaat_code=123 if zaat=="DAHAR"
replace zaat_code=124 if zaat=="GOPANG"
replace zaat_code=125 if zaat=="JATOI"
replace zaat_code=126 if zaat=="KHARAR"
replace zaat_code=127 if zaat=="SOMRO"
replace zaat_code=128 if zaat=="TANOORI"
replace zaat_code=129 if zaat=="TANVI"
replace zaat_code=130 if zaat=="THAHEEM"
replace zaat_code=131 if zaat=="SALMANKHEL"
replace zaat_code=133 if zaat=="KHOHAR"
replace zaat_code=134 if zaat=="KAMBO"
replace zaat_code=135 if zaat=="KALER"
replace zaat_code=136 if zaat=="DAOD"
replace zaat_code=137 if zaat=="CHANGYA"
replace zaat_code=138 if zaat=="BHATA"
replace zaat_code=139 if zaat=="KUMBO"
replace zaat_code=140 if zaat=="MISSAN"
replace zaat_code=141 if zaat=="JHALO"
replace zaat_code=142 if zaat=="TARHALI"
replace zaat_code=143 if zaat=="JABHIL"
replace zaat_code=144 if zaat=="DERICHA"
replace zaat_code=145 if zaat=="LEHNGA"
replace zaat_code=147 if zaat=="WATTU"
replace zaat_code=148 if zaat=="JAMBEEL"
replace zaat_code=149 if zaat=="MASTOIE"
replace zaat_code=150 if zaat=="RANDHAWA"
replace zaat_code=151 if zaat=="ALWI"
replace zaat_code=152 if zaat=="NIHAYA"
replace zaat_code=153 if zaat=="GHAKER FERZALI"
replace zaat_code=154 if zaat=="ZARGAR"
replace zaat_code=155 if zaat=="WARICH"
replace zaat_code=156 if zaat=="WARAH"
replace zaat_code=157 if zaat=="WAHIA"
replace zaat_code=158 if zaat=="SIYAL"
replace zaat_code=159 if zaat=="TOOR"
replace zaat_code=160 if zaat=="SINDHU"
replace zaat_code=161 if zaat=="SARAA"
replace zaat_code=162 if zaat=="REMA"
replace zaat_code=163 if zaat=="RATHOOR"
replace zaat_code=164 if zaat=="RANJA"
replace zaat_code=165 if zaat=="JAKHAR"
replace zaat_code=166 if zaat=="KATHIYA"
replace zaat_code=167 if zaat=="BHAYA"
replace zaat_code=168 if zaat=="GUNIAL"
replace zaat_code=169 if zaat=="SAHU"
replace zaat_code=170 if zaat=="MADHOL"
replace zaat_code=171 if zaat=="QAZI"
replace zaat_code=172 if zaat=="DALU"
replace zaat_code=173 if zaat=="KUNIAL"
replace zaat_code=174 if zaat=="CLASS"
replace zaat_code=175 if zaat=="INSARI"
replace zaat_code=176 if zaat=="KAHITA"
replace zaat_code=177 if zaat=="KLASAN"
replace zaat_code=178 if zaat=="JOPU"
replace zaat_code=179 if zaat=="MARWAI"
replace zaat_code=180 if zaat=="MENGWAL"
replace zaat_code=181 if zaat=="SHTAAL"
replace zaat_code=182 if zaat=="DAB"
replace zaat_code=183 if zaat=="JANGLA"
replace zaat_code=184 if zaat=="ATRAAL"
replace zaat_code=185 if zaat=="GHAFARI"
replace zaat_code=186 if zaat=="PHATAN"
replace zaat_code=187 if zaat=="PARYAR"
replace zaat_code=188 if zaat=="DOSEE"
replace zaat_code=189 if zaat=="KHAN"
replace zaat_code=190 if zaat=="BABO"
replace zaat_code=191 if zaat=="MAAMANPURI"
replace zaat_code=192 if zaat=="KAKAR"
replace zaat_code=193 if zaat=="DOBI"
replace zaat_code=194 if zaat=="QAZI"
replace zaat_code=195 if zaat=="NIDU"
replace zaat_code=196 if zaat=="RAJAR"
replace zaat_code=197 if zaat=="NOON"
replace zaat_code=198 if zaat=="WIRK"
replace zaat_code=199 if zaat=="WARDAG"
replace zaat_code=200 if zaat=="JHANEG"
replace zaat_code=201 if zaat=="MASHE"
replace zaat_code=202 if zaat=="PHOR"
replace zaat_code=203 if zaat=="GORI"
replace zaat_code=204 if zaat=="PATHOR"
replace zaat_code=205 if zaat=="LUDHAR"
replace zaat_code=206 if zaat=="WALOOT"
replace zaat_code=207 if zaat=="GHAFARI"
replace zaat_code=208 if zaat=="MHAR"
replace zaat_code=209 if zaat=="DHALOON"
replace zaat_code=210 if zaat=="RAJA"
replace zaat_code=211 if zaat=="QALYAAR"
replace zaat_code=212 if zaat=="MUHEEL"
replace zaat_code=213 if zaat=="KATE"
replace zaat_code=214 if zaat=="GHALLO"
replace zaat_code=215 if zaat=="KHUMYAR"
replace zaat_code=216 if zaat=="KACHI"
replace zaat_code=217 if zaat=="JODRA"
replace zaat_code=218 if zaat=="SADHAN"
replace zaat_code=219 if zaat=="RONGA"
replace zaat_code=220 if zaat=="DOGAR"
replace zaat_code=221 if zaat=="COBLER"
replace zaat_code=222 if zaat=="SAKAY"
replace zaat_code=223 if zaat=="HASMI"
replace zaat_code=224 if zaat=="DAYA"
replace zaat_code=225 if zaat=="KANJO"
replace zaat_code=226 if zaat=="MAKOOL"
replace zaat_code=227 if zaat=="SOTRAQ"
replace zaat_code=228 if zaat=="NANDAN"
replace zaat_code=229 if zaat=="MARKI"
replace zaat_code=230 if zaat=="MALIYAR"
replace zaat_code=231 if zaat=="KASHMIRI"
replace zaat_code=233 if zaat=="AFGHANI"
replace zaat_code=234 if zaat=="HINDU"
replace zaat_code=235 if zaat=="MINHAS"
replace zaat_code=236 if zaat=="CHEENY"
replace zaat_code=237 if zaat=="NANGI"
replace zaat_code=238 if zaat=="JUNJOWA"
replace zaat_code=239 if zaat=="KATWAL"
replace zaat_code=240 if zaat=="MERALAM"
replace zaat_code=241 if zaat=="BHATTI"
replace zaat_code=242 if zaat=="MITHA"
replace zaat_code=243 if zaat=="DURANI"
replace zaat_code=244 if zaat=="ADAL"
replace zaat_code=245 if zaat=="CHUNGER"
replace zaat_code=246 if zaat=="BHADER"
replace zaat_code=247 if zaat=="CHANAR"
replace zaat_code=248 if zaat=="RAO"
replace zaat_code=249 if zaat=="MALAH"
replace zaat_code=250 if zaat=="KHANAN"
replace zaat_code=251 if zaat=="BHATYARA"
replace zaat_code=252 if zaat=="TURKHAN"
replace zaat_code=253 if zaat=="HAJAM"
replace zaat_code=254 if zaat=="JAWALA"
replace zaat_code=255 if zaat=="KHER"
replace zaat_code=256 if zaat=="WILLERA"
replace zaat_code=257 if zaat=="LONA"
replace zaat_code=258 if zaat=="KUNDAL"




tab zaat_code, m

replace zaat_code=23 if zaat_code==.

/*
	* let's look at share of people missing per village
	bysort mauzaid: egen vpop=count(hhid)
	bysort mauzaid zaat_code: egen zpop=count(hhid)
	gen share=zpop/vpop

	egen tag=tag(mauzaid zaat_code)

* 	collapse (mean) share (count) hhid (max) zaat_code,by(mauzaid zaat)

	sort share hhid
	br if zaat_code==23
	* tab share if tag==1 & zaat_code==23
*/
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
