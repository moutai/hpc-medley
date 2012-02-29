import sys
import string 
for bench in ['sp','bt','lu']:
	print bench
	for nprocs in [9,16,25]:
		for nperproc in [1,2,3,4]:
			#args=sys.argv
			filename= bench+".C."+str(nprocs)+"."+str(nperproc)+"-results.txt"
			#print filename
			try:
				f=open(filename,"r")
			except:
				print "no data"
				break
			for line in f.readlines():
			    words = string.split(line) 
			    #print words    
			    if ( len(words)>0 and words[0] == 'Time'):
			    	# print words[1]
				#['Time', 'in', 'seconds', '=', '111.06']
				#print words[4]
				time1=words[4]
			    if (len(words)>0 and words[0] == 'Mop/s'):
				#print words[3]
				ops=words[3]
			print  bench+".C."+str(nprocs)+"."+str(nperproc)+" "+time1+"   "+ops

