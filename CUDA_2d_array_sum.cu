#include "stdio.h"
#define COLUMNS 4
#define ROWS 3
//based off sum2darr.cu example code
__global__ void add(int* a,int* c)
{
    int x = blockIdx.x;
    int sum = 0;
    for(int i = 0; i < rows; i ++){
        sum += a[(COLUMNS * i) + x];
    }
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
            a[y][x] = rand()% 50;

    cudaMemcpy(dev_a, a, ROWS * COLUMNS * sizeof(int), cudaMemcpyHostToDevice);
    add <<<1, COLUMNS >>> (dev_a, dev_c);

    cudaMemcpy(c), dev_c, COLUMNS * sizeof(int), cudaMemcpyDeviceToHost);

    for (int y = 0; y < ROWS; y++)              // Output Arrays
    {
        for (int x = 0; x < COLUMNS; x++)
            printf("[%d][%d]=%d ", y, x, c[y][x]);
        printf("\n");
    }
    return 0;
}

