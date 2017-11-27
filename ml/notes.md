# Machine Learning 2017/18

## Linear Modelling by Least Squares

We have some inputs `X = {x₁, x₂, ..., xn}` and their corresponding labels `T = {t₁, t₂, ... tn}`. We want to predict the `t` for any `x`.

We can approximate the data using a linear equation:
```
t = mx + c
```
Where `m` and `c` are learnt variables.

### Vectorizing

We can vectorize this by converting `m` and `c` into a vector of weights `W = {c, m}` and the input becomes `X = {1, x}`. Therefore, we can do `t = trans(W) * X`.

This has the benefit of us being able to add more input attributes to `X` without having to restructure our algorithms.

### Loss/Cost Function

A function that estimates how poorly our model performs on the dataset.

We use here squared difference:
```
L = avg((t - t')²)
```
Where `t` is the ground truth, and `t'` is our prediction.

### Deriving Optimal Values for the Weights `W`

We need to find `dW/dL = 0`, i.e. what values of `W` give use the minimum value for our loss function

TODO: How do we know that this is the global minima? And not just a local minima/maxima?

We can derive from the loss function `L` the minimum value is given by:
```
W' = (trans(X) * X)⁻¹ * trans(X) * t
```
Where `W'` is our approximation for the perfect values of `W`.

### Making Our Model Non-Linear

We can do this by adding extra variables to our `X` input vector.

If we add `x²`, `x³`, etc. to `X` then we can allow the model to make non-linear predictions from a single input value `x`.

Therefore, `X` becomes `[x⁰, x¹, x², ..., xn]` or `[1, x, x², ..., xn]` for some complexity `n`.

The more we increase `n`, the more our model can fit the data exactly. This has two main effects:

1) The model becomes very good at predicting data it has seen before

2) The model becomes very bad at predicting data it hasn't seen before

This is called overfitting, and should be avoided. Therefore, we want to pick an `n` that is large enought to model the complexity of the data, but not too big to overfit it.

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

