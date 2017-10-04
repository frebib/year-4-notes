# Cryptography

## What is Cryptography? (26/09/2017)

> Converting plain-text (or data) to an undecipherable text

_Encryption is essential for communication on the internet as it provides confidentiality and integrity_

## Pre-modern Cryptography

### Kinds of cryptography
- **Transposition:** permutes components of a message
- **Substitution:** replacing components via
  - **Codes:** algorithms for substitution of entire words
  - **Ciphers:** algorithms substituting bits, bytes or blocks

### Transposition cipher
Example: _rail fence cipher_
- **Key:** column size (height)
- **Enc:** arrange message in columns of fixed size. Add dummy text to fill the last column. Cipher text is rows read left to right
- **Dec:** calculate row size by dividing message length by key. Arrange message in rows to decrypt.

**Security**
- Not secure. Message of size _n_, there are at most n possibilities for the key.

### Permutations
> A re-arrangement of an ordered list of elements with a 1-1 correspondence of itself.

Two notations are used for 1,2,3 -> 2,3,1:
- **Array notation:** ![](https://i.imgur.com/f9yM8HM.png)
- **Cycles:**
  - Apply permutation to 1 and note 1 and result
  - Repeat permutation for result until reaching initial number
  - E.g. 1,2,3,4,5 -> 3,5,1,2,4 = (1,3) (2,5,4)

#### Operations on permutations
- **Identity** maps any number to itself
- Two permutations can be **composed**, resulting in another permutation
  - E.g. 1,2,3 -> 2,1,3 composed with 1,2,3 -> 3,2,1 = 1,2,3 -> 3,1,2
  - See explanation [here](https://math.stackexchange.com/questions/549186/the-product-or-composition-of-permutation-groups-in-two-line-notation#549191)
- **Inverse** of permutation _s_ is permutation _t_, such that _s_ composed with _t_ is the identity

#### Monoalphabetic substitution cipher
- **Key:** permutation of the alphabet
- **Encryption:** Apply permutation
- **Decryption:** Apply inverse permutation

**Security**
- Lots of possible keys but vulnerable to frequency analysis

## Modern Cryptography

### Modular arithmetic
(Not covered in detail in lecture)

### Probability
- Always a chance of getting the correct key from guesswork
- We want very low probabilities of guessing a key
- Probability distribution P is a function such that the sum of all possible events through P = probability 1
- Uniform distribution is function P where probability = 1/(no. events)


- Let P : U → [0, 1] be a probability distribution.
  - An event A is a subset of U.
  - The probability of an event A, written P[A], is defined as: ![](https://i.imgur.com/daavv76.png)

### Bitstrings
- Write {0, 1}<sup>_n_</sup> for the set of all sequences of _n_ bits
- XOR (⊕) is addition modulo 2 on each bit

### One-time pad (29/09/2017)
- First cipher which is secure
- Message and keys are bitstrings


- **Key:** Random bitstring k<sub>1</sub>,...,k<sub>n</sub> as long as message m<sub>1</sub>,...,m<sub>n</sub>
- **Encryption:** k<sub>1</sub>⊕m<sub>1</sub>,...,k<sub>n</sub>⊕m<sub>n</sub>
- **Decryption** of ciphertext c<sub>1</sub>,...,c<sub>n</sub>: k<sub>1</sub>⊕c<sub>1</sub>,...,k<sub>n</sub>⊕c<sub>n</sub>

#### Security
- Very strong notion of security
- Attacker can't learn info by looking only at ciphertexts
- Where P is uniform distribution over keys of length _n_
  - P[E(_k_, _m_<sub>1</sub>) = _c_] = P[E(_k_, _m_<sub>2</sub>) = _c_]
- Satisfies perfect security
  - For randomly-chosen _m_, _c_ and _n_, P[E(_k_, _m_) = _c_] = ![](http://www.sciweavers.org/upload/Tex2Img_1506705424/eqn.png)

### Formulation of cipher algorithm
Let K, M and C be the sets keys, messages and ciphertexts.

E = Encryption, D = Decryption

A cipher is (E : K x M -> C, D : K x C -> M) such that for all _m_ ∈ M and _k_ ∈ K,

D(_k_, E(_k_, _m_)) = _m_

## Symmetric ciphers
- **Block cipher:** operating on fixed-length groups of bits, called blocks
- **Stream cipher:** encrypting plaintext continuously. Bits are encrypted one at a time, differently for each bit.

### Feistel cipher
- Same encryption scheme applied iteratively for several rounds
- Next message state derived from previous message state via "_Feistel function_"
- Each round works as follows:
  - Split input in half
  - Apply Feistel function to the right half
  - Compute XOR of result with old left half to create new left half
  - Swap old right and new left half unless we're in the last round

#### Formal definition
- Split plaintext block into equal pieces _M_ = (_L_<sub>0</sub>, _R_<sub>0</sub>)
- For each round _i_ = 0,1,...,_r_-1 compute
  - _L_<sub>_i_+1</sub> = _R_<sub>_i_</sub>
  - _R_<sub>_i_+1</sub> = _L_<sub>_i_</sub> ⊕ _F_(_K_<sub>_i_</sub>, _R_<sub>_i_</sub>)
  - The ciphertext is _C_ = (_R_<sub>_r_</sub>, _L_<sub>_r_</sub>)

![](https://i.imgur.com/UGEd7fj.png)

#### Decryption
- Works same as encryption but with reversed order of keys
  - Split ciphertext block into two equal pieces _C_ = (_R_<sub>_r_</sub>, _L_<sub>_r_</sub>)
  - For each round _i_ = _r_, _r_-1,...,1 compute
    - _R_<sub>_i_-1</sub> = _L_<sub>_i_</sub>
    - _L_<sub>_i_-1</sub> = _R_<sub>_i_</sub> ⊕ _F_(_K_<sub>_i_-1</sub>, _L_<sub>_i_</sub>)
  - Plaintext is _M_ = (_L_<sub>_0_</sub>, _R_<sub>_0_</sub>)

### DES
- Key size is 56 bits (can be broken in 10 hours)
- Steps:
  - Initial permutation on plaintext
  - 16 rounds of Feistel cipher
  - Opposite of initial permutation


- Block length of 64 bits
- Number of rounds r is 16
- Key length is 56 bits
- Round key length is 48 bit for each subkey _K_<sub>0</sub>,...,_K_<sub>15</sub>. Derived from 56 bit key via special key schedule.


![](https://i.imgur.com/4XwYIbb.png)

#### DES Feistel function
- Four stage procedure:
  - **Expansion permutation:** Expand 32 bit message half block to 48 bit block by doubling 16 bits and permuting them.
  - **Round key addition:** Compute XOR of 48 bit block with round key _K_<sub>_i_</sub>.
  - **S-Box:** Split 48 bit into eight 6 bit blocks. Each is given as input to 8 substitution boxes, substituting 6 bit blocks with 4 bit blocks.
  - **P-Box:** Combine the eight 4 bit blocks to 32 bit block and apply another permutation.

#### DES operation notation
- **Cyclic shifts** on bitstring blocks: _b_ <<< _n_ means move bits of block _b_ by _n_ to the left, bits that would have fallen out are added at the right of _b_. Similar but in the other direction for _b_ >>> _n_.
- **Permutations on the position of bits**: Written as output order of input bits.
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
- Computing different keys for each round
- 64 bit key (56 bit key with 8 parity bits)
- Steps:
  - Apply PC-1 permutation to remove parity bits
  - Split in half to get (_C_<sub>0</sub>, _D_<sub>0</sub>)
  - For each round, compute:
    - _C_<sub>_i_</sub> = _C_<sub>_i_-1</sub> <<< _p_<sub>_i_</sub>
    - _D_<sub>_i_</sub> = _D_<sub>_i_-1</sub> <<< _p_<sub>_i_</sub>
    - Where _p_<sub>_i_</sub> = 1 (if _i_ = 1,2,9,16) else 2
  - Join _C_<sub>i</sub> and _D_<sub>i</sub> and apply permutation PC-2 to produce a 48 bit output

### Security of block ciphers (03/10/2017)
{missing notes here}

### Back to DES
- Good design but only 56 bit keys - 2<sup>56</sup> security
- {missing notes here}
