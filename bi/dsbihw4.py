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


train = pd.read_csv(paste0(os.path.join(data_path,"train_sample_hw4.csv"))
test = pd.read_csv(os.path.join(data_path,"test_sample_hw4.csv"))


param = {'objective': 'binary:logistic', 'eval_metric': 'auc'}

np.savez('submission.npz', rf_most_important=rf_most_important, 
         prediction=prediction)


npzfile = np.load('submission.npz')
print(npzfile['rf_most_important'],npzfile['prediction'].shape)
