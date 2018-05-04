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
