import pandas as pd
import numpy as np
import os
import statsmodels.api as sm
from sklearn.linear_model import LassoCV, Lasso # Removed unused LinearRegression
# import matplotlib.pyplot as plt # Removed unused import
# from scipy import stats # Removed unused import (F-test was removed)

# === 1. load data ===
# IMPORTANT: Verify this is the correct path and filename as specified by the assignment!
# The problem description mentions "test_sample.csv", your code uses "test_sample_hw2.csv".
# Ensure this file contains Y and X0-X489.
data_path = "/Users/xiaolincheng/Desktop/2025spring/dsci"
data_file = "test_sample_hw2.csv" # Make sure this is the correct file name
try:
    data = pd.read_csv(os.path.join(data_path, data_file))
    # Optional: Add a check for expected columns/dimensions
    # print(f"Data shape: {data.shape}")
    # print(f"Data columns: {data.columns.tolist()}")
    if 'Y' not in data.columns or data.shape[1] != 491: # Assuming Y + 490 X variables
         print(f"Warning: Data in {data_file} does not seem to have the expected structure (Y + 490 X variables).")

    Y = data['Y'].values
    X = data.drop(columns=['Y'])
    # Ensure X columns are X0, X1,... if needed for index mapping, though integer index should work
    # X.columns = [f'X{i}' for i in range(X.shape[1])] # Optional: Rename columns if needed

except FileNotFoundError:
    print(f"Error: Data file not found at {os.path.join(data_path, data_file)}")
    print("Please ensure the data_path and data_file variables are correct.")
    # Exit or handle error appropriately
    exit()
except Exception as e:
    print(f"An error occurred while loading data: {e}")
    exit()


# === 2.1 alpha for Lasso regression ===
# Find optimal alpha using LassoCV
# Using recommended parameters: cv=5, random_state=1
print("Running LassoCV...")
lasso_cv = LassoCV(cv=5, random_state=1, n_jobs=-1) # Use n_jobs=-1 for potentially faster computation
lasso_cv.fit(X, Y)
alpha_min = lasso_cv.alpha_
print(f"Optimal alpha found by LassoCV: {alpha_min}")

# === 2.2 Lasso regression ===
# Perform Lasso regression with the optimal alpha
print("Running Lasso regression...")
lasso = Lasso(alpha=alpha_min, random_state=1)
lasso.fit(X, Y)
# Find indices of coefficients shrunk to exactly zero
eliminated_by_Lasso = np.where(lasso.coef_ == 0)[0]
print(f"Number of features eliminated by Lasso: {len(eliminated_by_Lasso)}")


# === 3. Linear regression (OLS) ===
# Fit OLS model using all predictors to get p-values
print("Running OLS regression...")
X_with_const = sm.add_constant(X) # Add constant for statsmodels OLS
ols_model = sm.OLS(Y, X_with_const)
ols_results = ols_model.fit()

# Get p-values, excluding the constant term
pvalues = ols_results.pvalues[1:] # pvalues correspond to X0, X1, ...

# Identify indices where p-value > 0.1
# Note: We strictly follow "> 0.1" as per instructions.
mask = pvalues > 0.1
eliminated_by_lm = np.where(mask)[0]
print(f"Number of features eliminated by OLS (p > 0.1): {len(eliminated_by_lm)}")


# === 4. Prepare answer.csv ===
# Convert arrays of indices to space-separated strings
lasso_zeros_str = ' '.join([str(idx) for idx in eliminated_by_Lasso])
lm_zeros_str = ' '.join([str(idx) for idx in eliminated_by_lm])

# Create DataFrame and save to CSV
print("Saving results to answer.csv...")
output_df = pd.DataFrame([lasso_zeros_str, lm_zeros_str], index=['eliminated_by_Lasso', 'eliminated_by_lm'])
# Use header=False because the index provides the row labels needed in the output format
output_df.to_csv('answer.csv', header=False)

print("Script finished.")
print("--- Eliminated Indices ---")
print("Lasso:", lasso_zeros_str)
print("LM (OLS):", lm_zeros_str)

