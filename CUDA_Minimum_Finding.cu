#include "stdio.h"
#include <stdlib.h>
//based on cuda summing_Arrrays example
#define N 8 * 1000000
#define MINE 8
__global__ void findMin(int* a, int* c )
{
    int numToSort = N / 8;
    int low = numToSort * threadIdx.x;
    int high = low + numToSort - 1;
    int minValForThread = 1000000000;
    
    for(int i = low; i < high; i++ ){
        if(minValForThread > a[i]){
            minValForThread = a[i];
        }
    }
    c[threadIdx.x] = minValForThread;
}

int main()
{
    dim3 grid(1);
    dim3 threads(8);
    int a[N];
    int *dev_a;
    int c[8];
    int *dev_c;
    
    for(int i = 0; i < 8; i++){
        c[i] = 1000000000;
    }
    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_c, 8 * sizeof(int));
    //fill array
    for (int i = 0; i < N; i++){
        a[i] = rand() % 1000000000;
    }
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    findMin <<<grid, threads >>> (a,low,high,minVal[threadIdx.x]);
    
    cudaMemcpy(c, dev_c, MINE * sizeof(int), cudaMemcpyDeviceToHost);
    int min = c[0];
    for(int i = 0; i < 8; i++){
        if(min> c[i]){
            min= c[i];
        }
    }
    printf("minimum value using cuda is: %d\n", min);
    cudaFree(dev_a);
    return 0;
}

