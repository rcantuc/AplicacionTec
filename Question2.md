# Question 2
I have known the theory for many years, but I have never performed a Machine Learning prediction model (and, of course, I haven't evaluated one either). What I did here is something similar to the requested task, but using Stata commands. In this manner, the choice of model is simply to answer the question quickly, with no theory behind it.

In the GitHub repository, you will find a **Python script** converted with AI from my Stata code. I could actually make it work!


## Split the data
I kept all non-missing values and took a random sample of 70% training and 30% testing.

	** 0. Directorio de trabajo **
	clear all
	
	cd "/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/"
	/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec
	
	
	** 1. Split the data into training and testing sets **
	use if CountryCode == "ARG" | CountryCode == "BLZ" | CountryCode == "BOL" ///
	    | CountryCode == "BRA" | CountryCode == "CHL" | CountryCode == "COL" ///
	    | CountryCode == "CRI" | CountryCode == "CUB" | CountryCode == "DOM" ///
	    | CountryCode == "ECU" | CountryCode == "SLV" | CountryCode == "GTM" ///
	    | CountryCode == "GUY" | CountryCode == "HND" | CountryCode == "JAM" ///
	    | CountryCode == "MEX" | CountryCode == "NIC" | CountryCode == "PAN" ///
	    | CountryCode == "PRY" | CountryCode == "PER" | CountryCode == "SUR" ///
	    | CountryCode == "TTO" | CountryCode == "URY" | CountryCode == "VEN" ///
	    using WDI_STATA.dta, clear
	
	 
	keep if IndicatorName == "Total greenhouse gas emissions (kt of CO2 equivalent)" /// EN.ATM.GHGT.KT.CE
	         | IndicatorName == "Population in urban agglomerations of more than 1 million" /// EN.URB.MCTY
	         | IndicatorName == "Energy use (kg of oil equivalent per capita)" /// EG.USE.PCAP.KG.OE
	         | IndicatorName == "Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)" /// SE.SEC.CUAT.LO.ZS
			 | IndicatorName == "GDP per capita (constant 2015 US$)" /// NY.GDP.PCAP.KD
			 | IndicatorName == "CO2 emissions from transport (% of total fuel combustion)" /// EN.CO2.TRAN.ZS
			 | IndicatorName == "Investment in transport with private participation (current US$)" // IE.PPI.TRAN.CD
	(2,280,960 observations deleted)
	
	 
	 drop IndicatorName
	
	 replace IndicatorCode = subinstr(IndicatorCode, ".", "_", .)
	(10,752 real changes made)
	
	 reshape wide valor, i(Country* anio) j(IndicatorCode) string
	(j = EG_USE_PCAP_KG_OE EN_ATM_GHGT_KT_CE EN_CO2_TRAN_ZS EN_URB_MCTY IE_PPI_TRAN_CD NY_GDP_PCAP_KD SE_SEC_CUAT_LO_ZS)
	
	Data                               Long   ->   Wide
	-----------------------------------------------------------------------------
	Number of observations           10,752   ->   1,536       
	Number of variables                   5   ->   10          
	j variable (7 values)     IndicatorCode   ->   (dropped)
	xij variables:
	                                  valor   ->   valorEG_USE_PCAP_KG_OE valorEN_ATM_GHGT_KT_CE ... valorSE_SEC_CUAT_LO_ZS
	-----------------------------------------------------------------------------
	
	. 
	. drop if valorEN_ATM_GHGT_KT_CE == . | valorEN_URB_MCTY == . | valorEG_USE_PCAP_KG_OE == . ///
	>         | valorSE_SEC_CUAT_LO_ZS == . | valorNY_GDP_PCAP_KD == . | valorEN_CO2_TRAN_ZS == . ///
	>     | valorIE_PPI_TRAN_CD == .
	(1,465 observations deleted)
	
	. 
	. set seed 12345
	
	. gen random = runiform()
	
	. sort random
	
	. gen train = random <= 0.7



## Evaluate the model's performance
I have known the theory for many years, but I have never performed a Machine Learning prediction model (and, of course, I haven't evaluated one either). So, what I did here, is something similar to the requested, but using Stata commands. So, in this manner, the choice of model is just to answer the quesetion quickly with no theory behind.


	. ** 2. Train the model **
	. regress valorEN_ATM_GHGT_KT_CE ///
	>         valorEN_URB_MCTY valorEG_USE_PCAP_KG_OE valorSE_SEC_CUAT_LO_ZS ///
	>         valorNY_GDP_PCAP_KD valorEN_CO2_TRAN_ZS valorIE_PPI_TRAN_CD if train == 1
	
	      Source |       SS           df       MS      Number of obs   =        55
	-------------+----------------------------------   F(6, 48)        =   2730.04
	       Model |  7.3470e+12         6  1.2245e+12   Prob > F        =    0.0000
	    Residual |  2.1529e+10        48   448529602   R-squared       =    0.9971
	-------------+----------------------------------   Adj R-squared   =    0.9967
	       Total |  7.3686e+12        54  1.3645e+11   Root MSE        =     21179
	
	----------------------------------------------------------------------------------------
	valorEN_ATM_GHGT_KT_CE | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
	-----------------------+----------------------------------------------------------------
	      valorEN_URB_MCTY |    .011357   .0001717    66.14   0.000     .0110117    .0117022
	valorEG_USE_PCAP_KG_OE |   234.4006   31.10514     7.54   0.000     171.8595    296.9416
	valorSE_SEC_CUAT_LO_ZS |   1731.646   517.7557     3.34   0.002     690.6282    2772.663
	   valorNY_GDP_PCAP_KD |  -19.03942   5.058131    -3.76   0.000    -29.20948   -8.869367
	   valorEN_CO2_TRAN_ZS |   1046.349   658.1218     1.59   0.118    -276.8932    2369.592
	   valorIE_PPI_TRAN_CD |   1.49e-06   7.05e-07     2.11   0.040     6.96e-08    2.90e-06
	                 _cons |  -200111.6   40408.24    -4.95   0.000    -281357.9   -118865.4
	----------------------------------------------------------------------------------------
	
	. predict yhat_complete, xb
	
	. 
	. ** 3. Test the model **
	. predict yhat if train == 0, xb
	(55 missing values generated)
	
	. gen residual = valorEN_ATM_GHGT_KT_CE - yhat if train == 0
	(55 missing values generated)
	
	. gen mse = residual^2 if train == 0
	(55 missing values generated)
	
	. sum mse, meanonly
	
	. scalar mean_mse = r(mean)
	
	. display "Mean Squared Error (MSE) = " mean_mse
	Mean Squared Error (MSE) = 1.363e+08
	
	. 
	. gen rmse = sqrt(mean_mse)
	
	. sum rmse, meanonly
	
	. display "Root Mean Squared Error (RMSE) = " r(mean)
	Root Mean Squared Error (RMSE) = 11676.358
	
	. 
	. display "R-squared from training = " e(r2)
	R-squared from training = .9970782



## Simulate the scenario where GDP increases 10%
Using the regression coefficients, I just change the variable in question and predict the new dependent variable.

	. ** 4. Simulate scenario **
	. replace valorNY_GDP_PCAP_KD = valorNY_GDP_PCAP_KD*1.1
	(71 real changes made)
	
	. predict scenario, xb
	
	. replace valorNY_GDP_PCAP_KD = valorNY_GDP_PCAP_KD/1.1
	(71 real changes made)

	. tabstat yhat_complete scenario, stat(mean) save f(%10.0fc) by(CountryName)
	
	Summary statistics: Mean
	Group variable: CountryName (Country Name)
	
	     CountryName |   yhat_c~e   scenario
	-----------------+----------------------
	       Argentina |    246,247    228,299
	         Bolivia |     49,630     45,789
	          Brazil |    940,055    924,846
	        Colombia |    169,737    160,474
	      Costa Rica |      5,022    -12,581
	Dominican Republ |     34,359     24,899
	         Ecuador |     33,555     24,614
	       Guatemala |     43,705     36,274
	        Honduras |     -2,223     -6,413
	          Mexico |    610,286    592,123
	            Peru |     76,610     67,581
	-----------------+----------------------
	           Total |    352,018    339,517
	----------------------------------------
	
	. 
	. noisily di in g "El aumento de un 10% en el PIB per cápita resulta en una disminución de " ///
	>     in y %10.0fc r(StatTotal)[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(StatTotal)[1,2] in g " kt de CO2 equivalente " ///
	>     in y %7.2fc ((r(StatTotal)[1,2]-r(StatTotal)[1,1])/r(StatTotal)[1,1])*100 "%."
El aumento de un 10% en el PIB per cápita resulta en una disminución de    352,018 kt de CO2 equivalente a    339,517 kt de CO2 equivalente   -3.55%.


## Analyze and interpret the results
Con el modelo anterior, Costa Rica sería el país con mayores reducciones de CO2 (-350.5%). Le seguirían República Dominicana y Ecuador con -27.5% y 26.7%, respectivamente.

	. ** 5. Analyze results **
	. forvalues k=1(1)11 {
	  .         noisily di in g r(name`k') " reduciría sus emisiones de CO2 en " ///
	>         in y %10.0fc r(Stat`k')[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(Stat`k')[1,2] in g " kt de CO2 equivalente " ///
	>         in y %7.2fc ((r(Stat`k')[1,2]-r(Stat`k')[1,1])/r(Stat`k')[1,1])*100 "%."
	}
		
	Argentina reduciría sus emisiones de CO2 en    246,247 kt de CO2 equivalente a    228,299 kt de CO2 equivalente   -7.29%.
	Bolivia reduciría sus emisiones de CO2 en     49,630 kt de CO2 equivalente a     45,789 kt de CO2 equivalente   -7.74%.
	Brazil reduciría sus emisiones de CO2 en    940,055 kt de CO2 equivalente a    924,846 kt de CO2 equivalente   -1.62%.
	Colombia reduciría sus emisiones de CO2 en    169,737 kt de CO2 equivalente a    160,474 kt de CO2 equivalente   -5.46%.
	Costa Rica reduciría sus emisiones de CO2 en      5,022 kt de CO2 equivalente a    -12,581 kt de CO2 equivalente -350.54%.
	Dominican Republic reduciría sus emisiones de CO2 en     34,359 kt de CO2 equivalente a     24,899 kt de CO2 equivalente  -27.53%.
	Ecuador reduciría sus emisiones de CO2 en     33,555 kt de CO2 equivalente a     24,614 kt de CO2 equivalente  -26.65%.
	Guatemala reduciría sus emisiones de CO2 en     43,705 kt de CO2 equivalente a     36,274 kt de CO2 equivalente  -17.00%.
	Honduras reduciría sus emisiones de CO2 en     -2,223 kt de CO2 equivalente a     -6,413 kt de CO2 equivalente  188.50%.
	Mexico reduciría sus emisiones de CO2 en    610,286 kt de CO2 equivalente a    592,123 kt de CO2 equivalente   -2.98%.
	Peru reduciría sus emisiones de CO2 en     76,610 kt de CO2 equivalente a     67,581 kt de CO2 equivalente  -11.79%.

