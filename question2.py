import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.tree import DecisionTreeRegressor  # Import DecisionTreeRegressor
import numpy as np

# Load the dataset
df = pd.read_stata('/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/AplicaciónTec/Question2b.dta')  # Update with your actual file path

# Split the data into training and testing sets based on the 'train' column
train_df = df[df['train'] == 1]
test_df = df[df['train'] == 0]

# Define the features and target variable
X_train = train_df[['valorEN_URB_MCTY', 'valorEG_USE_PCAP_KG_OE', 'valorSE_SEC_CUAT_LO_ZS', 'valorNY_GDP_PCAP_KD', 'valorEN_CO2_TRAN_ZS', 'valorIE_PPI_TRAN_CD']]
y_train = train_df['valorEN_ATM_GHGT_KT_CE']

X_test = test_df[['valorEN_URB_MCTY', 'valorEG_USE_PCAP_KG_OE', 'valorSE_SEC_CUAT_LO_ZS', 'valorNY_GDP_PCAP_KD', 'valorEN_CO2_TRAN_ZS', 'valorIE_PPI_TRAN_CD']]
y_test = test_df['valorEN_ATM_GHGT_KT_CE']

# Train the model
model = DecisionTreeRegressor()
model.fit(X_train, y_train)

# Test the model
y_pred = model.predict(X_test)

# Calculate MSE and RMSE
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)

# Display results
print(f"Mean Squared Error (MSE) = {mse}")
print(f"Root Mean Squared Error (RMSE) = {rmse}")
print(f"R-squared from training = {model.score(X_train, y_train)}")

# Increase GDP by 10% in training and testing sets
X_train['valorNY_GDP_PCAP_KD'] = X_train['valorNY_GDP_PCAP_KD'] * 1.10
X_test['valorNY_GDP_PCAP_KD'] = X_test['valorNY_GDP_PCAP_KD'] * 1.10

# Train the model with updated GDP
model.fit(X_train, y_train)

# Test the model with updated GDP
y_pred = model.predict(X_test)

# Calculate MSE and RMSE with updated GDP
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)

# Display results with updated GDP
print(f"Mean Squared Error (MSE) with updated GDP = {mse}")
print(f"Root Mean Squared Error (RMSE) with updated GDP = {rmse}")
print(f"R-squared from training with updated GDP = {model.score(X_train, y_train)}")