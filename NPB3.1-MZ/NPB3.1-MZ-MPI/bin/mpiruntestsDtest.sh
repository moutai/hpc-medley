#!/bin/sh
#PBS -l walltime=01:00:00
#PBS -N MZ.CD.-omp.4
#PBS -q normal 
#PBS -l nodes=4:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o MZ.CD.4-omp.log
#PBS -e MZ.CD.4-omp.err

cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt
python parsenodefile.py nodefile.txt 

module load cuda
module load lammps


#mpirun -x OMP_NUM_THREADS=3 -npernode 16 lmp_openmpi-omp

#########################
#SP C
python setnodefile.py 4;

#export OMP_NUM_THREADS=1;
#mpirun -x OMP_NUM_THREADS=12 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/sp-mz.C.4.1-results.txt ;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/sp-mz.C.4.2-results.txt ;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/sp-mz.C.4.4-results.txt ;
#export OMP_NUM_THREADS=8;
#mpirun -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/sp-mz.C.4.8-results.txt ;
#export OMP_NUM_THREADS=12;
#mpirun -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/sp-mz.C.4.12-results.txt ;




