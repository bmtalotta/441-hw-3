//MPI_Minimum_Finding.c
//Ben Talotta
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
//based on para_mergesort example
#define N 8 * 1000000
int findMin(int a[], int low, int high)
{
    int minVal = a[low];
    for (int i = low; i < high; i++)
    {
        if (minVal > a[i])
        {
            minVal = a[i];
        }
    }
    return minVal;
}

int main(int argc, char *argv[])
{
    int *a, *temp;
    int i;
    int rank, p;
    int tag = 0;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &p);

    a = (int *)malloc(sizeof(int) * N);
    temp = (int *)malloc(sizeof(int) * 1);
    
    printf("minimum value rank is 1 : %d\n", rank);
    if (rank == 0)
    {
        for (i = 0; i < N; i++){
            a[i] = rand() % 1000000000;
        }
        
    }
    
    MPI_Bcast(a, N, MPI_INT, 0, MPI_COMM_WORLD);
    int numToSort = N / p;
    int low = rank * numToSort;
    int high = low + numToSort - 1;
    
    temp[0] = findMin(a, low, high);
    if (rank != 0)
    {
        MPI_Send(temp, 1, MPI_INT, 0, tag, MPI_COMM_WORLD);
    }
    printf("minimum value rank is: %d\n", rank);
    MPI_Barrier(MPI_COMM_WORLD); //wait till all threads get here
    
    //recieve loop
    if (rank == 0)
    {
        int min = temp[0];
        for (i = 0; i < p; i++)
        {
            MPI_Recv(temp, 1, MPI_INT, i, tag, MPI_COMM_WORLD, &status);
            if(min > temp[0]){
                min = temp[0];
            }
        }
        int answer = findMin(a, 0, N-1);
        printf("minimum value parallel is: %d", min);
        printf("minimum value not parallel is: %d", answer);
    }
    free(a);
    free(temp);
    MPI_Finalize();
    return 0;
}



