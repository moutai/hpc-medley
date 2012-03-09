import sys
f =open("parsedhostfile.txt", "r")
numhosts=sys.argv[1]
fout= open ("myhostfile.txt","w")

print numhosts
i=0;
for line in f.readlines():
	fout.write(line)		
	#print line
	i=i+1
	print i 
	if i==int(numhosts):
		break;

f.close()
fout.close()

