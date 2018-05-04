# Exercise 5

Tasks for this week:
1. Evenness
  1. implement a function that tests (returns boolean) if a `Nat` is even,
     returning true if it is and false if it is not.
  2. define a data-type of proof terms for evenness.
  3. prove that the two definitions above are equivalent (soundness and
     completeness).
  4. prove that a `Nat n` is even if and only if there exists a unique `Nat m`
     such that `n = m + m`
2. Product: Assuming that two functions `f, g` are equal `f ≡ g`, by
   definition, if and only if `∀ x, f(x)≡g(x)`, formulate in Agda and prove the
   following property:
  1. For any functions `f : X → A, f' : X → A'`, there exists a unique function
     `g ∶ X → A × A'` such that `f ≡ π₁∘g` and `f' ≡ π₂ ∘ g`, where `_∘_` is
     function compositions and `π₁, π₂` are the projection functions from `A ×
     A'`.

