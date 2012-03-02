python sethostsfile.py 2;
mpirun -npernode 2 -hostfile computehosts.txt ./sp.C.4  | tee 2.sp.C.4.2-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.C.4  | tee 4.sp.C.4.1-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./sp.C.16 | tee 4.sp.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 2 -hostfile computehosts.txt ./sp.C.16 | tee 8.sp.C.16.2-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.C.16 | tee 16.sp.C.16.1-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./sp.C.64 | tee 16.sp.C.64.4-results.txt ;

python sethostsfile.py 32;
mpirun -npernode 2 -hostfile computehosts.txt ./sp.C.64 | tee 32.sp.C.64.2-results.txt ;


####

python sethostsfile.py 2;
mpirun -npernode 2 -hostfile computehosts.txt ./bt.C.4  | tee 2.bt.C.4.2-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.C.4  | tee 4.bt.C.4.1-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./bt.C.16 | tee 4.bt.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 2 -hostfile computehosts.txt ./bt.C.16 | tee 8.bt.C.16.2-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.C.16 | tee 16.bt.C.16.1-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./bt.C.64 | tee 16.bt.C.64.4-results.txt ;

python sethostsfile.py 32;
mpirun -npernode 2 -hostfile computehosts.txt ./bt.C.64 | tee 32.bt.C.64.2-results.txt ;



####


python sethostsfile.py 2;
mpirun -npernode 2 -hostfile computehosts.txt ./lu.C.4  | tee 2.lu.C.4.2-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.C.4  | tee 4.lu.C.4.1-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./lu.C.16 | tee 4.lu.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 2 -hostfile computehosts.txt ./lu.C.16 | tee 8.lu.C.16.2-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.C.16 | tee 16.lu.C.16.1-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./lu.C.64 | tee 16.lu.C.64.4-results.txt ;

python sethostsfile.py 32;
mpirun -npernode 2 -hostfile computehosts.txt ./lu.C.64 | tee 32.lu.C.64.2-results.txt ;



