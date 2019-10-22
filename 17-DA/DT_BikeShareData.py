# Importing Libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Importing Dataset
data_set = pd.read_csv(r"D:\MyFiles\Projects\LP1-LabAsg\17-DA\DT_BikeShareData.csv")

# Data set summary
print(data_set.info())

# Separation of Independent Variable(IV), Dependent Variable (DV)
X = data_set.iloc[:, [0, 3, 5]].values #Column 0, 3, 5
y = data_set.iloc[:, -1].values #Column 'Member type'
print(X[:5]) #First 5
print(y[:5])

# y has Categorical data hence needs Encoding
from sklearn.preprocessing import LabelEncoder
labelencoder_y =LabelEncoder()
y = labelencoder_y.fit_transform(y)
print("Sample y:",y[:5])
print("0 :",labelencoder_y.classes_[0])
print("1 :",labelencoder_y.classes_[1])

# Splitting of Data into Training & Testing
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=0)

# Machine: Classifier | Classifier: Decision Tree
from sklearn.tree import DecisionTreeClassifier
classifier = DecisionTreeClassifier(criterion='entropy', min_samples_leaf=4, random_state=0)
classifier.fit(X_train, y_train)

# Predicting the Test set results
y_pred = classifier.predict(X_test)

# for i in range(len(X_test)):
#     print("X=%s, P=%s" % (X_test[i], Y_pred[i]))

#Accuracy
print("Accuracy: %.3f" %((Y_test == Y_pred).sum()/X_test.shape[0]*100))

# Making the Confusion Matrix
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)
print(cm)
