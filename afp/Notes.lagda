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
    refl : (a : A) → a ≡ a
  infix 0 _≡_
\end{code}

This definition will be used from now on
