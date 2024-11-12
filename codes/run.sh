module use /opt/nvidia/hpc_sdk/modulefiles/ # on th100
# module use /mnt/Scratch_space/jaber/modulefiles on ih100 
module load nvhpc/24.3
 
cd build && cmake .. && make && cd ../



export OMPI_ALLOW_RUN_AS_ROOT=1
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

#sudo  turbostat  --interval 0.1 -S  --quiet  --out $PWD/cpu_freq_analysis.out&
#nvidia-smi --query-gpu=power.draw,utilization.gpu,utilization.memory --format=csv --loop-ms=100 -f $PWD/gpu_analysis.out&

#amd
mpirun -np 8 --map-by ppr:1:l3cache:PE=1 --bind-to core --report-bindings ./bin/bench 1
#mpirun -np 1 --report-bindings ./bin/bench 1

#intel
#  mpirun -np 8 --map-by ppr:4:numa:PE=1 --bind-to core  --report-bindings ./bin/bench 1
