#include <cstdio>
#include <omp.h>

int main() {
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("%03d/%03d\n", tid, num_threads);
  }
}
