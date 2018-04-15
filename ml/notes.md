# Machine Learning 2017/18

# Intro

Machine learning is improving in a task `T`, w.r.t. performance measure `P`,
based on experience `E`.

# Supervised Linear Modelling

We try to fit a linear line to some data set, making these assumptions:
- There is a relationship between the variables
- This relationship is linear
- This relationship will hold in the future

## Linear Modelling (by Least Squares, and Maximum Likelihood)

We have some inputs `X = {x₁, x₂, ..., xn}` and their corresponding labels `T =
{t₁, t₂, ... tn}`. We want to predict the `t` for any `x`.

We can approximate the data using a linear equation:

```
t = mx + c
```

Where `m` and `c` are learnt variables.

### With single variables

We need to derive `m` and `c` (a.k.a `w₁` and `w₂`) that minimises a loss
function.

### Vectorizing

We can vectorize this by converting `m` and `c` into a vector of weights `W =
{c, m}` and the input becomes `X = {1, x}`. Therefore, we can do `t = trans(W) *
X`.

This has the benefit of us being able to add more input attributes to `X`
without having to restructure our algorithms.

### Loss/Cost Function

A function that estimates how poorly our model performs on the dataset.

We use here squared difference:
```
L = avg((t - t')²)
```
Where `t` is the ground truth, and `t'` is our prediction.

### Deriving Optimal Values for the Weights `W`

We need to find `dW/dL = 0`, i.e. what values of `W` give use the minimum value
for our loss function

TODO: How do we know that this is the global minima? And not just a local
minima/maxima?

We can derive from the loss function `L` the minimum value is given by:

```
W' = (trans(X) * X)⁻¹ * trans(X) * t
```

Where `W'` is our approximation for the perfect values of `W`.

### Making Our Model Non-Linear

We can do this by adding extra variables to our `X` input vector.

If we add `x²`, `x³`, etc. to `X` then we can allow the model to make non-linear
predictions from a single input value `x`.

Therefore, `X` becomes `[x⁰, x¹, x², ..., xn]` or `[1, x, x², ..., xn]` for some
complexity `n`.

The more we increase `n`, the more our model can fit the data exactly. This has
two main effects:

1. The model becomes very good at predicting data it has seen before
2. The model becomes very bad at predicting data it hasn't seen before

This is called overfitting, and should be avoided. Therefore, we want to pick an
`n` that is large enough to model the complexity of the data, but not too big to
overfit it.

## Regularisation

Regularising is a technique to stop a model from overfitting its training data.

One way to regularise is append another term to the cost function:

```
L' = L + λσ(W)
```

Where `λ` is the weighting of our regularisation, and `σ` is some function that
combines the values of `W`. For `L1` regularisation, we have `σ(W) =
avg(abs(W))`, and for `L2` regularisation, we have `σ(W) = abs(W²)`.

Intuition: Model complexity (thus overfitting) increases as `W` increases. If we
punish high values of `W`, then the model will only increase `W` (and therefore
complexity), if it is worth the gain in the original loss function.

## Generative Models
- Add some random noise to make linear predictions look like real data
- Use additive noise: `tn = f(xn; W) + ε`
  - where `p(ε) = N(0, σ²)`
  - Model now determined by `W` and `σ`
- For each `(t, x)` we have a likelihood of `t` being observed, given by:
  - `p(t | x, W, σ²)`
  - We now want to maximise this function
- TODO: Go over the maths for this part

## Classification

### 0/1 Loss

```
avg(d(truth[n] == prediction[n]))
```
where
```
d(b: bool) = 1 if b else 0
```

Can be used to get classification accuracy

### Confusion Matrix
- Create a table of True Positive, True Negative, False Positive, False Negative
- Can be expanded for >2 classes

#### Sensitivity
```
Sensitivity = TP / (TP + FN) = TP / (All Positive)
```

#### Specificity
```
Specificity = TN / (TN + FP) = TN / (All Negative)
```

#### ROC Analysis
1. Plot sensitivity and complementary specificity (`1 - Spec`) on a graph
2. Modify the model in some way (e.g. change threshold)
3. Check with modification has a point in the ROT graph closest to the top left
   corner (i.e. highest sensitivity and specificity)

##### Area Under Curve (AUC)
- Get the area under the ROC curve
- Higher is better
- That way we get a performance metric that is independent of the variable we
  changed during ROC analysis (e.g. we might change threshold at run time)

##### For >2 Classes
Do one-against-all ROC analyses, so if you have 3 classes, you have 3 ROC graphs

## Hold-Out Validation
- Take a percentage of the dataset and don't show it to the model (e.g. 80/20)

### Disadvantages
1. Reduce training data
2. Reduce representativeness, as you've lost some data

### K-fold 

1. Separate data into `K` sets
2. Train once with `K-1` of the sets, validated on the remaining set
3. Repeat, cycling the validation set

### Leave-one-out cross validation (LOOCV)
Special case of k-fold where `K = N`

# Instance Based Supervised Learning
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
  - Cosine angle is measuring the difference in angles, so we essentially ignore
    the "magnitude" of the vectors

### Disadvantages
- Class imbalance, if you have a class with only 5 instances, and a `k` of 11,
  you will never classify this class
- Classification performance cost is high, even though training performance cost
  is non-existent
- There may be irrelevant attributes in the dataset

### When To Use?
- Not too much data attributes (~20)
- Lots of training data
- Can learn complex target functions (lots of wiggly class boundaries)

### Distance-Weighted kNN
- Multiply the effect of each label by the distance to that instance

# Bias-variance tradeoff
- Generalisation vs overfitting
- Error of a model consists of two components: `M = B² + V`
  - `B²` is mismatch between model and actual process that generated data
  - `V` is the variance, a more complex model has higher variance

# Supervised Bayesian Classification

## Probabilistic vs Non-probabilistic
- Non-prob models give hard classifications, `C=1, C=2...`
- While prob models give percentage likeliness, `C=10% 1, 90% 2`
  - Provides a lot more information
  - Important when the cost of misclassification is high

## Bayes Rule

```
P(x|y) = P(y|x) * P(x) / P(y)
```
- `P(x)` prior belief: probability of `x` occurring, without any other data
- `P(y|x)` class-conditional likelihood: prob of `y` occurring given `x`
  occurred
- `P(y)` data evidence: marginal probability of the observed data `y`
  - `= Σ(P(y && x))` for all `x`
  - `= Σ(P(y|x)P(x))` for all `x`
- `P(x|y)` posterior probability: probability of `x` occurring after seeing the
  new data `y`

## Bayesian classification
- Pick the class that optimises the posterior probability
- For "maximum a posterior hypothesis":
  - `argmax_c P(c|x)` where `c` is the class, and `x` is the observed data
  - `= argmax_c P(x|c) * P(c) / P(x)`
  - `= argmax_c P(x|c) * P(c)` because `P(x)` is independent of `c`, and can be
    omitted
- For "maximum likelihood hypothesis":
  - We omit `P(c)`, therefore assuming all classes are equally likely to occur
  - The equation becomes: `argmax_c P(x|c)`

## Naive Bayes Assumption
- We're now classifying a list of data `X = {x₁, x₂...}`
- Maximum a posterior now becomes:
  - `argmax_c P(x₁, x₂... | c) * P(c)`
- The naive assumption is that all in `X` are conditionally independent, thus:
  - `P(X|c) = P(x₁|c) * P(x₂|c) * ...`
  - Although, theoretically should be violated...
  - This assumption simplifies process, and works well in practice
- Example:
  - If we have attributes "has runny nose", "has temperature", and want to
    predict "has flu", the equation becomes:
  - `P(flu|RN, TMP) = P(RN|flu) * P(TMP|flu) * P(flu)`

## Continuous Values
- We calculate mean (`μ`) and stddev (`σ²`) for each attribute in `X`
- Then, `P(x|μ, σ²)` is the Gaussian formula
- Then, we can calculate the MAP and ML hypotheses
- We can do multi-variate Gaussian where `μ` is a vector and `Σ` is a matrix,
  this is non-naive
- We can also use naive bayes assumption here to deal with small amounts of
  training data

