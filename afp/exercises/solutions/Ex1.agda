module Agda-1 where

data ⊤ : Set where
  ● : ⊤

data ⊥ : Set where

data _∧_ (A B : Set) : Set where
  _,_ : A → B → A ∧ B

infixl  6 _∧_

data _∨_ (A B : Set) : Set where
  inl : A → A ∨ B
  inr : B → A ∨ B

infixl 5 _∨_

P1 : {A : Set} → A → A
P1 a = a

P2 : {A B : Set} → A → (B → A)
P2 a _ = a

P3 : {A B C D : Set} → (A → B → C) → (A → B) → (A → C)
P3 f g a = f a (g a) 

¬ : Set → Set 
¬ A = A → ⊥

P4m : {A B : Set} → (A → B) → (A → ¬ B) → ¬ A
P4m f g a = g a (f a) 

P4i : {A : Set} → (A → ¬ A) → ¬ A
P4i f a = f a a 

enq : {A : Set} → ⊥ → A
enq ()

P5i : {A B : Set} → ¬ A → A → B
P5i f a = enq (f a)

CI : {A B : Set} → A → B → A ∧ B
CI a b = a , b

CEL : {A B : Set} → A ∧ B → A
CEL (a , _) = a

CER : {A B : Set} → A ∧ B → B
CER (_ , b) = b

DIL : {A B : Set} → A → A ∨ B
DIL a = inl a

DIR : {A B : Set} → B → A ∨ B
DIR b = inr b

DE : {A B C : Set} → (A → C) → (B → C) → A ∨ B → C
DE f _ (inl x) = f x
DE _ g (inr x) = g x

-- Classical Logic

postulate LEM : {A : Set} → A ∨ ¬ A

postulate DNE : {A : Set} → ¬ (¬ A) → A


-- Hilbert's style system
FR3 : {A B : Set} → (A → B) → (¬ B → ¬ A)
FR3 f = λ x → λ y → x (f y)

HL2 : {A B C : Set} → ( A → ( B → C )) → (B → (A → C))
HL2 f = λ b → λ a → f a b

HL3 : {A B C : Set} → (B → C) → ((A → B) → (A → C))
HL3 f = λ g → λ a → f (g a)

HL4 : {A B : Set} → A → (¬ A → B)
HL4 a = λ f → enq (f a)

HL5 : {A B : Set} → (A → B) → ((¬ A → B) → B)
HL5 f = λ g → DE f g LEM -- not constructive

-- Meredith's system
-- not constructive
M : {A B C D E : Set}
    → ((((A → B) → (¬ C → ¬ D)) → C) → E)
    → ((E → A) → (D → A))
M {A} {B} {C} {D} f g d with LEM {A}
... | inl a = a
... | inr na with LEM {C}
...   | inl c = g (f (λ _ → c))
...   | inr nc = g (f (λ h → enq (h (λ a → enq (na a)) nc d)))


-- DNI and TNE
DNI : {P : Set} → P → ¬ (¬ P)
DNI p = λ np → np p

TNE : {P : Set} → ¬ (¬ (¬ P)) → (¬ P)
TNE nnnp = λ p → nnnp (DNI p)


-- De Morgan's laws
DEM1 : {P Q : Set} → ¬ (P ∨ Q) → ¬ P ∧ ¬ Q
DEM1 f = CI (λ p → f (DIL p)) (λ q → f (DIR q))

DEM2 : {P Q : Set} → ¬ P ∧ ¬ Q → ¬ (P ∨ Q)
DEM2 f = λ prf → DE (CEL f) (CER f) prf

DEM3 : {P Q : Set} → ¬ P ∨ ¬ Q → ¬ (P ∧ Q)
DEM3 prf = DE (λ np → λ p∧q → np (CEL p∧q)) (λ nq → λ p∧q → nq (CER p∧q)) prf

DEM4 : {P Q : Set} → ¬ (P ∧ Q) → ¬ P ∨ ¬ Q
DEM4 prf = DE (λ p → DIR (λ q → prf (CI p q))) (λ np → DIL np) LEM -- not constructive


-- DNE ⇔ LEM
lem = {P : Set} → P ∨ ¬ P
dne = {P : Set} → (¬ (¬ P) → P)

DL1 : lem → dne
DL1 lem = λ f → DE (λ b → b) (λ nb → enq (f nb)) lem

DL2 : dne → lem
DL2 dne = dne (λ f → f (DIR (λ b → f (DIL b))))
-- here what I am proving is really "if ⊢ ¬ ¬ A → A then ⊢ A ∨ ¬ A" 
-- however it is not possible to prove "⊢ (¬ ¬ A → A) → A ∨ ¬ A" constructively
-- there is an interesting discussion on StackExchange:
-- https://math.stackexchange.com/questions/910240/equivalence-between-middle-excluded-law-and-double-negation-elimination-in-heyti


-- Peirce's law
peirce = {P Q : Set} → ((P → Q) → P) → P

PL1 : lem → peirce
PL1 lem = λ f → DE (λ p → p) (λ np → f (P5i np)) lem

PL2 : peirce → lem
PL2 pei = pei (λ f → DIR (λ p → f (DIL p)))

PD1 : dne → peirce
PD1 dne = λ f → dne (λ np → (np (f (λ p → enq (np p)))))

PD2 : peirce → dne
PD2 pei = λ nnp → pei (λ np → enq (nnp np))
