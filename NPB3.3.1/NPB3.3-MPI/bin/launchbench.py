import os
import subprocess
import string 
import time

listbench=open('listofbenchs','r')

#fresults =open ('results.txt','w')
#currentbenchtorun='sp'

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
	for npernode in range(1,5):
		bin_name= str(benchname)+'.'+str(benchsize)+'.'+str(benchprocs)
		resultfilename = bin_name+"."+str(npernode)+"-results.txt"
		command2run= "mpirun -np "+ str(benchprocs)+" -npernode " +str(npernode)+" -hostfile computehosts.txt ./"+str(bin_name)+" | tee "+ resultfilename
		print command2run
		p=subprocess.Popen(command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		for outputline in p.stdout.readlines():
               		print outputline        	
		time.sleep(5)	
listbench.close()
#fresults.close()
