import os
import pandas as pd
from urllib.request import urlretrieve
import zipfile

# 0. Change working directory
os.chdir("/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/")

# 1 and 2. Database handling
wdi_file_path = "WDI_STATA.dta"
wdi_excel_path = "WDIEXCEL.xlsx"
wdi_excel_url = "https://databank.worldbank.org/data/download/WDI_EXCEL.zip"

# Check if WDI_STATA.dta exists, if not check for WDIEXCEL.xlsx, if not download and unzip
if not os.path.exists(wdi_file_path):
    if not os.path.exists(wdi_excel_path):
        zip_path, _ = urlretrieve(wdi_excel_url)
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(".")
    # Import Excel file
    df = pd.read_excel(wdi_excel_path, sheet_name='Data', skiprows=3)

    # 3. Cleaning
    df = df.melt(id_vars=['CountryName', 'CountryCode', 'IndicatorName', 'IndicatorCode'],
                 var_name='anio', value_name='valor')
    df.to_stata(wdi_file_path, write_index=False)

# 4. Summary of the dataset
df = pd.read_stata(wdi_file_path)
countries = ["ARG", "BLZ", "BOL", "BRA", "CHL", "COL", "CRI", "CUB", "DOM",
             "ECU", "SLV", "GTM", "GUY", "HND", "JAM", "MEX", "NIC", "PAN",
             "PRY", "PER", "SUR", "TTO", "URY", "VEN"]
df = df[df['CountryCode'].isin(countries)]
df.dropna(subset=['valor'], inplace=True)

indicators = [
    "Total greenhouse gas emissions (kt of CO2 equivalent)",
    "Population in urban agglomerations of more than 1 million",
    "Energy use (kg of oil equivalent per capita)",
    "Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)",
    "GDP per capita (constant 2015 US$)",
    "CO2 emissions from transport (% of total fuel combustion)",
    "Investment in transport with private participation (current US$)"
]

for indicator in indicators:
    subset = df[df['IndicatorName'] == indicator].dropna(subset=['valor'])
    stats = subset['valor'].describe(percentiles=[0.1, 0.5, 0.9])
    print(f"\n{indicator} has:")
    print(f"{int(stats['count'])} observations, {stats['mean']} average, {stats['std']} standard deviation.")
    print(f"The 90th percentile is {stats['90%']/stats['10%']} times more than the 10th percentile and the maximum is {stats['max']/stats['mean']} times more than the average.")