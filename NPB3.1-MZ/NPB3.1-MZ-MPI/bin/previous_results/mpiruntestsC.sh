#python sethostsfile.py 9;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./sp-mz.C.9  | tee 9.sp-mz.C.9.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./sp-mz.C.9  | tee 9.sp-mz.C.9.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./sp-mz.C.9  | tee 9.sp-mz.C.9.4-results.txt;

#python sethostsfile.py 16;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./sp-mz.C.16 | tee 16.sp-mz.C.16.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./sp-mz.C.16 | tee 16.sp-mz.C.16.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./sp-mz.C.16 | tee 16.sp-mz.C.16.4-results.txt;


python sethostsfile.py 4;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./sp-mz.D.4 | tee 4.sp-mz.D.4.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./sp-mz.D.4 | tee 4.sp-mz.D.4.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./sp-mz.D.4 | tee 4.sp-mz.D.4.4-results.txt ;
#
####


#python sethostsfile.py 9;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./bt-mz.C.9  | tee 9.bt-mz.C.9.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./bt-mz.C.9  | tee 9.bt-mz.C.9.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./bt-mz.C.9  | tee 9.bt-mz.C.9.4-results.txt;

#python sethostsfile.py 16;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./bt-mz.C.16 | tee 16.bt-mz.C.16.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./bt-mz.C.16 | tee 16.bt-mz.C.16.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./bt-mz.C.16 | tee 16.bt-mz.C.16.4-results.txt;



python sethostsfile.py 4;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./bt-mz.D.4 | tee 4.bt-mz.D.4.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./bt-mz.D.4 | tee 4.bt-mz.D.4.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./bt-mz.D.4 | tee 4.bt-mz.D.4.4-results.txt ;



#####



#python sethostsfile.py 9;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./lu-mz.C.9  | tee 9.lu-mz.C.9.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./lu-mz.C.9  | tee 9.lu-mz.C.9.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./lu-mz.C.9  | tee 9.lu-mz.C.9.4-results.txt;

#python sethostsfile.py 16;
#export OMP_NUM_THREADS=1;
#mpirun -hostfile computehosts.txt ./lu-mz.C.16 | tee 16.lu-mz.C.16.1-results.txt;
#export OMP_NUM_THREADS=2;
#mpirun -hostfile computehosts.txt ./lu-mz.C.16 | tee 16.lu-mz.C.16.2-results.txt;
#export OMP_NUM_THREADS=4;
#mpirun -hostfile computehosts.txt ./lu-mz.C.16 | tee 16.lu-mz.C.16.4-results.txt;



python sethostsfile.py 4;
export OMP_NUM_THREADS=1;
mpirun -hostfile computehosts.txt ./lu-mz.D.4 | tee 4.lu-mz.D.4.1-results.txt ;
export OMP_NUM_THREADS=2;
mpirun -hostfile computehosts.txt ./lu-mz.D.4 | tee 4.lu-mz.D.4.2-results.txt ;
export OMP_NUM_THREADS=4;
mpirun -hostfile computehosts.txt ./lu-mz.D.4 | tee 4.lu-mz.D.4.4-results.txt ;


