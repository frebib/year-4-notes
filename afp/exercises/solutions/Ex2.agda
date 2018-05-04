module Agda-2 where

data Bool : Set where
  true : Bool
  false : Bool

data Nat : Set where
  zero : Nat
  suc  : Nat → Nat

_+_ : Nat → Nat → Nat
zero + n = n
suc m + n = suc (m + n)
infixl 5 _+_

data List (A : Set) : Set where
  nil : List A
  _∷_ : A → List A → List A

infixr 4 _∷_
infix 5 _++_

length : {A : Set} → List A → Nat
length nil      = zero
length (a ∷ as) = suc (length as)

data istrue : Bool → Set where                   
  ok : istrue true

{-
LAB EXERCISES 
 0. Write an append function on lists
 1. Write a function that checks two lists have the same length
 2. Write a data-type of proofs that two lists have the same length
 3. Check/prove that appending nil preserves the length
 4. Check/prove that appending lists with the same length preserves length
 5. Prove soundness and completeness of of checking/proving same-length
-}


{----------- Part 0 -----------}
_++_ : {A : Set} → List A → List A → List A
nil ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)


{----------- Part 1 -----------}
check-len : {A B : Set} → List A → List B → Bool
check-len nil nil = true
check-len nil (x ∷ ys) = false
check-len (x ∷ xs) nil = false
check-len (x ∷ xs) (y ∷ ys) = check-len xs ys


{----------- Part 2 -----------}
data prove-len {A B : Set} : List A → List B → Set where
  zero-eq : prove-len nil nil
  succ-eq : ∀ x y xs ys → prove-len xs ys → prove-len (x ∷ xs) (y ∷ ys)


{----------- Part 3 -----------}
xs++nil≡xs : {A : Set} → (xs : List A) → prove-len xs (xs ++ nil)
xs++nil≡xs nil = zero-eq
xs++nil≡xs (x ∷ xs) = succ-eq x x xs (xs ++ nil) (xs++nil≡xs xs)

xs++nil≡xs' : {A : Set} → (xs : List A) → istrue (check-len xs (xs ++ nil))
xs++nil≡xs' nil = ok
xs++nil≡xs' (x ∷ xs) = xs++nil≡xs' xs


{----------- Part 4 -----------}
xs++ys≡xs++zs : {A B C : Set} → (xs ys zs : List A) → prove-len ys zs → prove-len (xs ++ ys) (xs ++ zs)
xs++ys≡xs++zs nil ys zs prf = prf
xs++ys≡xs++zs {A} {B} {C} (x ∷ xs) ys zs prf = succ-eq x x (xs ++ ys) (xs ++ zs) (xs++ys≡xs++zs {A} {B} {C} xs ys zs prf)

xs++ys≡xs++zs' : {A B C : Set} → (xs ys zs : List A) → istrue (check-len ys zs) → istrue (check-len (xs ++ ys) (xs ++ zs))
xs++ys≡xs++zs' nil ys zs prf = prf
xs++ys≡xs++zs' {A} {B} {C} (x ∷ xs) ys zs prf = xs++ys≡xs++zs' {A} {B} {C} xs ys zs prf


{----------- Part 5 -----------}
soundness : {A B : Set} (xs : List A) (ys : List B) → prove-len xs ys → istrue (check-len xs ys)
soundness .nil .nil zero-eq = ok
soundness .(x ∷ xs) .(y ∷ ys) (succ-eq x y xs ys prf) = soundness xs ys prf

completeness : {A B : Set} (xs : List A) (ys : List B) → istrue (check-len xs ys) → prove-len xs ys
completeness nil nil prf = zero-eq
completeness nil (x ∷ ys) ()
completeness (x ∷ xs) nil ()
completeness (x ∷ xs) (y ∷ ys) prf = succ-eq x y xs ys (completeness xs ys prf)

{-
 6. Re-do exercises 3 and 4 above using ≡ instead.
 7. Prove reflexivity, symmetry and transitivity of ≡
 8. Prove the Leibniz axioms for ≡
-}

data _≡_ {A : Set} : A → A → Set where
  refl : (x : A) → x ≡ x

infix 0 _≡_

cong : {A B : Set} {x y : A} → (f : A → B) → x ≡ y → f x ≡ f y
cong f (refl x) = refl (f x)


{----------- Part 6 -----------}
xs++nil≡<n>xs : {A : Set} (xs : List A) → length xs ≡ length (xs ++ nil)
xs++nil≡<n>xs nil = refl zero
xs++nil≡<n>xs (x ∷ xs) = cong suc (xs++nil≡<n>xs xs)

xs++nil≡<n>xs' : {A : Set} (xs : List A) → check-len xs (xs ++ nil) ≡ true
xs++nil≡<n>xs' nil = refl true
xs++nil≡<n>xs' (x ∷ xs) = xs++nil≡<n>xs' xs

xs++ys≡<n>xs++zs : {A : Set} (xs ys zs : List A) → length ys ≡ length zs → length (xs ++ ys) ≡ length (xs ++ zs)
xs++ys≡<n>xs++zs nil ys zs prf = prf
xs++ys≡<n>xs++zs (x ∷ xs) ys zs prf = cong suc (xs++ys≡<n>xs++zs xs ys zs prf)

xs++ys≡<n>xs++zs' :  {A : Set} (xs ys zs : List A) → check-len ys zs ≡ true → check-len (xs ++ ys) (xs ++ zs) ≡ true
xs++ys≡<n>xs++zs' nil ys zs prf = prf
xs++ys≡<n>xs++zs' (x ∷ xs) ys zs prf = xs++ys≡<n>xs++zs' xs ys zs prf


{----------- Part 7 -----------}
≡-refl : {A : Set} (x : A) → x ≡ x
≡-refl x = refl x

≡-sym : {A : Set} (x y : A) → x ≡ y → y ≡ x
≡-sym x .x (refl .x) = refl x

≡-trans : {A : Set} (x y z : A) → x ≡ y → y ≡ z → x ≡ z
≡-trans x .x .x (refl .x) (refl .x) = refl x


{----------- Part 8 -----------}
≡-leibniz : {A : Set} → (x y : A) → ({B : Set} → (f : A → B) → f x ≡ f y) → x ≡ y
≡-leibniz x y prf = prf (λ z → z)
