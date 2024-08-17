******************
***            ***
*** Pregunta 3 ***
***            ***
******************
use Question2.dta, clear

replace valorEN_CO2_TRAN_ZS = valorEN_CO2_TRAN_ZS*.5
predict scenario2, xb

tabstat yhat_complete scenario2, stat(mean) save f(%10.0fc) by(CountryName)

noisily di in g "La reducción de un 50% en las emisiones de CO2 del transporte resulta en una disminución de " ///
    in y %10.0fc r(StatTotal)[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(StatTotal)[1,2] in g " kt de CO2 equivalente " ///
    in y %7.2fc ((r(StatTotal)[1,2]-r(StatTotal)[1,1])/r(StatTotal)[1,1])*100 "%."

** 5. Analyze results **
forvalues k=1(1)11 {
    noisily di in g r(name`k') " reduciría sus emisiones de CO2 en " ///
    in y %10.0fc r(Stat`k')[1,1] in g " kt de CO2 equivalente a " in y %10.0fc r(Stat`k')[1,2] in g " kt de CO2 equivalente " ///
    in y %7.2fc ((r(Stat`k')[1,2]-r(Stat`k')[1,1])/r(Stat`k')[1,1])*100 "%."
}
