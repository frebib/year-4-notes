# Distributed and Parallel Computing

## Lecture One (11/1/2017)
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
  - Doesn't matter how long to get each result, so long as total time is short as possible

### Latency Oriented Processors - Standard CPUs
- Large cache to speed up memory access
  - Temporal/Spatial locality, Working sets (likely to use same value from memory again, likely to use value close to used value from memory)
    - Ensure each operation has smallest probability of fetching from slow memory
    - May be a good idea to pre-fetch data
- Complex control units
  - Short pipelines, Branch prediction, Data forwarding
    - Make each instruction finish ASAP with minimal pipeline stalls
- Complex, energy expensive ALUs
  - Large complex transistor arrangements
    - Minimise no. of clock cycles per operation, get result ASAP

### Throughput Oriented Processors - GPUs
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
    - Long wait for 1st result (filling the pipeline), following results come quickly
  - Requires large no. of threads to keep processor occupied

### Von Neumann Architecture
- CPU
![](https://i.imgur.com/97AvFWj.png)
- Modified for GPU
  - One control unit but many processing units
![](https://i.imgur.com/8tV9eRa.png)

### Compiling for CUDA
- Conceptually, host CPU and GPU are separate devices, connected by communication path
  - Need to generate separate code for each device. Nvidia compiler for CUDA "nvcc"
  - nvcc takes C/C++ with Nvidia extensions, separates and compiles GPU code itself, passes host code to host for compilation
  - Result binary contains host and device binary, downloaded to device from host when run

### Programming in CUDA
- Have to identify if function runs on host, device or both. Identify where it's callable from:
  - Host: `__host__ void f(...)`
    - Default, can be omitted
    - Callable from host only
  - Device: `__global__ void f(...)`
    - Special functions called _kernel_ functions
    - Callable from host only, how host gets code to run on GPU
  - Device: `__device__ void f(...)`
    - Callable from device only, helper functions to kernel functions and other GPU functions
  - Both: `__host__ __device__ void f(...)`
    - Generates host and device function, same code can run on both. Host/device cannot call other version

### GPU Computational Unit Structure
- When calling kernel function, specify how threads are organised to execute it
  - Every thread executes same kernel function
  - Different GPU devices can support different no. of threads
  - Making thread structure uniform would sacrifice potential computing power

### CUDA Thread Issues
- Don't want fixed no. of threads to dictate size of largest vector we can add
- Don't want to change code to run on different GPU with different thread count
- Want to be able to organise threads to co-locate groups of threads on sets of processing units, taking advantage of shared caches and synchronisation facilities.


- Nvidia GPUs organise threads into hierarchical structure
  - A _Grid_ is a collection of _Blocks_
  - A _Block_ is a collection of _Threads_
  - A _Thread_ is execution of a _kernel_ on a single processing unit
