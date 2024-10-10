#include "bindCpuToGpu.cuh"
#include <iostream>

void deviceProp::getDeviceProp(int device_id) {
  cudaDeviceProp prop;
  cudaGetDeviceProperties(&prop, device_id);
  device_name = prop.name;
  smp_count = prop.multiProcessorCount;
  global_mem = prop.totalGlobalMem / 1024 / 1024 / 1024;
  compute_cap_major = prop.major;
  compute_cap_minor = prop.minor;
  clock = prop.clockRate / 1024;
  engine_count = prop.asyncEngineCount;
}

nodalDeviceInfo::nodalDeviceInfo() {
  cudaGetDeviceCount(&device_count);
  prop = new deviceProp[device_count];
  getRank();
  for (int id = 0; id < device_count; id++) {
    prop[id].getDeviceProp(id);
    if (rank == 0) {
      std::cout << " GPU  " << prop[id].device_name << std::endl;
      std::cout << " mem " << prop[id].global_mem << std::endl;
      std::cout << " sm cpunt " << prop[id].smp_count << std::endl;
      std::cout << " compuate_cap " << prop[id].compute_cap_major << "."
                << prop[id].compute_cap_minor << std::endl;
      std::cout << " clock " << prop[id].clock << std::endl;
      std::cout << " aync engine count " << prop[id].engine_count << std::endl;
    }
  }
}

void nodalDeviceInfo::getRank() {
  // int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_split_type(MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, nodal_rank,
                      MPI_INFO_NULL, &nodal_comm);
  // MPI_Comm_split_type( MPI_COMM_WORLD, OMPI_COMM_TYPE_NUMA, nodal_rank,
  // MPI_INFO_NULL, &nodal_comm ); MPI_Comm_split_type( MPI_COMM_WORLD,
  // OMPI_COMM_TYPE_L3CACHE, nodal_rank, MPI_INFO_NULL, &nodal_comm );
  MPI_Comm_size(nodal_comm, &nodal_comm_size);
  MPI_Comm_rank(nodal_comm, &nodal_rank);
  MPI_Comm_free(&nodal_comm);
  if (rank == 0)
    std::cout << " size of comm " << nodal_comm_size << std::endl;
}

void nodalDeviceInfo::bindOne2One() {
  //    assert( nodal_comm_size <= device_count );
  std::cout << " nodal rank " << nodal_rank << std::endl;
  std::cout << " device count " << device_count << std::endl;
  cudaSetDevice(nodal_rank % device_count);
  int id;
  cudaGetDevice(&id);
  std::cout << "nodal rank " << rank << " is bound to GPU number " << id
            << std::endl;
}

void nodalDeviceInfo::bind() { checkP2P(); }

void nodalDeviceInfo::checkP2P() {
  int accessibility[device_count * device_count];
  if (nodal_rank == 0) {
    for (int i = 0; i < device_count; i++) {
      for (int j = 0; j < device_count; j++) {
        cudaDeviceCanAccessPeer(accessibility, i, j);
      }
    }
  }

  if (nodal_rank == 0) {
    std::cout << " checking CUDA accessibility" << std::endl;
    for (int i = 0; i < device_count; i++) {
      for (int j = 0; j < device_count; j++) {
        std::cout << accessibility[i * device_count + j] << '\t';
      }
      std::cout << std::endl;
    }
  }
}

nodalDeviceInfo::~nodalDeviceInfo() { delete[] prop; }
