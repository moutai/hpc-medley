#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N bt.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o bt.log
#PBS -o bt.err

#cd $PBS_O_WORKDIR
#cat $PBS_NODEFILE > nodefile.txt
#python parsenodefile.py nodefile.txt 


python setnodefile.py 2
mpirun -npernode 2 -hostfile myhostfile.txt ./bt.C.4 | tee bt-values-O3/bt.C.4.n2.p2-results.txt;

python setnodefile.py 4
mpirun -npernode 1 -hostfile myhostfile.txt ./bt.C.4 | tee bt-values-O3/bt.C.4.n4.p1-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./bt.C.16 | tee bt-values-O3/bt.C.16.n4.p4-results.txt;


python setnodefile.py 8 
mpirun -npernode 1 -hostfile myhostfile.txt ./bt.C.4 | tee bt-values-O3/bt.C.4.n8.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./bt.C.16 | tee bt-values-O3/bt.C.16.n8.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./bt.C.25 | tee bt-values-O3/bt.C.25.n8.p4-results.txt;


python setnodefile.py 16
mpirun -npernode 1 -hostfile myhostfile.txt ./bt.C.16 | tee bt-values-O3/bt.C.16.n16.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./bt.C.25 | tee bt-values-O3/bt.C.25.n16.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./bt.C.64 | tee bt-values-O3/bt.C.64.n16.p4-results.txt;



python setnodefile.py 32
mpirun -npernode 1 -hostfile myhostfile.txt ./bt.C.25 | tee bt-values-O3/bt.C.25.n32.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./bt.C.64 | tee bt-values-O3/bt.C.64.n32.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./bt.C.121 | tee bt-values-O3/bt.C.121.n32.p4-results.txt;









