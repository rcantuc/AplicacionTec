# Question 1
**I am not an expert in coding in Python, R, or Matlab**. However, I feel confident enough in my coding skills in Stata, HTML, Pascal, and my brief interactions with Python, R, and Matlab that I can tackle any problem using my available tools, including Artificial Intelligence.

In the Github repository you would find a **preliminar Python script** converted with AI from my Stata code. I couldn't make it to work immediately, I think I would eventually.


## Download WB Database from the Web
To simplify future tasks, I will download the entire dataset (all variables and countries once), reshape it, change it into a more usable format, and then use it as needed.

First, I verify if the file exist. If not, I will download it from the website.

	capture confirm file "WDI_STATA.dta"
 	if _rc != 0 {
         capture confirm file "WDIEXCEL.xlsx"
         if _rc != 0 unzipfile "https://databank.worldbank.org/data/download/WDI_EXCEL.zip", replace
         else import excel "WDIEXCEL.xlsx", clear sheet(Data) firstrow
         
         ** 3 Limpieza **
         local anio = 1960
         foreach k of varlist E-BP {
                   rename `k' valor`anio'
                   local ++anio
           }
         reshape long valor, i(Country* Indicator*) j(anio)
        save WDI_STATA.dta, replace
	}



## Summary of the dataset
I will use variables such as total greenhouse gas emissions, population in urban areas, energy use, educational attainment, and GDP per capita for all Latin American countries.



	use if CountryCode == "ARG" | CountryCode == "BLZ" | CountryCode == "BOL" ///
         | CountryCode == "BRA" | CountryCode == "CHL" | CountryCode == "COL" ///
         | CountryCode == "CRI" | CountryCode == "CUB" | CountryCode == "DOM" ///
         | CountryCode == "ECU" | CountryCode == "SLV" | CountryCode == "GTM" ///
         | CountryCode == "GUY" | CountryCode == "HND" | CountryCode == "JAM" ///
         | CountryCode == "MEX" | CountryCode == "NIC" | CountryCode == "PAN" ///
         | CountryCode == "PRY" | CountryCode == "PER" | CountryCode == "SUR" ///
         | CountryCode == "TTO" | CountryCode == "URY" | CountryCode == "VEN" ///
         using WDI_STATA.dta, clear
 
	local indicators `""Total greenhouse gas emissions (kt of CO2 equivalent)" "Population in urban agglomerations of more than 1 million" "Energy use (kg of oil equivalent per capita)"  "Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)" "GDP per capita (constant 2015 US$)" "CO2 emissions from transport (% of total fuel combustion)" "Investment in transport with private participation (current US$)" "'

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


### Resultados
Total greenhouse gas emissions (kt of CO2 equivalent) tiene:     744 observaciones,   117,542 de promedio,    213,789 de desviación estándar.
El percentil 90 tiene    92.6 veces más que el percentil 10 y el máximo es     9.6 veces más que el promedio.

Population in urban agglomerations of more than 1 million tiene:   1,216 observaciones, 7,831,689 de promedio, 14,847,169 de desviación estándar.
El percentil 90 tiene    34.8 veces más que el percentil 10 y el máximo es    11.8 veces más que el promedio.

Energy use (kg of oil equivalent per capita) tiene:     950 observaciones,     1,176 de promedio,      1,568 de desviación estándar.
El percentil 90 tiene     3.8 veces más que el percentil 10 y el máximo es    12.1 veces más que el promedio.

Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative) tiene:     393 observaciones,        47 de promedio,         16 de desviación estándar.
El percentil 90 tiene     2.8 veces más que el percentil 10 y el máximo es     1.8 veces más que el promedio.

GDP per capita (constant 2015 US) tiene:   1,450 observaciones,     5,402 de promedio,      3,425 de desviación estándar.
El percentil 90 tiene     5.2 veces más que el percentil 10 y el máximo es     4.3 veces más que el promedio.

CO2 emissions from transport (% of total fuel combustion) tiene:     939 observaciones,        39 de promedio,         16 de desviación estándar.
El percentil 90 tiene     3.0 veces más que el percentil 10 y el máximo es     2.4 veces más que el promedio.

Investment in transport with private participation (current US$) tiene:     193 observaciones,1402221969 de promedio, 3396823213 de desviación estándar.
El percentil 90 tiene   157.2 veces más que el percentil 10 y el máximo es    24.1 veces más que el promedio.

