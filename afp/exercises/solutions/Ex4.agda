module Agda-4 where


data Unit : Set where
  unit : Unit

data ⊥ : Set where

¬ : Set → Set 
¬ A = A → ⊥

enq : {A : Set} → ⊥ → A
enq ()

data _∨_ (A B : Set) : Set where
  inl : A → A ∨ B
  inr : B → A ∨ B

infixl 5 _∨_

DE : {A B C : Set} → (A → C) → (B → C) → A ∨ B → C
DE f _ (inl x) = f x
DE _ g (inr x) = g x

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

data Nat : Set where
  zero : Nat
  suc  : Nat → Nat

_+_ : Nat → Nat → Nat
zero + n = n
suc m + n = suc (m + n)
infixl 5 _+_

data List (A : Set) : Set where
  nil  : List A
  _∷_  : (x : A) → List A → List A

infixr 4 _∷_

data Bool : Set where
  true : Bool
  false : Bool

if_then_else : {A : Set} → Bool → A → A → A
if true  then x else _ = x
if false then _ else x = x

_≤_ : Nat → Nat → Bool
zero ≤ _ = true
(suc m) ≤ (suc n) = m ≤ n
(suc _) ≤ zero = false

infix 5 _≤_

data _≤p_ : Nat → Nat → Set where
  zero≤p : ∀ n → zero ≤p n
  suc≤p  : ∀ m n → m ≤p n → suc m ≤p suc n

infix 5 _≤p_

sound≤ : (m n : Nat) → m ≤p n → m ≤ n ≡ true
sound≤ .zero n (zero≤p .n) = refl true
sound≤ .(suc m) .(suc n) (suc≤p m n p) = sound≤ m n p 

comp≤ : (m n : Nat) → m ≤ n ≡ true → m ≤p n 
comp≤ zero zero p = zero≤p zero
comp≤ zero (suc n) p = zero≤p (suc n)
comp≤ (suc m) zero ()
comp≤ (suc m) (suc n) p = suc≤p m n (comp≤ m n p)

{- ≤p is an order -}
refl≤ : ∀ n → (n ≤p n)
refl≤ zero = zero≤p zero
refl≤ (suc m) = suc≤p m m (refl≤ m)

trans≤ : ∀ m n p → m ≤p n → n ≤p p → m ≤p p
trans≤ .zero .zero p (zero≤p .zero) (zero≤p .p) = zero≤p p
trans≤ .zero .(suc m) .(suc n) (zero≤p .(suc m)) (suc≤p m n r) = zero≤p (suc n)
trans≤ .(suc m) .(suc n) .(suc n₁) (suc≤p m n q) (suc≤p .n n₁ r) = suc≤p m n₁ (trans≤ m n n₁ q r)

antisym≤ : ∀ m n → m ≤p n → n ≤p m → m ≡ n
antisym≤ .zero .zero (zero≤p .zero) (zero≤p .zero) = refl zero
antisym≤ .(suc m) .(suc n) (suc≤p m n p) (suc≤p .n .m q) = cong-≡ suc (antisym≤ m n p q) -- with hint cong-≡

{- for Nat it is a total order -}
total≤Nat : ∀ m n → (m ≤p n) ∨ (n ≤p m)
total≤Nat zero zero = inl (zero≤p zero)
total≤Nat zero (suc n) = inl (zero≤p (suc n))
total≤Nat (suc m) zero = inr (zero≤p (suc m))
total≤Nat (suc m) (suc n) = DE (λ z → inr (suc≤p n m z))
                               (λ z → inl (suc≤p m n z))
                               (total≤Nat n m)


min : Nat → Nat → Nat
min m n = if m ≤ n then m else n

Suspend : Set → Set
Suspend A = Unit → A

suspend : {A : Set} {B : A → Set} (f : (x : A) → B x) (x : A) → Suspend (B x)
suspend f x = λ { unit → f x }

force : {A : Set} → Suspend A → A
force f = f unit

data _≣_ {A : Set} (x : Suspend A) (y : A) : Set where
  it : (force x) ≡ y → x ≣ y

inspect : {A : Set} (x : Suspend A) → x ≣ (force x)
inspect f = it (refl (f unit))

lemma : ∀ b → b ≡ true → ¬ (b ≡ false)
lemma .true (refl .true) ()

{----------- Part 1 -----------}
max : Nat → Nat → Nat
max m n = if m ≤ n then n else m


{----------- Part 2 -----------}
min-mono : ∀ m₁ n₁ m₂ n₂ → m₁ ≤p m₂ → n₁ ≤p n₂ → min m₁ n₁ ≤p min m₂ n₂
min-mono m₁ n₁ m₂ n₂ p1 p2 with m₁ ≤ n₁ | m₂ ≤ n₂ | inspect (suspend (_≤_ m₁) n₁) 
min-mono m₁ n₁ m₂ n₂ p1 p2 | true  | true  | it p = p1
min-mono m₁ n₁ m₂ n₂ p1 p2 | true  | false | it p = trans≤ m₁ n₁ n₂ (comp≤ m₁ n₁ p) p2
min-mono m₁ n₁ m₂ n₂ p1 p2 | false | true  | it p = trans≤ n₁ m₁ m₂ (DE (λ q → q) (λ q → enq (lemma (m₁ ≤ n₁) ((sound≤ m₁ n₁ q)) p)) (total≤Nat n₁ m₁)) p1
min-mono m₁ n₁ m₂ n₂ p1 p2 | false | false | it p = p2

max-mono : ∀ m₁ n₁ m₂ n₂ → m₁ ≤p m₂ → n₁ ≤p n₂ → max m₁ n₁ ≤p max m₂ n₂
max-mono m₁ n₁ m₂ n₂ p1 p2 with m₁ ≤ n₁ | m₂ ≤ n₂ | inspect (suspend (_≤_ m₂) n₂)
max-mono m₁ n₁ m₂ n₂ p1 p2 | true  | true  | it p = p2
max-mono m₁ n₁ m₂ n₂ p1 p2 | true  | false | it p = trans≤ n₁ n₂ m₂ p2 (DE (λ q → q) (λ q → enq (lemma (m₂ ≤ n₂) (sound≤ m₂ n₂ q) p)) (total≤Nat n₂ m₂))
max-mono m₁ n₁ m₂ n₂ p1 p2 | false | true  | it p = trans≤ m₁ m₂ n₂ p1 (comp≤ m₂ n₂ p)
max-mono m₁ n₁ m₂ n₂ p1 p2 | false | false | it p = p1


{----------- Part 3 -----------}
_-_ : Nat → Nat → Nat
zero - zero = zero
zero - suc n = zero
suc m - zero = suc m
suc m - suc n = m - n

δ : Nat → Nat → Nat
δ m n = if m ≤ n then (n - m) else (m - n)

metric₁ : ∀ m n → δ m n ≡ zero → m ≡ n
metric₁ zero zero p = refl zero
metric₁ zero (suc n) ()
metric₁ (suc m) zero p = p
metric₁ (suc m) (suc n) p = cong-≡ suc (metric₁ m n p)

lemma₁ : ∀ m → m - m ≡ zero
lemma₁ zero = refl zero
lemma₁ (suc m) = lemma₁ m

metric₂ : ∀ m n → m ≡ n → δ m n ≡ zero
metric₂ m .m (refl .m) with m ≤ m
metric₂ m .m (refl .m) | true  = lemma₁ m
metric₂ m .m (refl .m) | false = lemma₁ m

lemma₂ : ∀ m n → m ≡ n → n - m ≡ m - n
lemma₂ m .m (refl .m) = refl (m - m)

metric₃ : ∀ m n → δ m n ≡ δ n m
metric₃ m n with m ≤ n | n ≤ m | inspect (suspend (_≤_ m) n) | inspect (suspend (_≤_ n) m)
metric₃ m n | true  | true  | it p1 | it p2 = lemma₂ m n (antisym≤ m n (comp≤ m n p1) (comp≤ n m p2))
metric₃ m n | true  | false | it p1 | it p2 = refl (n - m)
metric₃ m n | false | true  | it p1 | it p2 = refl (m - n)
metric₃ m n | false | false | it p1 | it p2 = lemma₂ n m
                                                     (antisym≤ n m (DE (λ q → q) (λ q → enq (lemma (m ≤ n) (sound≤ m n q) p1)) (total≤Nat n m))
                                                                   (DE (λ q → q) (λ q → enq (lemma (n ≤ m) (sound≤ n m q) p2)) (total≤Nat m n)))


≡⇒≤p : ∀ m n → m ≡ n → m ≤p n
≡⇒≤p zero .zero (refl .zero) = zero≤p zero
≡⇒≤p (suc m) .(suc m) (refl .(suc m)) = suc≤p m m (≡⇒≤p m m (refl m))

≡≤ : ∀ m n o → m ≡ n → n ≤p o → m ≤p o
≡≤ m .m o (refl .m) p1 = p1

≤≡ : ∀ m n o → m ≤p n → n ≡ o → m ≤p o
≤≡ m n .n p0 (refl .n) = p0

δ-zero-x : ∀ n → n ≡ δ zero n
δ-zero-x zero = refl zero
δ-zero-x (suc n) = refl (suc n)

δ-x-zero : ∀ n → n ≡ δ n zero
δ-x-zero zero = refl zero
δ-x-zero (suc n) = refl (suc n)

x+zero≡x : ∀ x → x + zero ≡ x
x+zero≡x zero = refl zero
x+zero≡x (suc x) = cong-≡ suc (x+zero≡x x)

+-suc-pos : ∀ x y → suc x + y ≡ x + suc y
+-suc-pos zero y = refl (suc y)
+-suc-pos (suc x) y = cong-≡ suc (+-suc-pos x y)

≤-suc : ∀ x y → x ≤p y → x ≤p suc y
≤-suc .zero y (zero≤p .y) = zero≤p (suc y)
≤-suc .(suc m) .(suc n) (suc≤p m n p) = suc≤p m (suc n) (≤-suc m n p)

δsuc-E : ∀ x y → δ (suc x) (suc y) ≡ δ x y
δsuc-E x y = refl (δ x y)

metric₄ : ∀ m n p → δ m n ≤p (δ m p + δ p n)
metric₄ zero zero zero = zero≤p zero
metric₄ zero zero (suc p) = zero≤p (suc (p + suc p))
metric₄ zero (suc n) zero = ≡⇒≤p (suc n) (suc n) (refl (suc n))
metric₄ zero (suc n) (suc p) = suc≤p n (p + δ (suc p) (suc n)) (≤≡ n (p + δ p n) (p + δ (suc p) (suc n)) (≡≤ n (δ zero n) (p + δ p n) (δ-zero-x n) (≤≡ (δ zero n) (δ zero p + δ p n) (p + δ p n) (metric₄ zero n p) (cong-≡ (λ x → x + δ p n) (sym-≡ (δ-zero-x p))))) (refl (p + if p ≤ n then n - p else (p - n)))) 
metric₄ (suc m) zero zero = ≤≡ (suc m) (suc m) (suc (m + zero)) (≡⇒≤p (suc m) (suc m) (refl (suc m))) (cong-≡ suc (sym-≡ (x+zero≡x m)))
metric₄ (suc m) zero (suc p) = ≤≡ (suc m) (δ m p + (suc p)) (δ (suc m) (suc p) + (suc p)) (≤≡ (suc m) (suc (δ m p + p)) (δ m p + suc p) (suc≤p m (δ m p + p) (≡≤ m (δ m zero) (δ m p + p) (δ-x-zero m) (≤≡ (δ m zero) (δ m p + δ p zero) (δ m p + p) (metric₄ m zero p) (cong-≡ (λ x → δ m p + x) (sym-≡ (δ-x-zero p)))))) (+-suc-pos (δ m p) p)) (cong-≡ (λ x → x + suc p) (sym-≡ (δsuc-E m p)))
metric₄ (suc m) (suc n) zero = ≡≤ (δ (suc m) (suc n)) (δ m n) (suc (m + δ zero (suc n))) (δsuc-E m n) (≤-suc (δ m n) (m + δ zero (suc n)) (≤≡ (δ m n) (suc (m + n)) (m + δ zero (suc n)) (≤-suc (δ m n) (m + n) (≤≡ (δ m n) (δ m zero + δ zero n) (m + n) (metric₄ m n zero) (trans-≡ (cong-≡ (λ x → x + δ zero n) (sym-≡ (δ-x-zero m))) (cong-≡ (λ x → m + x) (sym-≡ (δ-zero-x n)))))) (+-suc-pos m n)))
metric₄ (suc m) (suc n) (suc p) = ≡≤ (δ (suc m) (suc n)) (δ m n) (δ (suc m) (suc p) + δ (suc p) (suc n)) (δsuc-E m n) (≤≡ (δ m n) (δ m p + δ p n) (δ (suc m) (suc p) + δ (suc p) (suc n)) (metric₄ m n p) (trans-≡ (cong-≡ (λ x → x + δ p n) (sym-≡ (δsuc-E m p))) (cong-≡ (λ x → δ (suc m) (suc p) + x) (sym-≡ (δsuc-E p n)))))
