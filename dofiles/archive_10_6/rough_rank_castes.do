clear

* From Alex:
*1. High status (Syed, Mughal, Rajput)
*2. Cultivator (Jat, Arain)
*3. Occupational (Julaha, Darzi)
*4. Untouchable (Chuha)

use $datadir/constructed/school_panel/school_panel_long, clear


gen caste_bin=.

	* Bin 1 -- high status
replace caste_bin=1 if ///
	school_zaat_one==16 |  /// Syed
	school_zaat_one==19 |  /// Rajput	
	school_zaat_one==18 |  /// Mughal

	* Bin 2 -- land holders
replace caste_bin=2 if ///
	school_zaat_one==6 |  /// Jaat
	school_zaat_one==1 |  /// Arian
	school_zaat_one==2 |  /// Gujar


	* Bin 3 -- Labor, artisans
replace caste_bin=3 if ///
	school_zaat_one==23 |  /// Dhobi/lohar

	* Bin 4 -- low castes
	replace caste_bin=3 if ///
		school_zaat_one==20 |  /// Chahar (treating as Chamar?)



        Arian |        968       29.95       29.95
        Gujar |        160        4.95       34.90
        Naich |         21        0.65       35.55
      Sameeja |          5        0.15       35.71
       Ansari |         25        0.77       36.48
         Jaat |        347       10.74       47.22
       Pathan |        269        8.32       55.54
       Sheikh |         12        0.37       55.91
        Aiwan |        450       13.92       69.83
          Lar |         47        1.45       71.29
       Abbasi |         28        0.87       72.15
      Solangi |         42        1.30       73.45
       Balack |        150        4.64       78.09
       Mohana |         25        0.77       78.87
      Qurashi |         23        0.71       79.58
        Syeed |         51        1.58       81.16
         Butt |          8        0.25       81.40
           18 |         44        1.36       82.77
      Rajpoot |        188        5.82       88.58
       Chahar |         29        0.90       89.48
      Rehmani |          5        0.15       89.63
Muslim Sheikh |         10        0.31       89.94
        Other |        325       10.06      100.00

