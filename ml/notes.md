## 0/1 Loss

```
avg(d(truth[n] == prediction[n]))
```
where
```
d(b: bool) = 1 if b else 0
```

Can be used to get classification accuracy

## Confusion Matrix

- Create a table of True Positive, True Negative, False Positive, False Negative

- Can be expanded for >2 classes

### Sensitivity
```
Sensitivity = TP / (TP + FN) = TP / (All Positive)
```

### Specificity
```
Specificity = TN / (TN + FP) = TN / (All Negative)
```

### ROC Analysis

1) Plot sensitivity and complementary specificity (`1 - Spec`) on a graph

2) Modify the model in some way (e.g. change threshold)

3) Check with modification has a point in the ROT graph closest to the top left corner (i.e. highest sensitivity and specificity)

#### Area Under Curve (AUC)

Get the area under the ROC curve

Higher is better

That way we get a performance metric that is independent of the variable we changed during ROC analysis (e.g. we might change threshold at run time)

#### For >2 Classes

Do one-against-all ROC analyses, so if you have 3 classes, you have 3 ROC graphs

## Hold-Out Validation

- Take a percentage of the dataset and don't show it to the model (e.g. 80/20)

### Disadvantages

1) Reduce training data

2) Reduce representativeness, as you've lost some data

### K-fold and LOO cross validation

TODO

## Instance Based Supervised Learning

- No training, just store training examples and use those

- Lazy, does all work on inference

- Local approximation / generalisation

## kNN Classification

- Store all `N` training examples

- Choose parameter `k < N`

- Find `k` nearest instances in training set

- Find the most common class in these `k` nearest

- In case of tie, assign randomly from tied

### Real Valued

- Same as above, but average `k` nearest labels

- Could use any distance measurement: Euclidean, Manhattan, cosine angle

### Disadvantages

- Class imbalance, if you have a class with only 5 instances, and a `k` of 11, you will never classify this class

- Classification performance cost is high, even though training performance cost is non-existent

- There may be irrelevant attributes in the dataset

### When To Use?

- Not too much data attributes (~20)

- Lots of training data

- Can learn complex target functions (lots of wiggly class boundaries)

### Distance-Weighted kNN

- Multiply the effect of each label by the distance to that instance

