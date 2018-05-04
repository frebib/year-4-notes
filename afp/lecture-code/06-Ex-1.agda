module Ex where

open import AFP

{--------------------------------------------------------
== Week 6 : Existentials quantifier and depenent pairs ==
---------------------------------------------------------}

-- Remember the isomorphism ∧ ∼ × 
data _×_ (A : Set) (B : Set) : Set where
  _,_ : A → B → A × B

infixl 3 _×_

-- A generalised version of pairs : 'dependent' pairs
-- The second projection type depends on the first projection type
-- We have already seen 'dependent' types in 'inject'
data Σ (A : Set) (B : A → Set) : Set where
  _,_ : (a : A) → (b : B a) → Σ A B

infixr 4 _,_

-- Σ generalises ×
const : (A B : Set) → Set → (A → Set)
const A B C _ = C

to× : {A B : Set} → Σ A (const A B B) → A × B 
to× (a , b) = a , b 

toΣ : {A B : Set} → A × B → Σ A (const A B B)
toΣ (a , b) = a , b 

-- Σ generalises disjoint union ⊎
If_then_else_ : Bool → Set → Set → Set
If true  then A else B = A
If false then A else B = B

-- remember the isomorphism ∨ ∼ ⊎
data _⊎_ (A B : Set) : Set where
  inl : (x : A) → A ⊎ B
  inr : (x : B) → A ⊎ B

to⊎ : {A B : Set} → A ⊎ B → Σ Bool (λ b → If b then A else B)
to⊎ (inl x) = true , x
to⊎ (inr x) = false , x 

toΣ' : {A B : Set} → Σ Bool (λ b → If b then A else B) → A ⊎ B 
toΣ' (true , x) = inl x
toΣ' (false , x) = inr x 
-- OBS: The ⊎ data type is akin to a 'manual' sum type
--      where the tag is a Bool value rather than a type constructor

-- Some examples
x1 : Σ Bool (λ b → If b then Nat else (Bool → Bool))
x1 = true , ₁
x2 : Σ Bool (λ b → If b then Nat else (Bool → Bool))
x2 = false , (λ b → if b then false else true) 

{-- To conclude:

    * Σ is an extremely powerful construct which generalises ∧ and ∨
    * Σ also generalises existential quantifiers
    * Σ can also make dependent data types (e.g. BST) easier to work with
    * Σ is perhaps the MOST IMPORTANT derived concept in Agda
      (It is 'derived' because it requires no language extension.)
--}

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

-- A quick look at Hilbert-style Axioms for ∃
-- ∀x(P→∃y(P[x:=y]))
∃I : {A : Set} {P : A → Set} → (x : A) → P x → ∃[ y ∶ A ] P y 
∃I x p = x , p 

-- A=⊥ leads to contradiction
∄I : {P : ⊥ → Set} → (x : ⊥) → P x → ∃[ y ∶ ⊥ ] P y → ⊥
∄I ()
-- OBS: This is a consequence / illustration of untyped vs typed quantifiers

-- ∀x(P→Q)→∃x(P)→Q
∃E : {A : Set} {P Q : A → Set} → ((x : A) → (P x → Q x)) → (p : ∃[ x ∶ A ] (P x)) → Q (witness p)
∃E {A} {P} {Q} f (x0 , p0) = f x0 p0 

{-- EXAMPLE : An alternative formulation of m ≤p n ∼ Σ Nat (λ k → m + k ≡ n) = ∃[ k : Nat ] m + k ≡ n
    READING : There is a k such that m + k ≡ n --}

p :  ∃[ k ∶ Nat ]  (k + zero ≡ suc zero)
p = (suc zero) , (refl (suc zero))

-- Soundness and Completeness 

-- (interactive)
∃to≤ : ∀ m n →  ∃[ k ∶ Nat ]  (m + k ≡ n) → m ≤p n
∃to≤ m .(m + k) (k , refl .(m + k)) = lem m k where
  lem : ∀ m k → m ≤p (m + k)
  lem zero k = zero≤p k
  lem (suc m) k = suc≤p m (m + k) (lem m k) 

-- (interactive)
≤to∃ : ∀ m n → m ≤p n → ∃[ k ∶ Nat ]  (m + k ≡ n)
≤to∃ zero n (zero≤p .n) = n , refl n 
≤to∃ (suc m) .(suc n) (suc≤p .m n q) = k , (cong≡ suc (proof IH)) where
  IH : ∃[ k ∶ Nat ]  (m + k ≡ n)
  IH = ≤to∃ m n q
  k : Nat
  k = witness IH

{-- EXAMPLE : Index with Membership check --}

data _∈_ {A : Set}(x : A) : List A → Set where
  first : {xs : List A} → x ∈ (x ∷ xs)
  next  : {y : A}{xs : List A} → x ∈ xs → x ∈ (y ∷ xs)

infix 4 _∈_

ex∈ : false ∈ (true ∷ false ∷ nil)
ex∈ = next first 

-- A standard implementation of the nth element of a list
_▸_ : {A : Set} → List A → Nat → Maybe A
nil      ▸ _       = nothing
(x ∷ as) ▸ zero    = some x
(_ ∷ as) ▸ (suc n) = as ▸ n 

-- An enhanced 'lookup' function which
--   a) is guaranteed not to fail (Agda)
--   b) does not require a Maybe monad
--   c) requires membership proof
--   d) returns location along with proof of correctness

-- (interactive)
lookup : {A : Set} → (x : A)(xs : List A) → x ∈ xs → ∃[ k ∶ Nat ]  (xs ▸ k ≡ some x)
lookup x .(x ∷ _) first = zero , refl (some x)
lookup x .(_ ∷ _) (next p) = suc (witness (lookup x _ p)) , proof (lookup x _ p) 

{-- Relations vs. functions --}

data Sum : (List Nat) → Nat → Set where 
  SumNil : Sum nil zero 
  SumElm : ∀ m → Sum (m ∷ nil) m
  Sum++  : ∀ m n xs ys → Sum xs m → Sum ys n → Sum (xs ++ ys) (m + n) 

exSum : Sum nil zero
exSum = Sum++ zero zero nil nil SumNil SumNil

-- Sum is a total relation
Sum∃ : ∀ xs → ∃[ k ∶ Nat ] Sum xs k
Sum∃ nil = zero , SumNil
Sum∃ (x ∷ xs) = x + (witness IH) , Sum++ x (witness IH) (x ∷ nil) xs (SumElm x) (proof IH) where 
  IH : Σ Nat (λ k → Sum xs k)
  IH = Sum∃ xs 

-- But is it a deterministic relation?
Sum! : ∀ xs m n → Sum xs n → Sum xs m → m ≡ n
Sum! .nil m .zero SumNil q = {!!}
Sum! .(n ∷ nil) m n (SumElm .n) q = {!!}
Sum! .(xs ++ ys) m₁ .(m + n) (Sum++ m n xs ys p₁ p₂) q = {!!} 

lem-sum : ∀ m → Sum nil m → m ≡ zero
lem-sum zero p = refl zero
lem-sum (suc m) p = {!p!}

-- A direct proof is a challenging
-- Hint: You need to formulate your own inductive principle on Sum.
--       In general, this is a challenging task.
--       Local experts: Noam Zeilberger, Martin Escardo, Benedikt Ahrents

ind-sum : (P : (m : Nat) → (xs : List Nat) → Sum xs m → Set) →
             P zero nil SumNil →
             (∀ m → P m (m ∷ nil) (SumElm m)) →
             (∀ m n xs ys p q → P m xs p → P n ys q → P (m + n) (xs ++ ys) (Sum++ m n xs ys p q)) →
             ∀ m xs (p : Sum xs m)
           → P m xs p
ind-sum P p0 p1 p+ .zero .nil SumNil = p0
ind-sum P p0 p1 p+ m .(m ∷ nil) (SumElm .m) = p1 m
ind-sum P p0 p1 p+ .(m + n) .(xs ++ ys) (Sum++ m n xs ys p p₁) = p+ m n xs ys p p₁ (ind-sum P p0 p1 p+ m xs p) (ind-sum P p0 p1 p+ n ys p₁)

-- OBS: The formulation of the property matters!
P : (m : Nat) → (xs : List Nat) → Sum xs m → Set 
P m xs _ = xs ≡ nil → m ≡ zero
-- As formulated earlier (lem-sum) not general enough (because no mention of xs)
-- (It took some trial and error then Noam solved it.)

lemma0 : ∀ m n → m ≡ zero → n ≡ zero → (m + n) ≡ zero
lemma0 .zero .zero (refl .zero) (refl .zero) = refl zero 

lemma1 : {A : Set} (xs ys : List A) → (xs ++ ys) ≡ nil → xs ≡ nil
lemma1 nil .nil (refl .nil) = refl nil
lemma1 (x ∷ xs) ys ()
  
lemma2 : {A : Set} (xs ys : List A) → (xs ++ ys) ≡ nil → ys ≡ nil
lemma2 nil .nil (refl .nil) = refl nil
lemma2 (x ∷ xs) ys () 

lemsum : ∀ m xs p → P m xs p
lemsum m xs p = goal  where
  p0 : P zero nil SumNil
  p0 = λ _ → refl zero

  p1 : (∀ m → P m (m ∷ nil) (SumElm m))
  p1 m ()

  p+ : (∀ m n xs ys p  q → P m xs p → P n ys q → P (m + n) (xs ++ ys) (Sum++ m n xs ys p q))
  p+      m n xs ys p1 p2  q1         q2       = λ r → lemma0 m n (q1 (lemma1 xs ys r)) (q2 (lemma2 xs ys r))
  -- r  : xs ++ ys ≡ nil
  -- Goal: m + n ≡ zero

  goal : xs ≡ nil → m ≡ zero
  goal q = ind-sum P p0 p1 p+ m xs p q

-- Our original formulation follows
lem-sum' : ∀ m → Sum nil m → m ≡ zero
lem-sum' m p = lemsum m nil p (refl nil)

-- A comment on the mathematical method:
--    * definitions sometimes matter more than proofs!
--    * finding the right definitions is a matter of design (no 'right' and 'wrong', but 'useful' vs. 'useless')
--    * good mathematics is a lot like good software architecture

{- 
A concluding quote from Eugenia Cheng:

Brouwer believed that a construction can never be perfectly communicated by verbal or
symbolic language; rather it’s a process within the mind of an individual mathematician.
What we write down is merely a language for communicating something to other mathematicians,
in the hope that they will be able to reconstruct the process within their own
mind. When I’m doing maths I often feel like I have to do it twice—once, morally in my head.
And then once to translate it into communicable form. The translation is not a trivial process
-}

-- OBS: The proof of Sum! is left as exercise (hard)



















