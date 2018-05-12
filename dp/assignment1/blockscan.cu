/*
 * Name:    Joe Groocock
 * ID:      1467414
 *
 * Goals:
 *   - Block scan       ✓
 *   - Full scan        ✓
 *   - BCAO             ✓
 *
 * Performance:
 *   - Block w/o BCAO   0.61907 ms
 *   - Block w/  BCAO   0.44096 ms
 *   - Full  w/o BCAO   1.04813 ms
 *   - Full  w/  BCAO   0.85840 ms
 *
 * Hardware:
 *   - CPU:     i5 4690K @ 4.0Ghz
 *   - GPU:     GTX 1070 @ 1.8Ghz
 *
 * Optimisations:
 *   - Using the constant BLOCK_SIZE macro instead of a variable read from the
 *     user or calculated allows the compiler to inline many computations at
 *     compile-time and unroll loops through constant propogation. This gives a
 *     ~30% performance improvement at runtime.
 *   - Using the smallest possible BLOCK_SIZE with a level-3 scan in most cases
 *     is marginally faster than a fixed value of 1024 (/whatever the maximum is
 *     for the hardware) so is preferred.
 *   - Often running multiple scans back-to-back or running the process multiple
 *     times reduces the runtime slightly. I'm putting this down to GPU cache
 *     utilisation, most likely.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/param.h>

#include <cuda_runtime.h>

///////////////////
// CONFIGURATION //
///////////////////

/* Define BCAO to enable 'Bank Conflict Avoidance Optimization' */
#define BCAO 1
/* Define MULTILEVEL to enable L2/L3 scans and blockadd */
#define MULTILEVEL 1
#define GPU_SINGLETHREAD 1
#define BLOCK_SIZE 256

//////////////////
//////////////////

//#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
#define CONFLICT_FREE_OFFSET(n) \
    (((n) >> LOG_NUM_BANKS) + ((n) >> (2 * LOG_NUM_BANKS)))


/*
 * A helper macro to simplify handling cuda error checking
 */
#define cudaErr(e, msg) { \
    cudaError_t err = e; \
    if (err != cudaSuccess) { \
        printf("Error: %s: %s <%s:%d@%s>\n", msg, cudaGetErrorString(err), \
                __FILE__, __LINE__, __func__); \
        exit(EXIT_FAILURE); \
    } \
}

#define printArr(pre, arr, len, _ofs, _count) { \
    uint32_t ofs = MAX(0, _ofs); \
    uint32_t count = MIN(_count, len - ofs); \
    printf("%s%s", pre, (ofs == 0 ? "[" : "[.. ")); \
    for(uint acc = ofs; acc < ofs + count; acc++) \
        printf("%2d, ", arr[acc]); \
    printf("%2d%s\n", arr[ofs + count], (ofs + count >= len ? "]" : " ..]")); \
}

#define timespec_diff(a, b, out) { \
    if (((b)->tv_nsec - (a)->tv_nsec) < 0) { \
        (out)->tv_sec = (b)->tv_sec - (a)->tv_sec - 1; \
        (out)->tv_nsec = (b)->tv_nsec - (a)->tv_nsec + 1000000000; \
    } else { \
        (out)->tv_sec = (b)->tv_sec - (a)->tv_sec; \
        (out)->tv_nsec = (b)->tv_nsec - (a)->tv_nsec; \
    } \
}

#define scancmp(msg, ref, out, len, ms, extra) { \
    long idx = arrcmp((ref), (out), sizeof(int), (len)); \
    if (idx > 0) { \
        printf("    - [!] " msg " differs at index %zu (%.5f ms)\n", idx - 1, (ms)); \
        extra \
        /* Print partial array section for debugging */ \
        printArr("      - ref: ", ref, len, idx - 4, 12); \
        printArr("        gpu: ", out, len, idx - 4, 12); \
    } else { \
        printf("    - [✓] " msg " success (%.5f ms)\n", (ms)); \
    } \
}

/**
 * Compares two arrays for equality
 * @param arr array to compare
 * @param brr array to compare
 * @param elem_sz size of each array element (in bytes)
 * @param len length of the smallest array, in elements (not bytes)
 * @return 0 when arr and brr are identical otherwise nth element where they
 *         first differ (index + 1)
 */
uint32_t arrcmp(void *arr, void *brr, uint32_t elem_sz, uint32_t len) {
    for (uint32_t i = 0; i < len; i++) {
        uint32_t idx = i * elem_sz;
        if (memcmp((uint8_t *) arr + idx, (uint8_t *) brr + idx, elem_sz) != 0)
            return i + 1;
    }
    return 0;
}


// tmp[] is local to the block, not global to the array
extern __shared__ int tmp[];
__global__ void prescan(int *out, int *in, int *last, uint32_t count) {

    uint32_t thid = threadIdx.x;
    uint32_t thid2 = thid << 1;
    uint32_t offset = 1;

    // Offset of block within (full) array
    uint32_t blockOfs = blockIdx.x * BLOCK_SIZE;

#ifdef BCAO
    uint32_t ai = thid;
    uint32_t bi = thid + (BLOCK_SIZE >> 1);
    uint32_t bankOffsetA = CONFLICT_FREE_OFFSET(ai);
    uint32_t bankOffsetB = CONFLICT_FREE_OFFSET(bi);
    tmp[ai + bankOffsetA] = in[ai + blockOfs];
    tmp[bi + bankOffsetB] = in[bi + blockOfs];
#else
    tmp[thid2]     = in[blockOfs + thid2];
    tmp[thid2 + 1] = in[blockOfs + thid2 + 1];
#endif

    // build sum in place up the tree
    for (uint32_t d = BLOCK_SIZE >> 1; d > 0; d >>= 1) {
        __syncthreads();

        // Ensure we stay within the bounds of the data size
        if (thid < d) {
            uint32_t aii = offset * (thid2 + 1) - 1;
            uint32_t bii = offset * (thid2 + 2) - 1;
#ifdef BCAO
            aii += CONFLICT_FREE_OFFSET(aii);
            bii += CONFLICT_FREE_OFFSET(bii);
#endif
            tmp[bii] += tmp[aii];
        }

        offset <<= 1;
    }

    if (thid == 0) {
#ifdef BCAO
        uint32_t lastIdx = BLOCK_SIZE - 1 + CONFLICT_FREE_OFFSET(BLOCK_SIZE - 1);
#else
        uint32_t lastIdx = BLOCK_SIZE - 1;
#endif

        if (last != NULL) {
            // save the last element before clearing it
            last[blockIdx.x] = tmp[lastIdx];
        }
        // clear the last element
        tmp[lastIdx] = 0;
    }

    // traverse down tree & build scan
    for (uint32_t d = 1; d < BLOCK_SIZE; d <<= 1) {
        offset >>= 1;
        __syncthreads();

        if (thid < d) {
            uint32_t aii = offset * (thid2 + 1) - 1;
            uint32_t bii = offset * (thid2 + 2) - 1;
#ifdef BCAO
            aii += CONFLICT_FREE_OFFSET(aii);
            bii += CONFLICT_FREE_OFFSET(bii);
#endif

            int t = tmp[aii];
            tmp[aii] = tmp[bii];
            tmp[bii] += t;
        }
    }
    __syncthreads();

    // write results to device memory
#ifdef BCAO
    out[ai + blockOfs] = tmp[ai + bankOffsetA];
    out[bi + blockOfs] = tmp[bi + bankOffsetB];
#else
    out[blockOfs + thid2]     = tmp[thid2];
    out[blockOfs + thid2 + 1] = tmp[thid2 + 1];
#endif
}

__global__ void blockadd(int *arr, uint32_t len, int *sums) {
    uint32_t dstIdx = threadIdx.x + blockDim.x * blockIdx.x;
    if (dstIdx < len) {
        arr[dstIdx] += sums[blockIdx.x];
    }
}

void blockscan_gpu(int *arr, uint32_t len, int *out, float *ms) {

    // Length in bytes
    uint32_t bytLen = len * sizeof(int);
    uint32_t shm_sz = (BLOCK_SIZE * 4) * sizeof(int);
    // Number of blocks [ ceil(tc->len / BLOCK_SIZE) ]
    uint32_t grid_sz = 1 + (len - 1) / (BLOCK_SIZE);
    uint32_t l3_grdsz = 1 + (grid_sz - 1) / (BLOCK_SIZE);

    int *gpuIn = NULL,    *gpuOut = NULL,
        *gpuSums = NULL,  *gpuIncs = NULL,
        *gpuSums2 = NULL, *gpuIncs2 = NULL;

    cudaErr(cudaMalloc(&gpuIn, bytLen), "cudaMalloc");
    cudaErr(cudaMalloc(&gpuOut, bytLen), "cudaMalloc");
    cudaErr(cudaMalloc(&gpuSums, grid_sz * sizeof(int)), "cudaMalloc");
#ifdef MULTILEVEL
    cudaErr(cudaMalloc(&gpuIncs, grid_sz * sizeof(int)), "cudaMalloc");
    cudaErr(cudaMalloc(&gpuSums2, l3_grdsz * sizeof(int)), "cudaMalloc");
    cudaErr(cudaMalloc(&gpuIncs2, l3_grdsz * sizeof(int)), "cudaMalloc");
#endif

    // Create Device timer event objects
    cudaEvent_t start, stop;
    cudaErr(cudaEventCreate(&start), "cudaEventCreate");
    cudaErr(cudaEventCreate(&stop), "cudaEventCreate");

    // Copy host array to GPU memory
    cudaErr(cudaMemcpy(gpuIn, arr, bytLen, cudaMemcpyHostToDevice), "cudaMemcpy");

    /*
     * Start the timer!
     */
    cudaErr(cudaEventRecord(start, 0), "cudaEventRecord");

    // <<< blocks-per-grid, threads-per-block, shared-mem(bytes) >>>
    prescan<<<grid_sz, BLOCK_SIZE / 2, shm_sz>>>(gpuOut, gpuIn, gpuSums, len);
    cudaErr(cudaGetLastError(), "prescan<<<>>>");

#ifdef MULTILEVEL
    // Check if we need a 2rd scan level
    if (grid_sz > 1) {
        // Layer 2 scan
        prescan<<<l3_grdsz, BLOCK_SIZE / 2, shm_sz>>>(gpuIncs, gpuSums, gpuSums2, grid_sz);
        cudaErr(cudaGetLastError(), "prescan<<<>>>");

        // Check if we need a 3rd scan level
        if (l3_grdsz > 1) {
            prescan<<<l3_grdsz, BLOCK_SIZE / 2, shm_sz>>>(gpuIncs2, gpuSums2, NULL, l3_grdsz);
            cudaErr(cudaGetLastError(), "prescan<<<>>>");

            blockadd<<<l3_grdsz, BLOCK_SIZE>>>(gpuIncs, grid_sz, gpuIncs2);
            cudaErr(cudaGetLastError(), "blockadd<<<>>>");
        }
    }

    blockadd<<<grid_sz, BLOCK_SIZE>>>(gpuOut, len, gpuIncs);
    cudaErr(cudaGetLastError(), "blockadd<<<>>>");
#endif

    /*
     * Stop the timer!
     */
    cudaErr(cudaEventRecord(stop, 0), "cudaEventRecord");
    cudaErr(cudaEventSynchronize(stop), "cudaEventSynchronize");
    cudaErr(cudaDeviceSynchronize(), "cudaDeviceSynchronize");
    cudaErr(cudaEventElapsedTime(ms, start, stop), "cudaEventElapsedTime");

    cudaErr(cudaMemcpy(out, gpuOut, bytLen, cudaMemcpyDeviceToHost), "cudaMemcpy");

    // Deallocate memory
    cudaErr(cudaFree(gpuIn), "cudaFree");
    cudaErr(cudaFree(gpuOut), "cudaFree");
    cudaErr(cudaFree(gpuSums), "cudaFree");
    cudaErr(cudaFree(gpuIncs), "cudaFree");
    cudaErr(cudaFree(gpuSums2), "cudaFree");
    cudaErr(cudaFree(gpuIncs2), "cudaFree");
    cudaErr(cudaEventDestroy(start), "cudaEventDestroy");
    cudaErr(cudaEventDestroy(stop), "cudaEventDestroy");
    cudaErr(cudaDeviceReset(), "Failed to reset the device");
}

/**
 * Performs a sequential blockscan on the CPU, in a single thread
 */
__host__ void blockscan_cpu(const int *in, int *out, uint32_t count, float *ms) {

    struct timespec start, end, diff;
    clock_gettime(CLOCK_MONOTONIC, &start);

    // Perform sequential scan
    out[0] = 0;
    for (uint64_t i = 1; i < count; i++)
        out[i] = in[i - 1] + out[i - 1];

    clock_gettime(CLOCK_MONOTONIC, &end);
    timespec_diff(&start, &end, &diff);
    *ms = (float) (diff.tv_sec * 1000.0 + diff.tv_nsec / 1000000.0);

}

/**
 * Performs a sequential blockscan on the GPU, in a single thread/block
 * Should be invoked as blockscan_single_gpu<<<1, 1>>>(..)
 */
__global__ void _blockscan_single_gpu(const int *in, int *out, uint32_t count) {
    out[0] = 0;
    for (uint64_t i = 1; i < count; i++)
        out[i] = in[i - 1] + out[i - 1];
}
__host__ void blockscan_single_gpu(const int *in, int *out, uint32_t count,
                                     float *ms) {

    uint32_t bytLen = sizeof(int) * count;

    cudaEvent_t gpuStart, gpuStop;
    cudaErr(cudaEventCreate(&gpuStart), "cudaEventCreate");
    cudaErr(cudaEventCreate(&gpuStop), "cudaEventCreate");

    // Memory management
    int *gpuIn = NULL, *gpuOut = NULL;
    cudaErr(cudaMalloc(&gpuIn, bytLen), "cudaMalloc");
    cudaErr(cudaMalloc(&gpuOut, bytLen), "cudaMalloc");
    cudaErr(cudaMemcpy(gpuIn, in, bytLen, cudaMemcpyHostToDevice),
            "cudaMemcpy");
    cudaErr(cudaEventRecord(gpuStart, 0), "cudaEventRecord");
    // Timer start

    _blockscan_single_gpu<<<1, 1>>>(gpuIn, gpuOut, count);

    // Timer end
    cudaErr(cudaEventRecord(gpuStop, 0), "cudaEventRecord");
    cudaErr(cudaEventSynchronize(gpuStop), "cudaEventSynchronize");
    cudaErr(cudaDeviceSynchronize(), "cudaDeviceSynchronize");
    cudaErr(cudaEventElapsedTime(ms, gpuStart, gpuStop),
            "cudaEventElapsedTime");

    cudaErr(cudaMemcpy(out, gpuOut, bytLen, cudaMemcpyDeviceToHost), "cudaMemcpy");

    cudaErr(cudaFree(gpuIn), "cudaFree");
    cudaErr(cudaFree(gpuOut), "cudaFree");
    cudaErr(cudaDeviceReset(), "Failed to reset the device");
}


/**
 * Host main routine
 */
int main(void) {

    /*
     * Define some test cases
     */
    int devurandom = open("/dev/urandom", O_RDONLY);
    if (devurandom < 0) perror("open");

#define DEFINE_TEST(rnd, name, size) \
    uint32_t name##_sz = (size); \
    int *(name) = (int *) malloc((size) * sizeof(int)); \
    read(rnd, (name), (size) * sizeof(int)); \

    DEFINE_TEST(devurandom, test1, BLOCK_SIZE);
    DEFINE_TEST(devurandom, test2, BLOCK_SIZE << 4);
    DEFINE_TEST(devurandom, test3, 10000000);

    // Fight me @domwillia.ms
    close(devurandom);

    struct test_case {
        int *arr;
        uint32_t len;
    } tests[] = {
        { test1, test1_sz },
        { test2, test2_sz },
        { test3, test3_sz },
    };

    /*
     * Run each test case and print the results
     */
    uint32_t count = sizeof(tests) / sizeof(struct test_case);
    printf("[~] Block size is %u\n", BLOCK_SIZE);
    printf("[#] %u tests to run\n", count);

    for (uint i = 0; i < count; i++) {
        // Compute the simple sequential scan on the CPU
        struct test_case *tc = &tests[i];

        uint32_t bytLen = sizeof(int) * tc->len;
        int *ref = (int *) malloc(bytLen);
        int *out = (int *) malloc(bytLen);

        // Print input test case
        printf("  [*] Testing case #%d, %u elements\n", i + 1, tc->len);

        float refMs = -1, gpuMs = -1;
        /*
         * Compute CPU scan
         */
        blockscan_cpu(tc->arr, ref, tc->len, &refMs);
        printf("    - [✓] CPU reference scan (%.5f ms)\n", refMs);

#ifdef GPU_SINGLETHREAD
        /*
         * Compute GPU single-threaded scan
         */
        blockscan_single_gpu(tc->arr, out, tc->len, &gpuMs);
        scancmp("GPU sequential scan", ref, out, tc->len, gpuMs, {});

#endif
        /*
         * Compute GPU scan
         */
        blockscan_gpu(tc->arr, tc->len, out, &gpuMs);
        scancmp("GPU parallel scan", ref, out, tc->len, gpuMs, {
                uint32_t shm_sz = (BLOCK_SIZE * 4) * sizeof(int);
                uint32_t grid_sz = 1 + (tc->len - 1) / (BLOCK_SIZE);
                printf("      - %u blocks, %u threads, %u tmp bytes\n",
                       grid_sz, BLOCK_SIZE, shm_sz);
        });

        printf("    - Speedup: CPU -> GPU = %.2fx\n", refMs / gpuMs);
        printf("\n");
    }

    // Deallocate dynamically allocated arrays
    for (uint i = 0; i < count; i++)
        free(tests[i].arr);
}
