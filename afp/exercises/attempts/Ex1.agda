module Ex1 where

data ⊤ : Set where
  ∘ : ⊤
data ⊥ : Set where

enq : {A : Set} → ⊥ → A
enq ()

¬ : Set → Set
¬ A = A → ⊥

data _v_ : Set → Set → Set where
  inl : {A B : Set} → A → A v B
  inr : {A B : Set} → B → A v B

data _^_ : Set → Set → Set where
  _,_ : {A B : Set} → A → B → A ^ B

conj-elim-l : {A B : Set} → A ^ B → A
conj-elim-l (a , _) = a
conj-elim-r : {A B : Set} → A ^ B → B
conj-elim-r (_ , b) = b

postulate lem : {A : Set} → A v ¬ A

demorgan₀ : {A B : Set} → (¬ A) v (¬ B) → ¬ (A ^ B)
demorgan₀ (inl ¬a) = λ a^b → ¬a (conj-elim-l a^b)
demorgan₀ (inr ¬b) = λ a^b → ¬b (conj-elim-r a^b)

-- Relies on `lem`
demorgan₁ : {A B : Set} → ¬ (A ^ B) → (¬ A) v (¬ B)
demorgan₁ {A} {B} ¬a^b = goal bv¬b where
  bv¬b : B v ¬ B
  bv¬b = lem
  goal : (B v ¬ B) → (¬ A) v (¬ B)
  goal (inl b) = inl λ a → ¬a^b (a , b)
  goal (inr ¬b) = inr ¬b

demorgan₂ : {A B : Set} → ¬ (A v B) → (¬ A) ^ (¬ B)
demorgan₂ ¬avb = (λ a → ¬avb (inl a)) , λ b → ¬avb (inr b)

demorgan₃ : {A B : Set} → (¬ A) ^ (¬ B) → ¬ (A v B)
demorgan₃ {A} {B} (¬a , ¬b) = f where
  f : (A v B) → ⊥
  f (inl a) = ¬a a
  f (inr b) = ¬b b

disj-elim : {A B C : Set} → (A → C) → (B → C) → A v B → C
disj-elim f g (inl x) = f x
disj-elim f g (inr x) = g x

dni : {A : Set} → A → ¬ (¬ A)
dni a ¬a = ¬a a

tne : {A : Set} → ¬ (¬ (¬ A)) → ¬ A
tne ¬¬¬a = λ a → ¬¬¬a (dni a)

hilbert₀ : {A B : Set} → A → (B → A)
hilbert₀ a = λ b → a

hilbert₁ : {A B C : Set} → (A → (B → C)) → ((A → B) → (A → C))
hilbert₁ a→b→c = λ a→b → λ a → (a→b→c a (a→b a))

hilbert₂ : {A B C : Set} → (B → C) → ((A → B) → (A → C))
hilbert₂ b→c = λ a→b → λ a → b→c (a→b a)

hilbert₃ : {A B : Set} → A → (¬ A → B)
hilbert₃ a = λ ¬a → enq (¬a a)

hilbert₄ : {A B : Set} → (A → B) → ((¬ A → B) → B)
hilbert₄ a→b = λ ¬a→b → disj-elim a→b ¬a→b lem

lem→dne : {A : Set} → ((A' : Set) → A' v ¬ A') → (¬ (¬ A) → A)
lem→dne {A} lem = p₁ (lem A) where
  p₀ : (¬ (¬ A)) v (¬ (¬ (¬ A)))
  p₀ = lem (¬ (¬ A))
  p₁ : (A v ¬ A) → ¬ (¬ A) → A
  p₁ (inl a) ¬¬a = a
  p₁ (inr ¬a) ¬¬a = enq (¬¬a ¬a)

dne→lem : {A : Set} → ((A' : Set) → ¬ (¬ A') → A') → (A v ¬ A)
dne→lem {A} dne =
  dne
    (A v ¬ A)
    (λ z → z (inr (λ x → z (inl x))))
