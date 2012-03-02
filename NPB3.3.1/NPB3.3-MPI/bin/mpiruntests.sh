#python sethostsfile.py 2;
#mpirun -npernode 1 -hostfile computehosts.txt ./cg.C.2  | tee 2.cg.C.2.1-results.txt;
#mpirun -npernode 2 -hostfile computehosts.txt ./cg.C.4  | tee 2.cg.C.4.2-results.txt;
#mpirun -npernode 4 -hostfile computehosts.txt ./cg.C.8  | tee 2.cg.C.8.4-results.txt;
#
#python sethostsfile.py 4;
#mpirun -npernode 1 -hostfile computehosts.txt ./cg.C.4  | tee 4.cg.C.4.1-results.txt;
#mpirun -npernode 2 -hostfile computehosts.txt ./cg.C.8  | tee 4.cg.C.8.2-results.txt;
#mpirun -npernode 4 -hostfile computehosts.txt ./cg.C.16 | tee 4.cg.C.16.4-results.txt;
#
#python sethostsfile.py 8; 
#mpirun -npernode 1 -hostfile computehosts.txt ./cg.C.8  | tee 8.cg.C.4.1-results.txt;
#mpirun -npernode 2 -hostfile computehosts.txt ./cg.C.16 | tee 8.cg.C.8.2-results.txt;
#mpirun -npernode 4 -hostfile computehosts.txt ./cg.C.32 | tee 8.cg.C.32.4-results.txt; 
#
#python sethostsfile.py 16;
#mpirun -npernode 1 -hostfile computehosts.txt ./cg.C.16 | tee 16.cg.C.16.1-results.txt ;
#mpirun -npernode 2 -hostfile computehosts.txt ./cg.C.32 | tee 16.cg.C.32.2-results.txt ;
#mpirun -npernode 4 -hostfile computehosts.txt ./cg.C.64 | tee 16.cg.C.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.C.32 | tee 32.cg.C.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.C.64 | tee 32.cg.C.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.C.128 | tee 32.cg.C.128.4-results.txt ;
