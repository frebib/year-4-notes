module Agda-3 where

{-
    Show that (Nat, +, 0) is a commutative monoid.
    Define the type of integers Int.
    Define addition and subtraction for integers.
    Show that (Int, +, 0, -) forms an abelian group.
    Define multiplication for Nat. 
    Show that (Nat, +, 0, x, 1) forms a semi-ring.
-}

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

[_] : {A : Set} → A → List A
[ x ] = x ∷ nil

_++_ : {A : Set} → (xs ys : List A) → List A
nil      ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

reverse : {A : Set} → List A → List A
reverse nil      = nil
reverse (x ∷ xs) = (reverse xs) ++ [ x ]

revapp : {A : Set} → (xs zs : List A) → List A
revapp nil      zs = zs
revapp (x ∷ xs) zs = revapp xs (x ∷ zs)

frev : {A : Set} → List A → List A
frev xs = revapp xs nil


{----------- Part 0 -----------}
revapp-lemma : {A : Set} → (xs ys zs : List A)
             → (revapp xs ys) ++ zs ≡ revapp xs (ys ++ zs)
revapp-lemma nil ys zs = refl (ys ++ zs)
revapp-lemma (x ∷ xs) ys zs = revapp-lemma xs (x ∷ ys) zs 

reverse=frev : {A : Set} → (xs : List A) → reverse xs ≡ frev xs
reverse=frev nil = refl nil
reverse=frev (x ∷ xs) = trans-≡ (cong-≡ ((λ □ → □ ++ [ x ])) IH) (revapp-lemma xs nil (x ∷ nil))
  where
    IH : reverse xs ≡ frev xs
    IH = reverse=frev xs


{----------- Part 1 -----------}
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


{----------- Part 2 -----------}
data Int : Set where
  -[1⊕_] : Nat → Int -- negative number
  ⁺_ : Nat → Int     -- non-negative numbers

₀ = ⁺ zero


{----------- Part 3 -----------}
_-_ : Nat → Nat → Int
zero - zero = ⁺ zero
zero - suc y = -[1⊕ y ]
suc x - zero = ⁺ (suc x)
suc x - suc y = x - y
infixl 5 _-_

_⊕_ : Int → Int → Int
-[1⊕ x ] ⊕ -[1⊕ y ] = -[1⊕ (x + suc y) ]
-[1⊕ x ] ⊕ (⁺ y) = y - suc x
(⁺ x) ⊕ -[1⊕ y ] = x - suc y
(⁺ x) ⊕ (⁺ y) = ⁺ (x + y)
infixl 5 _⊕_

─_ : Int → Int
─ -[1⊕ x ] = ⁺ (suc x)
─ (⁺ zero) = ⁺ zero
─ (⁺ suc x) = -[1⊕ x ]
infixl 6 ─_

_⊖_ : Int → Int → Int
x ⊖ y = x ⊕ (─ y)

{----------- Part 4 -----------}
assoc-⊕ : ∀ x y z → (x + y) + z ≡ x + (y + z)
assoc-⊕ zero y z = refl (y + z)
assoc-⊕ (suc x) y z = cong-≡ suc (assoc-⊕ x y z)

commutative-lemma : ∀ x y → x + suc y ≡ suc x + y
commutative-lemma zero y = refl (suc y)
commutative-lemma (suc x) y = cong-≡ suc (commutative-lemma x y)

commutative-⊕ : ∀ x y → x ⊕ y ≡ y ⊕ x
commutative-⊕ -[1⊕ zero ] -[1⊕ x ] = trans-≡ p0 (trans-≡ p1 p2) where
  p0 : (-[1⊕ zero ]) ⊕ (-[1⊕ x ]) ≡ -[1⊕ (zero + suc x) ]
  p0 = refl -[1⊕ suc x ]

  p1 : -[1⊕ (zero + suc x) ] ≡ -[1⊕ (suc x + zero) ]
  p1 = cong-≡ (λ z → -[1⊕ z ]) (+-comm zero (suc x))

  p2 : -[1⊕ (suc x + zero) ] ≡ -[1⊕ x ] ⊕ -[1⊕ zero ]
  p2 = sym-≡ (cong-≡ -[1⊕_] (commutative-lemma x zero))
commutative-⊕ -[1⊕ zero ] (⁺ x) = refl (x - suc zero)
commutative-⊕ -[1⊕ suc x ] -[1⊕ y ] = cong-≡ -[1⊕_] (trans-≡ p1 p2) where
  p0 : x + suc y ≡ y + suc x
  p0 = trans-≡ (commutative-lemma x y) (+-comm (suc x) y)
  
  p1 : suc (x + suc y) ≡ suc (y + suc x)
  p1 = cong-≡ suc p0

  p2 : suc (y + suc x) ≡ y + suc (suc x)
  p2 = sym-≡ (commutative-lemma y (suc x))
commutative-⊕ -[1⊕ suc x ] (⁺ y) = refl (y - suc (suc x))
commutative-⊕ (⁺ x) -[1⊕ y ] = refl (x - suc y)
commutative-⊕ (⁺ x) (⁺ y) = cong-≡ ⁺_ (+-comm x y)

unitl-₀-⊕ : ∀ x → ₀ ⊕ x ≡ x
unitl-₀-⊕ -[1⊕ x ] = refl -[1⊕ x ]
unitl-₀-⊕ (⁺ x) = refl (⁺ x)

unitr-₀-⊕ : ∀ x → x ⊕ ₀ ≡ x
unitr-₀-⊕ x = trans-≡ (commutative-⊕ x (⁺ zero)) (unitl-₀-⊕ x)

left-inverse-⊕ : ∀ x → x ⊕ (─ x) ≡ ₀
left-inverse-⊕ -[1⊕ zero ] = refl (⁺ zero)
left-inverse-⊕ -[1⊕ suc x ] = left-inverse-⊕ -[1⊕ x ]
left-inverse-⊕ (⁺ zero) = refl (⁺ zero)
left-inverse-⊕ (⁺ suc x) = left-inverse-⊕ -[1⊕ x ]

right-inverse-⊕ : ∀ x → (─ x ⊕ x) ≡ ₀
right-inverse-⊕ x = trans-≡ (commutative-⊕ (─ x) x) (left-inverse-⊕ x)


{----------- Part 5 -----------}
_*_ : Nat → Nat → Nat
zero * n = zero
suc m * n = n + m * n

infixl 6 _*_

begin_ : ∀{A : Set}{x y : A} → x ≡ y → x ≡ y
begin_ x≡y = x≡y

_≡⟨_⟩_ : ∀{A : Set} (x {y z} : A) → x ≡ y → y ≡ z → x ≡ z
_ ≡⟨ x≡y ⟩ y≡z = trans-≡ x≡y y≡z

_∎ : ∀{A : Set} (x : A) → x ≡ x
_∎ _ = refl _

infix  3 _∎
infixr 2 _≡⟨_⟩_ 
infix  1 begin_


{----------- Part 6 -----------}
*-id₁ : ∀ m → m * (suc zero) ≡ m
*-id₁ zero = refl zero
*-id₁ (suc m) = cong-≡ suc (*-id₁ m)

*-id₂ : ∀ m → (suc zero) * m ≡ m
*-id₂ m = +-id₁ m

*-bot₁ : ∀ m → m * zero ≡ zero
*-bot₁ zero = refl zero
*-bot₁ (suc m) = *-bot₁ m

*-bot₂ : ∀ m → zero * m ≡ zero
*-bot₂ m = refl zero

l-distr : ∀ m n k → m * (n + k) ≡ m * n + m * k
l-distr zero n k = refl zero
l-distr (suc m) n k
  = begin
    n + k + m * (n + k)        ≡⟨ cong-≡ (λ □ → n + k + □) (l-distr m n k) ⟩
    n + k + (m * n + m * k)    ≡⟨ sym-≡ (+-assoc n k (m * n + m * k)) ⟩
    n + (k + (m * n + m * k))  ≡⟨ cong-≡ (λ □ → n + □) (+-assoc k (m * n) (m * k)) ⟩
    n + ((k + m * n) + m * k)  ≡⟨ cong-≡ ((λ □ → n + (□ + m * k))) (+-comm k (m * n)) ⟩
    n + ((m * n) + k + m * k)  ≡⟨ cong-≡ (λ □ → n + □) (sym-≡ (+-assoc (m * n) k (m * k))) ⟩
    n + (m * n + (k + m * k))  ≡⟨ +-assoc n (m * n) (k + m * k) ⟩
    n + m * n + (k + m * k)    
    ∎

r-distr : ∀ m n k → (n + k) * m ≡ n * m + k * m
r-distr m zero k = refl (k * m)
r-distr m (suc n) k
  = begin
    m + (n + k) * m      ≡⟨ cong-≡ (λ □ → m + □) (r-distr m n k) ⟩
    m + (n * m + k * m)  ≡⟨ +-assoc m (n * m) (k * m) ⟩
    m + n * m + k * m
    ∎

