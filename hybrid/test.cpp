#include <cstdio>
#include <mpi.h>
#include <omp.h>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("Thread:%03d/%03d Process:%03d/%03d\n", tid, num_threads, rank,
           size);
  }

  MPI_Finalize();
}
