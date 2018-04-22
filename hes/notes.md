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

## Implementation of Asymmetric (Public Key) Cryptography

- Higher computational and storage requirements
- Longer keys
- Easy for PCs, harder for embedded systems

### RSA
- _l_-bit RSA
- Pick secret primes _p,q_, each about <sup>_l_</sup>/<sub>2</sub> size
- _n_ = _p * q_
- Pick public exponent _e_
- **Public key**: (_n, e_)
- **Private Key**: (_p, q, d_) where _d_ = _e<sup>-1</sup>_ mod _𝜙_(_n_)
- **Encrypt _x_**: _y_ = _x<sup>e</sup>_ mod _n_
- **Decrypt _y_**: _x_ = _y<sup>d</sup>_ mod _n_

### Long-Number Arithmetic
- Required for computations with numbers > width _w_ of a single CPU register

#### Number Representation
- With a processor with _w_-bit registers, given an _l_-bit number _u_,
we store the number in _k_ = ceiling(<sup>_l_</sup>/<sub>_w_</sub>)
- Example:
  * Take 12345678 in binary this is a 24-bit number
  _u_ = (101111000110000101001110)<sub>2</sub>
  * We have a CPU with 5-bit registers
  * ceil(24/5) = 5
  * _u_ = (01011 11000 11000 01010 01110)<sub>2<sup>5</sup></sub>
  (added a leading zero)
  * _u_ = (a<sub>4</sub>, a<sub>3</sub>, a<sub>2</sub>, a<sub>1</sub>,
  a<sub>0</sub>)<sub>2<sup>5</sup></sub>

#### Addition
<img src="https://i.imgur.com/ovyUymI.png" style="width: 30em;"/>

- mod: take lower limb of result _t_
- floor(_t/b_): take upper limb of result _t_
- _t_ must be a two limb number for algorithm to work


- Some architectures have an add-with-carry (ADDC) instruction
- Use workarounds to implement add-with-carry in higher-level languages
  * e.g. _if t >= b: c = 1 else c = 0_
  * In this example, execution time is dependent on inputs (less secure)

**Subtraction**
- Done similar to addition, carry becomes "borrow" bit
- Can work in two's complement representation
  - Negative sign by negating each bit and adding 1

**Complexity**
- _k_ base-_b_ additions-with-carry
- _2k_ if no ADDC instruction
- Complexity O(_k_)

#### Multiplication
<img src="https://i.imgur.com/a0OCNZf.png" style="width: 35em;" />

- Product of _k_-limb and _m_-limb numbers is at most _k_ + _m_ length

<img src="https://i.imgur.com/kcYrjfg.png" style="width: 30em;" />

**Complexity**
- Requires _k_ + _m_ base-_b_ multiplications and _2_(_b_ + _m_) base-_b_ shifts
- If _k_ = _m_, complexity O(_k_<sup>2</sup>)

#### Karatsuba Multiplication
- Split two _k_-digit numbers _u, v_ into halves of equal size
  _k_ = ceil(<sup>_k_</sup>/<sub>_2_</sub>)
- Write values as:
  * _u_ = _u_<sub>H</sub> * b<sup>_k_</sup> + _u_<sub>L</sub>
  * _v_ = _v_<sub>H</sub> * b<sup>_k_</sup> + _v_<sub>L</sub>
- _u * v_ written as:

  (u<sub>H</sub> * b<sup>k</sup> + u<sub>L</sub>) *
  (v<sub>H</sub> * b<sup>k</sup> + v<sub>L</sub>) =
  u<sub>H</sub>v<sub>H</sub>b<sup>2k</sup> +
  (u<sub>H</sub>v<sub>L</sub> +u<sub>L</sub>v<sub>H</sub>)b<sup>k</sup> +
  u<sub>L</sub>v<sub>L</sub>
- Middle part (u<sub>H</sub>v<sub>L</sub> +u<sub>L</sub>v<sub>H</sub>)
  can be expressed as:

  (u<sub>H</sub> + u<sub>L</sub>) * (v<sub>L</sub> + v<sub>H</sub>) −
  u<sub>H</sub>v<sub>H</sub> − u<sub>L</sub>v<sub>L</sub> =
  u<sub>H</sub>v<sub>L</sub> + u<sub>L</sub>v<sub>H</sub>
- u<sub>H</sub>v<sub>H</sub> and u<sub>L</sub>v<sub>L</sub> are already computed
  once, so we save one multiplication
- Method expressed as:
  * D<sub>0</sub> = u<sub>L</sub> * v<sub>L</sub>
  * D<sub>2</sub> = u<sub>H</sub> * v<sub>H</sub>
  * D<sub>1</sub> = (u<sub>H</sub> + u<sub>L</sub>) *
    (v<sub>L</sub> + v<sub>H</sub>)
  * Hence:
  * u * v = D<sub>2</sub>b<sup>2k</sup> +
    [D<sub>1</sub> - D<sub>2</sub> - D<sub>0</sub>]b<sup>k</sup> + D<sub>0</sub>

**Recursion**
- Algorithm should be implemented recursively to compute sub-products
- In practice, algorithm applied until threshold, then schoolbook algorithm used
  * At some point, additional additions/management become more expensive than
    the saved multiplication

**Complexity**
- O((<sup>3</sup>/<sub>4</sub>)<sup>i</sup> k<sup>2</sup>)
- Refactor to O(k<sup>1.585</sup>) for two numbers of length k = 2<sup>i</sup>

#### Modulo Arithmetic
- Complicated algorithms
- Dividing 2k-digit number by a k-digit number, requires k * (k - 2)
  multiplications and k divisions
- Barrett reduction is an optimisation by performing an expensive
  pre-computation floor(b<sup>2k</sup> / n)

### Exponentiation Algorithms
**Square-and-Multiply (SAM)**
- Interleaves modular reduction and multiplications
  * Square first, then reducing would require huge storage/computation

<img src="https://i.imgur.com/OIQ9n7w.png" style="width: 35em;" />

- _t_ = exponent length
- Scans binary exponent _e_ from left to right
- Squares for each bit and multiplies if exponent bit = 1

<img src="https://i.imgur.com/JP0aIRQ.png" style="width: 40em;" />

**Complexity**
- On average, assume half of the bits are set
- We need (t-1)/2 multiplications and t-1 squares

### Elliptic Curve Cryptography
- 2048-bit keys recommended in RSA, for ECC 256-bit is sufficient
- Faster long-number ops due to shorter key inputs
- Single group operation requires multiple long-number operations
- ECC better suited for constrained embedded devices

