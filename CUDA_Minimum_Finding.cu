#include "stdio.h"
#include <stdlib.h>
//based on cuda summing_Arrrays example
#define N 8 * 1000000

__global__ void findMin(int* a, int low, int high, int minVal)
{
    for(int i = low; i < high; i++ ){
        if(minVal > a[i]){
            minVal = a[i];
        }
    }
}

int main()
{
    dim3 grid(1);
    dim3 threads(8);
    int a[N];
    int *dev_a;
    cudaMalloc((void**)&dev_a, 8 * sizeof(int));
    //fill array
    for (int i = 0; i < N; i++){
        a[i] = rand() % 1000000000;
    }
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    int numToSort = N / 8;
    int low = numToSort * threadIdx.x;
    int high = low + numToSort - 1;
    int MinVal[8];
    for(int i = 0; i < 8; i++){
        minVal[i] = 1000000000;
    }
    findMin <<<grid, threads >>> (a,low,high,minVal[threadIdx.x]);
    int minAnswer = MinVal[0];
    for(int i = 0; i < 8; i++){
        if(minAnswer > MinVal[i]){
            minAnswer = minVal[i];
        }
    }
    printf("minimum value using cuda is: %d\n", min);

    return 0;
}

