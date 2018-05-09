# Cryptography

## What is Cryptography? (26/09/2017)

> Converting plain-text (or data) to an undecipherable text

_Encryption is essential for communication on the internet as it provides
confidentiality and integrity_

## Pre-modern Cryptography

### Kinds of cryptography
- **Transposition:** permutes components of a message
- **Substitution:** replacing components via
  - **Codes:** algorithms for substitution of entire words
  - **Ciphers:** algorithms substituting bits, bytes or blocks

### Transposition cipher
Example: _rail fence cipher_
- **Key:** column size (height)
- **Enc:** arrange message in columns of fixed size. Add dummy text to fill the
  last column. Cipher text is rows read left to right
- **Dec:** calculate row size by dividing message length by key. Arrange message
  in rows to decrypt.

**Security**
- Not secure. Message of size _n_, there are at most n possibilities for
  the key.

### Security Game
**Parties:**
- Attacker(A): Aims to obtain plaintext for a given ciphertext
- Challenger(C): Provides the challenge for an attacker

**Moves of the game:**
1. C selects message length _n_ and chooses key _k_
2. C chooses message _m_ and sends encrypted message Enc<sub>k</sub>(_m_) to A
3. A does some computation and outputs a message

- A wins the game if A's output is essentially the same as _m_
- A has probability of at least 1/n of winning the game for any message
- Protocol is insecure

### Permutations
> A re-arrangement of an ordered list of elements with a 1-1 correspondence
  of itself.

Two notations are used for 1,2,3 -> 2,3,1:
- **Array notation:** ![](https://i.imgur.com/f9yM8HM.png)
  * Re-ordered list below the original
- **Cycles:**
  - Apply permutation to 1 and note 1 and result
  - Repeat permutation for result until reaching initial number
  - E.g. 1,2,3,4,5 -> 3,5,1,2,4 = (1,3) (2,5,4)

#### Operations on permutations
- **Identity** maps any number to itself
- Two permutations can be **composed**, resulting in another permutation
  - E.g. 1,2,3 -> 2,1,3 composed with 1,2,3 -> 3,2,1 = 1,2,3 -> 3,1,2
  - See explanation [here](https://math.stackexchange.com/questions/549186/the-product-or-composition-of-permutation-groups-in-two-line-notation#549191)
- **Inverse** of permutation _s_ is permutation _t_, such that _s_ composed
  with _t_ is the identity

#### Monoalphabetic substitution cipher
- **Key:** permutation of the alphabet
- **Encryption:** Apply permutation
- **Decryption:** Apply inverse permutation

**Security**
- Lots of possible keys but vulnerable to frequency analysis

## Modern Cryptography

### Modular arithmetic
- Numbers _a_ and _b_ are congruent modulo _n_ (written a ≡ b(mod n))
  , if _a_ - _b_ is divisible by _n_
- If 0 <= a <= n, write [a]<sub>n</sub> as residue class of _a_ modulo _n_,
  for set of all _b_ where a ≡ b(mod n)
  * Essentially a set of all possible values modulo _n_
- Arithmetic on residue classes:
  * [a]<sub>n</sub> + [b]<sub>n</sub> = [c]<sub>n</sub>
    if (a + b) ≡ c(mod n)
  * [a]<sub>n</sub> − [b]<sub>n</sub> = [c]<sub>n</sub>
    if (a − b) ≡ c(mod n)
  * [a]<sub>n</sub> ∗ [b]<sub>n</sub> = [c]<sub>n</sub>
    if (a ∗ b) ≡ c(mod n)

### Probability
- Always a chance of getting the correct key from guesswork
- We want very low probabilities of guessing a key
- Probability distribution P is a function such that the sum of all possible
  events through P = probability 1
- Uniform distribution is function P where probability = 1/(no. events)


- Let P : U → [0, 1] be a probability distribution.
  - An event A is a subset of U (U being a finite set).
  - The probability of an event A, written P[A], is defined as:
    ![](https://i.imgur.com/daavv76.png)

### Bitstrings
- Write {0, 1}<sup>_n_</sup> for the set of all sequences of _n_ bits
- XOR (⊕) is addition modulo 2 on each bit

### One-time pad (29/09/2017)
- Message and keys are bitstrings


- **Key:** Random bitstring k<sub>1</sub>,...,k<sub>n</sub> as long as message
  m<sub>1</sub>,...,m<sub>n</sub>
- **Encryption:** k<sub>1</sub>⊕m<sub>1</sub>,...,k<sub>n</sub>⊕m<sub>n</sub>
- **Decryption** of ciphertext c<sub>1</sub>,...,c<sub>n</sub>:
  k<sub>1</sub>⊕c<sub>1</sub>,...,k<sub>n</sub>⊕c<sub>n</sub>

#### Security
- Very strong notion of security
- Attacker can't learn info by looking only at ciphertexts
- Where P is uniform distribution over keys of length _n_
  - P[E(_k_, _m_<sub>1</sub>) = _c_] = P[E(_k_, _m_<sub>2</sub>) = _c_]
- Satisfies perfect security
  - For randomly-chosen _m_, _c_ and _n_, P[E(_k_, _m_) = _c_] =
    <sup>1</sup>/<sub>2<sup>n</sup></sub>

### Formulation of cipher algorithm
Let K, M and C be the sets keys, messages and ciphertexts.

E = Encryption, D = Decryption

A cipher is (E : K x M -> C, D : K x C -> M) such that for all
_m_ ∈ M and _k_ ∈ K,

D(_k_, E(_k_, _m_)) = _m_

## Symmetric ciphers
- **Block cipher:** operating on fixed-length groups of bits, called blocks
- **Stream cipher:** encrypting plaintext continuously. Bits are encrypted one
  at a time, differently for each bit.

### Players
- **Alice**: sender of encrypted message
- **Bob**: intended receiver of encrypted message. Has the key.
- **Eve** (Passive): intercepts messages, trying to identify plaintexts or keys
- **Mallory** (Active): intercepts and modifies messages to identify plaintexts
  or keys

### Feistel cipher
- Same encryption scheme applied iteratively for several rounds
- Next message state derived from previous message state via
  "_Feistel function_"
- Each round works as follows:
  - Split input in half
  - Apply Feistel function to the right half
  - Compute XOR of result with old left half to create new left half
  - Swap old right and new left half unless we're in the last round

#### Formal definition
- Split plaintext block into equal pieces
  _M_ = (_L_<sub>0</sub>, _R_<sub>0</sub>)
- For each round _i_ = 0,1,...,_r_-1 compute
  - _L_<sub>_i_+1</sub> = _R_<sub>_i_</sub>
  - _R_<sub>_i_+1</sub> = _L_<sub>_i_</sub> ⊕ _F_(_K_<sub>_i_</sub>,
    _R_<sub>_i_</sub>)
  - The ciphertext is _C_ = (_R_<sub>_r_</sub>, _L_<sub>_r_</sub>)

![](https://i.imgur.com/UGEd7fj.png)

#### Decryption
- Works same as encryption but with reversed order of keys
  - Split ciphertext block into two equal pieces _C_ = (_R_<sub>_r_</sub>,
    _L_<sub>_r_</sub>)
  - For each round _i_ = _r_, _r_ - 1,...,1 compute
    - _R_<sub>_i_-1</sub> = _L_<sub>_i_</sub>
    - _L_<sub>_i_-1</sub> = _R_<sub>_i_</sub> ⊕ _F_(_K_<sub>_i_-1</sub>,
      _L_<sub>_i_</sub>)
  - Plaintext is _M_ = (_L_<sub>_0_</sub>, _R_<sub>_0_</sub>)

### DES
- Key size is 56 bits (can be broken in 10 hours)
- Steps:
  - Initial permutation on plaintext
  - 16 rounds of Feistel cipher
  - Inverse of initial permutation


- Block length of 64 bits
- 16 rounds _R_
- Key length is 56 bits
- Round key length is 48 bit for each subkey _K_<sub>0</sub>,...,
  _K_<sub>15</sub>.
  * Derived from 56 bit key via key schedule.


![](https://i.imgur.com/4XwYIbb.png)

#### DES Feistel function
- Four stage procedure:
  - **Expansion permutation:** Expand 32-bit message half block to 48-bit block
    by doubling 16 bits and permuting them.
  - **Round key addition:** Compute XOR of 48-bit block with round key
    _K_<sub>_i_</sub>.
  - **S-Box:** Split 48 bits into eight 6-bit blocks. Each is given as input to
    8 substitution boxes, substituting 6-bit blocks with 4-bit blocks.
  - **P-Box:** Combine the eight 4-bit blocks to 32-bit block and apply
    another permutation.

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Data_Encription_Standard_Flow_Diagram.svg/600px-Data_Encription_Standard_Flow_Diagram.svg.png"
  style="width: 18em" />

#### DES operation notation
- **Cyclic shifts** on bitstring blocks: _b_ <<< _n_ means move bits of block
  _b_ by _n_ to the left, bits that would have fallen out are added at the
  right of _b_. Other direction is _b_ >>> _n_.
- **Permutations on the position of bits**: Written as output order of
  input bits.
  - e.g. 4123 means:
    - fourth input becomes first output
    - first input becomes second output
    - second input becomes third output
    - third input becomes fourth output

#### S-boxes
- Substitution table lookup
- Input is 6 bits, output is 4 bits
  - Outside bits joined as row index
  - Four inside bits are column index
  - Output is corresponding entry in table

#### Key schedule
- Computes different keys for each round
- 64-bit key (56-bit key with 8 parity bits)
- Steps:
  - Apply PC-1 permutation to remove parity bits
  - Split in half to get (_C_<sub>0</sub>, _D_<sub>0</sub>)
  - For each round, compute:
    - _C_<sub>_i_</sub> = _C_<sub>_i_-1</sub> <<< _p_<sub>_i_</sub>
    - _D_<sub>_i_</sub> = _D_<sub>_i_-1</sub> <<< _p_<sub>_i_</sub>
    - Where _p_<sub>_i_</sub> = 1 (if _i_ = 1,2,9,16) else 2
  - Join _C_<sub>i</sub> and _D_<sub>i</sub> and apply permutation PC-2 to
    produce a 48-bit output

### Security of block ciphers (03/10/2017)
- Use an abstract notion: pseudorandom permutations
  - Let X = {0,1}<sup>_n_</sup> and pseudorandom permutation over (K,X) is
    function E: K x X -> X
  - There exists an efficient deterministic algorithm to compute E(k,x) for
    any k and x
  - The function E(k,\_) is one-to-one for each k
  - There exists a function D : K × X → X which is efficiently computable, and
    D(k, E(k, x)) = x for all k and x.

#### Security of pseudorandom permutations
- Secure if an adversary can't distinguish it from a "genuine"
  random permutation
- Far fewer pseudorandom permutations than total permutations
  - 2<sup>n</sup>! permutations
  - 2<sup>n</sup> pseudorandom permutations

### Pseudorandom permutation security game
Let X = {0,1}<sup>n</sup>, F be the set of all permutations on X
and E a pseudorandom permutation over (K, X)

- Challenger chooses a random bit _b_ ∈ {0,1}
- If _b_ = 0, challenger chooses _k_ ∈ K at random,
  if _b_ = 1, challenger chooses a permutation _f_ on X at random
- Attacker does arbitrary computations
- Attacker has access to a black box, which is a function from X to X operated
  by the challenger. He can ask the challenger for the values
  _g_(x<sub>1</sub>),…,_g_(x<sub>n</sub>) during his computation
- If _b_ = 0, challenger answers query _g_(x<sub>i</sub>) by returning
  _E_(k, x<sub>i</sub>), if _b_ = 1, the answer is _f_(x<sub>i</sub>)
- Attacker outputs a bit _b_' ∈ {0,1}

Attacker wins the game if _b_ = _b_'

### Negligible functions
A function of natural numbers to positive real number is negligible if the
output number is less than 1/(everything greater than the input)

A pseudorandom permutation is secure if P[_b_=_b_'] - <sup>1</sup>/<sub>2</sub>
is negligible in size of _K_

### DES
- Good design but only 56 bit keys - 2<sup>56</sup> security
- 2DES encrypts twice
  Enc<sub>K<sub>1</sub></sub>(Enc<sub>K<sub>2</sub></sub>(M)),
  key length of 112 bit (_K_<sub>1</sub>_K_<sub>2</sub>)
  , not much more secure
  - ~2<sup>57</sup> work to find 112-bit key _K_<sub>1</sub>_K_<sub>2</sub>
    1. Try all keys _K_<sub>2</sub>, store encryption of M in order
    2. Try all keys _K_<sub>1</sub>, compute decryption of C, check if value
       is in previous list

#### 3DES
- Good but slow
- 168 bit key split into K<sub>1</sub>, K<sub>2</sub>, K<sub>3</sub>
- Encrypt M: Enc<sub>K<sub>1</sub></sub>(Dec<sub>K<sub>1</sub></sub>(
  Enc<sub>K<sub>1</sub></sub>(M)))
  - Enc-Dec-Enc gives option of setting K<sub>1</sub> =  K<sub>2</sub> =
    K<sub>3</sub> so we can also do DES
- Security of 2<sup>118</sup>

## AES (06/10/17)
- 128-bit block size
- Key size of 128, 192 or 256-bit
- Works in rounds, with round keys
  * 10, 12 or 14 rounds depending on number of bits in the key
- Is a _substitution-permutation network_ (not a Feistel network)

### Encryption Process
**AES-128**:

Arrange the message in a 4×4 matrix (8 bits per square), spreading 128 bits
over the grid, as below:

|8|8|8|8|
|-|-|-|-|
|8|8|8|8|
|8|8|8|8|
|8|8|8|8|

Below is 1 round defined. AES-128 consists of 10 rounds:
- Byte Substitution
  - Gives non-linearity
- ShiftRows
  - Permutes bytes
- MixColumns
  - MixColumns and ShiftRows give _diffusion_
- Key Addition (XOR with round key)

No MixColumns in final round.

#### SubBytes
- Using the S-box lookup table, map each byte in the state matrix to a
  value in the table

#### ShiftRows
Cyclic shift each row left by the row index, top to bottom, starting at row 0
(the top)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/AES-ShiftRows.svg/640px-AES-ShiftRows.svg.png)

#### MixColumns
- Achieved by multiplying with a matrix
- Use ⊕ (XOR) for addition
- Use ⊗ "special" operation for multiplication

#### AddRoundKey
- Use the key schedule to compute round keys
- Can be represented as matrix, same as the state
- XOR round key with state matrix

### Key schedule
AES-128 requires 11 round keys (one initial, 10 for the rounds)

```text
<b>for</b> i := 1 <b>to</b> 10 <b>do</b>
    T := W<sub>4i−1</sub> ≪ 8
    T := <i>SubBytes</i>(T)
    T := T ⊕ <i>RC</i><sub>i</sub>
    W 4i := W<sub>4i−4</sub> ⊕ T
    W 4i+1 := W<sub>4i−3</sub> ⊕ W<sub>4i</sub>
    W 4i+2 := W<sub>4i−2</sub> ⊕ W<sub>4i+1</sub>
    W 4i+3 := W<sub>4i−1</sub> ⊕ W<sub>4i+2</sub>
<b>end</b>
```

### AES and finite fields of polynomials (10/10/2017)
- e.g. a bit string written as a polynomial

01111010 = x<sup>6</sup> + x<sup>5</sup> + x<sup>4</sup> + x<sup>3</sup> +
x<sup>1</sup>

#### Irreducible polynomials
A polynomial that is only divisible by 1 and itself.

- If _p_(x) is an irreducible polynomial in F<sub>2</sub>[x]
  - Write F<sub>2</sub>[x]/_p_(x) for set of polynomials in F<sub>2</sub>[x]
    considered modulo _p_(x)

### The ⊗ operation
- Bitstrings interpreted as polynomials
- The two polynomials are multiplied together and reduced mod x<sup>3</sup> +
  x + 1
- Result is converted back into a 3-bit string

### AES field
- F2[x] / (x<sup>8</sup> + x<sup>4</sup> + x<sup>3</sup> + x + 1)
  - This gives operations ⊕ and ⊗ on bytes
  - These two operations are used to define MixColumns and S-boxes

#### Substitution in AES
Substitution for byte _B_:
  1. Compute multiplicative inverse of _B_ in the AES field to
      - Obtains _B'_ = [x<sub>7</sub>,...,x<sub>0</sub>]
      - Zero element mapped to [0,...,0]
  2. Compute new bit vector _B''_ = [y<sub>7</sub>,...,y<sub>0</sub>] with
     transformation:
  ![](https://i.imgur.com/dLB01sp.png)

#### Key schedule in AES
- RC<sub>1</sub>,...,RC<sub>10</sub>
  - RC<sub>i</sub> = x<sup>i-1</sup> mod x<sup>8</sup> + x<sup>4</sup> +
    x<sup>3</sup> + x + 1

### AES Security
So far, only small "erosions" of AES
  - Meet-in-the-middle key recovery attack. Requires 2<sup>126</sup> operations
    (about 4x faster than brute-force)
  - "Related key" attack on AES-192 and AES-256. Security may be reduced if
    keys are related in a certain way but this is an "invalid" attack since
    keys should always be random.

## Block Cipher Modes (13/10/2017)

### Properties of good block ciphers
1. [Security] Identical plaintexts shouldn't produce identical ciphertexts
2. [Security] Identical blocks within a plaintext shouldn't produce identical
   ciphertext blocks
3. [Security] There should be protection against deletion or insertion of blocks
4. [Recovery] Ciphertext transmission errors should only affect the block
   containing the error
5. [Efficiency] It should be efficient (e.g. parallelisable)

|   |ECB|CBC|CTR|GCM|
|--:|:-:|:-:|:-:|:-:|
| 1 | ✘ | ✔ | ✔ | ✔ |
| 2 | ✘ | ✔ | ✔ | ✔ |
| 3 | ✘ | ✘ | ✔ | ✔ |
| 4 | ✔ | ✘ | ✔ | ✔ |
| 5 | ✔ | ✘ | ✔ | ✔ |

### ECB (Electronic Codebook Mode)
Apply encryption/decryption block by block.

![](https://blog.filippo.io/content/images/2015/11/Tux\_ecb.jpg)

### CBC (Cipher-Block Chaining)
- Uses an IV (Initialisation Vector (Random number))
  - IV is random and different for every encryption
  - First block of plaintext is XORed with the IV
- Each block uses the same key
- IV is publicly sent along with ciphertext (as the first block)
  - Could be thought as the 'zeroth block'
- Encrypting the IV is pointless, CBC is _provably secure_ without it
  (assuming a random IV)

#### Encryption
![](https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/CBC_encryption.svg/800px-CBC_encryption.svg.png)

#### Decryption
![](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/CBC_decryption.svg/800px-CBC_decryption.svg.png)

### CTR (Counter Mode)
- Uses a random nonce as well as a counter IV (which is incremented for each
  block), combined together
- As with CBC, the nonce is sent publicly along with the ciphertext

![](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/CTR_encryption_2.svg/1202px-CTR_encryption_2.svg.png)

### Block Cipher Mode Security Game (IND-CPA)
1. Challenger generates a key
1. Attacker performs a polynomial number of computations, possibly asking for
   encryption of some messages
1. Attacker asks for encryption of some number of messages
1. Attacker submits two messages _m_<sub>0</sub> and _m_<sub>1</sub> at random
1. Challenger chooses bit _b_ ∈ {0,1} at random
1. Challenger returns encryption of _m_<sub>_b_</sub>
1. Attacker performs a polynomial number of computations, possibly asking for
   encryption of some messages
1. Attacker outputs bit _b_'

- Attacker wins if _b_' = _b_
- Block cipher secure if attacker can only win half the time

## Stream Ciphers
- Generate a pseudorandom key stream, the length of data to encrypt

### LFSR (Linear-Feedback Shift Register)
- A register of bit cells shifted by one every clock cycle
- Initialised with a pseudorandom
- New input is a result of a function on bits in the register
- If it has _n_ bits, keystream period is at most 2<sup>n</sup>
- Not very secure

### Combining LFSRs
- Given lots of output, tap positions (function input) can be computed
- Combine many LFSRs in non-linear fashion to produce key stream

### A5/1
- Used in GSM phone communication
- Built from three LFSRs with irregular clock cycle
- Register only shifted if clock bit is the same as majority of three clock bits

**Security**
- Clock shifts make cryptanalysis harder
- Mainstream PC with 1TB flash memory can break in a few seconds

### RC4
- Two phases
  - Initialisation of _S_ ("key schedule"
  - Keystream generation phase

**Properties**
- Compact, well studied
- Many attacks, led to downfall of WEP

### WEP
- Based on RC4
- RC4 run based on seed = pre-shared WEP key (128-bit) and an IV (24-bit)
- Small IV means key streams repeat after at most 2<sup>24</sup> frames
- First bytes of key stream known by adversary, standard headers always sent

## Integrity and Authentication (24/10/2017)
### Integrity of messages
**Goal:** Ensure change of message by attacker can be detected
**Definition:** Cryptographic hash functions are functions from bitstrings of
almost any length to a bitstring of a small, fixed length such that:
  - Easy to compute
  - One-way (hard to invert)
  - Collision-resistant. Infeasible to find two files with the same hash

#### Collision-resistance
- Output space much smaller than input space. There are many collisions!
- Should be computationally hard to find a single collision
- If a collision is found, the hash function is considered broken
- Changing one bit of input should "completely change" the output
  - e.g. typically half of output bits are changed

#### One-way vs collision-resistant
**One-way:** given y, infeasible to find x such that h(x) = y

**Collision-resistant:** infeasible to find x and x' such that h(x) = h(x')

### The Merkle-Damgard Construction
- Produces a cryptographic hash function from a compression function shown as
  _f_ below.
- Apply compression function repeatedly
- Used by MD4, MD5, SHA-1 and SHA-2
![](https://i.imgur.com/NaihODP.png)

### MD4
#### MD4 algorithm
- IV is constant (part of hash function definition)
- K constant (part of the hash function definition)
- Message padded to length less than multiple of 512
- 64-bit representation of message length added
- Split into 512-bit blocks, processed to produce hash value

#### MD4 compression function
- **Input**: 512-bit block and current value of A,B,C,D
- **Output**: new A,B,C,D values
- Input is split into 16 chunks
- Three rounds of 16 steps transform A,B,C,D into new values using a particular
  function for each round

### MD5
- Same as MD4 but with a fourth round

### SHA-1
- Extension of MD4
- Extends hash size to 160 bits

### SHA-2
- More bitwise operations
- Increased block sizes
- Increased hash length

### SHA-3
- Uses _sponge construction_ rather than _Merkle-Damgard_ construction
- Output length can be varied

![](https://i.imgur.com/icKhGLC.png)

- P are input blocks
- C cannot be altered by input

### Message Authentication Codes (MAC)
- Used to guarantee authenticity
- A keyed hash function where Alice and Bob share key k
  - Alice -> Bob: _m_, MAC<sub>_k_</sub>(_m_)
  - Bob computes MAC<sub>_k_</sub>(_m_), checks if it matches what he was sent

#### How to define MAC from a hash function?
- MAC<sub>_k_</sub>(_m_) could be defined as _h_(_k_||_m_)
  - Vulnerable to _length extension attack_
    - Given _m_ and _h_(_k_||_m_), can construct _m'_ and _h_(_k_||_m_')
    - We've been able to get a hash without the key by adding to the end of
      original _m_

#### HMAC
- HMAC<sub>_k_</sub>(_m_) = _h_( (_k_ ⊕ _opad_) || _h_( (_k_ ⊕ _ipad_) || _m_) )
- _k_ padded with zeros to blocksize of hash function
- _ipad_ and _opad_ are constants of the blocksize
  - Large hamming distance from each other. Inner and outer keys have fewer
    bits in common

#### CBC-MAC
Uses CBC operation of block cipher
![](https://i.imgur.com/BEjuxVw.png)

#### PMAC
- Parrallelisable, unlike HMAC and CBC-MAC
![](https://i.imgur.com/ypIQ7aW.png)

### Security of hash function
Secure if attacker can't output a collision.

### Security of MAC
MAC is secure if attacker cannot produce a valid (message, tag) pair that he
hasn't seen before. (Assume he doesn't have the key)

### MAC Game
- Attacker does some computations supplying messages to challenger
- Challenger returns MACs for messages
- Attacker does more computations and supplies a message, tag pair not equal to
  any previously seen
- Challenger outputs 1 if the tag is valid for the message, otherwise 0

The attacker wins if the challenger outputs 1.

MAC is secure if no attacker can win the game with non-negligible probability.

### MAC Results
- If block cipher is secure and message lengths are fixed, CBC-MAC is secure
- If hash function is secure, HMAC is a secure MAC
- If block cipher is secure, PMAC is a secure MAC

## Authenticated encryption (31/10/2017)
For privacy and integrity:
- Combine encryption and MAC in appropriate way
- Use new mode, guarantees confidentiality and authenticity

### Combination possibilities
- Encrypt-then-MAC
  - Encrypt, compute MAC of ciphertext
  - E<sub>k1</sub>(m), MAC<sub>k2</sub> (E<sub>k1</sub> (m))
  - Gives both privacy and integrity (provided encrypt and MAC are secure)
  - Used in IPsec
- MAC-then-encrypt
  - Compute MAC, encrypt message-MAC pair
  - E<sub>k2</sub> (m, MAC<sub>k1</sub> (m))
  - Doesn't provide both privacy and integrity unless encryption is CBC or CTR
    with random IV (for example)
- Encrypt and MAC
  - Pair of ciphertext and MAC
  - E<sub>k1</sub> (m), MAC<sub>k2</sub> (m)
  - Doesn't provide both privacy and integrity

### Authenticated encryption game
- Challenger picks random encryption key
- Attacker does computations, may send messages m<sub>1</sub>,...,m<sub>n</sub>
- Challenger responds with ciphertexts c<sub>1</sub>,...,c<sub>n</sub>
- Attacker does more computations, submits different ciphertext c to challenger
- Attacker has won if he's forged a valid ciphertext c (where MAC is correct)

Authenticated encryption scheme is secure if:
- It satisfies IND-CPA
- An attacker wins the game with only negligible probability

### Galois counter mode (GCM)
- Encrypt-then-MAC is secure but requires two passes over data
- GCM only needs to pass through data once


- Encrypts nonce and counter value, produces key stream to XOR with plain text
- Computes an authentication tag on ciphertext
- Can authenticate additional unencrypted data

#### GCM: the authentication tag
{Missing notes (Complicated for exam)}

## Public Key Encryption - Syntax
Public key encryption scheme consists of the following algorithms:
- KG(λ) - input **security parameter** λ - outputs a pair of enc/dec keys
  (PK, SK)
- Enc(PK, m;r) - inputs public key PK, plaintext _m_ - outputs ciphertext C
- Dec(SK, C) - inputs decryption key SK, ciphertext C - outputs plaintext _m_

## Modular Arithmetic
- a = b (mod N) or a ≡ b mod N if N divides b − a
- if b − a = q · N for integer q, a and b are congruent modulo N or the
  reduction modulo N of a is b
- Z<sub>N</sub> for N ∈ Z, N > 0 is defined as Z<sub>N</sub>
  = {0, 1, . . . , N − 2, N − 1}

## Greatest Common Divisor (Euclidean Algorithm) (07/11/2017)
```text
while b != 0 do
  r = a mod b
  a = b
  b = r
return a
```

{Euclidean Algorithm not needed for exam}

### Inverses modulo N
- _x_ ∈ Z<sub>N</sub> has inverse _y_ ∈ Z<sub>N</sub> such that _x_·_y_
  = 1 mod N if gcd(N,_x_) = 1
- Z<sup>*</sup><sub>N</sub> is the subset of Z<sub>N</sub> of all its invertible
  elements
- φ(N) is the number of invertible elements in Z<sup>*</sup><sub>N</sub>

### Euler's theorem
- a<sup>φ(N) ≡ 1 mod N

### Fermat's little theorem
- For prime _p_ and integer _a_ != 0 mod _p_, _a_<sup>_p_-1</sup> ≡ mod _p_
- For any _a_, _a_<sup>_p_</sup> ≡ _a_ mod _p_

### RSA
- Key generation KG(λ)
  - Generate two distinct primes, p and q of same bit-size λ
  - Compute N = p x q and Φ = (p - 1)(q - 1)
  - Select random int e, 1 < e < phi such that gcd(e,Φ) = 1
  - Compute d, inverse of e mod Φ (e x d = 1 mod Φ) using extended euclidean
    algorithm
  - Public key is PK = (N, e)
  - Private key is SK = d


- **Encryption:** Enc(PK, m)
  - With message (m) and public key (PK = (N,e))
  - Ciphertext c = m<sup>e</sup> mod N
- **Decryption:** Dec(SK, c)
  - With ciphertext c, N from public key and private key (SK = d)
  - Message m = c<sup>d</sup> mod N

#### Decryption Proof
- Dec(SK, Enc(PK, m)) = m
- Does (m<sup>e</sup>)<sup>d</sup> = 1 mod N ?
- Since e · d ≡ 1 mod φ(N), there is _k_ such e · d = 1 + k · φ(N)
- If m != 0 mod N, by Euler's theorem m<sup>φ(N)</sup> ≡ 1 mod N
- m<sup>e·d</sup> = m<sup>1+k·φ(N)</sup>
  ≡ m · (m<sup>φ(N)</sup>)<sup><sup>k</sup></sup> ≡ m · 1 ≡ m mod N

#### Chinese Remainder Theorem
{Missing notes}

#### Proof that decryption works (CRT)
- e · d ≡ 1 mod φ, there is _k_ such that e · d = 1 + k · φ
- If m != 0 mod p, by Fermat's little theorem m<sup>p-1</sup> ≡ 1 mod p
- Gives m<sup>1+k ·(p−1)·(q−1)</sup> ≡ m mod p
  - Gives m<sup>ed</sup> ≡ m mod p for all m
  - Gives m<sup>ed</sup> ≡ m mod q for all m
  - By CRT, if p != q then m<sup>ed</sup> ≡ m mod N

#### Attacks Against RSA Encryption
- **Factoring**: given N = p x q, compute p and q
- **Secret key recovery**: given (N, e) with N = p x q, compute d
  = e<sup>-1</sup> mod φ(N)
  - φ(N) = (p-1)(q-1)
- **Breaking RSA primitive**: given (N, e) with random y, find x such that
  y = x<sup>e</sup> mod N
- **Dictionary attack**: m<sub>0</sub> -> c<sub>0</sub>,
  m<sub>1</sub> -> c<sub>1</sub>
- **Malleability attack**: given encryption c = m<sup>e</sup> mod N, it's
  possible to create encryption of m' = λ · m mod N by computing:
  - c' = (m)<sup>e</sup> · λ<sup>e</sup> = (m · λ)<sup>e</sup> mod N

### One-Wayness
**Game**
1. Challenger gives PK to attacker
2. Challenger gives encryption of random m using PK
3. Attacker performs computations and outputs m'


- Attacker wins the game if m' = m
- Secure if attacker only wins with negligible probability (Pr[m'=m])

### Defence Against Dictionary Attacks
**IND-CPA Game**
1. Challenger gives PK to attacker
2. Attacker performs computations
3. Attacker submits messages m<sub>0</sub> and m<sub>1</sub> of equal length to
   the challenger
4. Challenger selects a bit b ∈ {0, 1} at random
5. Challenger returns encryption of m<sub>b</sub>
6. Attacker performs computations and outputs b'


- Attacker wins the game if b' = b
- Secure if attacker can only win with negligible probability (Pr[b'=b] - 0.5)

#### IND-CPA Secure PK Encryption
- Add padding to RSA
- Encrypt random number rather than message (H is hash function)
  - Enc: E<sub>PK</sub>(r), H(r)⊕m)
  - Dec(c<sub>1</sub>,c<sub>2</sub>):
    H(D<sub>SK</sub>(c<sub>1</sub>))⊕c<sub>2</sub>

### Sophie Germain Primes q
- If both q and 2q + 1 are prime, q is Sophie Germain prime
- Generate p such that p - 1 = 2 x q for some prime q
  - Generate random prime p
  - Test if q = (p - 1)/2 is prime, if not, generate a new p

### ElGamel Encryption
- p = 2 x q + 1 prime
- g such that g<sup>q</sup = 1 mod p
- G<sub>q</sub> is the subgroup of Z<sup>*</sup<sub>p</sub> generated by g
- h = g<sup>x</sup> mod p
- PK: (G, g, h). SK: x


- Enc: c = (g<sup>r</sup>, h<sup>r</sup> · m)
- Dec (c<sub>1</sub>, c<sub>2</sub>): m = c<sub>2</sub>
  · (c<sub>1</sub><sup>x</sup>)<sup>-1</sup> mod p

#### Security of ElGamel
- One-way if solving CDH is infeasible
- IND-CPA secure if solving Decisional DH is infeasible
- ElGamel is multiplicative, can obtain enc of m' · m by multiplying previous
  ciphertexts

#### IND-CCA Game
1. Challenger give PK to attacker
2. Attacker given access to decryption oracle for ciphertext inputs
3. Attacker submits messages m<sub>0</sub> and m<sub>1</sub> of equal length to
   the challenger
4. Challenger selects random bit b ∈ {0, 1}
5. Challenger returns encryption of m<sub>b</sub>
6. Attacker uses oracle to decrypt c != c<sub>b</sub> and outputs b'


- Attacker wins the game is b' = b
- ElGamel is not IND-CCA secure
  - Given c = (g<sup>r</sup> , h<sup>r</sup> · m) where pk = (g, h)
  - Ask for decryption of c' = (g<sup>r+1</sup> , h<sup>r+1</sup> · m)
    and recover m

### Twin ElGamel Encryption
- Adds a MAC to ciphertext
- Is IND-CCA secure if computational DH assumption holds and MAC is unforgeable

## Diffie-Hellman Key Exchange
- Two parties can establish a shared key without previous communication
- Let p and q(=p-1) be primes
- Let g be a generator
- Alice generates a random _a_ less than q and publishes g<sup>a</sup> mod p,
  keeping _a_ secret
- Bob does the same for a _b_
- Alice and Bob compute g<sup>ab</sup>
- Alice and bob now share the same value (key)

### MITM
- DH is vulnerable to man in the middle attack

- Stop MITM attack by guaranteeing authenticity of g<sup>a</sup> g<sup>b</sup>
- Use public key digital signatures
- CA is used to authenticate public keys (gives relation between PK and identify
  of its owner)
- CA signs the relationship

### Certificate Process
- Alice generates PK,SK and sends PK to CA
- CA performs identity check
- Alice proves knowledge of SK to CA (decrypt data encrypted with PK)
- CA issues cert to Alice
- Alice sends cert to Bob
- Bob verifies cert and extracts Alice's PK

### Certificate Issuance
- Cert contains (CERTDATA, σ)
- σ is CA's signature on CERTDATA
- CERTDATA contains
  - PK, ID<sub>Alice</sub>
  - CA Name
  - Cert expiry
  - Restrictions
  - Security level

### Digital Signatures Schemes
- Better than using MAC since no need to share MAC key with all users
- MAC does not prevent parties from cheating each other
- Signatures are: publicly verifiable, transferable, non-repudiable

### Syntax of Digital Signatures
- We have verifying key and signing key
- Sign(sk, m;r) - Inputs: signing key sk, message m
- Verify(vk, m, σ) - Inputs: verifying key vk, message m, signature σ

### Usage
1. Signer generates vk and sk
2. Signer publicly announces vk
3. Verifier accepts vk
4. Signer produces signature σ on document M using sk
5. Verifier who has vk can verify signature for document using vk

### Unforgeability Game
- **Init**: Challenger gives vk to attacker
- **Find**: Attacker does computations, asks for challenger to sign messages
- Challenger returns signatures for messages
- **End**: Attacker outputs pair (m, s)


- Attacker wins if (m, s) is a valid signature for m that was not in **Find**
  phase
- Digital signature scheme secure against existential forgery if attacker only
  has negligible probability of winning the game

### Signature from Trapdoor One-Way Bijections
- Function is:
  - Easy to compute given PK
  - Efficiently invertible with **trapdoor** SK
  - Infeasible to invert without SK

### RSA - Full Domain Hash (RSA-FDH)
- Let H be secure hash function
- Sign((N,e,d),m): σ = F<sub>d</sub><sup>-1</sup>(H(m))
  = H(m)<sup>d</sup> mod N
- Verify((N,e),m,σ): Yes/No if H(m) = F<sub>N,e</sub>(σ) = σ<sup>e</sup> mod N


- Unforeable signature scheme under assumption hat RSA problem is infeasible to
  break

### Secure H
- H must be one-way, otherwise...
- If an adversary can invert the hash function (find M such that H(M) = y)
- Forgery is easy
  - Attacker chooses random σ
  - Attacker computes σ<sup>e</sup> mod N
  - Attacker computes M such that H(M) = σ<sup>e</sup> mod N
  - Attacker outputs pair (M,σ) as forgery


- H must be collision-resistant, otheriwse...
- Adversary can find collisions M1 != M2, such that H(M1) = H(M2)
- Forgery is easy
  - Request signature σ on M1
  - Output pair (M2,σ) as forgery

- H must not have structural properties
- If a hash has properties H(M1 XOR M2) = H(M1) x H(M2) for M1,M2 same size
- Forgery is easy
  - Request signature σ1 on M1
  - Request signature σ2 on M2
  - Set σ = σ1 x σ2 and M = M1 XOR M2
  - Output pair (M,σ) as forgery

### H as a Random Oracle
- Behaves as a public random function
  - H(M1) = H(M2) with probability 1/|Y| for M1 != M2
  - Attacker regards, H as lookup table
- In practice, instantiate function H with hash function

### Instantiate H in RSA-FDH
H(M) = SHA-512(1||M) || ... || SHA-512(4||M)

### Schnorr Signature Scheme
- Sign(sk, M):
  - Choose random r from {0,...,q-1}
  - Compute s = H(M||g<sup>r</sup>)
  - Compute t = (r + x · s) mod q
  - Output σ = (s,t)
- Verify(vk,σ,m):
  - Parse σ as (s,t)
  - Accept signature if H(M||g<sup>t</sup>y<sup>-s</sup>) = s


- Unforgeable under Discrete Logarithm assumption in Random Oracle Model

### DSA
- Sign(sk,M):
  - Choose random r
  - Compute s = (g<sup>r</sup> mod p) mod q
  - Compute t = (H(M) + x · s) · r<sup>-1</sup> mod q
  - Output σ = (s, t)
- Verify(vk,σ,m):
  - Calculate u1 = H(M) · t<sup>-1</sup> mod q
  - Calculate u2 = s · t<sup>-1</sup> mod q
  - Accept signature if (g<sup>u1</sup> · y<sup>u2</sup>) mod p mod q = s
