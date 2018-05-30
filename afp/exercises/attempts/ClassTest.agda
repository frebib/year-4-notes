module ClassTest where

module Question1 where
  data ⊤ : Set where
    ∘ : ⊤
  data ⊥ : Set where

  ¬ : Set → Set
  ¬ A = A → ⊥

  enq : {A : Set} → ⊥ → A
  enq ()

  data _v_ (A B : Set) : Set where
    inl : A → A v B
    inr : B → A v B

  lem = (A : Set) → A v ¬ A
  dne = (A : Set) → ¬ (¬ A) → A

  lem→dne : lem → dne
  lem→dne lem A ¬¬a = goal (lem A) where
    goal : A v ¬ A → A
    goal (inl a) = a
    goal (inr ¬a) = enq (¬¬a ¬a)

  dne→lem : dne → lem
  dne→lem dne A = dne (A v ¬ A) (λ z → z (inr (λ x → z (inl x))))

module Question2 where
  data List (A : Set) : Set where
    [] : List A
    _∷_ : A → List A → List A
  _++_ : {A : Set} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  data Bt (A : Set) : Set where
    leaf : Bt A
    fork : A → Bt A → Bt A → Bt A

  traverse : {A : Set} → Bt A → List A
  traverse leaf = []
  traverse (fork v left right) = v ∷ (traverse left ++ traverse right)

  data InList {A : Set} : A → List A → Set where
    in-[] : (a : A) → (as : List A) → InList a (a ∷ as)
    in-∷ : (a a' : A) → (as : List A) → InList a as → InList a (a' ∷ as)

  data InBt {A : Set} : A → Bt A → Set where
    in-leaf : (a : A) → (left right : Bt A) → InBt a (fork a left right)
    in-fork-left : (a a' : A) → (left right : Bt A) → InBt a left →
                   InBt a (fork a' left right)
    in-fork-right : (a a' : A) → (left right : Bt A) → InBt a right →
                    InBt a (fork a' left right)

  lemma₀ : {A : Set}(a : A)(as bs : List A) → InList a as → InList a (as ++ bs)
  lemma₀ a .(a ∷ as) bs (in-[] .a as) = in-[] a (as ++ bs)
  lemma₀ a .(a' ∷ as) bs (in-∷ .a a' as inl) = in-∷ a a' (as ++ bs) (lemma₀ a as bs inl)
  lemma₁ : {A : Set}(b : A)(as bs : List A) → InList b bs → InList b (as ++ bs)
  lemma₁ b as .(b ∷ bs) (in-[] .b bs) = {!!}
  lemma₁ b as .(b' ∷ bs) (in-∷ .b b' bs inl) = {!!}

  belonging₀ : {A : Set}{a : A}{bt : Bt A} → InBt a bt → InList a (traverse bt)
  belonging₀ (in-leaf a left right) = in-[] a (traverse left ++ traverse right)
  belonging₀ (in-fork-left a a' left right inbt) = lemma₀ a {!!} (a' ∷ (traverse left ++ traverse right)) {!!} where
    p₀ : InList a (traverse left)
    p₀ = belonging₀ {a = a} {bt = left} inbt
  belonging₀ (in-fork-right a a' left right inbt) = {!!}
