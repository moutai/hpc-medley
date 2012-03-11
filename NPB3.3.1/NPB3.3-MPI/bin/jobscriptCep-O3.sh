#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N ep.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o ep.log
#PBS -o ep.err

#cd $PBS_O_WORKDIR
#cat $PBS_NODEFILE > nodefile.txt
#python parsenodefile.py nodefile.txt


python setnodefile.py 2
mpirun  -npernode 1 -hostfile myhostfile.txt  ./ep.C.2   | tee ep-values-O3/ep.C.2.n2.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./ep.C.4   | tee ep-values-O3/ep.C.8.n2.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./ep.C.8   | tee ep-values-O3/ep.C.8.n2.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./ep.C.16  | tee ep-values-O3/ep.C.16.n2.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./ep.C.16  | tee ep-values-O3/ep.C.16.n2.p12-results.txt;



python setnodefile.py 4
mpirun  -npernode 1 -hostfile myhostfile.txt  ./ep.C.4   | tee ep-values-O3/ep.C.4.n4.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./ep.C.8   | tee ep-values-O3/ep.C.8.n4.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./ep.C.16   | tee ep-values-O3/ep.C.16.n4.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./ep.C.32  | tee ep-values-O3/ep.C.32.n4.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./ep.C.32  | tee ep-values-O3/ep.C.32.n4.p12-results.txt;


python setnodefile.py 8
mpirun  -npernode 1 -hostfile myhostfile.txt  ./ep.C.8   | tee ep-values-O3/ep.C.8.n8.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./ep.C.16   | tee ep-values-O3/ep.C.16.n8.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./ep.C.32   | tee ep-values-O3/ep.C.32.n8.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./ep.C.64  | tee ep-values-O3/ep.C.64.n8.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./ep.C.64  | tee ep-values-O3/ep.C.64.n8.p12-results.txt;
#

python setnodefile.py 16
mpirun  -npernode 1 -hostfile myhostfile.txt  ./ep.C.16   | tee ep-values-O3/ep.C.8.n16.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./ep.C.32   | tee ep-values-O3/ep.C.16.n16.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./ep.C.64   | tee ep-values-O3/ep.C.32.n16.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./ep.C.128  | tee ep-values-O3/ep.C.64.n16.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./ep.C.128  | tee ep-values-O3/ep.C.64.n16.p12-results.txt;


python setnodefile.py 32
mpirun  -npernode 1 -hostfile myhostfile.txt ./ep.C.32 | tee ep-values-O3/ep.C.32.n32.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt ./ep.C.64 | tee ep-values-O3/ep.C.64.n32.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt ./ep.C.128 | tee ep-values-O3/ep.C.128.n32.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt ./ep.C.256 | tee ep-values-O3/ep.C.256.n32.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./ep.C.256 | tee ep-values-O3/ep.C.256.n32.p12-results.txt;



