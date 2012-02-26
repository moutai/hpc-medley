import os
import subprocess
import string 
import sys
listhostsup=open('computehosts.txt','w')
#fresults =open ('results.txt','w')
#currentbenchtorun='cg'
#hostnum=0
numhosts=0

for hostnum in range(0,30) :
	if hostnum!= 5 and hostnum!=14 and hostnum!=22 and hostnum!=23 and hostnum!=2:
		print "On host clusternode"+str(hostnum)	
		command2run = sys.argv[1]
		p=subprocess.Popen("ssh clusternode"+str(hostnum)+" "+command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        	for outputline in p.stdout.readlines():
        		print outputline 
		numhosts=numhosts+1	
		listhostsup.write("clusternode"+str(hostnum)+"\n")			

print "Total number of hosts:  "+ str(numhosts)
listhostsup.close()

