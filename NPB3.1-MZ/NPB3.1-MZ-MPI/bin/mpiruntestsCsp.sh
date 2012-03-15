#!/bin/sh
#PBS -l walltime=03:00:00
#PBS -N MZ.C.sp
#PBS -q normal
#PBS -l nodes=16:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o MZ.CD.log
#PBS -o MZ.CD.err

cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt
python parsenodefile.py nodefile.txt 


pwd


#########################
#SP C
python setnodefile.py 4;
#export OMP_NUM_THREADS=1;
mpirun -x OMP_NUM_THREADS=1 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/classC/sp-mz.C.4.1-results.txt ;
#export OMP_NUM_THREADS=2;
mpirun -x OMP_NUM_THREADS=2 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/classC/sp-mz.C.4.2-results.txt ;
#export OMP_NUM_THREADS=4;
mpirun -x OMP_NUM_THREADS=4 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/classC/sp-mz.C.4.4-results.txt ;
#export OMP_NUM_THREADS=8;
mpirun -x OMP_NUM_THREADS=8 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/classC/sp-mz.C.4.8-results.txt ;
#export OMP_NUM_THREADS=12;
mpirun -x OMP_NUM_THREADS=12 -hostfile myhostfile.txt ./sp-mz.C.4 | tee sp-mz-values/classC/sp-mz.C.4.12-results.txt ;


python setnodefile.py 9;
#export OMP_NUM_THREADS=1;
mpirun -x OMP_NUM_THREADS=1  -hostfile myhostfile.txt ./sp-mz.C.9 | tee sp-mz-values/sp-mz.C.9.1-results.txt ;
#export OMP_NUM_THREADS=2;
mpirun -x OMP_NUM_THREADS=2  -hostfile myhostfile.txt ./sp-mz.C.9 | tee sp-mz-values/sp-mz.C.9.2-results.txt ;
#export OMP_NUM_THREADS=4;
mpirun -x OMP_NUM_THREADS=4 -hostfile myhostfile.txt ./sp-mz.C.9 | tee sp-mz-values/sp-mz.C.9.4-results.txt ;
#export OMP_NUM_THREADS=8;
mpirun -x OMP_NUM_THREADS=8 -hostfile myhostfile.txt ./sp-mz.C.9 | tee sp-mz-values/sp-mz.C.9.8-results.txt ;
#export OMP_NUM_THREADS=12;
mpirun -x OMP_NUM_THREADS=12 -hostfile myhostfile.txt ./sp-mz.C.9 | tee sp-mz-values/sp-mz.C.9.12-results.txt ;


python setnodefile.py 16;
#export OMP_NUM_THREADS=1;
mpirun -x OMP_NUM_THREADS=1 -hostfile myhostfile.txt ./sp-mz.C.16 | tee sp-mz-values/sp-mz.C.16.1-results.txt ;
#export OMP_NUM_THREADS=2;
mpirun -x OMP_NUM_THREADS=2 -hostfile myhostfile.txt ./sp-mz.C.16 | tee sp-mz-values/sp-mz.C.16.2-results.txt ;
#export OMP_NUM_THREADS=4;
mpirun -x OMP_NUM_THREADS=4 -hostfile myhostfile.txt ./sp-mz.C.16 | tee sp-mz-values/sp-mz.C.16.4-results.txt ;
#export OMP_NUM_THREADS=8;
mpirun -x OMP_NUM_THREADS=8 -hostfile myhostfile.txt ./sp-mz.C.16 | tee sp-mz-values/sp-mz.C.16.8-results.txt ;
#export OMP_NUM_THREADS=12;
mpirun -x OMP_NUM_THREADS=12 -hostfile myhostfile.txt ./sp-mz.C.16 | tee sp-mz-values/sp-mz.C.16.12-results.txt ;

