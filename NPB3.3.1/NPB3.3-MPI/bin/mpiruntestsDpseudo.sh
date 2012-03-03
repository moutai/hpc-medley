###
python sethostsfile.py 25;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.D.25 | tee 25.sp.D.64.1-results.txt ;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.D.16 | tee 16.sp.D.16.1-results.txt ;

python sethostsfile.py 9;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.D.9 | tee 9.sp.D.9.1-results.txt;


python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./sp.D.4  | tee 4.sp.D.4.1-results.txt;

#####


###
python sethostsfile.py 25;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.D.25 | tee 25.bt.D.64.1-results.txt ;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.D.16 | tee 16.bt.D.16.1-results.txt ;

python sethostsfile.py 9;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.D.9 | tee 9.bt.D.9.1-results.txt;


python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./bt.D.4  | tee 4.bt.D.4.1-results.txt;



#####


###
python sethostsfile.py 25;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.D.25 | tee 25.lu.D.64.1-results.txt ;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.D.16 | tee 16.lu.D.16.1-results.txt ;

python sethostsfile.py 9;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.D.9 | tee 9.lu.D.9.1-results.txt;


python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./lu.D.4  | tee 4.lu.D.4.1-results.txt;


