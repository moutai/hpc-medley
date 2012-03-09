#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N lu.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o lu.log
#PBS -o lu.err

cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt
python parsenodefile.py nodefile.txt 


python setnodefile.py 2
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n2.p2-results.txt;
mpirun -npernode 8 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n2.p8-results.txt;
mpirun -npernode 12 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n2.p12-results.txt;


python setnodefile.py 4
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n4.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n4.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n4.p4-results.txt;
mpirun -npernode 8 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n4.p8-results.txt;
mpirun -npernode 12 -hostfile myhostfile.txt ./lu.C.36 | tee lu.C.36.n4.p12-results.txt;


python setnodefile.py 8 
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n8.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n8.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n8.p4-results.txt;
mpirun -npernode 8 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n8.p8-results.txt;
mpirun -npernode 12 -hostfile myhostfile.txt ./lu.C.81 | tee lu.C.81.n8.p12-results.txt;


python setnodefile.py 16
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n16.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n16.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n16.p4-results.txt;
mpirun -npernode 8 -hostfile myhostfile.txt ./lu.C.121 | tee lu.C.121.n16.p8-results.txt;
mpirun -npernode 12 -hostfile myhostfile.txt ./lu.C.169 | tee lu.C.169.n16.p12-results.txt;



python setnodefile.py 32
mpirun -npernode 1 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n32.p1-results.txt;
mpirun -npernode 2 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n32.p2-results.txt;
mpirun -npernode 4 -hostfile myhostfile.txt ./lu.C.121 | tee lu.C.121.n32.p4-results.txt;
mpirun -npernode 8 -hostfile myhostfile.txt ./lu.C.256 | tee lu.C.256.n32.p8-results.txt;
mpirun -npernode 12 -hostfile myhostfile.txt ./lu.C.361 | tee lu.C.361.n32.p12-results.txt;









