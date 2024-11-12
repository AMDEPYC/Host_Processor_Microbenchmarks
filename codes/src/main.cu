#include "bindCpuToGpu.cuh"
#include <iostream>
#include <mpi.h>
#include <utmpx.h>

void launch(void);
void memcopy(void);

int main(int args, char *argsv[]) {
  int nexamples = atoi(argsv[1]);

  MPI_Init(&args, &argsv);

  int rank = 0;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  printf("cpu = %d\n", sched_getcpu());

  nodalDeviceInfo nodal;

  nodal.bindOne2One();

  MPI_Barrier(MPI_COMM_WORLD);
  double t0 = MPI_Wtime();
  if (nexamples > 0) {
    if (rank == 0) {
      std::cout << " solving launch start time " <<std::endl;
    }

    launch();
  }
  MPI_Barrier(MPI_COMM_WORLD);
  double t1 = MPI_Wtime();
  cudaDeviceSynchronize();
  if (nexamples > 1) {
    if (rank == 0) {
      std::cout << " solving memcopy" << std::endl;
    }

    memcopy();
  }

  cudaDeviceSynchronize();
  MPI_Barrier(MPI_COMM_WORLD);
  double t2 = MPI_Wtime();

  if (rank == 0) {
    std::cout << " ******************************************* " << std::endl;
    std::cout << " kernel launch " << (t1 - t0)*1000<< " mico seconds " << std::endl;
    std::cout << " memcopy " << t2 - t1 << std::endl;
    std::cout << " ******************************************* " << std::endl;
  }

  MPI_Finalize();

  return (0);
}
