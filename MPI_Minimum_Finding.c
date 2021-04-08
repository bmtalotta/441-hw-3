#include <mpi.h>
#include <stdio.h>

#define N 8000000
int findMin(int a[], int startPoint, int endPoint){
    int minVal = a[startPoint];
    for(int i = startPoint; i < endPoint; i++){
        if(minVal > a[i]){
            minVal = a[i];
        }
    }
    return minVal;
}
int main(int argc, char* argv[]) {
    int* a, * temp;  
    int i;   
    int rank, p;   
    int tag = 0;   
    MPI_Status status;

    MPI_Init(&argc, &argv);   
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);   
    MPI_Comm_size(MPI_COMM_WORLD, &p);

    a = (int*)malloc(sizeof(int) * N);   
    temp = (int*)malloc(sizeof(int) * 1);

    if (rank == 0) { 
        for (i = 0; i < N; i++)         
            a[i] = rand() % 1000000000;    
    }   
    MPI_Bcast(a, N, MPI_INT, 0, MPI_COMM_WORLD);
    int startPoint = 1000000 * rank;
    int endPoint = startPoint + 1000000 - 1;
    if(rank != 0){
        temp[rank] = findMin(a,startPoint,endPoint);
    MPI_Send(temp, 1, MPI_INT, 0, tag, MPI_COMM_WORLD);
    }
    else{
        temp[rank] == findMin(a,startPoint,endPoint);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    //recieve loop
    for(i = 0; i < 8; i++){
    MPI_Recv(temp, 1, MPI_INT, i, tag, MPI_COMM_WORLD, &status);
    }
    int answer = findMin(temp,0,7);
    printf("minimum value is: ", answer);
    free(a);
    free(temp);
    MPI_finalize();
    return 0;
