#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N lu.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o lu.log
#PBS -o lu.err

#cd $PBS_O_WORKDIR
#cat $PBS_NODEFILE > nodefile.txt
#python parsenodefile.py nodefile.txt 


python setnodefile.py 2
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.4 | tee lu-values-O3/lu.C.4.n2.p2-results.txt;

python setnodefile.py 4
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu-values-O3/lu.C.4.n4.p1-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.16 | tee lu-values-O3/lu.C.16.n4.p4-results.txt;


python setnodefile.py 8 
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu-values-O3/lu.C.4.n8.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.16 | tee lu-values-O3/lu.C.16.n8.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.25 | tee lu-values-O3/lu.C.25.n8.p4-results.txt;


python setnodefile.py 16
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.16 | tee lu-values-O3/lu.C.16.n16.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.25 | tee lu-values-O3/lu.C.25.n16.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.64 | tee lu-values-O3/lu.C.64.n16.p4-results.txt;



python setnodefile.py 32
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.25 | tee lu-values-O3/lu.C.25.n32.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.64 | tee lu-values-O3/lu.C.64.n32.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.121 | tee lu-values-O3/lu.C.121.n32.p4-results.txt;









