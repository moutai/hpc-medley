import os
import subprocess
import string 
listbench=open('listofbenchs','r')
#fresults =open ('results.txt','w')
currentbenchtorun='bt'

for currentbench in listbench.readlines():
	currentbench=currentbench.strip().rstrip()
	print currentbench
	tokens=currentbench.split()
	print tokens
 	benchname=tokens[0]
	benchsize=tokens[1]
	benchprocs=tokens[2]
	#print benchname
	#print benchsize
	#print benchprocs
	
	if benchname == currentbenchtorun:
		bin_name= str(benchname)+'.'+str(benchsize)+'.'+str(benchprocs)
		resultfilename = bin_name+"-results.txt"
		command2run= "mpirun -np "+ str(benchprocs)+" -hostfile computehosts.txt ./"+str(bin_name)+" | tee "+ resultfilename
		print command2run
		p=subprocess.Popen(command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		for outputline in p.stdout.readlines():
                	print outputline        	

listbench.close()
#fresults.close()
