#include "stdio.h"
#define COLUMNS 4
#define ROWS 3
//based off sum2darr.cu example code
__global__ void add(int* a,int* c)
{
    int x = threadIdx.x;
    int sum = 0;
    for(int i = 0; i < ROWS; i ++){
        sum += a[(COLUMNS * i) + x];
    }
    
    printf("the sum of the %d thread column is: %d\n", x, sum);
    c[x] = sum;
}

int main()
{
    int a[ROWS][COLUMNS];
    int c[COLUMNS];
    int* dev_a;
    int* dev_c;


    cudaMalloc((void**)&dev_a, ROWS * COLUMNS * sizeof(int));
    cudaMalloc((void**)&dev_c, COLUMNS * sizeof(int));

    for (int y = 0; y < ROWS; y++)              // Fill Arrays
        for (int x = 0; x < COLUMNS; x++)
            a[y][x] = rand()% 10;

    cudaMemcpy(dev_a, a, ROWS * COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    add <<<1, COLUMNS >>> (dev_a, dev_c);
    cudaMemcpy(c, dev_c, COLUMNS * sizeof(int), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();//wait for threads to finish
    int findColSum = 0;
    for(int i = 0; i < COLUMNS; i++){
        
        printf("the sum of the columns is: %d\n", findColSum);
        findColSum += c[i];
    }
    printf("the sum of the columns is: %d\n", findColSum);
    cudaFree(dev_a);
    cudaFree(dev_c);
    return 0;
}

