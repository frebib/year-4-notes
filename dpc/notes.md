# Distributed and Parallel Computing

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
