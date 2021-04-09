#include "stdio.h"
#define COLUMNS 8
#define ROWS 8
//based off sum2darr.cu and kernal test code examples code
__global__ void add(int* a,int* c)
{
    __shared__ float cache[COLUMNS];
    int tid = threadIdx.x + (blockIdx.x * blockDim.x);
    int x = threadIdx.x;
    int temp = a[tid];
    cache[x] = temp;
    int calculationInBox = blockDim.x / 2;
    while (calculationInBox >= 1)
    {
        if(x < calculationInBox){
            cache[x] += cache[x + calculationInBox];
            __syncthreads();
            calculationInBox /=2;
        }
    }
    if(x == 0){
        c[x] = cache[0];
    }
}

int main()
{
    int a[ROWS][COLUMNS];
    int c[COLUMNS];
    int* dev_a;
    int* dev_c;
    dim3 grid(ROWS);
    dim3 threads(COLUMNS);


    cudaMalloc((void**)&dev_a, ROWS * COLUMNS * sizeof(int));
    cudaMalloc((void**)&dev_c, COLUMNS * sizeof(int));

    for (int y = 0; y < ROWS; y++)              // Fill Arrays
        for (int x = 0; x < COLUMNS; x++)
            a[y][x] = rand()% 10;

    cudaMemcpy(dev_a, a, ROWS * COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    add <<<gird, threads >>> (dev_a, dev_c);
    cudaMemcpy(c, dev_c, COLUMNS * sizeof(int), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();//wait for threads to finish
    int findColSum = 0;
    for(int i = 0; i < COLUMNS; i++){
        findColSum += c[i];
    }
    printf("the sum of the columns is: %d\n", findColSum);
    cudaFree(dev_a);
    cudaFree(dev_c);
    return 0;
}
