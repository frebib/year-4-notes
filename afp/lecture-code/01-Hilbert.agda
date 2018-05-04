-- https://en.wikipedia.org/wiki/Hilbert_system

module 01-Hilbert where

data ⊤ : Set where
  ● : ⊤

data ⊥ : Set where

data _∧_ (A B : Set) : Set where
  _,_ : A → B → A ∧ B

infixl  6 _∧_

data _∨_ (A B : Set) : Set where
  inl : A → A ∨ B
  inr : B → A ∨ B

infixl 5 _∨_

P1 : {A : Set} → A → A
P1 a = a

P2 : {A B : Set} → A → (B → A)
P2 a _ = a

P3 : {A B C D : Set} → (A → B → C) → (A → B) → (A → C)
P3 f g a = f a (g a)

¬ : Set → Set
¬ A = A → ⊥

P4m : {A B : Set} → (A → B) → (A → ¬ B) → ¬ A
P4m f g a = g a (f a)

P4i : {A : Set} → (A → ¬ A) → ¬ A
P4i f a = f a a

enq : {A : Set} → ⊥ → A
enq ()

P5i : {A B : Set} → ¬ A → A → B
P5i f a = enq (f a)

CI : {A B : Set} → A → B → A ∧ B
CI a b = a , b

CEL : {A B : Set} → A ∧ B → A
CEL (a , _) = a

CER : {A B : Set} → A ∧ B → B
CER (_ , b) = b

DIL : {A B : Set} → A → A ∨ B
DIL a = inl a

DIR : {A B : Set} → B → A ∨ B
DIR b = inr b

DE : {A B C : Set} → (A → C) → (B → C) → A ∨ B → C
DE f _ (inl x) = f x
DE _ g (inr x) = g x

-- Classical Logic

postulate LEM : {A : Set} → A ∨ ¬ A

postulate DEE : {A : Set} → ¬ (¬ A) → A

