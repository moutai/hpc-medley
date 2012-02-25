import os
import subprocess

hosts = open('/home/hpcuser/computehosts.txt', 'r')

for line in hosts.readlines():
	command2run = "echo yes |ssh root@"+line+" ls"        
	print command2run
        p=subprocess.Popen(command2run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for outputline in p.stdout.readlines():
        	print outputline



f.close()
fmpi.close()

