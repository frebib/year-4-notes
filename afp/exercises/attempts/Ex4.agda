module Ex4 where

data ℕ : Set where
  zero : ℕ
  succ : ℕ → ℕ

data 𝔹 : Set where
  true : 𝔹
  false : 𝔹

data Ok : 𝔹 → Set where
  ok : Ok true

if_then_else_ : {A : Set} → 𝔹 → A → A → A
if true then a else _ = a
if false then _ else a = a

_≤_ : ℕ → ℕ → 𝔹
zero ≤ m = true
succ n ≤ zero = false
succ n ≤ succ m = n ≤ m

data _≤ₚ_ : ℕ → ℕ → Set where
  ≤-zero : {n : ℕ} → zero ≤ₚ n
  ≤-succ : {n m : ℕ} → n ≤ₚ m → succ n ≤ₚ succ m

completeness : {n m : ℕ} → Ok (n ≤ m) → n ≤ₚ m
completeness {zero} {m} p = ≤-zero
completeness {succ n} {zero} ()
completeness {succ n} {succ m} p = ≤-succ (completeness p)

soundness : {n m : ℕ } → n ≤ₚ m → Ok (n ≤ m)
soundness {zero} {m} p = ok
soundness {succ n} {zero} ()
soundness {succ n} {succ m} (≤-succ p) = soundness p

max : ℕ → ℕ → ℕ
max n m = if n ≤ m then m else n
min : ℕ → ℕ → ℕ
min n m = if n ≤ m then n else m

data _≡_ {A : Set} : A → A → Set where
  refl : {a : A} → a ≡ a

trans-≤ₚ : {a b c d : ℕ} → a ≤ₚ b → a ≡ c → b ≡ d → c ≤ₚ d
trans-≤ₚ p refl refl = p

{-
question₂ : {a₁ a₂ b₁ b₂ : ℕ} → a₁ ≤ₚ a₂ → b₁ ≤ₚ b₂ → min a₁ b₁ ≤ₚ min a₂ b₂
question₂ ≤-zero pb = ≤-zero
question₂ (≤-succ pa) ≤-zero = ≤-zero
question₂ {succ a₁}{succ a₂}{succ b₁}{succ b₂} (≤-succ pa) (≤-succ pb) =
  trans-≤ₚ p₁ (p₀ a₁ b₁) (p₀ a₂ b₂) where
    IH : min a₁ b₁ ≤ₚ min a₂ b₂
    IH = question₂ pa pb
    p₀ : (n m : ℕ) → succ (min n m) ≡ min (succ n) (succ m)
    p₀ n m with n ≤ m
    p₀ n m | true = refl
    p₀ n m | false = refl
    p₁ : succ (min a₁ b₁) ≤ₚ succ (min a₂ b₂)
    p₁ = ≤-succ IH
-}

data Unit : Set where
  unit : Unit

Suspend : Set → Set
Suspend A = Unit → A

suspend : {A : Set}{B : A → Set} → (f : (a : A) → B a) → (a : A) → Suspend (B a)
suspend f a = λ { unit → f a }

force : {A : Set} → Suspend A → A
force sa = sa unit

data _≣_ {A : Set} (sa : Suspend A) (a : A) : Set where
  it : (force sa) ≡ a → sa ≣ a

inspect : {A : Set} (sa : Suspend A) → sa ≣ (force sa)
inspect sa = it refl

trans-≤ : (a b c : ℕ) → Ok (a ≤ b) → Ok (b ≤ c) → Ok (a ≤ c)
trans-≤ zero b c p₁ p₂ = ok
trans-≤ (succ a) zero c ()
trans-≤ (succ a) (succ b) zero p₁ ()
trans-≤ (succ a) (succ b) (succ c) p₁ p₂ = trans-≤ a b c p₁ p₂

question₂ : (a₁ a₂ b₁ b₂ : ℕ) → Ok (a₁ ≤ a₂) → Ok (b₁ ≤ b₂) → Ok (min a₁ b₁ ≤ min a₂ b₂)
question₂ a₁ a₂ b₁ b₂ pa pb with a₁ ≤ b₁ | a₂ ≤ b₂ | inspect (suspend (_≤_ a₁) b₂)
question₂ a₁ a₂ b₁ b₂ pa pb | true | true | it x = pa
question₂ a₁ a₂ b₁ b₂ pa pb | true | false | it x = {!!}
question₂ a₁ a₂ b₁ b₂ pa pb | false | true | it x = {!!}
question₂ a₁ a₂ b₁ b₂ pa pb | false | false | it x = {!!}
_-_ : ℕ → ℕ → ℕ
zero - zero = zero
zero - succ m = zero
succ n - zero = succ n
succ n - succ m = n - m

δ : ℕ → ℕ → ℕ
δ n m = if (n ≤ m) then (m - n) else (m - n)
