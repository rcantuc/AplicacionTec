import pandas as pd
import numpy as np
import statsmodels.formula.api as smf

# Load the data
df = pd.read_stata('/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/Question2.dta')

# Replace valorEN_CO2_TRAN_ZS by half its value
df['valorEN_CO2_TRAN_ZS'] = df['valorEN_CO2_TRAN_ZS'] * 0.5

# Fit the model and predict scenario2
model = smf.ols('y ~ valorEN_CO2_TRAN_ZS', data=df).fit()
df['scenario2'] = model.predict(df['valorEN_CO2_TRAN_ZS'])

# Calculate mean of yhat_complete and scenario2 by CountryName
summary = df.groupby('CountryName').agg({'yhat_complete': 'mean', 'scenario2': 'mean'}).reset_index()

# Display the reduction in CO2 emissions
total_reduction = summary['scenario2'].mean() - summary['yhat_complete'].mean()
print(f"La reducción de un 50% en las emisiones de CO2 del transporte resulta en una disminución de {summary['yhat_complete'].mean():.0f} kt de CO2 equivalente a {summary['scenario2'].mean():.0f} kt de CO2 equivalente, lo que es un {total_reduction/summary['yhat_complete'].mean()*100:.2f}%.")

# Analyze results for each country
for index, row in summary.iterrows():
    reduction = row['scenario2'] - row['yhat_complete']
    print(f"{row['CountryName']} reduciría sus emisiones de CO2 en {row['yhat_complete']:.0f} kt de CO2 equivalente a {row['scenario2']:.0f} kt de CO2 equivalente, lo que es un {reduction/row['yhat_complete']*100:.2f}%.")