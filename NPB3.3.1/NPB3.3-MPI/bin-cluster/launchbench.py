import os
import subprocess
import string 
import time
import sethostsfile

def runwith(hosts):
	listbench=open('listofbenchs','r')
	for currentbench in listbench.readlines():
		currentbench=currentbench.strip().rstrip()
		tokens=currentbench.split()
		#print tokens
 		benchname=tokens[0]
		benchsize=tokens[1]
		benchprocs=tokens[2]
		#print benchname
		#print benchsize
		#print benchprocs		
		
		print "Checking:"+str(currentbench) + " with hosts= "+str(hosts)
		print benchprocs
		print hosts*4
		if int(benchprocs)<= hosts*4:
			for npernode in range(1,5):
				bin_name= str(benchname)+'.'+str(benchsize)+'.'+str(benchprocs)
				resultfilename = "results/"+str(hosts)+"."+bin_name+"."+str(npernode)+"-results.txt"
	
				command2run= "mpirun -np "+ str(benchprocs)+" -npernode "\
				+str(npernode)+" -hostfile computehosts.txt ./"+str(bin_name)+" | tee "+ resultfilename
				print command2run
				#p=subprocess.Popen(command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
				#for outputline in p.stdout.readlines():
       	        		#	print outputline        	
		time.sleep(1)	
	listbench.close()
	#fresults.close()



#main 

hosts=1
while hosts<=33:
	sethostsfile.sethosts(hosts)
	runwith(hosts)	
	hosts=hosts*2	
