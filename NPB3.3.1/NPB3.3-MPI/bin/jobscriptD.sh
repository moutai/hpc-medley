#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N sp.bt.lu.D
#PBS -q normal
#PBS -l nodes=3:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o sp.bt.lu.D.log
#PBS -o sp.bt.lu.D.err


cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt

mpirun -npernode 9 -hostfile nodefile.txt ./sp.D.9 | tee sp.D.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./sp.D.16 | tee sp.D.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./sp.D.25 | tee sp.D.25-results.txt;


mpirun -npernode 9 -hostfile nodefile.txt ./bt.D.9 | tee bt.D.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./bt.D.16 | tee bt.D.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./bt.D.25 | tee bt.D.25-results.txt;


mpirun -npernode 9 -hostfile nodefile.txt ./lu.D.9 | tee lu.D.9-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./lu.D.16 | tee lu.D.16-results.txt;
mpirun -npernode 12 -hostfile nodefile.txt ./lu.D.25 | tee lu.D.25-results.txt;






