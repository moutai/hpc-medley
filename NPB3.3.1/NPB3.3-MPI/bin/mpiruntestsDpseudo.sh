python sethostsfile.py 32;
mpirun -npernode 2 -hostfile Domputehosts.txt ./sp.D.64 | tee 32.sp.D.64.2-results.txt ;


python sethostsfile.py 16;

mpirun -npernode 1 -hostfile Domputehosts.txt ./sp.D.16 | tee 16.sp.D.16.1-results.txt ;

mpirun -npernode 4 -hostfile Domputehosts.txt ./sp.D.64 | tee 16.sp.D.64.4-results.txt ;

python sethostsfile.py 8;

mpirun -npernode 2 -hostfile Domputehosts.txt ./sp.D.16 | tee 8.sp.D.16.2-results.txt;


python sethostsfile.py 4;

mpirun -npernode 1 -hostfile Domputehosts.txt ./sp.D.4  | tee 4.sp.D.4.1-results.txt;

mpirun -npernode 4 -hostfile Domputehosts.txt ./sp.D.16 | tee 4.sp.D.16.4-results.txt;



python sethostsfile.py 2;

mpirun -npernode 2 -hostfile Domputehosts.txt ./sp.D.4  | tee 2.sp.D.4.2-results.txt;





####


python sethostsfile.py 32;
mpirun -npernode 2 -hostfile Domputehosts.txt ./bt.D.64 | tee 32.bt.D.64.2-results.txt ;


python sethostsfile.py 16;

mpirun -npernode 1 -hostfile Domputehosts.txt ./bt.D.16 | tee 16.bt.D.16.1-results.txt ;

mpirun -npernode 4 -hostfile Domputehosts.txt ./bt.D.64 | tee 16.bt.D.64.4-results.txt ;

python sethostsfile.py 8;

mpirun -npernode 2 -hostfile Domputehosts.txt ./bt.D.16 | tee 8.bt.D.16.2-results.txt;


python sethostsfile.py 4;

mpirun -npernode 1 -hostfile Domputehosts.txt ./bt.D.4  | tee 4.bt.D.4.1-results.txt;

mpirun -npernode 4 -hostfile Domputehosts.txt ./bt.D.16 | tee 4.bt.D.16.4-results.txt;



python sethostsfile.py 2;

mpirun -npernode 2 -hostfile Domputehosts.txt ./bt.D.4  | tee 2.bt.D.4.2-results.txt;


####

python sethostsfile.py 32;
mpirun -npernode 2 -hostfile Domputehosts.txt ./lu.D.64 | tee 32.lu.D.64.2-results.txt ;


python sethostsfile.py 16;

mpirun -npernode 1 -hostfile Domputehosts.txt ./lu.D.16 | tee 16.lu.D.16.1-results.txt ;

mpirun -npernode 4 -hostfile Domputehosts.txt ./lu.D.64 | tee 16.lu.D.64.4-results.txt ;

python sethostsfile.py 8;

mpirun -npernode 2 -hostfile Domputehosts.txt ./lu.D.16 | tee 8.lu.D.16.2-results.txt;


python sethostsfile.py 4;

mpirun -npernode 1 -hostfile Domputehosts.txt ./lu.D.4  | tee 4.lu.D.4.1-results.txt;

mpirun -npernode 4 -hostfile Domputehosts.txt ./lu.D.16 | tee 4.lu.D.16.4-results.txt;



python sethostsfile.py 2;

mpirun -npernode 2 -hostfile Domputehosts.txt ./lu.D.4  | tee 2.lu.D.4.2-results.txt;



