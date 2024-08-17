******************
***            ***
*** Pregunta 2 ***
***            ***
******************

** 0. Directorio de trabajo **
clear all
cd "/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/"

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

drop IndicatorName
replace IndicatorCode = subinstr(IndicatorCode, ".", "_", .)
reshape wide valor, i(Country* anio) j(IndicatorCode) string

drop if valorEN_ATM_GHGT_KT_CE == . | valorEN_URB_MCTY == . | valorEG_USE_PCAP_KG_OE == . ///
	| valorSE_SEC_CUAT_LO_ZS == . | valorNY_GDP_PCAP_KD == . | valorEN_CO2_TRAN_ZS == . ///
    | valorIE_PPI_TRAN_CD == .

set seed 12345
gen random = runiform()
sort random
gen train = random <= 0.7

** 2. Train the model **
regress valorEN_ATM_GHGT_KT_CE ///
	valorEN_URB_MCTY valorEG_USE_PCAP_KG_OE valorSE_SEC_CUAT_LO_ZS ///
	valorNY_GDP_PCAP_KD valorEN_CO2_TRAN_ZS valorIE_PPI_TRAN_CD if train == 1
predict yhat_complete, xb

** 3. Test the model **
predict yhat if train == 0, xb
gen residual = valorEN_ATM_GHGT_KT_CE - yhat if train == 0
gen mse = residual^2 if train == 0
sum mse, meanonly
scalar mean_mse = r(mean)
display "Mean Squared Error (MSE) = " mean_mse

gen rmse = sqrt(mean_mse)
sum rmse, meanonly
display "Root Mean Squared Error (RMSE) = " r(mean)

display "R-squared from training = " e(r2)

** 4. Simulate scenario **
replace valorNY_GDP_PCAP_KD = valorNY_GDP_PCAP_KD*1.1
predict scenario, xb
replace valorNY_GDP_PCAP_KD = valorNY_GDP_PCAP_KD/1.1

tabstat yhat_complete scenario, stat(mean) save f(%10.0fc) by(CountryName)

noisily di in g "El aumento de un 10% en el PIB per cápita resulta en una disminución de " ///
    in y %10.0fc r(StatTotal)[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(StatTotal)[1,2] in g " kt de CO2 equivalente " ///
    in y %7.2fc ((r(StatTotal)[1,2]-r(StatTotal)[1,1])/r(StatTotal)[1,1])*100 "%."

** 5. Analyze results **
forvalues k=1(1)11 {
	noisily di in g r(name`k') " reduciría sus emisiones de CO2 en " ///
	in y %10.0fc r(Stat`k')[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(Stat`k')[1,2] in g " kt de CO2 equivalente " ///
	in y %7.2fc ((r(Stat`k')[1,2]-r(Stat`k')[1,1])/r(Stat`k')[1,1])*100 "%."
}

save Question2.dta, replace