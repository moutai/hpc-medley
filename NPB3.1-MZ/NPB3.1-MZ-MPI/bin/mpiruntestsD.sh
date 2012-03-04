python sethostsfile.py 9;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./sp-mz.D.9  | tee 9.sp-mz.D.9.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./sp-mz.D.9  | tee 9.sp-mz.D.9.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./sp-mz.D.9  | tee 9.sp-mz.D.9.4-results.txt;

python sethostsfile.py 16;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./sp-mz.D.16 | tee 16.sp-mz.D.16.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./sp-mz.D.16 | tee 16.sp-mz.D.16.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./sp-mz.D.16 | tee 16.sp-mz.D.16.4-results.txt;


python sethostsfile.py 25;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./sp-mz.D.25 | tee 25.sp-mz.D.25.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./sp-mz.D.25 | tee 25.sp-mz.D.25.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./sp-mz.D.25 | tee 25.sp-mz.D.25.4-results.txt ;
#
####


python sethostsfile.py 9;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./bt-mz.D.9  | tee 9.bt-mz.D.9.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./bt-mz.D.9  | tee 9.bt-mz.D.9.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./bt-mz.D.9  | tee 9.bt-mz.D.9.4-results.txt;

python sethostsfile.py 16;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./bt-mz.D.16 | tee 16.bt-mz.D.16.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./bt-mz.D.16 | tee 16.bt-mz.D.16.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./bt-mz.D.16 | tee 16.bt-mz.D.16.4-results.txt;



python sethostsfile.py 25;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./bt-mz.D.25 | tee 25.bt-mz.D.25.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./bt-mz.D.25 | tee 25.bt-mz.D.25.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./bt-mz.D.25 | tee 25.bt-mz.D.25.4-results.txt ;



#####



python sethostsfile.py 9;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./lu-mz.D.9  | tee 9.lu-mz.D.9.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./lu-mz.D.9  | tee 9.lu-mz.D.9.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./lu-mz.D.9  | tee 9.lu-mz.D.9.4-results.txt;

python sethostsfile.py 16;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./lu-mz.D.16 | tee 16.lu-mz.D.16.1-results.txt;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./lu-mz.D.16 | tee 16.lu-mz.D.16.2-results.txt;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./lu-mz.D.16 | tee 16.lu-mz.D.16.4-results.txt;



python sethostsfile.py 25;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./lu-mz.D.25 | tee 25.lu-mz.D.25.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./lu-mz.D.25 | tee 25.lu-mz.D.25.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./lu-mz.D.25 | tee 25.lu-mz.D.25.4-results.txt ;


