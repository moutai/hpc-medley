

#!/bin/sh
#PBS -l walltime=00:15:00
#PBS -N sp.C.9
#PBS -q normal
#PBS -l nodes=1:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o 9.sp.C.log

cd $PBS_O_WORKDIR/hpc-medley/NPB3.3.1/NPB3.3-MPI/bin
cat $PBS_NODEFILE >> nodefile.txt
#parse nodefile.txt
mpirun -npernode 9 -hostfile nodefile.txt ./sp.C.9  | tee 9.sp.C.9-results.txt;



