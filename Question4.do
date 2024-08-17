******************
***            ***
*** Pregunta 4 ***
***            ***
******************
use Question2.dta, clear
encode CountryCode, gen(code)
xtset code anio

* Binary target: reducción en las emisiones de CO2 mayores al 10% en 10 años*
foreach k of varlist valorEN_ATM_GHGT_KT_CE valorEN_URB_MCTY valorEG_USE_PCAP_KG_OE ///
    valorSE_SEC_CUAT_LO_ZS valorNY_GDP_PCAP_KD valorEN_CO2_TRAN_ZS valorIE_PPI_TRAN_CD {

    g reduc_`k' = D10.`k' / L10.`k'
}


* Example: Logistic regression
logit reduc_valorEN_ATM_GHGT_KT_CE ///
    reduc_valorEN_URB_MCTY reduc_valorEG_USE_PCAP_KG_OE ///
    reduc_valorSE_SEC_CUAT_LO_ZS reduc_valorNY_GDP_PCAP_KD ///
    reduc_valorEN_CO2_TRAN_ZS reduc_valorIE_PPI_TRAN_CD if train == 1

* Display model summary
di "Log likelihood = " e(ll)
di "AIC = " e(ic)

* Predict probabilities on the training set (for illustration)
predict p, pr

* Evaluate model performance (example using a simple cutoff for binary classification)
gen pred_class = p >= 0.5
tabulate target pred_class
