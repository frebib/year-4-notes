module Ex2 where

data List (A : Set) : Set where
  [] : List A
  _∷_ : A → List A → List A

_++_ : {A : Set} → List A → List A → List A
[] ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

data Bool : Set where
  true : Bool
  false : Bool

data Ok : Bool → Set where
  ok : Ok true

eq-len-ck : {A : Set} → (xs ys : List A) → Bool
eq-len-ck [] [] = true
eq-len-ck (x ∷ xs) (y ∷ ys) = eq-len-ck xs ys
eq-len-ck _ _ = false

data eq-len-pv {A : Set} : (xs ys : List A) → Set where
  []-eq-len : eq-len-pv [] []
  ::-eq-len : (x y : A) → (xs ys : List A) → eq-len-pv xs ys →
              eq-len-pv (x ∷ xs) (y ∷ ys)

++[]-ck : {A : Set}(xs : List A) → Ok (eq-len-ck xs (xs ++ []))
++[]-ck [] = ok
++[]-ck (x ∷ xs) = ++[]-ck xs

++[]-pv : {A : Set}(xs : List A) → eq-len-pv xs (xs ++ [])
++[]-pv [] = []-eq-len
++[]-pv (x ∷ xs) = ::-eq-len x x xs (xs ++ []) (++[]-pv xs)

++-ck : {A : Set}(xs ys xs' ys' : List A) →
        Ok (eq-len-ck xs ys) → Ok (eq-len-ck xs' ys') →
        Ok (eq-len-ck (xs ++ xs') (ys ++ ys'))
++-ck [] [] xs' ys' p p' = p'
++-ck [] (x ∷ ys) xs' ys' ()
++-ck (x ∷ xs) [] xs' ys' ()
++-ck (x ∷ xs) (x₁ ∷ ys) xs' ys' p p' = ++-ck xs ys xs' ys' p p'

++-pv : {A : Set}(xs ys xs' ys' : List A) →
        eq-len-pv xs ys → eq-len-pv xs' ys' →
        eq-len-pv (xs ++ xs') (ys ++ ys')
++-pv .[] .[] .[] .[] []-eq-len []-eq-len = []-eq-len
++-pv .[] .[] .(x ∷ xs) .(y ∷ ys) []-eq-len (::-eq-len x y xs ys p') = ::-eq-len x y xs ys p'
++-pv .(x ∷ xs) .(y ∷ ys) .[] .[] (::-eq-len x y xs ys p) []-eq-len = ::-eq-len x y (xs ++ []) (ys ++ []) (++-pv xs ys [] [] p []-eq-len)
++-pv .(x ∷ xs) .(y ∷ ys) xs' ys' (::-eq-len x y xs ys p) p' = ::-eq-len x y (xs ++ xs') (ys ++ ys') (++-pv xs ys xs' ys' p p')

data _≡_ {A : Set} : A → A → Set where
  refl : {a : A} → a ≡ a

leibniz₀ : {A B : Set} → (a b : A) → a ≡ b → (f : A → B) → f a ≡ f b
leibniz₀ a .a refl f = refl
leibniz₁ : {A : Set} → (a b : A) → ({B : Set} (f : A → B) → f a ≡ f b) → a ≡ b
leibniz₁ a b f = f (λ x → x)
