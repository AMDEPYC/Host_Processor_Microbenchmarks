# Host_Processor_Microbenchmarks
This repository contains two benchmark tests designed to measure performance overheads related to kernel launches and data transfers between host and device. The benchmarks are as follows:

1. **Kernel Launch Overhead Benchmark:**
   - This benchmark launches a lightweight kernel several thousand times to measure the overhead of frequent kernel launches.

2. **Data Transfer Overhead Benchmark:**
   - This benchmark measures the overhead of transferring data between the host and device by copying data back and forth several thousand times.

## Build Instructions

To build the benchmarks, navigate to the `codes/` directory, which contains the CMake build configuration in `CMakeLists.txt`. Follow these steps to build:

```bash
cd codes
mkdir build
cd build
cmake ..
make

## Running the Benchmarks
To run the benchmarks, navigate to the `codes` directory and use the `run.sh` script provided.

```bash
cd codes/
./run.sh