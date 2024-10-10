#include <iostream>
#include <stdio.h>
#include <stdlib.h>

// make sure

__device__ int get_global_index(void) {
  // return the index of the current thread across the entire grid launch
  return blockIdx.x * blockDim.x + threadIdx.x;
}

// kernel1 returns the result of calling the __device__ function
// return_constant():

__global__ void kernel1(int *array) {
  int index = get_global_index();
  array[index] = 1.0;
}

int launch(void) {
  int num_elements = 1 << 28;
  std::cout << " number of elements " << num_elements << std::endl;
  int num_bytes = num_elements * sizeof(int);
  int *device_array = NULL;
  int *host_array = NULL;
  // malloc a host array
  host_array = (int *)malloc(num_bytes);

  // cudaMalloc a device array

  cudaMalloc((void **)&device_array, num_bytes);

  // if either memory allocation failed, report an error message

  if (host_array == NULL || device_array == NULL) {

    printf("couldn't allocate memory\n");

    return 1;
  }
  // choose a launch configuration

  int block_size = 1024;

  int grid_size = (block_size / 1024) + 1;

  // launch each kernel and print out the results
  for (int i = 0; i < 100000000; i++) {
    kernel1<<<grid_size, block_size>>>(device_array);
  }
  // this impliciltt does deviceSyc for single stream
  cudaMemcpy(host_array, device_array, num_bytes, cudaMemcpyDeviceToHost);

  // printf("kernel1 results:\n");

  // deallocate memory

  free(host_array);
  cudaFree(device_array);
  return 0;
}
