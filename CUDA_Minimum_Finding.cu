#include "stdio.h"
#include <stdlib.h>
//based on cuda summing_Arrrays example
#define N 8 * 1000000
#define ThreadCount 8
__global__ void findMin(int* a, int* c )
{
    int numToSort = N / 8;
    int low = numToSort * threadIdx.x;
    int high = low + numToSort - 1;
    int minValForThread = 1000000000;
    
    for(int i = low; i < high; i++ ){
        
        //printf("here\n");
        if(minValForThread > a[i]){
            minValForThread = a[i];
        }
    }
    printf("here 3\n");
    
    printf("min for thread %d: %d\n", threadIdx.x, c[threadIdx.x]);
    c[threadIdx.x] = minValForThread;
}

int main()
{
    dim3 grid(1000000000);
    dim3 threads(ThreadCount);
    int *a;
    a = (int *)malloc(sizeof(int) * N);
    int *dev_a;
    int c[8];
    int *dev_c;
    
    for(int i = 0; i < 8; i++){
        c[i] = 1000000000;
    }
    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_c, ThreadCount * sizeof(int));
    //fill array
    for (int i = 0; i < N; i++){
        a[i] = rand() % 1000000000;
    }
    
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, ThreadCount * sizeof(int), cudaMemcpyHostToDevice);
    findMin <<<grid, threads >>> (a, c);
    cudaDeviceSynchronize();
    
    cudaMemcpy(c, dev_c, ThreadCount * sizeof(int), cudaMemcpyDeviceToHost);
    int min = c[0];
    for(int i = 0; i < 8; i++){
        if(min > c[i]){
            min = c[i];
        }
        
    //   printf("min for thread %d: %d\n", i, c[i]);
    }
    printf("minimum value using cuda is: %d\n", min);
    cudaFree(dev_a);
    cudaFree(dev_c);
    return 0;
}

