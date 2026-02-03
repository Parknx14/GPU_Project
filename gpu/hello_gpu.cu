// hello_gpu.cu
#include <stdio.h>

__global__ void hello_kernel()
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    printf("Hello from GPU thread %d (block %d, thread %d)\n",
           tid, blockIdx.x, threadIdx.x);
}

int main()
{
    // launch 2 blocks of 8 threads (total 16 threads)
    dim3 blocks(2), threads(50);
    hello_kernel<<<blocks, threads>>>();
    // wait for GPU to finish and flush printf buffer
    cudaDeviceSynchronize();
    return 0;
}
