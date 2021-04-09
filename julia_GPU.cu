#include "FreeImage.h" // Compile with –lfreeimage  flag
#include "stdio.h"

#define DIM 2000

struct cuComplex {
    float   r;
    float   i;
    __device__ cuComplex(float a, float b) : r(a), i(b) {}
    __device__ float magnitude2(void) { return r * r + i * i; }
    __device__ cuComplex operator*(const cuComplex& a) {
        return cuComplex(r * a.r - i * a.i, i * a.r + r * a.i);
    }
    __device__ cuComplex operator+(const cuComplex& a) {
        return cuComplex(r + a.r, i + a.i);
    }
};

__device__ int julia(int x, int y)
{
    const float scale = 1.5;
    float jx = scale * (float)(DIM / 2 - x) / (DIM / 2);
    float jy = scale * (float)(DIM / 2 - y) / (DIM / 2);
    cuComplex c(-0.8, 0.156);
    cuComplex a(jx, jy);
    int i = 0;
    for (i = 0; i < 200; i++)
    {
        a = a * a + c;
        if (a.magnitude2() > 1000) return 0;
    }
    return 1;
}

__global__ void kernel(char* ptr)
{
    int x = blockIdx.x;
    int y = blockIdx.y;
    int offset = x + y * DIM;
    ptr[offset] = julia(x, y);
}

int main()
{
    FreeImage_Initialise();
    atexit(FreeImage_DeInitialise);
    FIBITMAP* bitmap = FreeImage_Allocate(DIM, DIM, 24);

    char charmap[DIM][DIM];
    char* dev_charmap;

    cudaMalloc((void**)&dev_charmap, DIM * DIM * sizeof(char));
    dim3 grid(DIM, DIM);
    kernel <<<grid, 1 >>> (dev_charmap);

    cudaMemcpy(charmap, dev_charmap, DIM * DIM * sizeof(char), cudaMemcpyDeviceToHost);

    RGBQUAD color;
    for (int i = 0; i < DIM; i++) {
        for (int j = 0; j < DIM; j++) {
            color.rgbRed = 0;
            color.rgbGreen = 0;
            color.rgbBlue = 0;
            if (charmap[i][j] == 1)
                color.rgbBlue = 255.0;
            FreeImage_SetPixelColor(bitmap, i, j, &color);
        }
    }

    FreeImage_Save(FIF_PNG, bitmap, "output.png", 0);
    FreeImage_Unload(bitmap);
    cudaFree(dev_charmap);

    return 0;
}