//CUDE_2d_arraySum_again.cu
//Ben Talotta
#include "stdio.h"
#define COLUMNS 8
#define ROWS 8
//based off sum2darr.cu and kernal test code examples code
__global__ void add(int* a,int* c)
{
    __shared__ int cache[COLUMNS];
    int tid = threadIdx.x + (blockIdx.x * blockDim.x);
    int x = threadIdx.x;
    cache[x] = a[tid];
    int calculationInBox = blockDim.x / 2;
    while (calculationInBox >= 1)
    {
        if(x < calculationInBox){
            cache[x] += cache[x + calculationInBox];
            __syncthreads();
            if(calculationInBox == 1){
                break;
            }
        }
        calculationInBox /=2;
    }
    if(x == 0){
        c[blockIdx.x] = cache[0];
    }
}

int main()
{
    int a[ROWS][COLUMNS];
    int c[ROWS];
    int* dev_a;
    int* dev_c;
    dim3 grid(ROWS);
    dim3 threads(COLUMNS);


    cudaMalloc((void**)&dev_a, ROWS * COLUMNS * sizeof(int));
    cudaMalloc((void**)&dev_c, ROWS * sizeof(int));

    for (int y = 0; y < ROWS; y++)              // Fill Arrays
        for (int x = 0; x < COLUMNS; x++)
            a[y][x] = rand()% 10;

    cudaMemcpy(dev_a, a, ROWS * COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, ROWS * sizeof(int), cudaMemcpyHostToDevice);
    add <<<grid, threads >>> (dev_a, dev_c);
    cudaMemcpy(c, dev_c, ROWS * sizeof(int), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();//wait for threads to finish
    int findColSum = 0;
    for(int i = 0; i < COLUMNS; i++){
        printf("+ %d",c[i]);
        findColSum += c[i];
    }
    printf("\nthe sum of the columns is: %d\n", findColSum);
    cudaFree(dev_a);
    cudaFree(dev_c);
    return 0;
}

