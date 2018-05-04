module Agda-5 where

-- A generalised version of pairs : 'dependent' pairs
-- The second projection type depends on the first projection type
-- We have already seen 'dependent' types in 'inject'
data Σ (A : Set) (B : A → Set) : Set where
  _,_ : (a : A) → (b : B a) → Σ A B

infixr 4 _,_

_×_ : ∀ (A : Set) (B : Set) → Set
A × B = Σ A (λ x → B)

infixl 3 _×_

syntax Σ A (λ y → B) = ∃[ y ∶ A ] B
--OBS : Mind the spaces!
--      And : is actually "\:" above!

-- The proof term has two components:
-- fst : the witness
-- snd : the proof
-- The fact that an actual witness is always required is essential for CONSTRUCTIVE logic!

-- witness : {A : Set}{B : Set} → ∃[ x ∶ A ] B → A
-- NB : Don't confuse simple with dependent types!
--      These are 'just' projections, but with dependent types.
witness : {A : Set}{B : A → Set} → ∃[ x ∶ A ] (B x) → A
witness (x , y) = x

proof : {A : Set}{B : A → Set} → (p : ∃[ x ∶ A ] (B x)) → (B (witness p))
proof (x , y) = y

π₁ = witness
π₂ = proof

data _≡_ {A : Set} : A → A → Set where
  refl : (x : A) → x ≡ x

infix 0 _≡_

sym-≡ : {A : Set} → {x y : A} → x ≡ y → y ≡ x
sym-≡ (refl x) = refl x

trans-≡ : {A : Set} → {x y z : A} → x ≡ y → y ≡ z → x ≡ z
trans-≡ (refl x) (refl .x) = refl x

cong-≡ : {A B : Set} → {x y : A} → (f : A → B) → x ≡ y → f x ≡ f y
cong-≡ f (refl x) = refl (f x)

subst : {A : Set} {a b : A} (P : A → Set) → a ≡ b → P a → P b
subst P (refl x) pa = pa

begin_ : ∀{A : Set}{x y : A} → x ≡ y → x ≡ y
begin_ x≡y = x≡y

_≡⟨_⟩_ : ∀{A : Set} (x {y z} : A) → x ≡ y → y ≡ z → x ≡ z
_ ≡⟨ x≡y ⟩ y≡z = trans-≡ x≡y y≡z

_∎ : ∀{A : Set} (x : A) → x ≡ x
_∎ _ = refl _

infix  3 _∎
infixr 2 _≡⟨_⟩_ 
infix  1 begin_

data Nat : Set where
  zero : Nat
  suc  : Nat → Nat

_+_ : Nat → Nat → Nat
zero + n = n
suc m + n = suc (m + n)
infixl 5 _+_

+-id₁ : ∀ m → m + zero ≡ m
+-id₁ zero = refl zero
+-id₁ (suc m) = cong-≡ suc (+-id₁ m)

+-id₂ : ∀ m → zero + m ≡ m
+-id₂ m = refl m

+-assoc : ∀ m n h → m + (n + h) ≡ (m + n) + h
+-assoc zero n h = refl (n + h)
+-assoc (suc m) n h = cong-≡ suc (+-assoc m n h)

+-comm : ∀ m n → m + n ≡ n + m
+-comm zero n = sym-≡ (+-id₁ n)
+-comm (suc m) n = Goal n
  where
    IH : ∀ n → m + n ≡ n + m
    IH n = +-comm m n
    p₁ : ∀ n → m + suc n ≡ suc n + m
    p₁ n = +-comm m (suc n)
    p₂ : ∀ n → m + suc n ≡ suc m + n
    p₂ n = trans-≡ (p₁ n) (sym-≡ (cong-≡ suc (IH n)))
    Goal : ∀ n → suc m + n ≡ n + suc m
    Goal zero = cong-≡ suc (+-id₁ m)
    Goal (suc n) = cong-≡ suc (trans-≡ (p₂ n) IH')
      where
        IH' : suc m + n ≡ n + suc m
        IH' = Goal n

data Bool : Set where
  true : Bool
  false : Bool


{----------- Part 1 -----------}
isEven? : Nat → Bool
isEven? zero = true
isEven? (suc zero) = false
isEven? (suc (suc n)) = isEven? n


{----------- Part 2 -----------}
data _isEven : Nat → Set where
  pZero : zero isEven
  pSuc  : ∀ n → n isEven → suc (suc n) isEven


{----------- Part 3 -----------}
sound-isEven : ∀ n → n isEven → isEven? n ≡ true
sound-isEven .zero pZero = refl true
sound-isEven .(suc (suc n)) (pSuc n prf) = sound-isEven n prf

comp-isEven : ∀ n → isEven? n ≡ true → n isEven
comp-isEven zero prf = pZero
comp-isEven (suc zero) ()
comp-isEven (suc (suc n)) prf = pSuc n (comp-isEven n prf)


{----------- Part 4 -----------}
data ⊥ : Set where

¬ : Set → Set
¬ A = A → ⊥

enq : {A : Set} → ⊥ → A
enq ()

lemma₁ : ∀ m → ¬ (suc zero ≡ suc (m + suc m))
lemma₁ zero ()
lemma₁ (suc m) ()

suc-elim : ∀ {m n} → suc m ≡ suc n → m ≡ n
suc-elim {m} (refl .(suc _)) = refl m

unique-m₁ : ∀ n → Σ Nat (λ m → (n ≡ m + m) × (∀ z → n ≡ z + z → z ≡ m)) → n isEven
unique-m₁ zero (m , prf) = pZero
unique-m₁ (suc zero) (zero , () , _)
unique-m₁ (suc zero) (suc m , p₁ , p₂) = enq (lemma₁ m p₁)
unique-m₁ (suc (suc n)) (zero , () , _)
unique-m₁ (suc (suc n)) (suc m , p₁ , p₂) = pSuc n IH
  where
    IH = unique-m₁ n (m , suc-elim (trans-≡ (suc-elim p₁) (+-comm m (suc m)))
                        , (λ z p → suc-elim (p₂ (suc z) (cong-≡ suc (trans-≡ (cong-≡ suc p) (+-comm (suc z) z))))))

lemma₂ : ∀ z → zero ≡ z + z → z ≡ zero
lemma₂ zero prf = refl zero
lemma₂ (suc z) ()

lemma₃ : ∀ m z → z + z ≡ m + m → z ≡ m
lemma₃ m zero prf = sym-≡ (lemma₂ m prf)
lemma₃ zero (suc z) ()
lemma₃ (suc m) (suc z) prf = cong-≡ suc (lemma₃ m z (suc-elim p2))
  where
    p0 : z + suc z ≡ suc z + z
    p0 = +-comm z (suc z)
    p1 : m + suc m ≡ suc m + m
    p1 = +-comm m (suc m)
    p2 : suc z + z ≡ suc m + m
    p2 = trans-≡ (sym-≡ p0) (trans-≡ (suc-elim prf) p1)

unique-m₂ : ∀ n → n isEven → Σ Nat (λ m → (n ≡ m + m) × (∀ z → n ≡ z + z → z ≡ m))
unique-m₂ .zero pZero = zero , refl zero , (λ z p → lemma₂ z p)
unique-m₂ .(suc (suc n)) (pSuc n p₁) with unique-m₂ n p₁
unique-m₂ .(suc (suc n)) (pSuc n p₁) | m , p₂ , p₃
  = suc m , cong-≡ suc (trans-≡ (cong-≡ suc p₂) (+-comm (suc m) m))
    , (λ z p₄ → lemma₃ (suc m) z (trans-≡ (sym-≡ p₄) p4))
  where
    p0 : suc n ≡ suc m + m
    p0 = cong-≡ suc p₂
    p1 : suc m + m ≡ m + suc m
    p1 = +-comm (suc m) m
    p2 : suc (suc m + m) ≡ suc m + suc m
    p2 = cong-≡ suc p1
    p3 : suc (suc n) ≡ suc (suc m + m)
    p3 = cong-≡ suc p0
    p4 : suc (suc n) ≡ suc m + suc m
    p4 = trans-≡ p3 p2


{----------- Part 5 -----------}
_⇔_ : Set → Set → Set
A ⇔ B = (A → B) × (B → A)

postulate fun-extension : ∀ {A B : Set} (f g : A → B) → (f ≡ g) ⇔ (∀ x → f x ≡ g x)

_∘_ : {A B C : Set} → (g : B → C) → (f : A → B) → A → C
g ∘ f = λ a → g (f a)

lemma₄ : ∀ {X A A' : Set} (y : X) (h : X → A × A') → h y ≡ (π₁ ∘ h) y , (π₂ ∘ h) y 
lemma₄ y h with h y
... | a , a' = refl (a , a')

theorem : ∀ {X A A' : Set} (f : X → A) (f' : X → A') → Σ (X → A × A') (λ g → (f ≡ π₁ ∘ g) × (f' ≡ π₂ ∘ g) × (∀ h → (f ≡ π₁ ∘ h) × (f' ≡ π₂ ∘ h) → h ≡ g))
theorem f f' = (λ z → f z , f' z) , (refl f , refl f')
               , (λ h x → π₂ (fun-extension h (λ z → f z , f' z))
                          (λ y → let p0 = cong-≡ (λ □ → □ y) (π₁ x) in
                                 let p1 = cong-≡ (λ □ → □ y) (π₂ x) in
                                 let p2 = lemma₄ (f' y) (λ _ → h y) in
                                 subst (λ x → h y ≡ x , f' y) (sym-≡ p0) (subst ((λ x → h y ≡ (π₁ ∘ h) y , x)) (sym-≡ p1) p2)
                          )
                 )
