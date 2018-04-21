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
  * Storing a-to-b table requires b \* 2<sup>a</sup> bits
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
- Permutations on byte level usually faster in software than bitwise
  * Architectures don't always have bitwise operations
- Bitwise permutations may be faster on hardware-based implementations

### Table-based Software Optimisations
- Combine S-Box and permutation layer
  * In PRESENT, instead of 4-to-4 bit, we use 4-to-64
  * Table size expands linearly e.g. 64 \* 2<sup>4</sup> = (b \* 2<sup>a</sup>)
  * Linear expansion raises fewer memory concerns

Example (saving 4 write ops to the state):
```C
// Apply S−Box
for (uint8t i = 0 ; i < 4 , i ++) {
  s[i] = sbox[s[i]];
}

// Permute bytes 0, 1, 2, 3 −> 2, 3, 1, 0
const uint8 t tmp = s[0];
s[0] = s[2];
s[2] = s[1];
s[1] = s[3];
s[3] = tmp;
```
vs
```C
// Permute bytes 0, 1, 2, 3 −> 2, 3, 1, 0 and apply S−Box
const uint8t tmp = s[0];
s[0] = sbox[s[2]];
s[2] = sbox[s[1]];
s[1] = sbox[s[3]];
s[3] = sbox[tmp];
```

- Minor effect with byte-oriented permutations (ShiftRows in AES)
- Cannot be applied directly to bitwise permutations since each S-Box output
  affects many bytes

**Creating the Larger Table (PRESENT S-Box Example)**

- S-Box output bits are stored at their permuted positions with remaining bits
set to zero

SP<sub>0</sub>
S-Box | 3 2 1 0 | … 48 … 32 … 16 … 0
---|---|---
0xC | 1 1 0 0 | … ..1 … ..1 … ..0 … 0
0x5 | 0 1 0 1 | … ..0 … ..1 … ..0 … 1
0x6 | 0 1 1 0 | … ..0 … ..1 … ..1 … 0
… | … | …

SP<sub>1</sub>
S-Box | 3 2 1 0 | … 49 … 33 … 17 … 1 0
---|---|---
0xC | 1 1 0 0 | … ..1 … ..1 … ..0 … 0 0
0x5 | 0 1 0 1 | … ..0 … ..1 … ..0 … 1 0
0x6 | 0 1 1 0 | … ..0 … ..1 … ..1 … 0 0
… | … | …

- For the first S-Box, only bits 0, 16, 32 and 48 can be non-zero, for the
  second S-Box, only bits 1, 17, 33 and 49, and so on
- Tables for each S-Box instance are re-combined into one state using bitwise
  XOR or OR
- There will only be at most one 1 at each bit position

**Efficiency and Cost**
- Speed-up by avoiding bit permutations
- Combined table requires more memory
- Program code memory saved from removing permutation implementation
- Structure of PRESENT permutation means we can save memory by storing the
  combined table once, looking up a value and shifting it left by one for each
  S-Box
- Could combine table approach with S-Box merging, approx halving S-Box lookup
  and permutation

### Bitslicing
- Smallest addressable unit on processor, normally a byte
- Could store each bit in a byte but with significant wasted space
- Bitslicing works on idea that we usually encrypt many blocks
- Bitslicing allows to "reclaim" some bits that would be lost in approach above

#### Expanded Form
Where each bit is represented in a byte.

**Key Addition**
- Both key and state are in "expanded" form, can XOR them byte-wise

**Permutation Layer**
- Becomes byte-wise permutation
- Example of byte-wise PRESENT permutation:
```C
state_out[0] = state[0];
state_out[16] = state[1];
state_out[32] = state[2];
state_out[48] = state[3];
state_out[1] = state[4];
// …
```

**S-Box Layer**
- Can no longer be easily implemented as a LUT
- Instead, represent outputs as boolean functions in input bits
  * We Mainly look at Algebraic Normal Form

**Modification to "Reclaim" Bits**
- Store plaintext in bitsliced state _s_'[0...63]
  * First bit of first block _p_<sub>_0_</sub> goes into bit 0 of _s_'[0]
  * First bit of second block _p_<sub>_1_</sub> goes into bit 1 of _s_'[0]
  * Second bit of _p_<sub>1</sub> goes into bit 1 of _s_'[1]
  * etc.
- Apply key addition, S-Box and permutation
- Map _s'_ back to normal representation

**Complexity**
- Significant performance increase due to operations saved for permutations
- Key addition layer keeps similar performance
- S-Box more costly, depends on number of boolean operations (more = bad)
- Memory overhead since multiple cipher states stored at once
- Code size may increase

#### Algebraic Normal Form
- Representation of boolean functions
- Use Fast Fourier Transform (FTT)-like algorithm to compute functions
  * Write the truth table for function inputs
  * Apply "butterfly" _n_ times, with spacing
  σ = 2<sup>0</sup> = 1, 2<sup>1</sup>, 2<sup>2</sup>, ..., 2<sup>n−1</sup>


Butterfly for computing ANF:

![](https://i.imgur.com/1N3B7Cu.png)

A full ANF butterfly table:

![](https://i.imgur.com/kGQgcEo.png)

- We take the rows that are set to one in the final column and use the inputs
  of these rows to form the boolean function
- If 000 is set, the result is inverted (+1)
- Example table above results in: x<sub>2</sub> + x<sub>1</sub> +
  x<sub>1</sub> * x<sub>2</sub>... + 1
