module load nvhpc/24.3

#amd
mpirun -np 8 --map-by ppr:1:l3cache:PE=8 --bind-to core ./bin/bench 3

#intel
#  mpirun -np 8 --map-by  ppr:4:numa:PE=1 --bind-to core ./bin/bench 3
