import sys

def sethosts(numhosts):
	f = open ("computehosts.txt","w")
	#numhosts=sys.argv[1]
	print numhosts
	for i in range(1,numhosts+1):
		f.write("clusternode"+str(i-1)+"\n")

	f.close()



f = open ("computehosts.txt","w")
numhosts=sys.argv[1]
print numhosts
for i in range(1,int(numhosts)+1):
	f.write("clusternode"+str(i-1)+"\n")
f.close()



