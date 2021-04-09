#include "FreeImage.h"
#include "stdio.h"

#define DIM 2000

struct cuComplex{
        float   r;
        float   i;
        cuComplex( float a, float b) : r(a), i(b) {};
        float magnitude2(void) { return r*r + i*i; }
        cuComplex operator*(const cuComplex& a) {
                return cuComplex( r * a.r - i * a.i, i * a.r + r * a.i );
        }
        cuComplex operator+(const cuComplex& a) {
                return cuComplex(r+ a.r, i + a.i);
        }
};



int julia(int x, int y)
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


void kernel(char* ptr)
{
    for (int y = 0; y < DIM; y++)
        for (int x = 0; x < DIM; x++)
        {
            int offset = x + y * DIM;
            ptr[offset] = julia(x, y);
        }
}


int main()
{
    FreeImage_Initialise();
    atexit(FreeImage_DeInitialise);
    FIBITMAP* bitmap = FreeImage_Allocate(DIM, DIM, 24);

    char charmap[DIM][DIM];
    kernel(&charmap[0][0]);

    RGBQUAD color;
    for (int i = 0; i < DIM; i++) {
        for (int j = 0; j < DIM; j++) {
            color.rgbRed = 0;
            color.rgbGreen = 0;
            color.rgbBlue = 0;
            if (charmap[i][j] == 1)
                color.rgbGreen = 255.0;
            FreeImage_SetPixelColor(bitmap, i, j, &color);
        }
    }
    FreeImage_Save(FIF_PNG, bitmap, "output.png", 0);
    FreeImage_Unload(bitmap);

    return 0;
}