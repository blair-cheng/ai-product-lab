import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import GridSearchCV
import tensorflow as tf
import tensorflow.keras.backend as K
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Activation, Flatten,Reshape, Lambda, Input
from tensorflow.keras.utils import to_categorical, plot_model
from tensorflow.keras.optimizers import Adam,SGD,Adagrad
from tensorflow.keras.utils import model_to_dot
from scikeras.wrappers import KerasClassifier
from tensorflow.keras.initializers import Identity
from IPython.display import SVG

'''
Define Keras sequential model correspondent to model_plot.png 
make prediction for data = np.arange(10).reshape((1,-1)). 

'''
# Task 
# ============== Task 1 Define Keras sequential model correspondent to model_plot.png ==============

# ============== 1. Prepare input  ==============
data = np.arange(10).reshape((1,-1))
# ============== 2. Build model  ==============

model = Sequential()
# ============== 2.1 Dense 73 input  ==============
model.add(Input(shape = (10,)))
# ============== 2.2 Dense 73  ==============
model.add(Dense(20, kernel_initializer=Identity()))
model.add(Dropout(0.3))

# ============== 2.2 Dense 118  ==============

# ============== 2.3 min_plus_square  ==============
model.add(Lambda(lambda x: K.square(x) + K.min(x, axis = 1, keepdims = True ), name = 'min_plus_square'))
model.add(Activation('relu'))
model.add(Reshape((2,10)))
model.add(Flatten())
# ============== 2.4 dense 74 ==============
model.add(Dense(10, kernel_initializer=Identity()))
model.add(Activation('relu'))
model.add(Lambda(lambda x: K.sin(x), name = 'sin'))
model.add(Dropout(0.1))

# ============== 2.5 Output Dense ==============
model.add(Dense(3, kernel_initializer=Identity()))
model.add(Activation('softmax'))
model.add(Lambda(lambda x: K.max(x, axis = 1, keepdims = True), name = 'max'))

# ============== 2.6 pred and print  ==============
model.summary()
pred = model(data)
print('pred = ', pred.numpy())
plot_model(model, to_file="model_plot_fixed.png", show_shapes=True, show_layer_names=True)

