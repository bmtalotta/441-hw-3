//CUDE_Minimum_Fineding.cu
//Ben Talotta
#include "stdio.h"
#include "stdlib.h"
//based on cuda summing_Arrrays example
#define N 8000000
#define ThreadCount 8
__global__ void findMin(int* a, int* c )
{

    int numToSort = N / 8;
    int low = numToSort * threadIdx.x;
    int high = low + numToSort - 1;
    int minValForThread = a[low];
    for(int i = low; i < high; ++i){
        if(minValForThread > a[i]){
            minValForThread = a[i];
        }
    }
    c[threadIdx.x] = minValForThread;
}

int main()
{
    dim3 grid(1);
    int *a;
    a = (int *)malloc(sizeof(int) * N);
    int *dev_a;
    int c[8];
    int *dev_c;
    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_c, ThreadCount * sizeof(int));

    for(int i = 0; i < 8; i++){
        c[i] = 1000000000;
    }
    
    //fill array
    for (int i = 0; i < N; i++){
        a[i] = rand() % 1000000000;
    }
    
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, ThreadCount * sizeof(int), cudaMemcpyHostToDevice);
    findMin <<<grid, ThreadCount >>> (dev_a, dev_c);

    cudaMemcpy(c, dev_c, ThreadCount * sizeof(int), cudaMemcpyDeviceToHost);
    int min = c[0];
    for(int i = 0; i < 8; i++){
        if(min > c[i]){
            min = c[i];
        }
    }
    printf("minimum value using cuda is: %d\n", min);
    cudaFree(dev_a);
    cudaFree(dev_c);
    return 0;
}

 