python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.C.2  | tee 2.ep.C.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.C.4  | tee 2.ep.C.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.C.8  | tee 2.ep.C.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.C.4  | tee 4.ep.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.C.8  | tee 4.ep.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.C.16 | tee 4.ep.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.C.8  | tee 8.ep.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.C.16 | tee 8.ep.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.C.32 | tee 8.ep.C.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.C.16 | tee 16.ep.C.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.C.32 | tee 16.ep.C.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.C.64 | tee 16.ep.C.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.C.32 | tee 32.ep.C.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.C.64 | tee 32.ep.C.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.C.128 | tee 32.ep.C.128.4-results.txt ;



####is

python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./is.C.2  | tee 2.is.C.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.C.4  | tee 2.is.C.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.C.8  | tee 2.is.C.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./is.C.4  | tee 4.is.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.C.8  | tee 4.is.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.C.16 | tee 4.is.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./is.C.8  | tee 8.is.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.C.16 | tee 8.is.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.C.32 | tee 8.is.C.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./is.C.16 | tee 16.is.C.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./is.C.32 | tee 16.is.C.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./is.C.64 | tee 16.is.C.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./is.C.32 | tee 32.is.C.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./is.C.64 | tee 32.is.C.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./is.C.128 | tee 32.is.C.128.4-results.txt ;




####ft


python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.C.2  | tee 2.ft.C.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.C.4  | tee 2.ft.C.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.C.8  | tee 2.ft.C.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.C.4  | tee 4.ft.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.C.8  | tee 4.ft.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.C.16 | tee 4.ft.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.C.8  | tee 8.ft.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.C.16 | tee 8.ft.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.C.32 | tee 8.ft.C.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.C.16 | tee 16.ft.C.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.C.32 | tee 16.ft.C.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.C.64 | tee 16.ft.C.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.C.32 | tee 32.ft.C.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.C.64 | tee 32.ft.C.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.C.128 | tee 32.ft.C.128.4-results.txt ;




###mg

python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.C.2  | tee 2.mg.C.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.C.4  | tee 2.mg.C.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.C.8  | tee 2.mg.C.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.C.4  | tee 4.mg.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.C.8  | tee 4.mg.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.C.16 | tee 4.mg.C.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.C.8  | tee 8.mg.C.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.C.16 | tee 8.mg.C.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.C.32 | tee 8.mg.C.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.C.16 | tee 16.mg.C.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.C.32 | tee 16.mg.C.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.C.64 | tee 16.mg.C.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.C.32 | tee 32.mg.C.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.C.64 | tee 32.mg.C.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.C.128 | tee 32.mg.C.128.4-results.txt ;



