#include <iostream>
#include <stdio.h>
#include <stdlib.h>

// make sure

int memcopy(void) {
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

  // launch each kernel and print out the results
  for (int i = 0; i < 1000; i++) {
    cudaMemcpy(host_array, device_array, num_bytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(device_array, host_array, num_bytes, cudaMemcpyHostToDevice);
  }
  // this impliciltt does deviceSyc for single stream
  cudaMemcpy(host_array, device_array, num_bytes, cudaMemcpyDeviceToHost);

  // deallocate memory

  free(host_array);
  cudaFree(device_array);
  return 0;
}
