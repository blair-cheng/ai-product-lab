import pandas as pd
import numpy as np
import os
import statsmodels.api as sm
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA



# Task 1
# === 1. load data ===
data_path =  "/Users/xiaolincheng/Desktop/2025spring/dsci"
data = pd.read_csv(os.path.join(data_path,"test_sample.csv"))

#np.random.seed(12345678)
Y = data['Y'].values
X = data.drop(columns = ['Y'])
#X = pd.DataFrame(np.random.normal(0, 2, size = (500, 500)), columns = colnames)

#  === 2. linear regression for R2 ===

#fits = [sm.OLS(Y[:,j-2], sm.add_constant(X.iloc[:,:j])).fit() for j in range(2, 491)]
fits = [sm.OLS(Y, sm.add_constant(X.iloc[:, :j])).fit() for j in range(2, 492)]
#fits = [sm.OLS(Y,sm.add_constant(X.iloc[:,:j])).fit() for j in range(2, 6)]
rSquared = [fit.rsquared for fit in fits]
#plt.show()

n_orig = 490
for idx, r2 in enumerate(rSquared):
    if r2 > 0.9 and idx < n_orig:
        n_orig = idx
        break
# Task 2
# === factorScores ===
pca = PCA(n_components=490)
xPCA = pca.fit(X)
factorScores = pd.DataFrame(np.dot(X, xPCA.components_.T), columns =["PC%i"%(j+1) for j in range(490)])
factorScores.cov()
m490_PCA = sm.OLS(Y, sm.add_constant(factorScores)).fit()
print(m490_PCA.summary())

# ===first_PCA_rank ===
def rel_imp_me(X, y): 
    names = X.columns
    ser = pd.Series(index = names)
    lm0 = sm.OLS(y, sm.add_constant(X)).fit()
    for c in names:
        lm = sm.OLS(y, sm.add_constant(X[names.drop(c)])).fit()
        ser[c] = lm0.rsquared - lm.rsquared 
    res = pd.DataFrame(columns =['last', 'first', 'betasq', 'pratt'], index=names)
    res['last'] = ser
    corr = X.apply(lambda x: np.corrcoef(y,x)[0,1], axis=0)
    res['first'] = corr**2
    sx = X.std()
    res['betasq'] = (lm0.params[names] * sx / np.std(y))**2
    res['pratt'] = (lm0.params[names] * sx / np.std(y)) * corr
    return res

metrics_PCA = rel_imp_me(factorScores, Y)

first_PCA_rank = metrics_PCA["first"].rank(ascending=False, method='first')
print(first_PCA_rank)

# ===orderedFactors ===

metrics_PCA_sort = pd.DataFrame({"Factors" : first_PCA_rank.index,
                                 "Rank" : first_PCA_rank.values}).sort_values(by="Rank") 
orderedFactors = pd.DataFrame(factorScores, columns= metrics_PCA_sort["Factors"])

# ===orderedPCA_R2 ===
def rSquar(j, y, X) :
    return sm.OLS(y, sm.add_constant(X.iloc[:,:j])).fit().rsquared
orderedPCA_R2 = [rSquar(j,Y, orderedFactors) for j in range(2,492)]
print('\nOrdered PCA R-squared:')
print(orderedPCA_R2)

# ===n_PCA ===
for idx, r2 in enumerate(orderedPCA_R2):
    if r2 > 0.9 :
        n_PCA = idx 
        break

# ===Output ===
n_orig = n_orig + 2
n_PCA= n_PCA+ 2
Model_dimensionality_reduction = n_orig - n_PCA
print(f"n_orig = {n_orig}")
print(f"n_PCA = {n_PCA} ")
print(f"Model dimensionality reduction: {Model_dimensionality_reduction}")
print(f"Determination coefficient (R²): {orderedPCA_R2[n_PCA-2]:.5f}")

plt.plot(range(2,492), orderedPCA_R2, label="PCA")
plt.axhline(y=0.9, color='r', linestyle='--', label="R² = 0.9 threshold")
plt.axvline(x=n_PCA, color='g', linestyle='--', label=f"n_PCA = {n_PCA}")
plt.title("PCA Regression R² by number of components")
plt.xlabel("Number of Components")
plt.ylabel("R²")
plt.legend()
plt.show()


