import os
import subprocess
import string 
#listbench=open('listofbenchs','r')
#fresults =open ('results.txt','w')
#currentbenchtorun='cg'
#hostnum=0

for hostnum in range(0,30) :
	
	command2run = sys.argv[1]
	p=subprocess.Popen("ssh clusternode"+hostnum+" "+command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for outputline in p.stdout.readlines():
        	print outputline 
	
