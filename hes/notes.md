# Hardware and Embedded Systems Security

## Implementation of Symmetric Cryptography
### Block Ciphers
- Encrypts fixed block size (_n_ in bits) plaintext (_p_) to fixed block size
  (_n_) ciphertext (_c_) using a key (_k_) of fixed size (_m_)
- Examples:

Block Cipher | _n_ | _m_
-------------|:---:|:---:
AES-128 | 128 | 128
DES | 64 | 56
3DES (Encrypt-Decrypt-Encrypt) | 64 | 112 or 168
PRESENT | 64 | 80 or 128

#### Round Function
- Block ciphers are usually _iterated_ ciphers (a round function is applied
  many times to map to ciphertext)
- Round function operates on _state_ of cipher
  * State usually initialised with plaintext
- In a round (_i_), a round key (_k_<sub>_i_</sub>) enters the function with
  the current state (_s_<sub>_i_</sub>)
- The final state is the ciphertext

#### Building Blocks
 - **Diffusion**: change in single single input bit affects all output bits
   with 50% probability
 - **Confusion**: relationship between input and output is
   "sufficiently complex"


- Key addition: key is combined with the state through addition-like op, e.g.
  XOR
- S-Box: substitution box providing a non-linear mapping over small no. of bits
  e.g. 8-to-8 or 6-to-4
  * Provides **confusion**
  * DES has many seemingly random S-boxes
  * AES has one algebraic structure S-box
- Permutation: permutation providing a linear mapping such that S-box output
  affects many S-box inputs in next round.
  * Provides **diffusion**
  * DES has bitwise permutations
  * AES has bytewise/wordwise operations

#### PRESENT Pseudocode
<img src="https://i.imgur.com/thJGH3W.png" style="width: 20em;" />

- _n_ = 64, _m_ = 80
- addRoundKey: bitwise XOR of state _s_ and round key _k_<sub>_i_</sub>
- sboxLayer: 4-to-4 PRESENT S-Box to state in groups of 4 bits
  * 64 / 4 = 16 times S-Box applied
- pLayer: bitwise permutation
  * bit at pos _j_ is permuted to new position:
  * <img src="https://i.imgur.com/EDpbhmE.png" style="width: 12em;" />
  * bit 0 to pos 0, 1 to 16, 2 to 32, etc.

#### Bitwise Operations in C
- getbit: return (word >> bit) & 0x1
- setbit: \*word |= (1 << bit)
- clrbit: \*word &= ~(1 << bit)

#### S-Box Layer Optimisations
- Normally implemented as a lookup table, so usually fast
- (Time) Can merge multiple S-Boxes to one lookup table
  e.g. 2x 4-to-4 -> 1x 8-to-8
- (Time) Can load S-Box into RAM
- (Memory) Can have smaller S-Box and lookup lower and upper nibble
  * Likely will cause additional time overhead
- Implement S-Box as combinatorial logic
  * Each output bit is represented by a boolean expression on input bits

#### Permutation Layer Optimisations
- Permutations on byte level usually fast

### Table-based Software Optimisations
- 
