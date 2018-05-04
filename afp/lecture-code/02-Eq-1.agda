 
module Eq where

data Nat : Set where
  zero : Nat
  suc  : Nat → Nat

_+_ : Nat → Nat → Nat
zero + n = n
suc m + n = suc (m + n)
infixl 5 _+_

₀ = zero
₁ = suc zero
₂ = ₁ + ₁
₄ = ₂ + ₂ 

{-
  PROOF VS. VERIFICATION            
  A subtle but important distinction
-}

-- The set of Booleans
data Bool : Set where
  true  : Bool
  false : Bool 

-- VERIFY whether two Nats are equal
check-eq : Nat → Nat → Bool
check-eq zero    zero    = true
check-eq (suc m) (suc n) = check-eq m n 
check-eq _       _       = false

-- A type that corresponds to a value !
data istrue : Bool → Set where                   
  ok : istrue true
-- OBS: value used in type definition

-- Alternative: construct a PROOF that two Nats are equal
data prove-eq : Nat → Nat → Set where
  zero-eq : prove-eq zero zero
  succ-eq : (m n : Nat) → prove-eq m n → prove-eq (suc m) (suc n)
                                                  
-- Exercise: Check that zero is a right-identity for +
zero-rid+ck : ∀ n → istrue (check-eq (n + zero) n)
zero-rid+ck zero    = ok
zero-rid+ck (suc n) = zero-rid+ck n
{-
 Obs:
 ‣ notation ∀ m → instead of (m : Nat) → 
 ‣ variables declared and used in function declaration
 ‣ terminating recursion / 'induction'
-}

-- Example: checking this fact for ₂ = suc (suc zero)
ex-ci : istrue (check-eq (₂ + ₀) ₂)
ex-ci = zero-rid+ck ₂ -- = ok if ^C^N

-- Exercise: prove that zero is a right-identity for +
zero-rid+pv : ∀ n → prove-eq (n + zero) n
zero-rid+pv zero    = zero-eq
zero-rid+pv (suc n) = succ-eq (n + zero) n (zero-rid+pv n)

-- Example: proving this fact for ₂
ex-pi : prove-eq (₂ + ₀) ₂
ex-pi = zero-rid+pv ₂
-- = succ-eq (suc zero) (suc zero) (succ-eq zero zero zero-eq)

{-
 OBS: A proof is more informative.
 It explains 'why' whereas a check only says 'what'.
 Lets see how 'checked' vs 'proved' equalities work out. 
 Exercise: Equality is an equivalence (reflexive, symmetric, transitive).
-}

refl-eq-pv : ∀ n → prove-eq n n
refl-eq-pv zero    = zero-eq
refl-eq-pv (suc n) = succ-eq _ _ (refl-eq-pv n) 

refl-eq-ck : ∀ n → istrue (check-eq n n)
refl-eq-ck zero    = ok
refl-eq-ck (suc n) = refl-eq-ck n 

sym-eq-pv : ∀ m n → prove-eq m n → prove-eq n m
sym-eq-pv  _       _        zero-eq         = zero-eq
sym-eq-pv (suc .m) (suc .n) (succ-eq m n x) = succ-eq n m (sym-eq-pv m n x)
{-
 OBS:
 ‣ pattern-match on proof term
 ‣ multiple occurrences of a variable in a pattern using .
 ‣ termination and coverage checking in Agda are complex
-}

sym-eq-ck : ∀ m n → istrue (check-eq m n) → istrue (check-eq n m)
sym-eq-ck zero    zero    _ = ok
sym-eq-ck zero    (suc n) ()
sym-eq-ck (suc m) zero    ()
sym-eq-ck (suc m) (suc n) x = sym-eq-ck m n x

trans-eq-pv : ∀ m n p → prove-eq m n → prove-eq n p → prove-eq m p
trans-eq-pv zero      zero     zero    zero-eq         zero-eq
  = zero-eq
trans-eq-pv (suc .m) (suc .n) (suc .p) (succ-eq m n x) (succ-eq .n p y)
  = succ-eq _ _ (trans-eq-pv m n p x y) 

trans-eq-ck : ∀ m n p → istrue (check-eq m n)
                      → istrue (check-eq n p)
                      → istrue (check-eq m p)
trans-eq-ck zero    zero    _       _  y = y
trans-eq-ck zero    (suc n) p       () _
trans-eq-ck (suc m) zero    p       () _
trans-eq-ck (suc m) (suc n) zero    _  ()
trans-eq-ck (suc m) (suc n) (suc p) x  y = trans-eq-ck m n p x y 
{-
 Obs:
 With 'proofs' we can pattern-match the proof and only consider
 cases for which the proof holds.
 Agda can have multiple occurrences of variables in a pattern using '.x'.
 With 'checks' we cannot pattern-match the (trivial) check.
 So we must pattern-match the arguments.
 This leads to more cases. Agda pattern-match exhaustiveness checking helps.
-}

{- LECTURE TWO -}

{-
  OBS: How do we know we have the 'right' notion of equality? This is a
  rather philosophical question. We can show that the two definitions 
  coincide, as a sanity check (see below) but we can also try to show that
  the definitions meet other properties of equality, such as the Leibniz
  axioms. Informally, they are

  ∀ m n ∀ P. m = n ↔ P (m) = P (n)
  
  However, we only have equality at Nat. So lets try that!
-}

cong-eq-pv : ∀ m n → (f : Nat → Nat) → prove-eq m n → prove-eq (f m) (f n)
cong-eq-pv .zero .zero f zero-eq = refl-eq-pv (f zero)
-- We need to produce data of type 'prove-eq (f zero) (f zero)'
cong-eq-pv .(suc m) .(suc n) f (succ-eq m n p) = cong-eq-pv m n g p 
  where
  g : Nat → Nat
  g x = f (suc x)
{- Comment on the proof:
   m, n : Nat
   f : Nat → Nat 
   p : prove-eq m n   
   succ-eq m n p : prov-eq (suc m) (suc n) ... Note this is not inductively on m or n 
   We need to prove (construct) prove-eq (f (suc m)) (f (suc n)).
   This is going to be a proof by induction with inductive call
   conge-eq-pv m n g? p
   Note that even though we made an induction on the proof-term, the inductive call 
   is on m and n. This is ok, both pattern coverage and termination check succeed, 
   but for different reasons.
   The trick here is to find the function g?
   Looking at the type that we need to prove/construct, we need a function that 
   would lead to f (suc m) and f(suc n)... that function is 
   g? = λ z → f (suc z).
   QED
-}

cong-eq-ck : ∀ m n → (f : Nat → Nat)
                   → istrue (check-eq m n)
                   → istrue (check-eq (f m) (f n))
cong-eq-ck zero zero f p = refl-eq-ck (f zero)
cong-eq-ck zero (suc n) f ()
cong-eq-ck (suc m) zero f ()
cong-eq-ck (suc m) (suc n) f p = cong-eq-ck m n (λ z → f (suc z)) p 

Leibniz-eq-pv : ∀ m n → ((f : Nat → Nat) → prove-eq (f m) (f n)) → prove-eq m n
Leibniz-eq-pv m n p = p (λ z → z)
-- We only need to find an instance of p. Identity does it.

Leibniz-eq-ck : ∀ m n
  → ((f : Nat → Nat) → istrue (check-eq (f m) (f n)))
  → istrue (check-eq m n)
Leibniz-eq-ck m n p = p (λ z → z) 

{- 
  OBS:
  This is a weak form of axioms since we only have equality at Nat.
-}

{-
======================================================================
==           SOUNDNESS AND COMPLETENESS THEOREMS                    == 
======================================================================
-}

-- "Theorem"
-- In general, if we have a proof, then equality should check ('soundness')
sound-eq : ∀ m n → prove-eq m n → istrue (check-eq m n)
sound-eq _   _ zero-eq         = ok
{- Explanation: 
   We are using induction on the third argument, which is a 'proof term.'
   In the case zero-eq : prove-eq zero zero it follows that the first
   two arguments can be inferred as m = n = zero. 
   We need the function to produce a term of type istrue (check-eq zero zero),
   which is the same as a term of type (istrue true).
   The type (istrue true) is inhabited by 'ok'. 
-}
sound-eq ._ ._ (succ-eq m n p) = sound-eq m n p
{-
  Explanation:
  The second inductive case is succ-eq m n p : prove_eq (suc m) (suc n)
  (Looking at the type of the thrid argument it follows that the first argument 
  must be 'suc m' and the second 'suc n'. Since they can be safely inferred,
  we can use '._' for the argument which means, roughly speaking, 'the safely
  inferred argument'. If there is no safely inferrable argument then the '._'
  will be hightlighted in yellow.)
  So it means that we need to produce a term of type istrue (check-eq (suc m) (suc n), 
  which simplifies, by executing the function check-eq, to istrue check-eq m n 
  This is the same type as 'sound-eq m n p', so we use that. 
  Agda makes sure that this is a terminating call.
-}

-- "Theorem"
-- In general, if equality checks out, then we should be able to prove it
-- ('completeness')
compl-eq : ∀ m n → istrue (check-eq m n) → prove-eq m n
compl-eq zero    zero    ok = zero-eq              
compl-eq (suc m) (suc n) q = succ-eq m n (compl-eq m n q)
compl-eq zero    (suc n) ()                       
compl-eq (suc m) zero    ()
{-
 OBS: 
 pattern-match on Nats
 q : istrue (check-eq m n)
 impossible patterns
 '_' on the RHS stands for 'inferred argument'
     If it cannot be inferred then Agda will highlight it in yellow
-}

-- We can construct a proof of equality by 'running the theorem'
ex-peq : prove-eq (suc (suc zero)) (suc (suc zero))
ex-peq = compl-eq (suc (suc zero)) (suc (suc zero)) ok
-- = succs (suc zero) (suc zero) (succs zero zero zeros)

----------------------------------
-- A GENERAL NOTION OF EQUALITY --
----------------------------------

data List (A : Set) : Set where
  nil  : List A
  _∷_  : (x : A) → List A → List A

infixr 4 _∷_

-- Example of function on lists, 'length'
length : {A : Set} → List A → Nat
length nil      = zero
length (a ∷ as) = suc (length as)

-- Example of list, lenght of a list
ex-l : List Nat
ex-l = ₀ ∷ ₁ ∷ ₄ ∷ nil

ex-len = length ex-l

{-
LAB EXERCISES 
 0. Write an append function on lists
 1. Write a function that checks two lists have the same length
 2. Write a data-type of proofs that two lists have the same length
 3. Check/prove that appending nil preserves the length
 4. Check/prove that appending lists with the same length preserves length
 5. Prove soundness and completeness of of checking/proving same-length
-}

{-
 OBS: In general we cannot use the same strategy to check
      whether two lists are equal!

 list-eq-ck : {A : Set} → List A → List A → Bool
 list-eq-ck nil      nil      = true
 list-eq-ck (x ∷ xs) (y ∷ ys) = What if A is a non-decidable type,
                                e.g. a function?
 list-eq-ck _        _        = false

 … but we can construct a proof that two lists are equal.
 Even better, we can construct a proof that any two things are equal
 … if they are identical!
-}

-- The EQUALITY TYPE
data _≡_ {A : Set} : A → A → Set where
  refl : (x : A) → x ≡ x

infix 0 _≡_

-- How does ≡ compare to prove-eq for Nats?

prove-eq⇒≡ : ∀ m n → prove-eq m n → m ≡ n
prove-eq⇒≡ zero zero zero-eq        = refl zero
prove-eq⇒≡ ._   ._  (succ-eq m n x) = suc≡ m n (prove-eq⇒≡ m n x)
  where
  suc≡ : ∀ m n → m ≡ n → suc m ≡ suc n
  suc≡ .m .m (refl m) = refl (suc m)
-- OBS: Induction on ≡ has only one case (one constructor)
--      A Lemma will be required: suc preserves ≡

≡⇒prove-eq : ∀ m n → m ≡ n → prove-eq m n
≡⇒prove-eq .m .m (refl m) = refl-eq-pv m  
{-
 OBS:
 So ≡ is equivalent to prove-eq, but more convenient due to more generality,
 more succinct.
 This is what we will use from now on for all equalities!
-}

{-
EXERCISES FOR THE LAB
 6. Re-do exercises 3 and 4 above using ≡ instead.
 7. Prove reflexivity, symmetry and transitivity of ≡
 8. Prove the Leibniz axioms for ≡
-}

