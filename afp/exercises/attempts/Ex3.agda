module Ex3 where

data _≡_ {A : Set} : A → A → Set where
  refl : {a : A} → a ≡ a
infix 5 _≡_

cong : {A B : Set}{a₀ a₁ : A} → (f : A → B) → a₀ ≡ a₁ → f a₀ ≡ f a₁
cong f refl = refl

trans : {A : Set}{a b c : A} → a ≡ b → b ≡ c → a ≡ c
trans refl refl = refl

sym : {A : Set}{a b : A} → a ≡ b → b ≡ a
sym refl = refl

data Nat : Set where
  zero : Nat
  succ : Nat → Nat
_+_ : Nat → Nat → Nat
zero + m = m
succ n + m = succ (n + m)

record Monoid (A : Set) (id : A) (op : A → A → A) : Set where
  field
    op-a-id : {a : A} → op a id ≡ a
    op-id-a : {a : A} → op id a ≡ a

nat-+-monoid : Monoid Nat zero _+_
nat-+-monoid = record { op-a-id = +zero ; op-id-a = zero+ } where
  +zero : {n : Nat} → (n + zero) ≡ n
  +zero {zero} = refl
  +zero {succ n} = cong succ +zero
  zero+ : {n : Nat} → (zero + n) ≡ n
  zero+ = refl

record ComMonoid (A : Set) (id : A) (op : A → A → A) : Set where
  open Monoid public
  field
    monoid : Monoid A id op
    com : (a b : A) → op a b ≡ op b a

nat-+-com-monoid : ComMonoid Nat zero _+_
nat-+-com-monoid = record { monoid = nat-+-monoid ; com = nat-com } where
  nat-com : (a b : Nat) → a + b ≡ b + a
  nat-com a zero = Monoid.op-a-id nat-+-monoid
  nat-com a (succ b) = trans (p₀ a b) (cong succ (nat-com a b)) where
    p₀ : (a b : Nat) → a + succ b ≡ succ (a + b)
    p₀ zero b = refl
    p₀ (succ a) b = cong succ (p₀ a b)

data Int : Set where
  int : (+ve -ve : Nat) → Int
₀ = int zero zero

_+ᵢ_ : Int → Int → Int
int i+ i- +ᵢ int j+ j- = int (i+ + j+) (i- + j-)

_-ᵢ_ : Int → Int → Int
int i+ i- -ᵢ int j+ j- = int (i+ + j-) (i- + j+)

normalize : Int → Int
normalize (int (succ +ve) (succ -ve)) = normalize (int +ve -ve)
normalize i = i
_+ₙ_ : Int → Int → Int
i +ₙ j = normalize (i +ᵢ j)
_-ₙ_ : Int → Int → Int
i -ₙ j = normalize (i -ᵢ j)

cong2 : {A B C : Set}{a₀ a₁ : A}{b₀ b₁ : B} →
        (f : A → B → C) → a₀ ≡ a₁ → b₀ ≡ b₁ →
        f a₀ b₀ ≡ f a₁ b₁
cong2 f refl refl = refl

int-eq : {i+ i- j+ j- : Nat} → i+ ≡ j+ → i- ≡ j- → int i+ i- ≡ int j+ j-
int-eq p+ p- = cong2 int p+ p- where

data Σ (A : Set) (B : A → Set) : Set where
  _,_ : (a : A) → (b : B a) → Σ A B

syntax Σ A (λ y → B) = ∃[ y of A ] B

record Abelian (A : Set) (id : A) (op : A → A → A) : Set where
  open ComMonoid
  field
    com-monoid : ComMonoid A id op
    inverse₀ : (a : A) → ∃[ inv of A ] (op a inv ≡ id)
    inverse₁ : (a : A) → ∃[ inv of A ] (op inv a ≡ id)

int-+-monoid : Monoid Int ₀ _+ᵢ_
int-+-monoid = record { op-a-id = +zero ; op-id-a = zero+ } where
  +zero : {i : Int} → i +ᵢ ₀ ≡ i
  +zero {int +ve -ve} = int-eq (Monoid.op-a-id nat-+-monoid) (Monoid.op-a-id nat-+-monoid)
  zero+ : {i : Int} → ₀ +ᵢ i ≡ i
  zero+ {int +ve -ve} = refl

int-+-com-mon : ComMonoid Int ₀ _+ᵢ_
int-+-com-mon = record { monoid = int-+-monoid ; com = int-com } where
  int-com : (i j : Int) → i +ᵢ j ≡ j +ᵢ i
  int-com (int i+ i-) (int j+ j-) =
    int-eq (ComMonoid.com nat-+-com-monoid i+ j+) (ComMonoid.com nat-+-com-monoid i- j-)

int-+-abelian : Abelian Int ₀ _+ᵢ_
int-+-abelian = record { com-monoid = int-+-com-mon ; inverse₀ = int-inv₀ ; inverse₁ = {!!} } where
  int-inv₀ : (i : Int) → ∃[ inv of Int ] (i +ᵢ inv ≡ ₀)
  int-inv₀ (int +ve -ve) = int -ve +ve , proof where
    proof : int (+ve + -ve) (-ve + +ve) ≡ int zero zero
    proof = {!!}

record SemiRing (A : Set)
                (+id : A) (+op : A → A → A)
                (*id : A) (*op : A → A → A) : Set where
  open Monoid
  open ComMonoid
  field
    +com-monoid : ComMonoid A +id +op
    *monoid : Monoid A *id *op
    dist₀ : (a b c : A) → *op a (+op b c) ≡ +op (*op a b) (*op a c)
    dist₁ : (a b c : A) → *op (+op a b) c ≡ +op (*op a c) (*op b c)
    annih₀ : (a : A) → *op a +id ≡ +id
    annih₁ : (a : A) → *op +id a ≡ +id

_*_ : Nat → Nat → Nat
zero * m = zero
succ n * m = m + (n * m)

nat-*-monoid : Monoid Nat (succ zero) _*_
nat-*-monoid = record { op-a-id = n*one ; op-id-a = one*n } where
  n*one : {n : Nat} → n * (succ zero) ≡ n
  n*one {zero} = refl
  n*one {succ n} = cong succ n*one
  one*n : {n : Nat} → (succ zero) * n ≡ n
  one*n {zero} = refl
  one*n {succ n} = cong succ one*n

nat-semi-ring : SemiRing Nat zero _+_ (succ zero) _*_
nat-semi-ring = record
                  { +com-monoid = nat-+-com-monoid
                  ; *monoid = nat-*-monoid
                  ; dist₀ = nat-dist₀
                  ; dist₁ = nat-dist₁
                  ; annih₀ = n*zero
                  ; annih₁ = zero*n
                  } where

  nat-dist₀ : (a b c : Nat) → a * (b + c) ≡ (a * b) + (a * c)
  nat-dist₀ zero b c = refl
  nat-dist₀ (succ a) b c = goal where
    p₀ : (a b c d : Nat) → (a + b) + (c + d) ≡ (a + c) + (b + d)
    p₀ zero b c d = goal₀ b c d where
      goal₀ : (a b c : Nat) → (a + (b + c)) ≡ (b + (a + c))
      goal₀ zero b c = refl
      goal₀ (succ a) b c = trans p₀₁ (p₀₀ b (a + c)) where
        p₀₀ : (a b : Nat) → succ (a + b) ≡ a + succ b
        p₀₀ zero b = refl
        p₀₀ (succ a) b = cong succ (p₀₀ a b)
        p₀₁ : succ (a + (b + c)) ≡ succ (b + (a + c))
        p₀₁ = cong succ (goal₀ a b c)
    p₀ (succ a) b c d = cong succ (p₀ a b c d)
    p₁ : (b + c) + (a * (b + c)) ≡ (b + c) + ((a * b) + (a * c))
    p₁ = cong (λ n → (b + c) + n) (nat-dist₀ a b c)
    goal : ((b + c) + (a * (b + c))) ≡ ((b + (a * b)) + (c + (a * c)))
    goal = trans p₁ (p₀ b c (a * b) (a * c))

  nat-dist₁ : (a b c : Nat) → (a + b) * c ≡ (a * c) + (b * c)
  nat-dist₁ zero b c = refl
  nat-dist₁ (succ a) b c = trans p₁ (sym (p₀ c (a * c) (b * c))) where
    p₀ : (a b c : Nat) → (a + b) + c ≡ a + (b + c)
    p₀ zero b c = refl
    p₀ (succ a) b c = cong succ (p₀ a b c)
    p₁ : c + ((a + b) * c) ≡ c + ((a * c) + (b * c))
    p₁ = cong (λ n → c + n) (nat-dist₁ a b c)

  n*zero : (n : Nat) → n * zero ≡ zero
  n*zero zero = refl
  n*zero (succ n) = n*zero n
  zero*n : (n : Nat) → zero * n ≡ zero
  zero*n n = refl
