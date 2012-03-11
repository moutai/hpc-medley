#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N is.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o is.log
#PBS -o is.err

#cd $PBS_O_WORKDIR
#cat $PBS_NODEFILE > nodefile.txt
#python parsenodefile.py nodefile.txt


python setnodefile.py 2
mpirun  -npernode 1 -hostfile myhostfile.txt  ./is.C.2   | tee is-values-O3/is.C.2.n2.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./is.C.4   | tee is-values-O3/is.C.8.n2.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./is.C.8   | tee is-values-O3/is.C.8.n2.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./is.C.16  | tee is-values-O3/is.C.16.n2.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./is.C.16  | tee is-values-O3/is.C.16.n2.p12-results.txt;



python setnodefile.py 4
mpirun  -npernode 1 -hostfile myhostfile.txt  ./is.C.4   | tee is-values-O3/is.C.4.n4.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./is.C.8   | tee is-values-O3/is.C.8.n4.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./is.C.16   | tee is-values-O3/is.C.16.n4.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./is.C.32  | tee is-values-O3/is.C.32.n4.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./is.C.32  | tee is-values-O3/is.C.32.n4.p12-results.txt;


python setnodefile.py 8
mpirun  -npernode 1 -hostfile myhostfile.txt  ./is.C.8   | tee is-values-O3/is.C.8.n8.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./is.C.16   | tee is-values-O3/is.C.16.n8.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./is.C.32   | tee is-values-O3/is.C.32.n8.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./is.C.64  | tee is-values-O3/is.C.64.n8.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./is.C.64  | tee is-values-O3/is.C.64.n8.p12-results.txt;
#

python setnodefile.py 16
mpirun  -npernode 1 -hostfile myhostfile.txt  ./is.C.16   | tee is-values-O3/is.C.8.n16.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt  ./is.C.32   | tee is-values-O3/is.C.16.n16.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt  ./is.C.64   | tee is-values-O3/is.C.32.n16.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt  ./is.C.128  | tee is-values-O3/is.C.64.n16.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./is.C.128  | tee is-values-O3/is.C.64.n16.p12-results.txt;


python setnodefile.py 32
mpirun  -npernode 1 -hostfile myhostfile.txt ./is.C.32 | tee is-values-O3/is.C.32.n32.p1-results.txt;
mpirun  -npernode 2 -hostfile myhostfile.txt ./is.C.64 | tee is-values-O3/is.C.64.n32.p2-results.txt;
mpirun  -npernode 4 -hostfile myhostfile.txt ./is.C.128 | tee is-values-O3/is.C.128.n32.p4-results.txt;
#mpirun  -npernode 8 -hostfile myhostfile.txt ./is.C.256 | tee is-values-O3/is.C.256.n32.p8-results.txt;
#mpirun  -npernode 12 -hostfile myhostfile.txt ./is.C.256 | tee is-values-O3/is.C.256.n32.p12-results.txt;



