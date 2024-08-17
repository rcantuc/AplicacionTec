******************
***            ***
*** Pregunta 1 ***
***            ***
******************

** 0. Directorio de trabajo **
clear all
cd "/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/"

** 1 y 2. Bases de datos **
capture confirm file "WDI_STATA.dta"
if _rc != 0 {
	capture confirm file "WDIEXCEL.xlsx"
	if _rc != 0 unzipfile "https://databank.worldbank.org/data/download/WDI_EXCEL.zip", replace
	
	import excel "WDIEXCEL.xlsx", clear sheet(Data) firstrow
	
	** 3. Limpieza **
	local anio = 1960
	foreach k of varlist E-BP {
		rename `k' valor`anio'
		local ++anio
	}
	reshape long valor, i(Country* Indicator*) j(anio)
	save WDI_STATA.dta, replace
}

** 4. Summary of the dataset **
use if CountryCode == "ARG" | CountryCode == "BLZ" | CountryCode == "BOL" ///
	| CountryCode == "BRA" | CountryCode == "CHL" | CountryCode == "COL" ///
	| CountryCode == "CRI" | CountryCode == "CUB" | CountryCode == "DOM" ///
	| CountryCode == "ECU" | CountryCode == "SLV" | CountryCode == "GTM" ///
	| CountryCode == "GUY" | CountryCode == "HND" | CountryCode == "JAM" ///
	| CountryCode == "MEX" | CountryCode == "NIC" | CountryCode == "PAN" ///
	| CountryCode == "PRY" | CountryCode == "PER" | CountryCode == "SUR" ///
	| CountryCode == "TTO" | CountryCode == "URY" | CountryCode == "VEN" ///
	using WDI_STATA.dta, clear
drop if valor == .

local indicators `""Total greenhouse gas emissions (kt of CO2 equivalent)" "Population in urban agglomerations of more than 1 million" "Energy use (kg of oil equivalent per capita)" "Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)" "GDP per capita (constant 2015 US$)" "CO2 emissions from transport (% of total fuel combustion)" "Investment in transport with private participation (current US$)" "'

foreach indicator of local indicators {
	quietly tabstat valor if IndicatorName == "`indicator'" & valor != ., stat(mean p10 p50 p90 max count sd) save
	noisily di _newline in y "`indicator'" in g " tiene: " ///
		in y %7.0fc r(StatTotal)[6,1] in g " observaciones," ///
		in y %10.0fc r(StatTotal)[1,1] in g " de promedio, " ///
		in y %10.0fc r(StatTotal)[7,1] in g " de desviación estándar." ///

	noisily di in g "El percentil 90 tiene " ///
		in y %7.1fc r(StatTotal)[4,1]/r(StatTotal)[2,1] in g " veces más que el percentil 10 y el máximo es " ///
		in y %7.1fc r(StatTotal)[5,1]/r(StatTotal)[1,1] in g " veces más que el promedio."
}
