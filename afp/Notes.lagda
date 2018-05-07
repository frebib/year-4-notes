# Advanced Functional Programming Notes

\begin{code}
module Notes where
\end{code}

# Hilbert System

We can represent true/false as sets with one element, or no elements:
\begin{code}
module Hilbert where
  data ⊤ : Set where
    ● : ⊤
  data ⊥ : Set where
\end{code}

We can therefore represent and/or as so, as the existence of a set means true:
\begin{code}
  data _^_ (A B : Set) : Set where
    _,_ : A → B → A ^ B
  infixl 6 _^_
  data _v_ (A B : Set) : Set where
    inl : A → A v B
    inr : B → A v B
  infixl 5 _v_
\end{code}

Some misc definitions can be made too:
\begin{code}
  -- Not `A`
  ¬ : Set → Set
  ¬ A = A → ⊥

  -- If false is occupied, we can prove anything
  enq : {A : Set} → ⊥ → A
  enq ()
  \end{code}

  Now we can start making some proofs:
  \begin{code}
  -- A set implies itself
  proof₁ : {A : Set} → A → A
  proof₁ a = a

  -- If we know `A` is true, we can infer it from anything
  proof₂ : {A B : Set} → A → (B → A)
  proof₂ a = λ _ → a

  proof₃ : {A B C : Set} → (A → B → C) → (A → B) → (A → C)
  proof₃ f g = λ a → f a (g a)

  proof₄ₘ : {A B : Set} → (A → B) → (A → ¬ B) → ¬ A
  proof₄ₘ f g = λ a → (g a) (f a)

  proof₄ᵢ : {A : Set} → (A → ¬ A) → ¬ A
  proof₄ᵢ f = λ a → (f a) a

  proof₅ᵢ : {A B : Set} → ¬ A → A → B
  proof₅ᵢ na a = enq (na a)

  conj-intro : {A B : Set} → A → B → A ^ B
  conj-intro a b = a , b

  conj-elim-l : {A B : Set} → A ^ B → A
  conj-elim-l (a , _) = a
  conj-elim-r : {A B : Set} → A ^ B → B
  conj-elim-r (_ , b) = b

  disj-intro-l : {A B : Set} → A → A v B
  disj-intro-l = inl
  disj-intro-r : {A B : Set} → B → A v B
  disj-intro-r = inr

  disj-elim : {A B C : Set} → (A → C) → (B → C) → (A v B) → C
  disj-elim f g (inl a) = f a
  disj-elim f g (inr b) = g b
\end{code}

# Equality

Start by defining natural numbers
\begin{code}
module NaturalNumbers where
  data Nat : Set where
    zero : Nat
    succ : Nat → Nat

  _+_ : Nat → Nat → Nat
  zero + b = b
  succ a + b = succ (a + b)

  ₀ = zero
  ₁ = succ ₀
  ₂ = succ ₁
  ₃ = succ ₂
\end{code}

We'll also need booleans
\begin{code}
module Booleans where
  data Bool : Set where
    true : Bool
    false : Bool

  if_then_else_ : {A : Set} → Bool → A → A → A
  if true then a else _ = a
  if false then _ else a = a

  -- We can make a type out of a value
  data is-true : Bool → Set where
    ok : is-true true
\end{code}

Now we can see how to prove that natural numbers are equal
\begin{code}
module NatEquality where
  open NaturalNumbers
  open Booleans

  -- We can check for equality, as we would in other languages
  check-eq : Nat → Nat → Bool
  check-eq zero zero = true
  check-eq (succ a) (succ b) = check-eq a b
  check-eq _ _ = false

  -- Or we can prove equality using Agda's typesystem
  data prove-eq : Nat → Nat → Set where
    zero-eq : prove-eq zero zero
    succ-eq : (a b : Nat) → prove-eq a b → prove-eq (succ a) (succ b)

  -- Now we can try some proofs using both techniques
  zero-rid-check : (n : Nat) → is-true (check-eq (n + ₀) n)
  zero-rid-check zero = ok
  zero-rid-check (succ n) = zero-rid-check n

  zero-rid-prove : (n : Nat) → prove-eq (n + ₀) n
  zero-rid-prove zero = zero-eq
  zero-rid-prove (succ n) = succ-eq (n + ₀) n (zero-rid-prove n)

  sym-check : (n m : Nat) → is-true (check-eq n m) → is-true (check-eq m n)
  sym-check zero zero p = ok
  sym-check (succ n) (succ m) p = sym-check n m p
  sym-check zero (succ m) ()
  sym-check (succ n) zero ()

  sym-prove : (n m : Nat) → prove-eq n m → prove-eq m n
  sym-prove .zero .zero zero-eq = zero-eq
  sym-prove .(succ a) .(succ b) (succ-eq a b p) = succ-eq b a (sym-prove a b p)

  -- We can prove that our proof is sound, and complete, w.r.t. the check
  -- function
  soundness : (n m : Nat) → is-true (check-eq n m) → prove-eq n m
  soundness zero zero c = zero-eq
  soundness (succ n) (succ m) c = succ-eq n m (soundness n m c)
  soundness zero (succ m) ()
  soundness (succ n) zero ()

  completeness : (n m : Nat) → prove-eq n m → is-true (check-eq n m)
  completeness .zero .zero zero-eq = ok
  completeness .(succ a) .(succ b) (succ-eq a b p) = completeness a b p
\end{code}

This works fine for natural numbers, but for all types we use a different
definition of equality:
\begin{code}
module Equality where
  data _≡_ {A : Set} : A → A → Set where
    refl : {a : A} → a ≡ a
  infix 0 _≡_

  sym : {A : Set}{a b : A} → a ≡ b → b ≡ a
  sym refl = refl

  trans : {A : Set}{a b c : A} → a ≡ b → b ≡ c → a ≡ c
  trans refl refl = refl

  cong : {A B : Set}{a b : A} → (f : A → B) → a ≡ b → f a ≡ f b
  cong f refl = refl

\end{code}

This definition will be used from now on. We can compare it with the previous definition:
\begin{code}
module NatEqualityComparison where
  open NaturalNumbers
  open NatEquality
  open Equality

  prove→≡ : {n m : Nat} → prove-eq n m → n ≡ m
  prove→≡ zero-eq = refl
  prove→≡ (succ-eq n m p) = cong succ (prove→≡ p)

  ≡→prove : {n m : Nat} → n ≡ m → prove-eq n m
  ≡→prove (refl {zero}) = zero-eq
  ≡→prove (refl {succ n}) = succ-eq n n (≡→prove refl)
\end{code}

## Equality with lists
We can try out this equality type when making proofs on lists.

First, we define lists:
\begin{code}
module Lists where
  data List (A : Set) : Set where
    [] : List A
    _∷_ : A → List A → List A
  infix 5 _∷_

  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  [_] : {A : Set} → A → List A
  [ x ] = x ∷ []

  map : {A B : Set} → (A → B) → List A → List B
  map f [] = []
  map f (x ∷ xs) = f x ∷ map f xs

  fold : {A B : Set} → (A → B → B) → B → List A → B
  fold f acc [] = acc
  fold f acc (x ∷ xs) = fold f (f x acc) xs
\end{code}

And now we can start some proofs:
\begin{code}
module ListsEquality where
  open Lists
  open Equality

  unit-++-l : {A : Set}{xs : List A} → [] ++ xs ≡ xs
  unit-++-l {xs = []} = refl
  unit-++-l {xs = x ∷ xs} = cong (_∷_ x) refl

  unit-++-r : {A : Set}{xs : List A} → xs ++ [] ≡ xs
  unit-++-r {xs = []} = refl
  unit-++-r {xs = x ∷ xs} = cong (_∷_ x) unit-++-r

  ++-assoc : {A : Set} → (as bs cs : List A) → as ++ (bs ++ cs) ≡ (as ++ bs) ++ cs
  ++-assoc [] bs cs = refl
  ++-assoc (a ∷ as) bs cs = cong (_∷_ a) (++-assoc as bs cs)
\end{code}

A more complicated proof is to prove that the reverse of the reverse of a list is itself (involution):

TODO: Complete

\\begin{code}
  rev : {A : Set} → List A → List A
  rev [] = []
  rev (x ∷ xs) = (rev xs) ++ [ x ]

  rev-invol : {A : Set}{xs : List A} → xs ≡ rev (rev xs)
  rev-invol {xs = []} = refl
  rev-invol {xs = x ∷ xs} = goal where

    -- p₃ : {A : Set}{x : A}{xs : List A} → rev (rev (x ∷ xs)) ≡ rev (rev xs ++ [ x ])
    -- p₃ = refl

    p₀ : {A : Set}{xs ys : List A} → rev (xs ++ ys) ≡ rev ys ++ rev xs
    p₀ {xs = []} {ys} = p₀₀ where
      p₀₀ : {A : Set}{as : List A} → as ≡ as ++ []
      p₀₀ {as = []} = refl
      p₀₀ {as = a ∷ as} = cong (_∷_ a) p₀₀
    p₀ {xs = x ∷ xs} {ys} = sym (trans
                                (p₀₀ (rev ys) (rev xs) [ x ])
                                (cong (λ xs' → xs' ++ xs) p₀)) where
      p₀₀ : {A : Set} → (as bs cs : List A) → as ++ (bs ++ cs) ≡ (as ++ bs) ++ cs
      p₀₀ [] bs cs = refl
      p₀₀ (a ∷ as) bs cs = cong (_∷_ a) (p₀₀ as bs cs)

    p₂ : {A : Set}{x : A}{xs : List A} → rev [ x ] ++ rev (rev xs) ≡ x ∷ rev (rev xs)
    p₂ = refl

    p₃ : {A : Set}{x : A}{xs : List A} → x ∷ rev (rev xs) ≡ x ∷ xs
    p₃ {x = x} = cong (_∷_ x) (sym rev-invol)

    goal : {A : Set}{x : A}{xs : List A} → x ∷ xs ≡ rev (rev (x ∷ xs))
    goal = sym (trans p₀ p₂)

\\end{code}

# Binary Search Trees

We can define BSTs in Agda. First we need to define comparison proofs for natural numbers:
\begin{code}
module ProveComp where
  open NaturalNumbers
  data _≤p_ : Nat → Nat → Set where
    ≤-zero : (n : Nat) → zero ≤p n
    ≤-succ : (n m : Nat) → n ≤p m → (succ n) ≤p (succ m)
\end{code}

We also will need the `Maybe` type, and a comparison for that type:
\begin{code}
module Maybes where
  data Maybe (A : Set) : Set where
    none : Maybe A
    some : A → Maybe A

  data _≤?_ {A : Set} {Leq : A → A → Set} : Maybe A → Maybe A → Set where
    ≤?-some : (a b : A) → (Leq a b) → (some a) ≤? (some b)
    ≤?-nonel : (a : A) → none ≤? (some a)
    ≤?-noner : (a : A) → (some a) ≤? none
\end{code}

Now we can define the BST:
\begin{code}

module BinarySearchTrees (A : Set) (Leq : A → A → Set) where
  open Maybes

  Leq? : Maybe A → Maybe A → Set
  Leq? = _≤?_ {A}{Leq}

  mutual
    data Bst : Set where
      leaf : Bst
      fork : (elem : A) → (left right : Bst) →
             Leq? (bst-min right) (some elem) →
             Leq? (some elem) (bst-max left) →
             Bst

    bst-min : Bst → Maybe A
    bst-min leaf = none
    bst-min (fork elem leaf _ _ _) = some elem
    bst-min (fork elem left _ _ _) = bst-min left

    bst-max : Bst → Maybe A
    bst-max leaf = none
    bst-max (fork elem _ leaf _ _) = some elem
    bst-max (fork elem _ right _ _) = bst-max right
\end{code}



