import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.preprocessing import StandardScaler

# Step 1: Load data and define the target variable
df = pd.read_stata('/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/Question2b.dta')

# List of variables to calculate the reduction for
variables = [
    'valorEN_ATM_GHGT_KT_CE', 'valorEN_URB_MCTY', 'valorEG_USE_PCAP_KG_OE',
    'valorSE_SEC_CUAT_LO_ZS', 'valorNY_GDP_PCAP_KD', 'valorEN_CO2_TRAN_ZS', 'valorIE_PPI_TRAN_CD'
]

# Assuming the DataFrame is sorted by Country and Year, if not, use:
# df.sort_values(by=['Country', 'Year'], inplace=True)

for var in variables:
    # Calculate the value 10 years later minus the current value, divided by the current value
    df[f'reduc_{var}'] = df.groupby('CountryCode')[var].shift(-10) / df[var] - 1

# Prepare features and target
X = df.drop(['valorEN_ATM_GHGT_KT_CE', 'CountryCode', 'anio'], axis=1)
y = df['valorEN_ATM_GHGT_KT_CE']

# Step 2: Train a classification model
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

model = RandomForestClassifier(random_state=42)
model.fit(X_train_scaled, y_train)

# Step 3: Evaluate the classifier's performance
y_pred = model.predict(X_test_scaled)
print(f"Accuracy: {accuracy_score(y_test, y_pred)}")
print(f"Precision: {precision_score(y_test, y_pred)}")
print(f"Recall: {recall_score(y_test, y_pred)}")
print(f"F1 Score: {f1_score(y_test, y_pred)}")

# Step 4: Analyze key features
feature_importances = pd.Series(model.feature_importances_, index=X.columns).sort_values(ascending=False)
print("Top 5 Key Features:", feature_importances.head(5))

# Step 5: Provide policy recommendations (example)
print("Policy Recommendations:")
print("1. Focus on improving indicators that are most influential in reducing CO2 emissions, such as [insert top indicators here].")
print("2. Implement policies that have been successful in countries identified as likely to achieve significant reductions.")