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
{c, m}` and the input becomes `X = {1, x}`. Therefore, we can do `t = W.t ⋅
X`.

This has the benefit of us being able to add more input attributes to `X`
without having to restructure our algorithms.

### Least Squares Loss Function
A function that estimates how poorly our model performs on the dataset.

We use here squared difference:
```
L = avg((t - t')²)
```
Where `t` is the ground truth, and `t'` is our prediction.

### Maximum Likelihood Loss Function
Try to maximise the likelihood of the prediction being correct
```
L = p(t|X, w, σ²) = mult(N(w.t⋅xₙ, σ²) for xₙ in X)
```
where
- `X` is the input data
- `w` is the learnt weights
- `σ²` is the learnt standard deviation

Deriving these weights gives us the same results as least squares

### Deriving Optimal Values for the Weights `W`
We need to find `dW/dL = 0`, i.e. what values of `W` give use the minimum value
for our loss function

TODO: How do we know that this is the global minima? And not just a local
minima/maxima?

We can derive from the loss function `L` the minimum value is given by:

```
W' = (X.t ⋅ X)⁻¹ * X.t ⋅ t
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

# Unsupervised Clustering
- Given some data `X = {x₁, x₂...}`, can we group similar ones together?
- Similarity
  - We measure similarity as closeness, i.e. `(x₁ - x₂)²`

## K-means Clustering
- We want to find a set `K` parameters
- Each cluster is represented by it's center
  - Say cluster `μ` contains `X = {x₁, x₂..}`
  - We represent it as the average of `X`
- Algorithm:
  1. Randomly initialise `K` clusters `C = {μ₁, μ₂...}`
  2. Assign each of `X` to its closest cluster in `C`
  3. Update each cluster in `C` to be represented by the average of its new
     members
  4. If the members of each `C` do not change, finish
    - Otherwise, go to step 2
- Alternate algorithm:
  1. Randomly set all in `X` to a random cluster in `C`
    - `C` originally has no center until `X`s are assigned to it
  2. Update each cluster in `C` to be the average of its assigned elements
  3. Continue from step 2 in original algorithm
- We can evaluate the performance of a run of K-means by calculating the
  intra-group distance estimate:
  - `D = avg(for c in C, for x in c: (x - c)²)`
- K-means will find local-minima for `D`
  - We can find a better `D` by re-running K-means several times, and picking
    the clustering with the best `D`
- How to choose `K`?
  - When we increase `K`, `D` decreases, but we do not get better results
  - Best to increase `K` until you stop seeing _large_ improvements in `D`

### Using Kernels
- If we have non-linear groups, it is hard to cluster it with linear K-means
  comparison metrics
- So we can project it into some new space, by perhaps squaring the elements
  - `φ(x) = x²`
  - `k(x₁, x₂) = φ(x₁).t ⋅ φ(x₂)`
- Some kernel functions:
  - Linear kernel: `k(x₁, x₂) = x₁.t ⋅ x₂`
  - Gaussian kernel: `k(x₁, x₂) = exp{γ||x₁ - x₂||²}`
  - Polynomial kernel: `k(x₁, x₂) = (x₁.t ⋅ x₂ + c)^β`
- For K-means, whenever we compare to elements we now use this kernel function
  - When calculating distance to cluster, we average the cluster then use the
    kernel function
  - We can use the kernel trick to estimate the distance between an element of
    `X` and a cluster in `C`
- Kernel trick:
```
D(x, μ) = (x - μ).t ⋅ (x - μ)
μ = avg(for x in μ)
D(x, μ) = (x - sum(for x in μ)).t ⋅ (x - sum(for x in μ))
D(x, μ) = (x.t ⋅ x)
... - 2*sum((x't ⋅ x) for x' in μ)
... + avg((x'.t ⋅ x'') for x' in μ, for x'' in μ)
```
And then replace dot product with kernel function:
```
D(x, μ) = k(x, x)
... - 2*sum(k(x, x) for x' in μ)
... + avg(k(x', x'') for x' in μ, for x'' in μ)
```

### K-means Limitations
- Sensitive to initialisation
- Computationally expensive, having to calculate `n²` distances each iteration
- Need to run repeatedly
- Makes hard assumptions, each element is 100% belonging to 1 cluster

## Hierarchical Clustering
- Agglomerative (bottom-up) approach
  - Each object starts as a singleton cluster
  - The two most similar clusters are merged iteratively
  - Stops when all objects are in the same cluster
- Divisive (top-down) approach
  - Each object starts in same cluster
  - Outsider objects from least cohesive cluster are  removed iteratively
  - Stops when all objects are in singleton clusters
- Measuring similarity between clusters:
  - Smallest distance between elements
    - Clusters can get very large
  - Largest distance between links
    - Small, round clusters
  - Average distance between links
    - Compromise between small and large

### Hierarchical Agglomerative Clustering (HAC)
Algorithm:
1. Each object is a singleton cluster
2. Compute distance between all pairs of clusters
3. Merge the closest pair
4. If there is more than one cluster, go to step 2

### Benefits
- Can tune the level of clustering easier
- More efficient than K-means

# Supervised Learning - Discriminative Classification

## Generative vs Discriminative
- Generative classifiers generate a model for each class
  - e.g. Bayesian classifiers have some data for existing classes, and for new
    data try to see what class model fits best
- Discriminative classifiers attempt to define where these classes cross over
- TODO: These definitions seem a bit weak, are they correct?

## Support Vector Machines (SVMs)
- We want to find a linear hyperplane that separates the two classes positions
  - Formalised as: `w.t ⋅ x + b = 0`
- We can then find the best `w` and `b` that optimise this decision boundary
  - End up having to perform `argmin_w 1/2 w.t ⋅ w`, with the constraint that
    `tₙ(w.t ⋅ xₙ + b) ≥ 1`
  - See slides, I ain't copying that out
- Called SVMs due to the vectors closest to the decision boundary that "support"
  it

### Soft Margins
- Allow the some data points to lie closer to (or even over) the decision
  boundary
- This is done by relaxing the constraint to:
  - `tₙ(w.t ⋅ xₙ + b) ≥ 1 - ξₙ` and `ξₙ ≥ 0`
- The optimisation problem becomes:
  - `argmin_w 1/2 w.t ⋅ w + C*sum(ξₙ)`
- `C` controls the "softness" of the boundary

### Non-linear Decision Boundaries
- Project into another space
  - `x → φ(x)`
- But we can just use the kernel tricks
  - `x₁.t ⋅ x₂ → k(x₁, x₂)`
- Gaussian kernel: `exp{-β||x₁ - x₂||²}`
  - `β` controls model complexity

### Multi-class Classification
- If we have `N'` classes, have `N'` different classifiers that do 1 vs rest
  classification
- Each SVM returns a confidence score, we pick the one that gives the most
  confidence
- Can also train `N'(N' - 1) / 2` different binary classifiers
  - Assign according to maximum voting
  - Addresses class imbalance in the data

# Dimensionality Reduction
- Dimensionality is the number of features in the data

## Feature Selection
- Gradually add features, seeing how it effects performance

## Subspace Projection
- Make new features by merging old features (linearly/non-linearly)
- `X = Y⋅W` where
  - `Y` is `(N x M)`, the original data with high dimensionality `M`
  - `W` is `(M x D)`, the matrix that reduces dimensionality to `D`
  - `X` is `(N x D)`, the data with reduced dimensionality `D`
- We want to preserve the interesting aspects of the data

## Principle Component Analysis
- Define the columns of `W` one by one
  - This means we define one of the output dimensions one by one
- `xₙ = Y⋅wₙ` to get the `n`th output dimension
- Each `wₙ` is defined so that
  - The variance of `xₙ` is minimised
  - The new column `wₙ` is orthogonal to previous columns
- `W` is the collection of _eigenvectors_ of the _covarience matrix_ `Σ` of `Y`
- Calculating `Σ`
  - `Σₘₙ = avg((yₘ - μₘ)(yₙ - μₙ) for y in Y)`
  - If we set `Y' = Y - avg(Y)`
  - `Σ = (1/N)(Y'.t ⋅ Y')`
- Calculating `W`
  - `wₙ.t ⋅ wₘ = 0` when `n ≠ m`
  - Chose `wₙ` to maximise variance:
    - `argmax_w var(Y'w)`
    - `var(Y'w) = (Y'w).t ⋅ (Y'w)`
    - `var(Y'w) = w.t ⋅ Y'.t ⋅ Y' ⋅ w`
    - `var(Y'w) = w.t ⋅ NΣ ⋅ w`
    - `argmax_w w.t ⋅ Σ ⋅ w`
    - Must have constraint `w.t ⋅ w = 1`, otherwise can just keep increasing
      `w` to increase variance
    - Using Lagrange multiplier trick to add constraint in:
      - `argmax_w (w.t⋅Σ⋅w - λ(w.t⋅w - 1))`
    - Differentiate w.r.t `w` and set to 0
      - `2Σw - 2λw = 0`
      - `Σw = λw`
    - Solve using eigenvalue/eigenvector method (not in this module)
  - Aside about eigenvectors
    - `Σw = λw` means that matmul by `Σ` for `w` increases by a scalar factor
    - `w` is called an eigenvector, and `λ` is the eigenvalue
- Solving `Σw = λw` gives us `M` eigenvectors and `M` eigenvalues
  - The one with the highest `λ` has the highest variance (we can see this by
    mutliplying both sides by `w.t`
- In summary: the principle components of `Y` are the eigenvectors
  `{w₁, w₂...}`, ordered by their eigenvalues `{λ₁, λ₂...}`

# Supervised Learning - Ensemble Methods

## Ensemble Methods
- Boosting
  - Train a new classifier focusing on training examples misclassified b
    earlier model
- Bagging (bootstrap aggregation)
  - Generate new training data as a random subset of original data
  - Train new classifier on this subset

## Binary Decision Tree
- For each split node `n`, go right if `fₙ(x) ≤ thₙ`, and go left otherwise,
  where
  - `x` is `N` dimensional attributes
  - `fₙ` selects a single attribute from its input
  - `thₙ` is the threshold value
- For each leaf node, return a probability distribution across all classes

### Learning
- Select a subset of the data `X`
- Create a set of random features `f`
  - `f(x) = ax₁ + bx₂` for 2D data, where `a, b` are chosen randomly
- Try several combinations of `f` and `th`
  - Separate `X` according to `f` and `th` into `Xₗ, Xᵣ`
  - Pick the `f` and `th` that optimise the information gain of this split
  - `IG(Xₗ, Xᵣ) = E(Xₗ + Xᵣ) - (|Xₗ|/|Xₙ|)E(Xₗ) - (|Xᵣ|/|Xₙ|)E(Xᵣ)`
    - where `E = sum(P(c)log₂(P(c)) for c in classes)`
- Recurse for left and right children

### Randomised Decision Forests
- Generate `n` binary decision trees
  - Each one uses a random subset of the training data
    - Subsets can overlap
    - Increases runtime
- When evaluating, run all and average the response

