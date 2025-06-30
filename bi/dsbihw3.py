import pandas as pd
import numpy as np
import os
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import mean_squared_error
from sklearn.tree import DecisionTreeRegressor
import matplotlib.pyplot as plt
from sklearn.tree import plot_tree



# Task 
# === 1. Read Data ===
data_path =  "/Users/xiaolincheng/Desktop/2025spring/dsci"
data = pd.read_csv(os.path.join(data_path,"test_sample_hw3.csv"))
Y = data['Y'].values
X = data.drop(columns = ['Y'])

# === 2. GridSearchCV wth cv=10 ===
param_grid = {'ccp_alpha': np.linspace(0.01, 0.1, 10)}
clf = DecisionTreeRegressor(random_state=0)

gcv = GridSearchCV(clf, param_grid , cv = 10,scoring='neg_mean_squared_error')
gcv.fit(X,Y)

# === 3. ccp_alpha  ===
best_alpha = gcv.best_params_['ccp_alpha']

# === 4. Re initializaton Re fit===
best_tree = DecisionTreeRegressor(ccp_alpha= best_alpha, random_state= 0)
best_tree.fit(X,Y)

y_pred = best_tree.predict(X)
mse = mean_squared_error(Y,y_pred)

# === Solution: Optimal ccp_alpha value ===
print("ccp_alpha = ",best_alpha)
# === Solution: Tree regression MSE ===

print("mse = ",mse)

# ======= rest =======
model = DecisionTreeRegressor(random_state=0, ccp_alpha=0)
model.fit(X, Y)
results = gcv.cv_results_
ccp_alphas = np.linspace(0.01, 0.1, 10)   
trees = []



for alpha in ccp_alphas:
    model = DecisionTreeRegressor(random_state=0, ccp_alpha=alpha)
    model.fit(X, Y)
    trees.append(model)

plt.figure(figsize=(20,10))
plot_tree(trees[0], filled=True, feature_names=X.columns)
plt.title(f"Decision Tree with ccp_alpha={ccp_alphas[0]:.2f}")
plt.show()
