import pandas as pd
import os
import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.svm import SVC
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import GridSearchCV 
# goal: make SVM model accuracy > 0.867

# === 1. Read Data ===
data_path =  "/Users/xiaolincheng/Desktop/2025spring/dsci/hw5"

train =pd.read_csv(os.path.join(data_path, "train_sample_hw5.csv"))
test = pd.read_csv(os.path.join(data_path, "test_sample_hw5.csv"))

X_train = train[['x0','x1']]
y_train = train['class']
X_test = test[['x0','x1']]
id_test = test['ID']

# === 2. Tune sklearn.svm.SVC model ===

# === 2.1 define pipeline ===
pipe = Pipeline([('scaler', MinMaxScaler()), ('svc', SVC())])

# === 2.2 Grid Search ===
param_grid = {
    'svc__gamma': [34,35,36,37],
    'svc__C': [52,53,54, 56,58, 60]

}
grid = GridSearchCV(pipe, param_grid, cv=5, scoring='accuracy', return_train_score=True)

grid.fit(X_train, y_train)

results = pd.DataFrame(grid.cv_results_)
results['overfit_gap'] = results['mean_train_score'] - results['mean_test_score']

print(results[['params', 'mean_test_score', 'std_test_score', 'mean_train_score', 'overfit_gap']]
      .sort_values(by='mean_test_score', ascending=False))

print("Best params:", grid.best_params_)
print("Best CV accuracy:", grid.best_score_)

# === 2.3 Predict  ===
test_prediction =  grid.predict(X_test)

# === 3. Outcome: submission.csv ===
test['class']= test_prediction
test[['ID','class']].to_csv('submission.csv', index=False)