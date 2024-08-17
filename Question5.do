******************
***            ***
*** Pregunta 5 ***
***            ***
******************
use Question2.dta, clear
encode CountryCode, gen(code)
xtset code anio

