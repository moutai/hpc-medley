#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N sp.bt.lu.C
#PBS -q normal
#PBS -l nodes=3:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o sp.bt.lu.C.log
#PBS -o sp.bt.lu.C.err


cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt

mpirun -npernode 9 -hostfile nodefile.txt ./sp.C.9 | tee sp.C.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./sp.C.16 | tee sp.C.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./sp.C.25 | tee sp.C.25-results.txt;


mpirun -npernode 9 -hostfile nodefile.txt ./bt.C.9 | tee bt.C.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./bt.C.16 | tee bt.C.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./bt.C.25 | tee bt.C.25-results.txt;


mpirun -npernode 9 -hostfile nodefile.txt ./lu.C.9 | tee lu.C.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./lu.C.16 | tee lu.C.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./lu.C.25 | tee lu.C.25-results.txt;






