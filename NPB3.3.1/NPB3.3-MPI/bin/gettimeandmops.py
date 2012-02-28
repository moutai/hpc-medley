import sys
import string 

args=sys.argv

filename=args[1]
print filename
f=open(filename,"r")

for line in f.readlines():
    
    words = string.split(line) 
    #print words    
    if ( len(words)>0 and words[0] == 'Time'):
    	# print words[1]
	#['Time', 'in', 'seconds', '=', '111.06']
	print words[4]
    if (len(words)>0 and words[0] == 'Mop/s'):
	print words[3]

