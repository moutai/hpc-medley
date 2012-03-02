
python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.D.2  | tee 2.cg.D.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.D.4  | tee 2.cg.D.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.D.8  | tee 2.cg.D.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.D.4  | tee 4.cg.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.D.8  | tee 4.cg.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.D.16 | tee 4.cg.D.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.D.8  | tee 8.cg.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.D.16 | tee 8.cg.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.D.32 | tee 8.cg.D.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.D.16 | tee 16.cg.D.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.D.32 | tee 16.cg.D.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.D.64 | tee 16.cg.D.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./cg.D.32 | tee 32.cg.D.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./cg.D.64 | tee 32.cg.D.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./cg.D.128 | tee 32.cg.D.128.4-results.txt ;



####ep
python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.D.2  | tee 2.ep.D.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.D.4  | tee 2.ep.D.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.D.8  | tee 2.ep.D.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.D.4  | tee 4.ep.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.D.8  | tee 4.ep.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.D.16 | tee 4.ep.D.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.D.8  | tee 8.ep.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.D.16 | tee 8.ep.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.D.32 | tee 8.ep.D.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.D.16 | tee 16.ep.D.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.D.32 | tee 16.ep.D.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.D.64 | tee 16.ep.D.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./ep.D.32 | tee 32.ep.D.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ep.D.64 | tee 32.ep.D.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ep.D.128 | tee 32.ep.D.128.4-results.txt ;



####is

python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./is.D.2  | tee 2.is.D.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.D.4  | tee 2.is.D.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.D.8  | tee 2.is.D.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./is.D.4  | tee 4.is.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.D.8  | tee 4.is.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.D.16 | tee 4.is.D.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./is.D.8  | tee 8.is.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./is.D.16 | tee 8.is.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./is.D.32 | tee 8.is.D.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./is.D.16 | tee 16.is.D.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./is.D.32 | tee 16.is.D.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./is.D.64 | tee 16.is.D.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./is.D.32 | tee 32.is.D.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./is.D.64 | tee 32.is.D.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./is.D.128 | tee 32.is.D.128.4-results.txt ;




####ft


python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.D.2  | tee 2.ft.D.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.D.4  | tee 2.ft.D.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.D.8  | tee 2.ft.D.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.D.4  | tee 4.ft.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.D.8  | tee 4.ft.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.D.16 | tee 4.ft.D.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.D.8  | tee 8.ft.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.D.16 | tee 8.ft.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.D.32 | tee 8.ft.D.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.D.16 | tee 16.ft.D.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.D.32 | tee 16.ft.D.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.D.64 | tee 16.ft.D.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./ft.D.32 | tee 32.ft.D.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./ft.D.64 | tee 32.ft.D.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./ft.D.128 | tee 32.ft.D.128.4-results.txt ;



###mg

python sethostsfile.py 2;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.D.2  | tee 2.mg.D.2.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.D.4  | tee 2.mg.D.4.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.D.8  | tee 2.mg.D.8.4-results.txt;

python sethostsfile.py 4;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.D.4  | tee 4.mg.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.D.8  | tee 4.mg.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.D.16 | tee 4.mg.D.16.4-results.txt;

python sethostsfile.py 8;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.D.8  | tee 8.mg.D.4.1-results.txt;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.D.16 | tee 8.mg.D.8.2-results.txt;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.D.32 | tee 8.mg.D.32.4-results.txt;

python sethostsfile.py 16;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.D.16 | tee 16.mg.D.16.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.D.32 | tee 16.mg.D.32.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.D.64 | tee 16.mg.D.64.4-results.txt ;


python sethostsfile.py 32;
mpirun -npernode 1 -hostfile computehosts.txt ./mg.D.32 | tee 32.mg.D.32.1-results.txt ;
mpirun -npernode 2 -hostfile computehosts.txt ./mg.D.64 | tee 32.mg.D.64.2-results.txt ;
mpirun -npernode 4 -hostfile computehosts.txt ./mg.D.128 | tee 32.mg.D.128.4-results.txt ;



