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
