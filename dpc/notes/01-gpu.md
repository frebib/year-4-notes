# Distributed and Parallel Computing - Parallel Computing

## Task vs Data Parallelism (11/1/2017)
Types of parallelism:
- Task based: do different operations in parallel
  - e.g. multiply/add
  - e.g. GNU Make (running subtasks in parallel)
  - Suitable for multi-core CPU or networks of computers
- Data based: same operations in lock step on different data in parallel
  - e.g. image ops on all pixels in an image simultaneously
  - Suitable for GPUs

Latency vs Throughput:
- Latency oriented
  - Get each result with minimum delay
  - Get first result ASAP, even if it slows getting all results
- Throughput oriented
  - Get all results back with minimum delay
  - Doesn't matter how long to get each result, so long as total time is short
    as possible

## Latency Oriented Processors - Standard CPUs
- Large cache to speed up memory access
  - Temporal/Spatial locality, Working sets (likely to use same value from
    memory again, likely to use value close to used value from memory)
    - Ensure each operation has smallest probability of fetching from slow
      memory
    - May be a good idea to pre-fetch data
- Complex control units
  - Short pipelines, Branch prediction, Data forwarding
    - Make each instruction finish ASAP with minimal pipeline stalls
- Complex, energy expensive ALUs
  - Large complex transistor arrangements
    - Minimise no. of clock cycles per operation, get result ASAP

## Throughput Oriented Processors - GPUs
- Small caches
  - For _staging_ data
    - Get blocks of data for groups of threads to work on
    - Avoids separate fetches from each thread
  - Not for temporally/spatially located data
- Simple control units
  - No branch prediction or data forwarding
  - Control shared by multiple threads working on different data
- Simple energy efficient ALU
  - Long pipeline
  - Large no. of cycles per operation, heavily pipelined
    - Long wait for 1st result (filling the pipeline), following results come
      quickly
  - Requires large no. of threads to keep processor occupied

## Von Neumann Architecture
- CPU
![](https://i.imgur.com/97AvFWj.png)
- Modified for GPU
  - One control unit but many processing units
![](https://i.imgur.com/8tV9eRa.png)

## Compiling for CUDA
- Conceptually, host CPU and GPU are separate devices, connected by
  communication path
  - Need to generate separate code for each device. Nvidia compiler for CUDA
    "nvcc"
  - nvcc takes C/C++ with Nvidia extensions, separates and compiles GPU code
    itself, passes host code to host for compilation
  - Result binary contains host and device binary, downloaded to device from
    host when run

## Programming in CUDA
- Have to identify if function runs on host, device or both. Identify where it's
  callable from:
  - Host: `__host__ void f(...)`
    - Default, can be omitted
    - Callable from host only
  - Device: `__global__ void f(...)`
    - Special functions called _kernel_ functions
    - Callable from host only, how host gets code to run on GPU
  - Device: `__device__ void f(...)`
    - Callable from device only, helper functions to kernel functions and other
      GPU functions
  - Both: `__host__ __device__ void f(...)`
    - Generates host and device function, same code can run on both. Host/device
      cannot call other version

## GPU Computational Unit Structure
- When calling kernel function, specify how threads are organised to execute it
  - Every thread executes same kernel function
  - Different GPU devices can support different no. of threads
  - Making thread structure uniform would sacrifice potential computing power

## CUDA Thread Issues
- Don't want fixed no. of threads to dictate size of largest vector we can add
- Don't want to change code to run on different GPU with different thread count
- Want to be able to organise threads to co-locate groups of threads on sets of
  processing units, taking advantage of shared caches and synchronisation
  facilities.

- Nvidia GPUs organise threads into hierarchical structure
  - A _Grid_ is a collection of _Blocks_
  - A _Block_ is a collection of _Threads_
  - A _Thread_ is execution of a _kernel_ on a single processing unit

## CPU Thread Organisation (16/01/2018)
There is the concept of a warp:
- A set of tightly related threads, must execute fully in lock step with each
  other
- Not part of the CUDA spec, but a feature of all Nvidia GPUs in low level
  hardware design
- No. of threads in a warp is a feature of GPU but current GPUs mostly 32
- Low level basis of thread scheduling on a GPU. If a thread is scheduled to
  execute, so must all other threads in warp
- Executing same instructions in lock step, all threads in warp have same
  instruction exec timing

## Grid/Block/Thread
- A block can have between 1 and max block size no. of threads for GPU. Is
  high-level basis for thread scheduling
- Because of warps, block size should be multiple of warp size, otherwise blocks
  are padded with remaining threads from a warp and many are wasted
- Grids have a large no. of blocks, more than can be executed at once
- Grid = whole problem divided into bitesize blocks
- (Missing notes)

## Invoking Kernel Functions
(Missing notes)

# Measuring Parallel Speedup

## Terms
- Latency: time from start to end of task
- Work: measure of work to do, i.e. FLOPS, num images processed
- Throughput: work done per time unit
- Speedup: improvement in speed from using 1 computational unit to `P`
  computational units
  - `S(p) = T1 / Tp` where `T1` is time taken for one computational unit and
    `Tp` is time taken for `p` computational units
  - Perfect linear speedup: `S(p) = p`
    - Means that for every computational unit we add, we get an extra `T1` boost
      to work done in a time unit
- Efficiency: ratio of `S(p) : p`
  - `E(p) = T1 / (Tp * p) = S(p) / p`
  - Measures how well computational units are contributing to latency/throughput
  - Perfect linear efficiency: `E(p) = 1`

## Amdahl's Law
- `T1 = Tser + Tper` where
  - `T1` is time spent using 1 computational unit
  - `Tser` is time spent doing non-parallelizable work
  - `Tpar` is time spent doing parallelizable work
- Therefore, using `p` computational units gives us:
  - `Tp = Tser + (Tpar / S(p))`
- Therefore, overall speed up is:
  - `S'(p) = (Tset + Tpar) / (Tser + (Tpar / S(p)))`
  - TODO: Are these equations right?
- We can write `Tser` and `Tpar` using a time `T` and a fraction of it that is
  parallelizable `f`
  - `S'(p) = ((1 - f)T + fT) / ((1 - f)T + (fT / S(p)))`
  - `S'(p) = 1 / (1 - f + (f / S(p)))`
- If as `p` tends to infinity, so does `S(p)`, the limit of speed is `Tser` or
  `(1 - f)T`

## Gustafson-Barsis Law
- Focuses on _workload_ instead of _time_
- `W = (1 - f)W + fW` where
  - `W` is the total workload executed
  - `f` is the fraction of the workload that is parallelizable
- Therefore, with `s` as some speedup factor for parallel parts:
  - `Ws = (1 - f)W + sfW`
- We can measure the ratio between `Ws` and `W`, giving us speedup:
  - `S = Ws / W`
  - `S = ((1 - f)W + sfW) / ((1 - f)W + fW)`
  - `S = 1 - f + fs`

# Using Warps Effectively
- A grid contains a collection of blocks, which contain a collection of threads
- Threads are executed in warps
  - e.g. 1024 threads in a block, 32 threads in a warp, 1024/32=32 warps needed
    to execute a block
  - TODO: How do warps relate to streaming multiprocessors?

## Synchronisation
- Warps execute in lock step, so implicit synchronisation
- For synchronisation in a block, we use `__syncthreads()`
  - All threads in a block will hit this point and wait
  - Once all threads reach it, execution will continue
  - Can not call `__syncthreads()` in a conditional
- Can not synchronise in a grid

## Warp allocation
- In a 1D block
  - Warp 0 has threads 0-31
  - Warp 1 has threads 32-63
- In a 2D block
  - Let's say block size of `(4, 4, 4)`
    - Thread `(0, 0, 0)` is given index 0
    - Thread `(0, 0, 1)` is given index 1
    - Thread `(0, 1, 0)` is given index 4
    - Thread `(0, 1, 2)` is given index 6
    - Thread `(1, 0, 0)` is given index 16
    - etc.
  - Then we allocate the warps as we did with 1D block, using these new indices

## Divergence
- In a warp, say threads 0-15 take branch A, and threads 16-31 take branch B.
  This is called divergence.
- They all have to execute the same commands, which means that the complete warp
  has to process branch A _and_ branch B
- If they all take branch A, branch B does not have to be executed
- We want to minimise divergence, and will design our algorithms so that threads
  next to each other in terms of index will execute the same instructions

# Prefix Sum
- Apply some operator to a list of data and store the cumulative output
- e.g.
  - List is [1, 2, 1, 3]
  - Operator is addition
  - Output is [1, 3, 4, 7]

## Block prefix sum
- Only works within a single block

### Hillis Stelle Horn
- Work through the list, where thread `n` adds together:
  - Items `n` and `n - 1`
  - Then items `n` and `n - 2`
  - Then items `n` and `n - 4`
  - etc.
- FLOPS:
  - `(N - 1) + (N - 2) + (N - 4) + ...`
  - For 1024, serial has 1023 FLOPS
  - For 1024, HSH has 9217 FLOPS
  - BAD!

### Blelloch Scan
- Two phases, reduction and distribution
- Can optimise through copying block into shared memeory, performing operations,
  and then copying back (this works for HSH too)
- Hopefully we don't get examined on this because it was in the assignment...
  imma skip.
- FLOPS:
  - Reduction phase: `(N/2) + (N/4) + (N/8)...`
  - Distribution phase: `...(N/8 - 1) + (N/4 - 1) + (N/2 - 1)`
  - For 1024, Blelloch has 2037 FLOPS

## Full prefix sum
1. Perform block scan on all blocks in the list
2. Extract the last value of each block into new list
3. Perform block scan on this list
4. Add this list back into the original block scanned list

# CUDA Programming Tips

## Coalesced Global Memory Access
- Global memory read/writes in transactions of size 32, 64, or 128 bytes
- Each memory transaction takes approx the same amount of time, so writing 8
  bytes is equivalent to writing 128 bytes
- If consecutive threads access consecutive bytes, then all reads will be done
  in one memory transaction
- If consecutive threads access non-consecutive bytes, then all reads will be
  done in separate memory transactions, which is a lot slower

### Array of Structs (AoS) or Struct of Arrays (SoA)
- In CUDA programming, favour SoA as it helps coalesced memory accesses

## Shared Memory Banks
- 2 orders of magnitude faster than global memory accesses
- There are 32 banks (since compute 2.0)
- 32 consecutive shared memory accesses are spread across the 32 banks
- `n` reads to `n` different banks can be done in one read operation
- `n` reads to `1` bank has to be done in `n` read operations - must be done
  serially
- With exception:
  - `n` reads to the same address in the same bank only takes one operation
  - TODO: What do these other exceptions mean?

## Atomic Operations
- Sometimes we need to perform an atomic operation, e.g. `array[i] += 1;`
  - This line contains a read, a modification, and a write
- We have some options:
  - Use `__syncthreads()` to make sure all threads can perform the operation
    uninterupted
  - Restructure so that one thread collects all the updates and performs them
  - Use an atomic operation: `atomicAdd(&(array[i]), 1);`
- TODO: Is this fast? How does it work? Not mentioned in the slides

# GPU Programming Patterns
- Map
  - One-to-one, each thread responsible for converting one element
- Gather
  - Read many, write one
  - No read/write races still
- Scatter
  - Read one, write many
  - Need to be careful with writes
- Stencil
  - Special case of gather
  - Pattern of reads is constant across threads
- Transpose
  - AoS → SoA
- Reduce
  - All values into one single value
- Scan/sort
  - All-to-all (or at least many-to-all)

## Example - Histogram
- Each thread calculates value for some element, and increments histogram bin
- Need to do atomic add
  - This doesn't scale well if you have many elements writing to one histogram
    bin
- Improvement
  - Each thread calculates histogram for a subset of the data, no atomic adds
    here
  - Add to final result
  - Atomic add final results
- Improvement 2
  - Instead of adding final results, perform reduce operation
- Improvement 3
  - Sort the keys, and then reduce by key

# Sparse Matrix Multiplication

## Prerequisites
- Gather
  - One-to-one mapping, but which "ones" are included is not uniform
- Exclusive scan
  - The scan at index `i` does not contain the value at index `i` in the
    original array
- Segmented scan
  - Only cumulate results across specific ranges

## Conditionally Mapping
- We want to apply `f()` to elements that satisfy `p()`
- While all threads execute `p()`, only few will execute `f()`, meaning that
  there will be a lot of divergence
- So we can compact all elements that satisfy `p()` into one array, and then
  iterate over that - call this `compat()`
  - First, map `xs` through `p()`
    - `xs = [1, 3, 2, 3, 2, 4], p(x) = iseven(x)`
    - `bs = [f, f, t, f, t, t]`
  - Cast booleans from `p()` into `0/1`s
    - `is = [0, 0, 1, 0, 1, 1]`
  - Perform exclusive sum scan
    - `scan = [0, 0, 0, 1, 1, 2]`
  - Perform scatter with original `xs` with indices `scan` if `bs` satisfied for
    index
    - `2 → 0, 2 → 1, 4 → 2`
    - `[2, 2, 4]`
  - Perform some arbitrary `f()` on the final array
- Can use this for clipping 2D triangle into a viewport
  - If a triangle is outside the viewport, it maps to 0 triangles
  - If a triangle is inside the viewport, it maps to 1 triangle
  - If the triangle is partially inside the viewport, it maps to `n` different
    triangles
  - We can use `compat()` to allocate indices for these triangles

## Sparse Matrix Dense Vector Multiplication (SpMv)
Matrix representation of `X⋅Y`:
```
[0 b c][x]   [bx + cx]
[d e f][y] = [dy + ey + fy]
[0 0 i][z]   [iz]
```

We can represent this as:
- `V = [b, c, d, e, f, i]`: The values in the `X`, excluding zeros
- `C = [1, 2, 0, 1, 2, 2]`: The columns of the values in `V`
- `R = [0, 2, 5]`: The indices of values in `V` that start a row

Algorithm:
1. Gather from `Y` using `C`:
  - `G = gather([x, y, z], [1, 2, 0, 1, 2, 2])`
  - `G = [y, z, x, y, z, z]`
2. Map `V * G`
  - `M = map(_*_, zip(V, G))`
  - `M = [by, cz, dx, ey, fz, iz]`
3. Run segmented inclusive sum scan on `M`
  - `[by + cz, dx + ey + fz, iz]`

# Sorting on GPUs

## Odd-even Sort
- In every even step, thread `i` compares elements `2i` and `2i + 1`, and swaps
  if out of order
- In odd steps, thread `i` compares `2i + 1` and `2i + 2`
- `O(n)` steps, `O(n²)` work

## Parallel Merge Sort
- Start with trivially sorted segments of size 1
- Merge pairs of segments at each step
- End when there is only one segment
- Small segments:
  - Perform merge on one thread
- Medium segments:
  - Use multiple threads to merge segments
- Large segments (bigger than block size)
  - Use multiple blocks to handle each merge

### Merging on Multiple Threads
- Merging `A[]` and `B[]`
- Thread `i` looks at element `A[i]`
- Binary search for `A[i]` in `B[]`, get index `j`
- We now know to insert into new array at index `i + j`

### Merging on Multiple Blocks
- Split `A[]` and `B[]` into segments of size `k`
- Take each of the splitting values, and merge into a single list using previous
  algorithm
- Find each of these splitting values in the _other_ array
- e.g.
  - Have splitting values `a₁, a₂, a₃` and `b₁, b₂, b₃`
  - Merged, they become `a₁, b₁, b₂, a₂, b₃, a₃`
  - We take range `0 - a₁` from _both_ `A[]` and `B[]` (where `a₁` is binary
    searched for in `B[]`)
  - We merge these two ranges into the final array
  - We do the same for `a₁ - b₁`, `b₁ - b₂`, `b₂ - a₂` from the previously
    merged splitters array

## Bitonic Sort

### Bitonic Sequences
- A monotonic sequence is where each value is greater than the last, or less
  than the last, e.g. `[1, 2, 3, 4]`
- A bitonic sequence is where the values in the list change once, e.g.
  `[1, 2, 3, 4, 2, 1]`
- A bitonic sequence can be shifted circularly, e.g. for the previous example,
  `[3, 4, 2, 1, 1, 2]`, and still remain a bitonic sequence

### Bitonic Split
- You can split a bitonic sequence into two bitonic sequences
- This is done by splitting it in half, and comparing swapping elements between
  the splits so that the first split contains all the lower elements
```
[1, 2, 3, 4, 2, 1]
=> [1, 2, 3]
   [4, 2, 1]
=> [1, 2, 1]
   [4, 2, 3]
```

### Bitonic List → Monotonic List
- We can split the bitonic list repeatedly, until there is only one element in
  each bitonic list
- Since they only have one element, they are trivially sorted
- Due to the nature of bitonic splits, all the lists concatenated will be sorted
- But first, we need a bitonic list...

### Unordered List → Bitonic List
- Change vector into lists of two elements
- Each of these is trivially bitonic
- We then turn it into a monotonic list (using above method)
- We then group these lists together, e.g. `[a₁, a₂, a₃, a₄] → [a₁++a₂, a₃++a₄]`
- These lists are then bitonic, as we've concatenated two monotonic lists, but
  they are of size 4
- We do this until all elements are merged into a single bitonic list, and then
  turn the list into a monotonic (i.e. sorted) list

### Evaluation
- Algorithm is easily parallelizable
- `O(nlog²n)` steps
- Fastest for small lists

## Radix Sort
- Can sort integers
- Look at each integer's binary representation, and do a _stable_ split based on
  whether the least significant bit is 0/1
  - Stable means that when you sort, if two elements are equal then they do not
    change order
- Then do this for the 2nd least significant bit, then 3rd, etc.
- Complexity is `O(kn)` where `k` is the number of bits, and `n` is the size of
  the list
- Where to put each element can be done with the `compact` operation previously
  discussed
- Fastest for medium to large lists

# Floating Point Numbers
- IEEE-754 floating point number has:
  - 1 bit sign (`S`)
  - 8 bit exponent field (`E`)
    - Bias of 127, i.e. `exponent = E - 127`
    - 0 and 255 reserved for special numbers
  - 23 bit mantissa field (`M`)
- For normal numbers, implicit initial 1 bit in the mantissa is assumed
  - i.e. `010101 → 1010101`
- Special bit patterns in `S, E, M` for:
  - Positive/negative zero
  - Positive/negative infinity
  - NaN
  - Other sub-normal numbers
- For normal numbers:
  - `(-1)^S * (1 + (2^-23) * M) * 2^(E - 127)`
- For sub-normal numbers:
  - Difference between `0 - succ(0)` is far greater than `succ(0) -
    succ(succ(0))`
  - Non-zero numbers that are smaller than the magnitude of the smallest
    IEE-754 floating point number
  - If `E=0`, then do not use the implicit 1 bit in the mantissa

## Unit in Last Place (ULP)
- Given some number `x`, what is the shortest distance between the pair `a, b`
  where `a ≤ x ≤ b`
- IEEE-754 requires operations round to the nearest representable floating point
  number
  - i.e. the computed result must be with in 0.5 ULPs of the mathematically
    correct result

## Problem
- If we try to sum the list `[1000.0, 0.1, 0.1, 0.1...]` the result will always
  be `1000.0` because the operation `1000.0 + 0.1` results in `1000.0`
- Worst error is `O(n)`

### Solution: Sorting
- Sort the list as ascending first, then sum
- However, accumulated small values will get significantly larger that later
  values in the vector

### Solution: Kahan
- Accumulate the sum, but calculate a correction term
```c
  float kahan_add(float *xs, size_t len) {
    float sum = 0;
    float correction = 0;
    for (size_t i = 0; i < len; i++) {
      float corrected_next_term = xs[i] - correction;
      float new_sum = sum + corrected_next_term;
      correction = (new_sum - sum) - corrected_next_term;
      sum = new_sum;
    }
    return sum;
  }
```
- Worst error is `O(1)`
- Not easy to parallelise

### Solution: Parallel Addition
- Sort the list, then thread `i` performs `a[i*s] + a[i*s + (s / 2)]`
  - where `s` is the stride that starts at 2 and doubles on each iteration
- Starts with adding similar pairs, but difference increases as you go on
- Worst error is `O(log(n))`
- Poor thread blocking, memory access patterns
  - Could have thread `i` perform `a[i] + a[i + s]`
    - where `s` is the stride that starts at `len(a) / 2` and halves on each
      iteration
  - This needs careful original ordering of `a[]`

## Error Measurements
- Absolute error: `|v - v'|` where `v` is the true value, and `v'` is the
  approximation
- Relative error: `|v - v'| / |v|` when `v ≠ 0`

# Multi-dimensional Kernels
- Used for image analysis, matrix multiplication, spacial simulations
- Threads are essentially broken down into 1D again, for example with a `(2, 2,
  2)` dimensional block
  - `threadIdx = (0, 0, 0) → thread 0`
  - `threadIdx = (1, 0, 0) → thread 1`
  - `threadIdx = (0, 1, 0) → thread 2`
  - `threadIdx = (1, 1, 0) → thread 3`
  - etc.

## Coalesced Global Memory Access
- `D[blockIdx.x][blockIdx.y]` where `D` and block size is `2x2`
  - Thread `(0, 0) → 0` accesses `D + 0`
  - Thread `(1, 0) → 1` accesses `D + 2`
  - Thread `(0, 1) → 2` accesses `D + 1`
  - So we're not coalesced
- `D[blockIdx.y][blockIdx.x]` (we switch `x` and `y`)
  - Thread `(0, 0) → 0` accesses `D + 0`
  - Thread `(1, 0) → 1` accesses `D + 1`
  - Thread `(0, 1) → 2` accesses `D + 2`
  - So we're coalesced!

## Shared Memory Bank Conflicts
- `D[x][y]` where `D` and block size is `K x K` and `K` is a multiple of 32
  - Thread `(0, 0) → 0` accesses bank 0
  - Thread `(1, 0) → 1K` accesses bank 0
  - Thread `(2, 0) → 2K` accesses bank 0
  - Conflicts!
- `D[y][x]` (we switch `x` and `y`)
  - Thread `(0, 0) → 0` accesses bank 0
  - Thread `(1, 0) → 1K` accesses bank 1
  - Thread `(2, 0) → 2K` accesses bank 2
  - No conflicts!

## Transposing
- When transposing, we need to access both `D[y][x]` and `D[x][y]`, meaning one
  of the accesses will have uncoalesced global memory accesses, and shared
  memory bank conflicts
- Trick:
  1. Copy in a element of `D` into shared memory with good indexing
  2. `__syncthreads()`
  3. Copy out a different element with also good indexing

## Matrix Multiplication
- Naive: each thread handles an output element, and performs the dot product of
  the correct row and column.
  - For the "compute to global memory access" ratio, we have two global reads,
    one multiplication, one addition. This gives us a 1:1 ratio - not good
- Clever:
  - Do dot product for tiles of the outputs
    - e.g. if we have 64x64 matrices, and 32x32 tiles, we have 2x2 tiles
    - To calculate `O[0, 0]`:
      - First do partial dot products of `A[0, 0]` and `B[0, 0]`
      - Then do partial dot products of `A[1, 0]` and `B[0, 1]`
      - Sum the results for the final `O[0, 0]` values

